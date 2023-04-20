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
        let process = Process()
        let pipe = Pipe()
        process.standardOutput = pipe
        process.executableURL = URL(filePath: "/bin/bash")
        switch key {
        case .singleAppEnabled: process.arguments = ["-c", "defaults read com.apple.dock static-only -bool"]
        case .singleAppDisabled: process.arguments = ["-c", "defaults read com.apple.dock static-only -bool"]
        case .autohideEnabled: process.arguments = ["-c", "defaults read com.apple.dock autohide -bool"]
        case .autohideDisabled: process.arguments = ["-c", "defaults read com.apple.dock autohide -bool"]
        case .magnificationEnabled:
            process.arguments = ["-c", "defaults read com.apple.dock magnification -bool"]
        case .magnificationDisabled:
            process.arguments = ["-c", "defaults read com.apple.dock magnification -bool"]
        case .hiddenAppsGrayedOutEnabled:
            process.arguments = ["-c", "defaults read com.apple.dock showhidden -bool"]
        case .hiddenAppsGrayedOutDisabled:
            process.arguments = ["-c", "defaults read com.apple.dock showhidden -bool"]
        }
        do {
            try process.run()
            let ShellResult = try String(data: pipe.fileHandleForReading.readToEnd() ?? pipe.fileHandleForReading.availableData, encoding: .utf8)!
            let result = Int(String(ShellResult.replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: " ", with: "")))
            switch result {
            case 1: return true
            default: return false
            }
        } catch let error {
            NSLog(error.localizedDescription)
            process.terminate()
            return false
        }
    }
    
    private func getKeyValue(key: DockFloatKeys) -> Int {
        let process = Process()
        let pipe = Pipe()
        process.standardOutput = pipe
        process.executableURL = URL(filePath: "/bin/bash")
        switch key {
        case .animationSpeed: process.arguments = ["-c", "defaults read com.apple.dock autohide-time-modifier -float"]
        case .popDelay: process.arguments = ["-c", "defaults read com.apple.dock autohide-delay -float"]
        }
        do {
            try process.run()
            let ShellResult = try String(data: pipe.fileHandleForReading.readToEnd() ?? pipe.fileHandleForReading.availableData, encoding: .utf8)!
            let result = Float(String(ShellResult.replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: " ", with: ""))) ?? 0
            return Int(result * 100)
        } catch let error {
            NSLog(error.localizedDescription)
            process.terminate()
            return 0
        }
    }
    private func getKeyValue(key: DockStringKeys) -> String {
        let process = Process()
        let pipe = Pipe()
        process.standardOutput = pipe
        process.executableURL = URL(filePath: "/bin/bash")
        switch key {
        case .typeOfAnimation: process.arguments = ["-c", "defaults read com.apple.dock mineffect -string"]
        case .orientation:
            process.arguments = ["-c", "defaults read com.apple.dock orientation -string"]
        }
        do {
            try process.run()
            let ShellResult = try String(data: pipe.fileHandleForReading.readToEnd() ?? pipe.fileHandleForReading.availableData, encoding: .utf8)!
            let result = String(ShellResult.replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: " ", with: ""))
            return result
        } catch let error {
            NSLog(error.localizedDescription)
            process.terminate()
            return ""
        }
    }
    
    
    private func setKeyValue(key: DockBoolKeys) {
        let process = Process()
        let pipe = Pipe()
        process.standardOutput = pipe
        process.executableURL = URL(filePath: "/bin/bash")
        switch key {
        case .singleAppEnabled: process.arguments = ["-c", "defaults write com.apple.dock static-only -bool true"]
        case .singleAppDisabled: process.arguments = ["-c", "defaults write com.apple.dock static-only -bool false"]
        case .autohideDisabled: process.arguments = ["-c", "defaults write com.apple.dock autohide -bool false"]
        case .autohideEnabled: process.arguments = ["-c", "defaults write com.apple.dock autohide -bool true"]
        case .magnificationEnabled:
            process.arguments = ["-c", "defaults write com.apple.dock magnification -bool true"]
        case .magnificationDisabled:
            process.arguments = ["-c", "defaults write com.apple.dock magnification -bool false"]
        case .hiddenAppsGrayedOutEnabled:
            process.arguments = ["-c", "defaults write com.apple.dock showhidden -bool true"]
        case .hiddenAppsGrayedOutDisabled:
            process.arguments = ["-c", "defaults write com.apple.dock showhidden -bool false"]
        }
        do {
            try process.run()
        } catch let error {
            NSLog(error.localizedDescription)
            process.terminate()
        }
    }
    
    private func setKeyValue(key: DockFloatKeys, value: Int) {
        let process = Process()
        let pipe = Pipe()
        process.standardOutput = pipe
        process.executableURL = URL(filePath: "/bin/bash")
        switch key {
        case .animationSpeed: process.arguments = ["-c", "defaults write com.apple.dock autohide-time-modifier -float \(Float(value) / 100)"]
        case .popDelay: process.arguments = ["-c", "defaults write com.apple.dock autohide-delay -float \(Float(value) / 100)"]
        }
        do {
            try process.run()
        } catch let error {
            NSLog(error.localizedDescription)
            process.terminate()
        }
    }
    
    private func setKeyValue(key: orientation) {
        let process = Process()
        let pipe = Pipe()
        process.standardOutput = pipe
        process.executableURL = URL(filePath: "/bin/bash")
        switch key {
        case .right: process.arguments = ["-c", "defaults write com.apple.dock orientation right"]
        case .left: process.arguments = ["-c", "defaults write com.apple.dock orientation left"]
        case .bottom: process.arguments = ["-c", "defaults write com.apple.dock orientation bottom"]
        }
        do {
            try process.run()
        } catch let error {
            NSLog(error.localizedDescription)
            process.terminate()
        }
    }
    
    private func setKeyValue(key: AnimationTypes) {
        let process = Process()
        let pipe = Pipe()
        process.standardOutput = pipe
        process.executableURL = URL(filePath: "/bin/bash")
        switch key {
        case .suck: process.arguments = ["-c", "defaults write com.apple.dock mineffect -string suck"]
        case .genie: process.arguments = ["-c", "defaults write com.apple.dock mineffect -string genie"]
        case .scale: process.arguments = ["-c", "defaults write com.apple.dock mineffect -string scale"]
        }
        do {
            try process.run()
        } catch let error {
            NSLog(error.localizedDescription)
            process.terminate()
        }
    }
    
    private func writeDiskArbitration(_ enable: Bool) {
        if SettingsMonitor.passwordSaved {
            switch enable {
            case true: _ = Shell.Parcer.sudo("/bin/bash", ["-c", "sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.DiskArbitration.diskarbitrationd.plist DADisableEjectNotification -bool true && sudo pkill diskarbitrationd"], password: SettingsMonitor.password) as String
            case false:
                _ = Shell.Parcer.sudo("/bin/bash", ["-c", "sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.DiskArbitration.diskarbitrationd.plist DADisableEjectNotification -bool false && sudo pkill diskarbitrationd"], password: SettingsMonitor.password) as String
            }
        }
    }
    
    private func readDiskArbitration() -> Bool {
        let process = Process()
        let pipe = Pipe()
        var retval = false
        process.standardOutput = pipe
        process.executableURL = URL(filePath: "/bin/bash")
        process.arguments = ["-c", "defaults read /Library/Preferences/SystemConfiguration/com.apple.DiskArbitration.diskarbitrationd.plist"]
        do {
            try process.run()
            let shellResutl = try String(data: pipe.fileHandleForReading.readToEnd() ?? Data(), encoding: .utf8)
            for line in shellResutl!.components(separatedBy: "\n") {
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
        } catch let error {
            NSLog(error.localizedDescription)
            process.terminate()
            return retval
        }
        return retval
    }
    
    public func addSpacer(_ type: spacerType) {
        let process = Process()
        let pipe = Pipe()
        process.standardOutput = pipe
        process.executableURL = URL(filePath: "/bin/bash")
        switch type {
        case .wide: process.arguments = ["-c", "defaults write com.apple.dock persistent-apps -array-add '{tile-data={}; tile-type=\"spacer-tile\";}'"]
        case .narrow: process.arguments = ["-c", "defaults write com.apple.dock persistent-apps -array-add '{\"tile-type\"=\"small-spacer-tile\";}'"]
        }
        do {
            try process.run()
        } catch let error {
            NSLog(error.localizedDescription)
            process.terminate()
        }
    }
    
    public func restartDock() {
        let process = Process()
        let pipe = Pipe()
        process.standardOutput = pipe
        process.executableURL = URL(filePath: "/bin/bash")
        process.arguments = ["-c", "killall Dock"]
        do {
            try process.run()
        } catch let error {
            NSLog(error.localizedDescription)
            process.terminate()
        }
    }

    public func dockDefaults() {
        let process = Process()
        let pipe = Pipe()
        process.standardOutput = pipe
        process.executableURL = URL(filePath: "/bin/bash")
        process.arguments = ["-c", "defaults delete com.apple.dock; killall Dock"]
        do {
            try process.run()
        } catch let error {
            NSLog(error.localizedDescription)
            process.terminate()
        }
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
