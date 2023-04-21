//
//  Finder Manager.swift
//  SuperStuff
//
//  Created by Олег Сазонов on 08.07.2022.
//

import Foundation
import Combine

public class DockManager {
    public init(){}
    deinit{}
    
    private func getKeyValue(key: DockBoolKeys) -> Bool {
        var arguments = [String]()
        switch key {
        case .singleAppEnabled: arguments = ["read", "com.apple.dock", "static-only", "-bool"]
        case .singleAppDisabled: arguments = ["read", "com.apple.dock", "static-only", "-bool"]
        case .autohideEnabled: arguments = ["read", "com.apple.dock", "autohide", "-bool"]
        case .autohideDisabled: arguments = ["read", "com.apple.dock", "autohide", "-bool"]
        case .magnificationEnabled: arguments = ["read", "com.apple.dock", "magnification", "-bool"]
        case .magnificationDisabled: arguments = ["read", "com.apple.dock", "magnification", "-bool"]
        case .hiddenAppsGrayedOutEnabled: arguments = ["read", "com.apple.dock", "showhidden", "-bool"]
        case .hiddenAppsGrayedOutDisabled: arguments = ["read", "com.apple.dock", "showhidden", "-bool"]
        }
        let ShellResult = Shell.Parcer.OneExecutable.withOptionalString(exe: "defaults", args: arguments) ?? ""
        let result = Int(String(ShellResult.replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: " ", with: "")))
        switch result {
        case 1: return true
        default: return false
        }
    }
    
    private func getKeyValue(key: DockFloatKeys) -> Int {
        var arguments = [String]()
        switch key {
        case .animationSpeed: arguments = ["read", "com.apple.dock", "autohide-time-modifier", "-float"]
        case .popDelay: arguments = ["read", "com.apple.dock", "autohide-delay", "-float"]
        }
        let ShellResult = Shell.Parcer.OneExecutable.withOptionalString(exe: "defaults", args: arguments) ?? ""
        let result = Float(String(ShellResult.replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: " ", with: ""))) ?? 0
        return Int(result * 100)
    }
    private func getKeyValue(key: DockStringKeys) -> String {
        var arguments = [String]()
        switch key {
        case .typeOfAnimation:  arguments = ["read", "com.apple.dock", "mineffect", "-string"]
        case .orientation:      arguments = ["read", "com.apple.dock", "orientation", "-string"]
        }
        let ShellResult = Shell.Parcer.OneExecutable.withOptionalString(exe: "defaults", args: arguments) ?? ""
        let result = String(ShellResult.replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: " ", with: ""))
        return result
    }
    
    
    private func setKeyValue(key: DockBoolKeys) {
        var arguments = [String]()
        switch key {
        case .singleAppEnabled: arguments = ["write", "com.apple.dock", "static-only", "-bool", "true"]
        case .singleAppDisabled: arguments = ["write", "com.apple.dock", "static-only", "-bool", "false"]
        case .autohideDisabled: arguments = ["write", "com.apple.dock", "autohide", "-bool", "false"]
        case .autohideEnabled: arguments = ["write", "com.apple.dock", "autohide", "-bool", "true"]
        case .magnificationEnabled: arguments = ["write", "com.apple.dock", "magnification", "-bool", "true"]
        case .magnificationDisabled: arguments = ["write", "com.apple.dock", "magnification", "-bool", "false"]
        case .hiddenAppsGrayedOutEnabled: arguments = ["write", "com.apple.dock", "showhidden", "-bool", "true"]
        case .hiddenAppsGrayedOutDisabled: arguments = ["write", "com.apple.dock", "showhidden", "-bool", "false"]
        }
        Shell.Parcer.OneExecutable.withNoOutput(exe: "defaults", args: arguments)
    }
    
    private func setKeyValue(key: DockFloatKeys, value: Int) {
        var arguments = [String]()
        switch key {
        case .animationSpeed:   arguments = ["write", "com.apple.dock", "autohide-time-modifier", "-float", "\(Float(value) / 100)"]
        case .popDelay:         arguments = ["write", "com.apple.dock", "autohide-delay", "-float", "\(Float(value) / 100)"]
        }
        Shell.Parcer.OneExecutable.withNoOutput(exe: "defaults", args: arguments)
    }
    
    private func setKeyValue(key: orientation) {
        var arguments = [String]()
        switch key {
        case .right:    arguments = ["write", "com.apple.dock", "orientation", "right"]
        case .left:     arguments = ["write", "com.apple.dock", "orientation", "left"]
        case .bottom:   arguments = ["write", "com.apple.dock", "orientation", "bottom"]
        }
        Shell.Parcer.OneExecutable.withNoOutput(exe: "defaults", args: arguments)
    }
    
    private func setKeyValue(key: AnimationTypes) {
        var arguments = [String]()
        switch key {
        case .suck:     arguments = ["write", "com.apple.dock", "mineffect", "-string", "suck"]
        case .genie:    arguments = ["write", "com.apple.dock", "mineffect", "-string", "genie"]
        case .scale:    arguments = ["write", "com.apple.dock", "mineffect", "-string", "scale"]
        }
        Shell.Parcer.OneExecutable.withNoOutput(exe: "defaults", args: arguments)
    }
    
    private func writeDiskArbitration(_ enable: Bool) {
        if SettingsMonitor.passwordSaved {
            switch enable {
            case true:
                Shell.Parcer.SUDO.withoutOutput("/bin/bash", ["-c", "sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.DiskArbitration.diskarbitrationd.plist DADisableEjectNotification -bool true && sudo pkill diskarbitrationd"], password: SettingsMonitor.password)
            case false:
                Shell.Parcer.SUDO.withoutOutput("/bin/bash", ["-c", "sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.DiskArbitration.diskarbitrationd.plist DADisableEjectNotification -bool false && sudo pkill diskarbitrationd"], password: SettingsMonitor.password)
            }
        }
    }
    
    private func readDiskArbitration() -> Bool {
        var retval = false
        let arguments = ["read", "/Library/Preferences/SystemConfiguration/com.apple.DiskArbitration.diskarbitrationd.plist"]
        let shellResutl = Shell.Parcer.OneExecutable.withOptionalString(exe: "defaults", args: arguments) ?? ""
            for line in shellResutl.components(separatedBy: "\n") {
                if line.contains("DADisableEjectNotification"){
                    if line.contains("1") {
                        retval = true
                        break
                    } else if line.contains("0") {
                        retval = false
                        break
                    }
                }
            }
        return retval
    }
    
    public func addSpacer(_ type: spacerType) {
        var arguments = [String]()
        switch type {
        case .wide:     arguments = ["write", "com.apple.dock", "persistent-apps", "-array-add", "'{tile-data={}; tile-type=\"spacer-tile\";}'"]
        case .narrow:   arguments = ["write", "com.apple.dock", "persistent-apps", "-array-add", "'{\"tile-type\"=\"small-spacer-tile\";}'"]
        }
        Shell.Parcer.OneExecutable.withNoOutput(exe: "defaults", args: arguments)
    }
    
    public func restartDock() {
        Shell.Parcer.OneExecutable.withNoOutput(exe: "killall", args: ["Dock"])
    }

    public func dockDefaults() {
        Shell.Parcer.OneExecutable.withNoOutput(exe: "defaults", args: ["delete", "com.apple.dock"])
        Shell.Parcer.OneExecutable.withNoOutput(exe: "killall", args: ["Dock"])
    }
    
    public var AnimationType: AnimationTypes {
        get {
            let val = getKeyValue(key: .typeOfAnimation)
            switch val {
            case "suck": return .suck
            case "scale": return .scale
            case "genie": return .genie
            default: return .genie
            }
        }
        set {
            switch newValue {
            case .genie: setKeyValue(key: .genie)
            case .suck: setKeyValue(key: .suck)
            case .scale: setKeyValue(key: .scale)
            }
        }
    }
    
    public var SingleAppMode: Bool {
        get {
            getKeyValue(key: .singleAppEnabled)
        }
        
        set {
            switch newValue {
            case true: setKeyValue(key: .singleAppEnabled)
            case false: setKeyValue(key: .singleAppDisabled)
            }
        }
    }
    
    public var AnimationSpeed: Int {
        get {
            getKeyValue(key: .animationSpeed)
        }
        
        set {
            setKeyValue(key: .animationSpeed, value: newValue)
        }
    }
    
    public var AnimationDelay: Int {
        get {
            getKeyValue(key: .popDelay)
        }
        set {
            setKeyValue(key: .popDelay, value: newValue)
        }
    }
    
    public var Autohide: Bool {
        get {
            getKeyValue(key: .autohideEnabled)
        }
        set {
            switch newValue {
            case true: setKeyValue(key: .autohideEnabled)
            case false: setKeyValue(key: .autohideDisabled)
            }
        }
    }
    
    public var Magnification: Bool {
        get {
            getKeyValue(key: .magnificationEnabled)
        }
        set {
            switch newValue {
            case true: setKeyValue(key: .magnificationEnabled)
            case false: setKeyValue(key: .magnificationDisabled)
            }
        }
    }
    
    public var DockOrientation: orientation {
        get {
            let v = getKeyValue(key: .orientation)
            switch v {
            case "left": return .left
            case "right": return .right
            case "bottom": return .bottom
            default: return .bottom
            }
        }
        set {
            switch newValue {
            case .left: setKeyValue(key: .left)
            case .right: setKeyValue(key: .right)
            case .bottom: setKeyValue(key: .bottom)
            }
        }
    }
    
    public var DiskArbitration: Bool {
        get {
            readDiskArbitration()
        }
        set {
            writeDiskArbitration(newValue)
        }
    }
    public var HiddenAppsMode: Bool {
        get {
            getKeyValue(key: .hiddenAppsGrayedOutEnabled)
        } set {
            switch newValue {
            case true : setKeyValue(key: .hiddenAppsGrayedOutEnabled)
            case false: setKeyValue(key: .hiddenAppsGrayedOutDisabled)
            }
        }
    }
}
