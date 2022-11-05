//
//  System.swift
//  SuperStuff
//
//  Created by Олег Сазонов on 29.06.2022.
//

import Darwin
import IOKit.pwr_mgt
import Foundation
import AppKit

//------------------------------------------------------------------------------
// MARK: PRIVATE PROPERTIES
//------------------------------------------------------------------------------


// As defined in <mach/tash_info.h>

private let HOST_BASIC_INFO_COUNT         : mach_msg_type_number_t =
UInt32(MemoryLayout<host_basic_info_data_t>.size / MemoryLayout<integer_t>.size)
private let HOST_LOAD_INFO_COUNT          : mach_msg_type_number_t =
UInt32(MemoryLayout<host_load_info_data_t>.size / MemoryLayout<integer_t>.size)
private let HOST_CPU_LOAD_INFO_COUNT      : mach_msg_type_number_t =
UInt32(MemoryLayout<host_cpu_load_info_data_t>.size / MemoryLayout<integer_t>.size)
private let HOST_VM_INFO64_COUNT          : mach_msg_type_number_t =
UInt32(MemoryLayout<vm_statistics64_data_t>.size / MemoryLayout<integer_t>.size)
private let HOST_SCHED_INFO_COUNT         : mach_msg_type_number_t =
UInt32(MemoryLayout<host_sched_info_data_t>.size / MemoryLayout<integer_t>.size)
private let PROCESSOR_SET_LOAD_INFO_COUNT : mach_msg_type_number_t =
UInt32(MemoryLayout<processor_set_load_info_data_t>.size / MemoryLayout<natural_t>.size)


public struct macOS_Subsystem {
    
    //--------------------------------------------------------------------------
    // MARK: PUBLIC PROPERTIES
    //--------------------------------------------------------------------------
    
    
    /**
     System page size.
     
     - Can check this via pagesize shell command as well
     - C lib function getpagesize()
     - host_page_size()
     
     TODO: This should be static right?
     */
    public static let PAGE_SIZE = vm_kernel_page_size
    
    
    //--------------------------------------------------------------------------
    // MARK: PUBLIC ENUMS
    //--------------------------------------------------------------------------
    
    
    /**
     Unit options for method data returns.
     
     TODO: Pages?
     */
    
    public static func osVersion() -> String {
        var osName: String {
            switch ProcessInfo.processInfo.operatingSystemVersion.majorVersion {
            case 11: return "Big Sur"
            case 12: return "Monterey"
            case 13: return "Ventura"
            default: return "NaN"
            }
        }
        
        let prepString = ProcessInfo.processInfo.operatingSystemVersionString.byWords.dropFirst()
        var retval = "macOS"
        let symbols = [" ", " \(osName) (" , " "]
        var index = 0
        for each in prepString {
            retval += symbols[index] + each
            index += 1
        }
        retval = String(retval.replacingOccurrences(of: "Выпуск", with: "Сборка"))
        return retval + ")"
    }
    
    public static func osIsBeta() -> Bool {
        let osVer = ProcessInfo.processInfo.operatingSystemVersionString
        let prep1 = osVer.replacingOccurrences(of: ")", with: "")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: " ", with: "")
        let charSet = Array(prep1)
        let lastElement = "\(charSet.last!)"
        if Int(lastElement) != nil {
            return false
        } else {
            return true
        }
    }
    
    public static func BatteryTemperature(TermperatureUnit t: UnitTemperature = .celsius) -> (value: Double, unit: UnitTemperature, valueString: String) {
        let process = Process()
        let pipe = Pipe()
        process.executableURL = URL(filePath: "/bin/bash")
        process.arguments = ["-c", "ioreg -r -n AppleSmartBattery | grep Temperature"]
        process.standardOutput = pipe
        do {
            try process.run()
            if let out = String(data: pipe.fileHandleForReading.availableData, encoding: .utf8) {
                let s = out.byLines.last ?? "0"
                let w = s.byWords.last ?? "0"
                let cRetval = (Double(String(w)) ?? 0) / 100
                let fRetval = Measurement(value: cRetval, unit: UnitTemperature.celsius).converted(to: .fahrenheit).value.rounded(.toNearestOrEven)
                let kRetval = Measurement(value: cRetval, unit: UnitTemperature.celsius).converted(to: .kelvin).value.rounded(.toNearestOrEven)
                let cRetvalString = "\(cRetval) ºC"
                let fRetvalString = "\(fRetval) ºF"
                let kRetvalString = "\(kRetval) K"
                switch t {
                case .celsius:
                    return (value: cRetval, unit: .celsius, valueString: cRetvalString)
                case .fahrenheit:
                    return (value: fRetval, unit: .fahrenheit, valueString: fRetvalString)
                case .kelvin:
                    return (value: kRetval, unit: .kelvin, valueString: kRetvalString)
                default: return (cRetval, .celsius, cRetvalString)
                }
            } else {
                return (value: 0, unit: .kelvin, valueString: "0 K")
            }
        } catch let error {
            NSLog(error.localizedDescription)
            return (value: 0, unit: .kelvin, valueString: "0 K")
        }
    }
    
    public class ThermalMonitor {
        public init(){}
        
        private func parce(_ s: ThermalPressure) -> ThermalData {
            var label: String = ""
            var state: ThermalPressure = .undefined
            switch s{
            case .nominal:
                label = StringLocalizer("therm.nominal")
                state = .nominal
            case .fair:
                label = StringLocalizer("therm.fair")
                state = .fair
            case .serious:
                label = StringLocalizer("therm.serious")
                state = .serious
            case .critical:
                label = StringLocalizer("therm.critical")
                state = .critical
            case .undefined:
                label = StringLocalizer("therm.unknown")
                state = .undefined
            case .noPassword:
                label = ""
                state = .noPassword
            }
            return (label, state)
        }
        
        public func asyncRun() async -> Task<(ThermalData), Never> {
            Task{
                let data = run()
                return data
            }
        }
        
        public func run() -> ThermalData{
            let process = Process()
            let killer = Process()
            let pipe = Pipe()
            let bash = URL(filePath: "/bin/bash")
            process.executableURL = bash
            process.arguments = ["-c", "echo \(SettingsMonitor.password) | sudo -S thermal watch"]
            process.standardOutput = pipe
            process.standardError = pipe
            killer.executableURL = bash
            killer.arguments = ["-c", "sleep 0.1 && echo \(SettingsMonitor.password) | sudo -S killall thermal"]
            var data: ThermalData = ("",.undefined)

            if SettingsMonitor.passwordSaved {
                do {
                    try killer.run()
                    try process.run()
                    if let out = String(data: try pipe.fileHandleForReading.readToEnd() ?? Data() , encoding: .utf8) {
                        let p = String(out.byLines[0])
                        if p.contains("therm_level=0"){
                            data = parce(.nominal)
                        } else if p.contains("therm_level=1") {
                            data = parce(.fair)
                        } else if p.contains("therm_level=2") {
                            data = parce(.fair)
                        } else if p.contains("therm_level=3") {
                            data = parce(.serious)
                        } else if p.contains("therm_level=4") {
                            data = parce(.critical)
                        } else {
                            data = parce(.undefined)
                        }
                    }
                    if process.isRunning {
                        process.terminate()
                    }
                    return data
                } catch let error {
                    NSLog(error.localizedDescription)
                    process.terminate()
                    return parce(.undefined)
                }
            } else {
                return parce(.noPassword)
            }
        }
    }
    
    public func macOSDriveName() -> String? {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do {
            let values = try url.resourceValues(forKeys: [.volumeNameKey])
            if let c = values.volumeName {
                return c
            } else {
                return nil
            }
        } catch let error {
            return error.localizedDescription
        }
    }
    
    //--------------------------------------------------------------------------
    // MARK: PRIVATE PROPERTIES
    //--------------------------------------------------------------------------
    
    
    fileprivate static let machHost = mach_host_self()
    fileprivate var loadPrevious = host_cpu_load_info()
    
    
    //--------------------------------------------------------------------------
    // MARK: PUBLIC INITIALIZERS
    //--------------------------------------------------------------------------
    
    
    public init() { }
    
    
    //--------------------------------------------------------------------------
    // MARK: PUBLIC METHODS
    //--------------------------------------------------------------------------
    
    
    /**
     Get CPU usage (system, user, idle, nice). Determined by the delta between
     the current and last call. Thus, first call will always be inaccurate.
     */
    public mutating func usageCPU() -> (system : Double,
                                        user   : Double,
                                        idle   : Double,
                                        nice   : Double) {
        let load = macOS_Subsystem.hostCPULoadInfo()
        
        let userDiff = Double(load.cpu_ticks.0 - loadPrevious.cpu_ticks.0)
        let sysDiff  = Double(load.cpu_ticks.1 - loadPrevious.cpu_ticks.1)
        let idleDiff = Double(load.cpu_ticks.2 - loadPrevious.cpu_ticks.2)
        let niceDiff = Double(load.cpu_ticks.3 - loadPrevious.cpu_ticks.3)
        
        let totalTicks = sysDiff + userDiff + niceDiff + idleDiff
        
        let sys  = sysDiff  / totalTicks * 100.0
        let user = userDiff / totalTicks * 100.0
        let idle = idleDiff / totalTicks * 100.0
        let nice = niceDiff / totalTicks * 100.0
        
        loadPrevious = load
        
        // TODO: 2 decimal places
        // TODO: Check that total is 100%
        return (sys, user, idle, nice)
    }
    
    public func CPUData() async -> Task<(system: Double, user: Double, idle: Double, nice: Double),Never> {
        Task {
            var subsystem = macOS_Subsystem()
            let system = subsystem.usageCPU().system
            let user   = subsystem.usageCPU().user
            let idle   = subsystem.usageCPU().idle
            let nice   = subsystem.usageCPU().nice
            return (system: system, user: user, idle: idle, nice: nice)
        }
    }
    
    public func getCPURealUsage() -> (user: Double, system: Double, idle: Double, total: Double) {
        func convertToDouble(_ s: String) -> Double {
            let r = s.replacingOccurrences(of: " ", with: "")
            let a = r.split(separator: "%")
            let d = Double(a[0]) ?? 0
            return d
        }
        let process = Process()
        let pipe = Pipe()
        process.standardOutput = pipe
        var retval: (user: Double, system: Double, idle: Double, total: Double) = (0, 0, 0, 0)
        var cpuusagestring = ""
        process.executableURL = URL(filePath: "/bin/bash")
        process.arguments = ["-c", "top -l 1"]
        do {
            try process.run()
            if let output = try String(data: pipe.fileHandleForReading.readToEnd() ?? Data(), encoding: .utf8) {
                for line in output.byLines {
                    if line.contains("CPU usage:") {
                        cpuusagestring = String(line)
                        break
                    }
                }
            }
            let indexOfPer = cpuusagestring.firstIndex(of: ":")!
            let meanerData = String(cpuusagestring.dropFirst(cpuusagestring.distance(from: cpuusagestring.startIndex, to: indexOfPer) + 2))
            let splitData = meanerData.split(separator: ",")
            let user = convertToDouble(String(splitData[0]))
            let sys = convertToDouble(String(splitData[1]))
            let idle = convertToDouble(String(splitData[2]))
            let total = user + sys + idle
            retval = (user: user, system: sys, idle: idle, total: total)
            return retval
        } catch let error {
            NSLog(error.localizedDescription)
            return (user: 0, system: 0, idle: 0, total: 0)
        }
    }
    
    //--------------------------------------------------------------------------
    // MARK: PUBLIC STATIC METHODS
    //--------------------------------------------------------------------------
    
    
    /// Get the model name of this machine. Same as "sysctl hw.model"
    public static func modelName() -> String {
        let name: String
        var mib  = [CTL_HW, HW_MODEL]
        
        // Max model name size not defined by sysctl. Instead we use io_name_t
        // via I/O Kit which can also get the model name
        var size = MemoryLayout<io_name_t>.size
        
        let ptr    = UnsafeMutablePointer<io_name_t>.allocate(capacity: 1)
        let result = sysctl(&mib, u_int(mib.count), ptr, &size, nil, 0)
        
        
        if result == 0 { name = String(cString: UnsafeRawPointer(ptr).assumingMemoryBound(to: CChar.self)) }
        else           { name = String() }
        
        
        ptr.deallocate()
        
#if DEBUG
        if result != 0 {
            print("ERROR - \(#file):\(#function) - errno = "
                  + "\(result)")
        }
#endif
        
        return name
    }
    
    
    /**
     sysname       Name of the operating system implementation.
     nodename      Network name of this machine.
     release       Release level of the operating system.
     version       Version level of the operating system.
     machine       Machine hardware platform.
     
     Via uname(3) manual page.
     */
    // FIXME: Two compiler bugs here. One has a workaround, the other requires
    //        a C wrapper function. See issue #18
    //    public static func uname() -> (sysname: String, nodename: String,
    //                                                     release: String,
    //                                                     version: String,
    //                                                     machine: String) {
    //        // Takes a generic pointer type because the type were dealing with
    //        // (from the utsname struct) is a huge tuple of Int8s (once bridged to
    //        // Swift), so it would be really messy to go that route (would have to
    //        // type it all out explicitly)
    //        func toString<T>(ptr: UnsafePointer<T>) -> String {
    //            return String.fromCString(UnsafePointer<CChar>(ptr))!
    //        }
    //
    //        let tuple: (String, String, String, String, String)
    //        var names  = utsname()
    //        let result = Foundation.uname(&names)
    //
    //        #if DEBUG
    //            if result != 0 {
    //                print("ERROR - \(__FILE__):\(__FUNCTION__) - errno = "
    //                        + "\(result)")
    //            }
    //        #endif
    //
    //        if result == 0 {
    //            let sysname  = withUnsafePointer(&names.sysname,  toString)
    //            let nodename = withUnsafePointer(&names.nodename, toString)
    //            let release  = withUnsafePointer(&names.release,  toString)
    //            let version  = withUnsafePointer(&names.version,  toString)
    //            let machine  = withUnsafePointer(&names.machine,  toString)
    //
    //            tuple = (sysname, nodename, release, version, machine)
    //        }
    //        else {
    //            tuple = ("", "", "", "", "")
    //        }
    //
    //        return tuple
    //    }
    
    public static func getModelYear() -> (localizedString: String, serviceData: String) {
        let process = Process()
        let pipe = Pipe()
        var year = ""
        process.executableURL = URL(filePath: "/bin/bash")
        process.arguments = ["-c", "/usr/libexec/PlistBuddy -c 'Print :0:product-name' /dev/stdin <<< \"$(ioreg -arc IOPlatformDevice -k product-name)\" 2> /dev/null | tr -cd '[:print:]'"]
        process.standardOutput = pipe
        do {
            try process.run()
            if let line = String(data: pipe.fileHandleForReading.availableData, encoding: .utf8) {
                year += line
            }
        } catch let error {
            NSLog(error.localizedDescription)
            return (localizedString: "", serviceData: "")
        }
        let words = year.byWords
        for word in words {
            if Int(word) ?? 0 > 2000 {
                year = word.description
            }
        }
        if Int(year) == nil {
            let reservedProcess = Process()
            let reservedPipe = Pipe()
            reservedProcess.executableURL = URL(filePath: "/bin/bash")
            reservedProcess.arguments = ["-c", "defaults read /Users/\(FileManager.default.homeDirectoryForCurrentUser.lastPathComponent)/Library/Preferences/com.apple.SystemProfiler.plist 'CPU Names' | cut -sd '\"' -f 4 | uniq"]
            reservedProcess.standardOutput = reservedPipe
            reservedProcess.standardError = reservedPipe
            do {
                try reservedProcess.run()
                if let line = String(data: reservedPipe.fileHandleForReading.availableData, encoding: .utf8) {
                    NSLog(line)
                    year += line
                }
            } catch let error {
                NSLog(error.localizedDescription)
                return (localizedString: "", serviceData: "")
            }
            let words = year.byWords
            for word in words {
                print(word)
                if Int(word) ?? 0 > 2000 {
                    year = word.description
                }
            }
        }
        
        if year != "" {
            return (localizedString: year + " " + StringLocalizer("year.string"), serviceData: year)
        } else {
            return (localizedString: "", serviceData: "")
        }
    }
    
    public static func isArm() -> Bool {
        var sMachine: String {
            var utsname = utsname()
            uname(&utsname)
            return withUnsafePointer(to: &utsname.machine) {
                $0.withMemoryRebound(to: CChar.self, capacity: Int(_SYS_NAMELEN)) {
                    String(cString: $0)
                }
            }
        }
        var retval: Bool {
            sMachine == "arm64"
        }
        return retval
    }

    public static func MacPlatform() -> (model: String,
                                         screenSize: String,
                                         modelType: deviceType,
                                         screenSizeInt: Int,
                                         platform: String,
                                         platformServiceData: platform) {
        
        func getVersionCode() -> String {
            var size : Int = 0
            sysctlbyname("hw.model", nil, &size, nil, 0)
            var model = [CChar](repeating: 0, count: Int(size))
            sysctlbyname("hw.model", &model, &size, nil, 0)
            return String.init(validatingUTF8: model) ?? ""
        }
        
        func getType(code: String) -> deviceType {
            let versionCode = getVersionCode()
            if versionCode.hasPrefix("MacPro") {
                return deviceType.macPro
            } else if versionCode.hasPrefix("iMac") {
                return deviceType.iMac
            } else if versionCode.hasPrefix("MacBookPro") {
                return deviceType.macBookPro
            } else if versionCode.hasPrefix("MacBookAir") {
                return deviceType.macBookAir
            } else if versionCode.hasPrefix("MacBook") {
                return deviceType.macBook
            } else if versionCode.hasPrefix("MacMini") {
                return deviceType.macMini
            } else if versionCode.hasPrefix("Xserve") {
                return deviceType.xserve
            }
            return deviceType.unknown
        }
        
        func sizeInInches() -> CGFloat {
            let screen = NSScreen.main
            let description = screen?.deviceDescription
            let displayPhysicalSize = CGDisplayScreenSize(description?[NSDeviceDescriptionKey(rawValue: "NSScreenNumber")] as? CGDirectDisplayID ?? 0)
            return floor(sqrt(pow(displayPhysicalSize.width, 2) + pow(displayPhysicalSize.height, 2)) * 0.0393701);
        }
        
        func size() -> Size {
            let sizeInInches = sizeInInches()
            
            switch sizeInInches {
            case 11:
                return Size.screen11Inch
            case 12:
                return Size.screen12Inch
            case 13:
                return Size.screen13Inch
            case 15:
                return Size.screen15Inch
            case 16:
                return Size.screen16Inch
            case 17:
                return Size.screen17Inch
            case 20:
                return Size.screen20Inch
            case 21:
                return Size.screen21_5Inch
            case 24:
                return Size.screen24Inch
            case 27:
                return Size.screen27Inch
            default:
                return Size.unknownSize
            }
        }
        func comparator() -> (model: String,
                              screenSize: String,
                              modelType: deviceType,
                              screenSizeInt: Int,
                              platform: String,
                              platformServiceData: platform) {
            var mo = ""
            var size = 0
            let versionCode = getVersionCode()
            if versionCode.hasPrefix("MacPro") {
                mo = "Mac Pro"
            } else if versionCode.hasPrefix("iMac") {
                mo = "iMac"
            } else if versionCode.hasPrefix("MacBookPro") {
                mo = "MacBook Pro"
            } else if versionCode.hasPrefix("MacBookAir") {
                mo = "MacBook Air"
            } else if versionCode.hasPrefix("MacBook") {
                mo = "MacBook"
            } else if versionCode.hasPrefix("MacMini") {
                mo = "Mac Mini"
            } else if versionCode.hasPrefix("Xserve") {
                mo = "XServer"
            }
            
            
            let sizeF = sizeInInches()
            switch sizeF {
            case 11:
                size = 11
            case 12:
                size = 12
            case 13:
                size = 13
            case 15:
                size = 15
            case 16:
                size = 16
            case 17:
                size = 17
            case 20:
                size = 20
            case 21:
                size = 21
            case 24:
                size = 24
            case 27:
                size = 27
            default:
                size = 0
            }
                        
            if Int(getModelYear().serviceData) != nil || Int(getModelYear().serviceData)! >= 2018 && !isArm() {
                size += 1
                if Int(getModelYear().serviceData)! >= 2020 {
                    size -= 1
                }
            }
            return (mo, "\(Int(size))\(StringLocalizer("inch.string"))",
                    getType(code: getVersionCode()),
                    size,
                    isArm() ? StringLocalizer("arm.string") : Int(getModelYear().serviceData)! >= 2020 ? StringLocalizer("rosetta.string") : StringLocalizer("intel.string"),
                    isArm() ? .AppleSilicon : Int(getModelYear().serviceData)! >= 2020 ? .AppleSiliconRosetta : .Intel)
        }
        return comparator()
    }
    
    public func cpuName() -> String  {
        let process = Process()
        let pipe = Pipe()
        process.standardOutput = pipe
        process.executableURL = URL(filePath: "/bin/bash")
        process.arguments = ["-c", "sysctl -a"]
        var retval = ""
        do {
            try process.run()
            if let output = try String(data: pipe.fileHandleForReading.readToEnd() ?? Data(), encoding: .utf8) {
                for line in output.byLines {
                    if line.contains("machdep.cpu.brand_string") {
                        let index = line.firstIndex(of: ":")
                        retval = String(line.dropFirst(line.distance(from: line.startIndex, to: index!) + 2))
                    }
                }
            }
        } catch let error {
            NSLog(error.localizedDescription)
        }
        return retval
    }
    
    public static func gpuName() -> [String] {
        var out = Array<String>()
        var process: Process?
        var pipe: Pipe?
        do {
            if isArm() {
                process = Process()
                pipe = Pipe()
                process?.arguments = ["-c" , "system_profiler SPDisplaysDataType | grep Apple"]
                process?.standardOutput = pipe
                process?.executableURL = URL(filePath: "/bin/bash")
                try process?.run()
                if let line = String(data: (pipe?.fileHandleForReading.availableData)!, encoding: .utf8) {
                    out.append(String(String(line.components(separatedBy: "\n")[0].dropFirst(4)).dropLast(1)))
                }
                process?.terminate()
                process = nil
                pipe = nil
            } else {
                process = Process()
                pipe = Pipe()
                process?.arguments = ["-c" , "system_profiler SPDisplaysDataType | grep Intel"]
                process?.standardOutput = pipe
                process?.executableURL = URL(filePath: "/bin/bash")
                try process?.run()
                if let line = String(data: (pipe?.fileHandleForReading.availableData)!, encoding: .utf8) {
                    out.append(String(String(line.components(separatedBy: "\n")[0].dropFirst(4)).dropLast(1)))
                    out.append(", ")
                }
                process?.terminate()
                process = nil
                pipe = nil
                
                process = Process()
                pipe = Pipe()
                process?.standardOutput = pipe
                process?.executableURL = URL(filePath: "/bin/bash")
                process?.arguments = ["-c", "system_profiler SPDisplaysDataType | grep AMD"]
                try process?.run()
                if let line = String(data: (pipe?.fileHandleForReading.availableData)!, encoding: .utf8) {
                    out.append(String(String(line.components(separatedBy: "\n")[0].dropFirst(4)).dropLast(1)))
                }
                for each in out {
                    if each == ", " {
                        out.remove(at: out.firstIndex(of: each)!)
                    }
                    if each == " " {
                        out.remove(at: out.firstIndex(of: each)!)
                    }
                    if each == "" {
                        out.remove(at: out.firstIndex(of: each)!)
                    }
                }
                if out.count > 1 {
                    for each in out {
                        if each == ", " {
                            out.remove(at: out.firstIndex(of: each)!)
                        }
                        if each == " " {
                            out.remove(at: out.firstIndex(of: each)!)
                        }
                        if each == "" {
                            out.remove(at: out.firstIndex(of: each)!)
                        }
                    }
                    out[0] = out[0] + ", "
                }
            }
            return out
        } catch let error {
            out = ["\(error.localizedDescription)"]
            NSLog(error.localizedDescription)
            return out
        }
    }
    
    /// Number of physical cores on this machine.
    public static func physicalCores() -> Int {
        return Int(macOS_Subsystem.hostBasicInfo().physical_cpu)
    }
    
    
    /**
     Number of logical cores on this machine. Will be equal to physicalCores()
     unless it has hyper-threading, in which case it will be double.
     
     https://en.wikipedia.org/wiki/Hyper-threading
     */
    public static func logicalCores() -> Int {
        return Int(macOS_Subsystem.hostBasicInfo().logical_cpu)
    }
    
    
    /**
     System load average at 3 intervals.
     
     "Measures the average number of threads in the run queue."
     
     - via hostinfo manual page
     
     https://en.wikipedia.org/wiki/Load_(computing)
     */
    public static func loadAverage(_ type: LOAD_AVG = .long) -> [Double] {
        var avg = [Double](repeating: 0, count: 3)
        
        switch type {
        case .short:
            let result = macOS_Subsystem.hostLoadInfo().avenrun
            avg = [Double(result.0) / Double(LOAD_SCALE),
                   Double(result.1) / Double(LOAD_SCALE),
                   Double(result.2) / Double(LOAD_SCALE)]
        case .long:
            getloadavg(&avg, 3)
        }
        
        return avg
    }
    
    
    /**
     System mach factor at 3 intervals.
     
     "A variant of the load average which measures the processing resources
     available to a new thread. Mach factor is based on the number of CPUs
     divided by (1 + the number of runnablethreads) or the number of CPUs minus
     the number of runnable threads when the number of runnable threads is less
     than the number of CPUs. The closer the Mach factor value is to zero, the
     higher the load. On an idle system with a fixed number of active processors,
     the mach factor will be equal to the number of CPUs."
     
     - via hostinfo manual page
     */
    public static func machFactor() -> [Double] {
        let result = macOS_Subsystem.hostLoadInfo().mach_factor
        
        return [Double(result.0) / Double(LOAD_SCALE),
                Double(result.1) / Double(LOAD_SCALE),
                Double(result.2) / Double(LOAD_SCALE)]
    }
    
    
    /// Total number of processes & threads
    public static func processCounts() -> (processCount: Int, threadCount: Int) {
        let data = macOS_Subsystem.processorLoadInfo()
        return (Int(data.task_count), Int(data.thread_count))
    }
    
    
    /// Size of physical memory on this machine
    public static func physicalMemory(_ unit: Unit = .gigabyte) -> Double {
        return Double(macOS_Subsystem.hostBasicInfo().max_mem) / unit.rawValue
    }
    
    
    /**
     System memory usage (free, active, inactive, wired, compressed).
     */
    public static func memoryUsage(_ unit: Unit) -> (
        free       : Double,
        active     : Double,
        inactive   : Double,
        wired      : Double,
        compressed : Double,
        cachedFiles: Double,
        total      : Double
    ) {
        let stats = macOS_Subsystem.VMStatistics64()
        
        let free     = Double(stats.free_count) * Double(PAGE_SIZE)
        / unit.rawValue
        let active   = Double(stats.active_count) * Double(PAGE_SIZE)
        / unit.rawValue
        let inactive = Double(stats.inactive_count) * Double(PAGE_SIZE)
        / unit.rawValue
        let wired    = Double(stats.wire_count) * Double(PAGE_SIZE)
        / unit.rawValue
        let cachedFiles     = Double(stats.external_page_count) * Double(PAGE_SIZE)
        / unit.rawValue
        // Result of the compression. This is what you see in Activity Monitor
        let compressed = Double(stats.compressor_page_count) * Double(PAGE_SIZE)
        / unit.rawValue
        
        let total = Double(ProcessInfo.processInfo.physicalMemory) / unit.rawValue
        
        return (free, active, inactive, wired, compressed, cachedFiles, total)
    }
    
    
    /// How long has the system been up?
    public static func uptime() -> (days: Int, hrs: Int, mins: Int, secs: Int, total: Int) {
        var currentTime = time_t()
        var bootTime    = timeval()
        var mib         = [CTL_KERN, KERN_BOOTTIME]
        
        // NOTE: Use strideof(), NOT sizeof() to account for data structure
        // alignment (padding)
        // http://stackoverflow.com/a/27640066
        // https://devforums.apple.com/message/1086617#1086617
        var size = MemoryLayout<timeval>.stride
        
        let result = sysctl(&mib, u_int(mib.count), &bootTime, &size, nil, 0)
        
        if result != 0 {
#if DEBUG
            print("ERROR - \(#file):\(#function) - errno = "
                  + "\(result)")
#endif
            
            return (0, 0, 0, 0, 0)
        }
        
        
        // Since we don't need anything more than second level accuracy, we use
        // time() rather than say gettimeofday(), or something else. uptime
        // command does the same
        time(&currentTime)
        
        let total = currentTime - bootTime.tv_sec
        var uptime = currentTime - bootTime.tv_sec
        
        let days = uptime / 86400   // Number of seconds in a day
        uptime %= 86400
        
        let hrs = uptime / 3600     // Number of seconds in a hour
        uptime %= 3600
        
        let mins = uptime / 60
        let secs = uptime % 60
        
        return (days, hrs, mins, secs, total)
    }
    
    
    //--------------------------------------------------------------------------
    // MARK: POWER
    //--------------------------------------------------------------------------
    
    
    /**
     As seen via 'pmset -g therm' command.
     
     Via <IOKit/pwr_mgt/IOPMLib.h>:
     
     processorSpeed: Defines the speed & voltage limits placed on the CPU.
     Represented as a percentage (0-100) of maximum CPU
     speed.
     
     processorCount: Reflects how many, if any, CPUs have been taken offline.
     Represented as an integer number of CPUs (0 - Max CPUs).
     
     NOTE: This doesn't sound quite correct, as pmset treats
     it as the number of CPUs available, NOT taken
     offline. The return value suggests the same.
     
     schedulerTime:  Represents the percentage (0-100) of CPU time available.
     100% at normal operation. The OS may limit this time for
     a percentage less than 100%.
     */
    
    public static func getBatteryState() -> (PowerSource: PowerSource, ChargingState: ChargingState, Percentage: Double, TimeRemaining: String)
    {
        var battState: ChargingState
        var powerSource: PowerSource
        let task = Process()
        let pipe = Pipe()
        task.launchPath = "/usr/bin/pmset"
        task.arguments = ["-g", "batt"]
        task.standardOutput = pipe
        do {
            try task.run()
            let data = try pipe.fileHandleForReading.readToEnd()
            task.waitUntilExit()
            let output = String(data: data ?? Data(), encoding: .utf8) ?? ""
            
            let batteryArray = output.components(separatedBy: ";")
            let source = output.components(separatedBy: "'")[1]
            let state = batteryArray[1].trimmingCharacters(in: NSCharacterSet.whitespaces).capitalized
            switch state {
            case "Ac Attached": battState = .acAttached
            case "Discharging": battState = .discharging
            case "Charging": battState = .charging
            case "Charged": battState = .charged
            case "Finishing Charge": battState = .finishingCharge
            default: battState = .unknown
            }
            switch source {
            case "AC Power": powerSource = .AC
            case "Battery Power": powerSource = .Internal
            default: powerSource = .unknown
            }
            let percent = String.init(batteryArray[0].components(separatedBy: ")")[1].trimmingCharacters(in: NSCharacterSet.whitespaces).dropLast())
            var remaining = String.init(batteryArray[2].dropFirst().split(separator: " ")[0])
            if(remaining == "not"){
                remaining = StringLocalizer("battstate.notCharging")
            }
            if(remaining == "(no"){
                remaining = StringLocalizer("calculating.string")
            }
            return (PowerSource: powerSource, ChargingState: battState, Percentage: Double(percent)!, TimeRemaining: remaining)
        } catch _ {
            return (PowerSource: PowerSource.unknown, ChargingState: ChargingState.unknown, Percentage: 0, TimeRemaining: "NaN")
        }
    }
    
    public static func CPUPowerLimit() -> (processorSpeed: Double,
                                           processorCount: Int,
                                           schedulerTime : Double) {
        var processorSpeed = -1.0
        var processorCount = -1
        var schedulerTime  = -1.0
        
        let status = UnsafeMutablePointer<Unmanaged<CFDictionary>?>.allocate(capacity: 1)
        
        let result = IOPMCopyCPUPowerStatus(status)
        
#if DEBUG
        // TODO: kIOReturnNotFound case as seen in pmset
        if result != kIOReturnSuccess {
            print("ERROR - \(#file):\(#function) - kern_result_t = "
                  + "\(result)")
        }
#endif
        
        
        if result == kIOReturnSuccess,
           let data = status.move()?.takeUnretainedValue() {
            let dataMap = data as NSDictionary
            
            // TODO: Force unwrapping here should be safe, as
            //       IOPMCopyCPUPowerStatus() defines the keys, but the
            //       the cast (from AnyObject) could be problematic
            processorSpeed = dataMap[kIOPMCPUPowerLimitProcessorSpeedKey]!
            as! Double
            processorCount = dataMap[kIOPMCPUPowerLimitProcessorCountKey]!
            as! Int
            schedulerTime  = dataMap[kIOPMCPUPowerLimitSchedulerTimeKey]!
            as! Double
        }
        
        status.deallocate()
        
        return (processorSpeed, processorCount, schedulerTime)
    }
    
    
    /// Get the thermal level of the system. As seen via 'pmset -g therm'
    public static func thermalLevelOld() -> ThermalLevel {
        var thermalLevel: UInt32 = 0
        
        let result = IOPMGetThermalWarningLevel(&thermalLevel)
        
        if result == kIOReturnNotFound {
            return ThermalLevel.NotPublished
        }
        
        
#if DEBUG
        if result != kIOReturnSuccess {
            print("ERROR - \(#file):\(#function) - kern_result_t = "
                  + "\(result)")
        }
#endif
        
        
        // TODO: Thermal warning level values no longer available through
        //       IOKit.pwr_mgt module as of Xcode 6.3 Beta 3. Not sure if thats
        //       intended behaviour or a bug, will investigate. For now
        //       hardcoding values, will move all power related calls to a
        //       separate struct.
        switch thermalLevel {
        case 0:
            // kIOPMThermalWarningLevelNormal
            return ThermalLevel.Normal
        case 5:
            // kIOPMThermalWarningLevelDanger
            return ThermalLevel.Danger
        case 10:
            // kIOPMThermalWarningLevelCrisis
            return ThermalLevel.Crisis
        default:
            return ThermalLevel.Unknown
        }
    }
    
    public static func thermalLevel() -> ThermalLevel {
        switch ProcessInfo.processInfo.thermalState {
        case .nominal: return ThermalLevel.Normal
        case .fair: return ThermalLevel.Normal
        case .serious: return ThermalLevel.Danger
        case .critical: return ThermalLevel.Crisis
        @unknown default:
            return ThermalLevel.NotPublished
        }
    }
    
    
    //--------------------------------------------------------------------------
    // MARK: - PRIVATE METHODS
    //--------------------------------------------------------------------------
    
    
    fileprivate static func hostBasicInfo() -> host_basic_info {
        // TODO: Why is host_basic_info.max_mem val different from sysctl?
        
        var size     = HOST_BASIC_INFO_COUNT
        let hostInfo = host_basic_info_t.allocate(capacity: 1)
        
        let result = hostInfo.withMemoryRebound(to: integer_t.self, capacity: Int(size)) {
            host_info(machHost, HOST_BASIC_INFO, $0, &size)
        }
        
        let data = hostInfo.move()
        hostInfo.deallocate()
        
#if DEBUG
        if result != KERN_SUCCESS {
            print("ERROR - \(#file):\(#function) - kern_result_t = "
                  + "\(result)")
        }
#endif
        
        return data
    }
    
    
    fileprivate static func hostLoadInfo() -> host_load_info {
        var size     = HOST_LOAD_INFO_COUNT
        let hostInfo = host_load_info_t.allocate(capacity: 1)
        
        let result = hostInfo.withMemoryRebound(to: integer_t.self, capacity: Int(size)) {
            host_statistics(machHost, HOST_LOAD_INFO,
                            $0,
                            &size)
        }
        
        let data = hostInfo.move()
        hostInfo.deallocate()
        
#if DEBUG
        if result != KERN_SUCCESS {
            print("ERROR - \(#file):\(#function) - kern_result_t = "
                  + "\(result)")
        }
#endif
        
        return data
    }
    
    
    fileprivate static func hostCPULoadInfo() -> host_cpu_load_info {
        var size     = HOST_CPU_LOAD_INFO_COUNT
        let hostInfo = host_cpu_load_info_t.allocate(capacity: 1)
        
        let result = hostInfo.withMemoryRebound(to: integer_t.self, capacity: Int(size)) {
            host_statistics(machHost, HOST_CPU_LOAD_INFO,
                            $0,
                            &size)
        }
        
        let data = hostInfo.move()
        hostInfo.deallocate()
        
#if DEBUG
        if result != KERN_SUCCESS {
            print("ERROR - \(#file):\(#function) - kern_result_t = "
                  + "\(result)")
        }
#endif
        
        return data
    }
    
    
    fileprivate static func processorLoadInfo() -> processor_set_load_info {
        // NOTE: Duplicate load average and mach factor here
        
        var pset   = processor_set_name_t()
        var result = processor_set_default(machHost, &pset)
        
        if result != KERN_SUCCESS {
#if DEBUG
            print("ERROR - \(#file):\(#function) - kern_result_t = "
                  + "\(result)")
#endif
            
            return processor_set_load_info()
        }
        
        
        var count    = PROCESSOR_SET_LOAD_INFO_COUNT
        let info_out = processor_set_load_info_t.allocate(capacity: 1)
        
        result = info_out.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
            processor_set_statistics(pset,
                                     PROCESSOR_SET_LOAD_INFO,
                                     $0,
                                     &count)
        }
        
#if DEBUG
        if result != KERN_SUCCESS {
            print("ERROR - \(#file):\(#function) - kern_result_t = "
                  + "\(result)")
        }
#endif
        
        
        // This is isn't mandatory as I understand it, just helps keep the ref
        // count correct. This is because the port is to the default processor
        // set which should exist by default as long as the machine is running
        mach_port_deallocate(mach_task_self_, pset)
        
        let data = info_out.move()
        info_out.deallocate()
        
        return data
    }
    
    
    /**
     64-bit virtual memory statistics. This should apply to all Mac's that run
     10.9 and above. For iOS, iPhone 5S, iPad Air & iPad Mini 2 and on.
     
     Swift runs on 10.9 and above, and 10.9 is x86_64 only. On iOS though its 7
     and above, with both ARM & ARM64.
     */
    fileprivate static func VMStatistics64() -> vm_statistics64 {
        var size     = HOST_VM_INFO64_COUNT
        let hostInfo = vm_statistics64_t.allocate(capacity: 1)
        
        let result = hostInfo.withMemoryRebound(to: integer_t.self, capacity: Int(size)) {
            host_statistics64(machHost,
                              HOST_VM_INFO64,
                              $0,
                              &size)
        }
        
        let data = hostInfo.move()
        hostInfo.deallocate()
        
#if DEBUG
        if result != KERN_SUCCESS {
            print("ERROR - \(#file):\(#function) - kern_result_t = "
                  + "\(result)")
        }
#endif
        
        return data
    }
}
