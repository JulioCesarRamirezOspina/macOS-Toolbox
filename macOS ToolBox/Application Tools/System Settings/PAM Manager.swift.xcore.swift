//
//  PAM Manager.swift
//  xCore
//
//  Created by Олег Сазонов on 23.01.2023.
//  Copyright © 2023 ~X~ Lab. All rights reserved.
//

import Foundation
import SwiftUI

public class PAMManager {
    
   public class SystemAuthData {
       
       public func localizedErrorReturner(_ errno: Int) -> String {
           
           let notInstalled = """
       !!!!!!!!!!!!!!!!!!!!!!!!!
       !!!!!!!!ATTENTION!!!!!!!!
       !!!!!!!!!!!!!!!!!!!!!!!!!
       
       Required software is not installed!
       Please insert Your key do the following in Terminal:
       1. brew install pam-u2f
       2. mkdir -p ~/.config/Yubico/
       3. pamu2fcfg > ~/.config/Yubico/u2f_keys
       MAKE SURE TO FOLLOW THESE INSTRUCTION CORRECTLY
       OTHERWISE THIS PROGRAM WILL NOT WORK
       """
           
           
           
           switch errno {
           case 1: return notInstalled
           default: return ""
           }
       }       
       
       public init() {
           self.pamLibLocationInOpt = {
               var retval: String? = nil
               if let out: String = Shell.Parcer.OneExecutable.withOptionalString(exe: "find", args: ["/opt", "-name", "pam_u2f.so"]) {
                   out.split(separator: "\n").forEach { line in
                       if !line.contains("find: /opt: No such file or directory") {
                           retval = String(out.replacingOccurrences(of: "\n", with: ""))
                       }
                   }
               }
               return retval
           }()
            
            self.sudoContents = {
                let data = FileManager.default.contents(atPath: "/etc/pam.d/sudo")
                let sudoText = String(data: data!, encoding: .utf8) ?? ""
                var state: pamTask = .disable
                sudoText.split(separator: "\n").forEach { line in
                    if line.contains(pamLibLocationInOpt ?? "asdasdasd") {
                        state = .enable
                    }
                }
                return (contents: sudoText, state: state)
            }()
            
            self.screensaverContents = {
                let data = FileManager.default.contents(atPath: "/etc/pam.d/screensaver")
                let sudoText = String(data: data!, encoding: .utf8) ?? ""
                var state: pamTask = .disable
                sudoText.split(separator: "\n").forEach { line in
                    if line.contains(pamLibLocationInOpt ?? "asdasdasd") {
                        state = .enable
                    }
                }
                return (contents: sudoText, state: state)
            }()
            
            self.enabled = {
                let mutualState = (sudo: sudoContents.state, screensaver: screensaverContents.state)
                switch mutualState {
                case (.enable, .enable) : return .both
                case (.enable, .disable) : return .sudo
                case (.disable, .enable) : return .screensaver
                case (.disable, .disable) : return .neither
                }
            }()
        }
        public var pamLibLocationInOpt: String? = nil
        
        public var sudoContents: (contents: String, state: pamTask) = ("", .disable)
        public var screensaverContents: (contents: String, state: pamTask) = ("", .disable)
        public var enabled: pamWhatIsEnabled = .neither
        
        public func notInstalled() -> Bool {
            let path = URL.homeDirectory.path(percentEncoded: false) + ".config/Yubico/u2f_keys"
            return !FileManager.default.isReadableFile(atPath: path) || pamLibLocationInOpt == nil
        }
        
        func inRange(_ i: Int, rang: ClosedRange<Int>) -> Bool {
            return i >= rang.lowerBound && i <= rang.upperBound
        }
        
        public func edit(_ task: pamTask, _ file: pamFile, _ password: String) {
            let f = file == .screensaver ? screensaverContents : sudoContents
            let lineToAdd = "auth       \(file == .sudo ? "sufficient" : "required  ")     \(pamLibLocationInOpt!)"
            switch task {
            case .enable:
                if f.state == .disable {
                    var index = 0
                    for line in (file == .sudo ? sudoContents : screensaverContents).contents.split(separator: "\n") {
                        if !line.contains("pam_opendirectory.so") {
                            index += 1
                        } else {
                            break
                        }
                    }
                    var array: [String] {
                        get {
                            var indexSelf = 0
                            var retval: [String] = []
                            f.contents.split(separator: "\n").forEach { line in
                                if indexSelf == index {
                                    retval.append(lineToAdd)
                                    retval.append(line.description)
                                } else {
                                    retval.append(line.description)
                                }
                                indexSelf += 1
                            }
                            return retval
                        }
                    }
                    var textToWrite = ""
                    array.forEach { line in
                        textToWrite += line + "\n"
                    }
                    FileManager().createFile(atPath: "/tmp/\(file == .sudo ? "sudo" : "screensaver")", contents: textToWrite.data(using: .utf8))
                    _ = Shell.Parcer.SUDO.withString("/bin/cp", ["/tmp/\(file == .sudo ? "sudo" : "screensaver")", "/etc/pam.d/\(file == .sudo ? "sudo" : "screensaver")"], password: password) as String
                    do {
                        try FileManager().removeItem(atPath: "/tmp/\(file == .sudo ? "sudo" : "screensaver")")
                    } catch let error {
                        NSLog(error.localizedDescription)
                    }
                }
            case .disable:
                if (file == .sudo ? sudoContents : screensaverContents).state == .enable {
                    var temp = ""
                    (file == .sudo ? sudoContents : screensaverContents).contents.split(separator: "\n").forEach { line in
                        if !line.contains(pamLibLocationInOpt!) {
                            temp += line + "\n"
                        }
                    }
                    FileManager().createFile(atPath: "/tmp/\(file == .sudo ? "sudo" : "screensaver")", contents: temp.data(using: .utf8))
                    _ = Shell.Parcer.SUDO.withString("/bin/cp", ["/tmp/\(file == .sudo ? "sudo" : "screensaver")", "/etc/pam.d/\(file == .sudo ? "sudo" : "screensaver")"], password: password) as String
                    do {
                        try FileManager().removeItem(atPath: "/tmp/\(file == .sudo ? "sudo" : "screensaver")")
                    } catch let error {
                        NSLog(error.localizedDescription)
                    }
                }
            }
            print("\(file == .sudo ? "Sudo" : "Screensaver") auth \(task == .enable ? "enabled" : "disabled")")
        }
        func checkInput(_ input: String) -> Bool {
            return Int(input) != nil && inRange(Int(input)!, rang: (enabled == .both || enabled == .neither ? 1...3 : 1...4))
        }
   }
    
    //MARK: - "/etc/pam.d/sudo" file processing
    //MARK: Public
    /// This class checks for existance of custom entry in '/etc/pam.d/sudo' which invokes TouchID prior to password.
    public class TouchID {
        //MARK: - Constant
        //MARK: Private
        private let stringToAdd = "auth       sufficient     pam_tid.so"
        
        //MARK: - Functions
        //MARK: Private
        /// Gets contents of "/etc/pam.d/sudo"
        /// - Returns: String representation of file contents
        private var tid: String {
            get {
                do {
                    return try String(contentsOfFile: "/etc/pam.d/sudo", encoding: .utf8)
                } catch _ {
                    return ""
                }
            }
        }
        
        /// Writes data to file
        /// - Parameters:
        ///   - input: used mainly for adding 'auth       sufficient     pam_tid.so' to sudo file
        ///   - password: sudo password
        private func writeToFile(_ input: String, _ password: String) {
            let fm = FileManager()
            fm.createFile(atPath: "/tmp/sudo", contents: input.data(using: .utf8), attributes: [:])
            _ = Shell.Parcer.SUDO.withString("/bin/cp", ["/tmp/sudo", "/etc/pam.d/sudo"], password: password) as String
            do {
                try fm.removeItem(atPath: "/tmp/sudo")
            } catch let error {
                NSLog(error.localizedDescription)
            }
        }
        
        /// Generates enabling TouchID string to add into pam.d/sudo file
        /// - Returns: Complete contents of existing file with addition of enabling string
        private func addToPam() -> String {
            var retval = ""
            switch analyzePam_d() {
            case false:
                let firstLine = "# sudo: auth account password session"
                let secondLine = stringToAdd
                let theRest = tid.replacingOccurrences(of: firstLine, with: "")
                retval = firstLine + "\n" + secondLine + theRest
            case true: break
            }
            return retval
        }
        
        /// Generates disabling TouchID string to remove from pam.d/sudo file
        /// - Returns: Complete contents of existing file without addition of enabling string
        private func removeFromPam() -> String {
            var retvalComplete = ""
            switch analyzePam_d(){
            case true: retvalComplete = tid.replacingOccurrences(of: stringToAdd, with: "")
            case false: break
            }
            let retval = retvalComplete.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: .newlines).filter{!$0.isEmpty}.joined(separator: "\n")
            return retval
        }

        //MARK: - Functions
        //MARK: Public
        
        /// Switches state of TouchID: enables it prior to password input and vice versa
        /// - Parameter password: sudo (superuser) password
        public func switchState(_ password: String) -> Void {
            switch analyzePam_d() {
            case true: writeToFile(removeFromPam(),password)
            case false: writeToFile(addToPam(),password)
            }
        }
        
        
        /// Analyzes "/etc/pam.d/sudo" file and returns true or false
        /// - Returns: "true" if TouchID is enables and "false" if not
        public func analyzePam_d() -> Bool {
            let pam_d = tid
            switch pam_d.contains(stringToAdd) {
            case true : return true
            case false : return false
            }
        }
        
        /// Returns localized description (string in Localizations file) whether TouchID is enables
        /// - Returns: Localized string
        public func localizedDescriptionOfPam() -> String {
            let status = analyzePam_d()
            switch status {
            case true: return NSLocalizedString("enabled.string", comment: "")
            case false: return NSLocalizedString("disabled.string", comment: "")
            }
        }
        
        //MARK: - Initializer
        public init() {}
    }
}
