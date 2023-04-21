//
//  SleepManager.swift
//  MultiTool
//
//  Created by Олег Сазонов on 26.06.2022.
//

import Foundation

/// Sleep Manager
public class SleepManager {
    public init(){}
    //MARK: - System Sleep settings
    /// Checks if Sleep is disabled
    /// - Returns: true if enabled, false otherwise
    public func getIsSleepEnabled() -> Bool {
        let shellResult = Shell.Parcer.OneExecutable.withOptionalString(exe: "pmset", args: ["-g"]) ?? ""
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
        var retval: Bool = false
        let shellResult = Shell.Parcer.OneExecutable.withOptionalString(exe: "pmset", args: ["-g"]) ?? ""
        let findingResult = shellResult.byLines
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
        return retval
    }
    
    /// Gets hibernation mode
    /// - Returns: 0 — disabled, 3 — sleep, 25 — hibernation
    public func getIsSleepEnabled() -> Int {
        let shellResult = Shell.Parcer.OneExecutable.withOptionalString(exe: "pmset", args: ["-g"]) ?? ""
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
        return resultingValue
    }
    
    
    /// Sets sleep mode
    /// - Parameters:
    ///   - parameter: 0 — sleep disabled, 3 — sleep, 25 — hibernation
    ///   - password: sudo password
    public func setHibernationMode(parameter: Int, password: String) {
        let exe = "/usr/bin/pmset"
        let args = ["hibernatemode", parameter.description]
        _ = Shell.Parcer.SUDO.withString(exe, args, password: password) as String
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
        var retval: Int? = nil
        let shellOut = Shell.Parcer.OneExecutable.withOptionalString(args: ["top -l 1 | grep caffeinate"]) ?? ""
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
        Shell.Parcer.OneExecutable.withNoOutput(exe: "caffeinate", args: [args])
    }
    
    /// Allow sleep
    public func allowSleep() {
        if sleepIsPermitted() {
            Shell.Parcer.OneExecutable.withNoOutput(exe: "kill", args: ["-9", "\(caffeinatePID!)"])
        }
    }
}
