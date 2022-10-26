//
//  SleepManager.swift
//  MultiTool
//
//  Created by Олег Сазонов on 26.06.2022.
//

import Foundation

/// Sleep Manager
public class SleepManager: xCore {
    override public init(){}
    //MARK: - System Sleep settings
    /// Checks if Sleep is disabled
    /// - Returns: true if enabled, false otherwise
    public func getIsSleepEnabled() -> Bool {
        let process = Process()
        let pipe = Pipe()
        process.executableURL = URL(filePath: "/usr/bin/pmset")
        process.arguments = ["-g"]
        process.standardOutput = pipe
        var shellResult = ""
        do {
            try process.run()
            shellResult = try String(data: pipe.fileHandleForReading.readToEnd() ?? pipe.fileHandleForReading.availableData, encoding: .utf8) ?? ""
        } catch let error {
            print(error.localizedDescription)
        }
        var hibernationValue = ""
        var resultingValue = 0
        let findingResult = shellResult.byLines
        for line in findingResult {
            if line.contains("hibernatemode") {
                hibernationValue = String(line)
                hibernationValue = hibernationValue.replacingOccurrences(of: "hibernatemode", with: "")
                hibernationValue = hibernationValue.replacingOccurrences(of: " ", with: "")
                hibernationValue = hibernationValue.replacingOccurrences(of: "\n", with: "")
                resultingValue = Int(hibernationValue) ?? 0
            }
        }
        switch resultingValue {
        case 0: return false
        default: return true
        }
    }
    
    /// System Sleep settings
    /// - Returns: true if sleep is disabled on system wide level, false otherwise
    public func SystemWideSleepStatus() -> Bool {
        let process = Process()
        let pipe = Pipe()
        process.executableURL = URL(filePath: "/usr/bin/pmset")
        process.arguments = ["-g"]
        process.standardOutput = pipe
        var retval: Bool = false
        do {
            try process.run()
            let shellResult = try String(data: pipe.fileHandleForReading.readToEnd() ?? pipe.fileHandleForReading.availableData, encoding: .utf8) ?? ""
            let findingResult = shellResult.byLines
//            print(shellResult)
            for line in findingResult {
                if line.contains("SleepDisabled") {
                    let stringValue = line.byWords.last ?? ""
                    let value = Int(stringValue)
                    switch value {
                    case 1: retval = true
                    default: retval = false
                    }
                }
            }
        } catch let error {
            print(error.localizedDescription)
            retval = false
        }
        return retval
    }
    
    /// Gets hibernation mode
    /// - Returns: 0 — disabled, 3 — sleep, 25 — hibernation
    public func getIsSleepEnabled() -> Int {
        let process = Process()
        let pipe = Pipe()
        process.executableURL = URL(filePath: "/usr/bin/pmset")
        process.arguments = ["-g"]
        process.standardOutput = pipe
        var shellResult = ""
        do {
            try process.run()
            shellResult = try String(data: pipe.fileHandleForReading.readToEnd() ?? pipe.fileHandleForReading.availableData, encoding: .utf8) ?? ""
        } catch let error {
            print(error.localizedDescription)
        }
        var hibernationValue = ""
        var resultingValue = 0
        let findingResult = shellResult.byLines
//        print(shellResult)
        for line in findingResult {
            if line.contains("hibernatemode") {
                hibernationValue = String(line)
                hibernationValue = hibernationValue.replacingOccurrences(of: "hibernatemode", with: "")
                hibernationValue = hibernationValue.replacingOccurrences(of: " ", with: "")
                hibernationValue = hibernationValue.replacingOccurrences(of: "\n", with: "")
                resultingValue = Int(hibernationValue) ?? 0
            }
        }
        return resultingValue
    }
    
    
    /// Sets sleep mode
    /// - Parameters:
    ///   - parameter: 0 — sleep disabled, 3 — sleep, 25 — hibernation
    ///   - password: sudo password
    public func setHibernationMode(parameter: Int, password: String) {
        let exe = "/usr/bin/pmset"
        let args = ["hibernatemode", parameter.description]
        _ = Shell.Parcer.sudo(exe, args, password: password) as String
    }
    
    /// Localized sleep setting descripton
    /// - Returns: Exact what it's called
    public func getSleepSetting() -> String {
        switch getIsSleepEnabled() as Int {
        case 0:
            return StringLocalizer("hibernationDisabled.string")
        case 3:
            return StringLocalizer("hibernationWithoutPoweroff.string")
        case 25:
            return StringLocalizer("hibernationWithPoweroff.string")
        default:
            return StringLocalizer("undefined.string")
        }
    }
    
    /// Localized sleep setting descripton
    /// - Parameter input: 0 — sleep disabled, 3 — sleep, 25 — hibernation

    /// - Returns: Exact what it's called
    public func getSleepSetting(_ input: Int) -> String {
        switch input {
        case 0:
            return StringLocalizer("hibernationDisabled.string")
        case 3:
            return StringLocalizer("hibernationWithoutPoweroff.string")
        case 25:
            return StringLocalizer("hibernationWithPoweroff.string")
        default:
            return StringLocalizer("undefined.string")
        }
    }
    //MARK: - Caffeinate
    /// Checks if settings can be applied due to sleep weirdness in macOS
    /// - Returns: true if permitted, false otherwise
    public func sleepIsPermitted() -> Bool {
        switch caffeinatePID {
        case nil: return false
        default: return true
        }
    }
    
    /// If exists process caffeinate returns it's PID, nil otherwise
    private var caffeinatePID: Int? {
        let process = Process()
        let pipe = Pipe()
        var retval: Int? = nil
        process.executableURL = URL(filePath: "/bin/bash")
        process.standardOutput = pipe
        process.arguments = ["-c", "top -l 1 | grep caffeinate"]
        do {
            try process.run()
            delay(after: 3) {
                process.terminate()
            }
            let data = try pipe.fileHandleForReading.readToEnd() ?? Data(capacity: 0)
            let shellOut = String(data: data, encoding: .utf8) ?? ""
            let lines = shellOut.byLines
            for line in lines {
                switch line.contains("caffeinate") {
                case true:
                    let string = line.firstWord!.description
                    retval = Int(string)!
                    break
                case false: retval = nil
                }
            }
        } catch let error {
            NSLog(error.localizedDescription)
        }
        return retval
    }
    
    /// Permits system sleep
    /// - Parameter screenSleep: .allow — allow screen to sleep, .deny — otherwise
    public func permitSleep(_ screenSleep: DisplaySleep = .allow) {
        var args = ""
        switch screenSleep {
        case .allow:
            args = ""
        case .deny:
            args = " -disum"
        }
        let process = Process()
        process.executableURL = URL(filePath: "/bin/bash")
        process.arguments = ["-c", "caffeinate\(args) & "]
        do {
            try process.run()
        } catch let error {
            NSLog(error.localizedDescription)
        }
    }
    
    /// Allow sleep
    public func allowSleep() {
        if sleepIsPermitted() {
            let process = Process()
            process.executableURL = URL(filePath: "/bin/kill")
            process.arguments = ["-9", "\(caffeinatePID!)"]
            do {
                try process.run()
            } catch let error {
                NSLog(error.localizedDescription)
            }
        }
    }
}
