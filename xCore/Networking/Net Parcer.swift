//
//  Netowrking.swift
//  xCore
//
//  Created by Олег Сазонов on 03.03.2023.
//  Copyright © 2023 ~X~ Lab. All rights reserved.
//

import Foundation
import SwiftUI
import Network

public class NetParcer: xCore {
    private static var oldBand: Bandwidth = (0, 0)
    
    private class func netMonitorTask() -> Bandwidth {
        let process = Process()
        let pipe = Pipe()
        var newBand: Bandwidth = (0, 0)
        process.executableURL = URL(filePath: "/usr/bin/nettop")
        process.arguments = ["-P", "-L", "1"]
        process.standardOutput = pipe
        var totalCurrentBand: Bandwidth = (0, 0)
        do {
            if !process.isRunning {
                try process.run()
                process.waitUntilExit()
            }
            if let out = String(data: pipe.fileHandleForReading.availableData, encoding: .utf8) {
                out.split(separator: "\n").dropFirst().forEach { line in
                    let arr = line.description.split(separator: ",").dropLast(3).dropFirst(2)
                    totalCurrentBand = (Double(arr.first ?? "0") ?? 0, Double(arr.last ?? "0") ?? 0)
                }
                if totalCurrentBand.Out - oldBand.Out < 0 {
                    oldBand.Out = 0
                    newBand.Out = 0
                }
                if totalCurrentBand.In - oldBand.In < 0 {
                    oldBand.In = 0
                    newBand.In = 0
                }
                if oldBand == newBand {
                    oldBand.Out = 0
                    newBand.Out = 0
                    oldBand.In = 0
                    newBand.In = 0
                }
                newBand = ((totalCurrentBand.In - oldBand.In) / 8, (totalCurrentBand.Out - oldBand.Out) / 8)
            }
        } catch {}
        totalCurrentBand = (0, 0)
        oldBand = newBand
        return newBand
    }

    public class func netMonitor(_ unit: Unit = .megabyte) async -> Task<(Bandwidth), Never> {
        Task {
            let retval = netMonitorTask()
            switch unit {
            case .byte:
                return (retval.In.rounded(), retval.Out.rounded())
            case .kilobyte:
                return ((retval.In / 1024).rounded(), (retval.Out / 1024).rounded())
            case .megabyte:
                return ((retval.In / 1024 / 1024).rounded(), (retval.Out / 1024 / 1024).rounded())
            case .gigabyte:
                return ((retval.In / 1024 / 1024 / 1024).rounded(), (retval.Out / 1024 / 1024 / 1024).rounded())
            case .terabyte:
                return ((retval.In / 1024 / 1024 / 1024 / 1024).rounded(), (retval.Out / 1024 / 1024 / 1024 / 1024).rounded())
            }
        }
    }
    
    private class func ip() async -> Task<netProps, Never> {
        Task {
            var address : String?
            var ifaddr : UnsafeMutablePointer<ifaddrs>?
            guard getifaddrs(&ifaddr) == 0 else { return (nil, .none) }
            guard let firstAddr = ifaddr else { return (nil, .none) }
            var retInterface: iface = .none
            for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
                let interface = ifptr.pointee
                let addrFamily = interface.ifa_addr.pointee.sa_family
                if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                    let name = String(cString: interface.ifa_name)
                    if  name == "en0" ||
                            name == "en12" ||
                            name == "en2" ||
                            name == "en3" ||
                            name == "en4" {
                        if isVPN().connected {
                            retInterface = .vpn
                        } else {
                            if name.contains("en") {
                                if name == "en0" {
                                    retInterface = .wireless
                                } else {
                                    retInterface = .wired
                                }
                            }
                        }
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                    &hostname, socklen_t(hostname.count),
                                    nil, socklen_t(0), NI_NUMERICHOST)
                        let url = URL(string: "https://api.ipify.org")
                        do {
                            if let url = url {
                                address = try String(contentsOf: url)
                            }
                        } catch _ {}
                    }
                }
            }
            freeifaddrs(ifaddr)
            return (address, retInterface)
        }
    }
    
    private class func isVPN() -> VPNProps {
        var isConnectedToVpn: VPNProps {
            if let settings = CFNetworkCopySystemProxySettings()?.takeRetainedValue() as? Dictionary<String, Any>,
               let scopes = settings["__SCOPED__"] as? [String:Any] {
                for (key, _) in scopes {
                    if key.contains("tap") {
                        return (true, .tap)
                    } else if key.contains("tun") {
                        return (true, .tun)
                    } else if key.contains("ppp") {
                        return (true, .ppp)
                    } else if key.contains("ipsec") {
                        return (true, .ipsec)
                    }
                }
            }
            return (false, .none)
        }
        return isConnectedToVpn
    }
    
    public class func netIP() async -> String {
        return await self.ip().value.address ?? StringLocalizer("disconnected.string")
    }
    
    public class func netInterface() async -> String {
        switch await self.ip().value.interface {
        case .wired:
            return StringLocalizer("wired.string")
        case .wireless:
            return StringLocalizer("wireless.string")
        case .vpn:
            return StringLocalizer("vpn.string")
        case .cellular:
            return StringLocalizer("cellular.string")
        case .none:
            return StringLocalizer("disconnected.string")
        }
    }
}

public class NetViews: xCore {
    struct Monitor: View {
        @State var isRun = false
        @State var bandwidth: Bandwidth = (0, 0)
        @State var interface: String = ""
        @State var ip = ""

        var body: some View {
            ZStack{
                if isRun {
                    VStack{
                        HStack{
                            HStack{
                                Spacer()
                                Text("\(StringLocalizer("interface.string")):").monospacedDigit()
                            }
                            HStack{
                                Text(interface).monospacedDigit()
                                Spacer()
                            }
                        }
                        HStack{
                            HStack{
                                Spacer()
                                Text("\(StringLocalizer("ipaddress.string")):").monospacedDigit()
                            }
                            HStack{
                                Text(ip).monospacedDigit()
                                Spacer()
                            }
                        }
                        HStack{
                            HStack{
                                Spacer()
                                Text("\(StringLocalizer("megabytesIn.string")):").monospacedDigit()
                            }
                            HStack{
                                Text(bandwidth.In.description).monospacedDigit()
                                Spacer()
                            }
                        }
                        HStack{
                            HStack{
                                Spacer()
                                Text("\(StringLocalizer("megabytesOut.string")):").monospacedDigit()
                            }
                            HStack{
                                Text(bandwidth.Out.description).monospacedDigit()
                                Spacer()
                            }
                        }
                    }
                } else {
                    ProgressView()
                }
            }.onAppear {
                isRun = true
            }.task {
                Task {
                    repeat {
                        let monitor = await NetParcer.netMonitor(.megabyte)
                        bandwidth = await monitor.value
                        try? await Task.sleep(nanoseconds: 1000000000)
                        interface = await NetParcer.netInterface()
                        ip = await NetParcer.netIP()
                    } while (isRun)
                }
            }
            .background {
                RoundedRectangle(cornerRadius: 15)
                    .foregroundStyle(.ultraThinMaterial)
                    .shadow(radius: 5)
            }
        }
    }
}
