//
//  Tor Networking.swift
//  TORVpn
//
//  Created by Олег Сазонов on 05.06.2022.
//

import Foundation
import AppKit

public class TorNetworking {
    /// Enables and disabled proxy for using in tor class
    public class Connectivity {
        public init(disconnectionArgs: [String] = ["-setsocksfirewallproxystate", "Wi-Fi", "off"], connectionArgs: [String] = ["-setsocksfirewallproxy", "Wi-Fi", "127.0.0.1", "9050"]) {
            disArgs = disconnectionArgs
            conArgs = connectionArgs
        }
        private var isConnected = false
        private var disArgs: [String]
        private var conArgs: [String]
        private let n = "networksetup"
        
        /// Enables Proxy
        public func connect() {
            let f = Shell.RunnerForTorNetworks(app: n, args: conArgs)
            try? f.process.run()
            f.process.waitUntilExit()
        }
        
        /// Disables proxy
        public func disconnect() {
            let f = Shell.RunnerForTorNetworks(app: n, args: disArgs)
            try? f.process.run()
            f.process.waitUntilExit()
        }
        
        /// Gets proxy status
        /// - Returns: true if enabled, false otherwise
        public func status() -> Bool {
            let data = Shell.RunnerForTorNetworks(app: n, args: ["-getsocksfirewallproxy", "Wi-Fi"])
            try? data.process.run()
            let put = data.returnAllOutput()
            if put.contains("Enabled: Yes") {
                isConnected = true
            } else {
                isConnected = false
            }
            data.stopTask()
            try? data.pipe.fileHandleForReading.close()
            return isConnected
        }
    }
    
    public class Tor {
        //MARK: - INIT and DEINIT
        public init() {
            func killPreviousTOR() {
                Shell.Parcer.OneExecutable.withNoOutput(exe: "killall", args: ["tor"])
            }
            
            killPreviousTOR()
            let defaultfilePath = "/opt/homebrew/bin/tor"
            var filePath = "/opt/homebrew/bin/tor"
            let defaultBrewExe = URL(fileURLWithPath: "/opt/homebrew/bin/brew")
            let oldBrewExe = URL(fileURLWithPath: "/usr/local/bin/brew")
            if FileManager.default.fileExists(atPath: defaultfilePath){
                filePath = defaultfilePath
                process.executableURL = URL(fileURLWithPath: filePath)
                process.standardOutput = pipe
            } else if FileManager.default.fileExists(atPath: "/usr/local/bin/tor") {
                filePath = "/usr/local/bin/tor"
                process.executableURL = URL(fileURLWithPath: filePath)
                process.standardOutput = pipe
            } else {
                //MARK: -  IMPLEMENT DOWNLOAD
                do {
                    process.executableURL = defaultBrewExe
                    process.arguments = ["reinstall", "tor"]
                    process.standardOutput = pipe
                    try process.run()
                } catch {
                    do {
                        process.executableURL = oldBrewExe
                        process.arguments = ["reinstall", "tor"]
                        process.standardOutput = pipe
                        try process.run()
                    } catch let error {
                        process.executableURL = URL(fileURLWithPath: "/bin/echo")
                        process.arguments = ["TOR binary not found. Try manualy installing it.","\n","TOR не найден.\n\(error.localizedDescription)"]
                        process.standardOutput = pipe
                    }
                }
            }
        }
        deinit {
            process.terminate()
            do {
                try pipe.fileHandleForReading.close()
            } catch let error {
                NSLog(error.localizedDescription)
            }
        }
        //MARK: - Vars
        private var process = Process()
        public var pipe = Pipe()
        
        //MARK: - Funcs
        /// Enables TOR
        public func run() {
            DispatchQueue.main.async {
                do {
                    try self.process.run()
                } catch let error {
                    NSLog(error.localizedDescription)
                }
            }
        }
        
        /// Disables TOR
        public func stop() {
            process.terminate()
            do {
                try pipe.fileHandleForReading.close()
            } catch let error {
                NSLog(error.localizedDescription)
            }
        }
    }
}
