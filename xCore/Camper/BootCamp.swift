//
//  BootCamp.swift
//  BootCamper
//
//  Created by Олег Сазонов on 03.01.2022.
//

import Foundation
import SwiftUI

//MARK: - BootCamp
//MARK: Public
/// BootCamp manager
public class BootCampStart: xCore {
    //MARK: - Functions
    //MARK: Private
    /// Gets UUID of BootCamp volume from dictionary
    /// - Parameter diskLabel: Disk name
    /// - Returns: Value for key in dictionary
    private class func getBootCampVolume(diskLabel: String) -> String {
        let volumes = getMountedDisks()
        var retval = ""
        for each in volumes {
            if each.value == diskLabel {
                retval = each.key
                break
            }
        }
        return retval
    }
    
    /// Uses AppleScript to safely reboot Mac
    private class func reboot() {
        ScriptProcessing.launcher(script: "tell application \"Finder\" to restart")
    }
    
    //MARK: - Functions
    //MARK: Public
    /// Gets mounted disks
    /// - Returns: Dictionary of id and Name of disk
    public class func getMountedDisks() -> [String : String] {
        var diskProps = [(String(), String())]
        var bsdString = String()
        var retval = [String() : String()]
        if let session = DASessionCreate(kCFAllocatorDefault) {
            let mountedVolumeURLs = FileManager.default.mountedVolumeURLs(includingResourceValuesForKeys: [.volumeNameKey], options: .skipHiddenVolumes)!
            for volumeURL in mountedVolumeURLs {
                if let disk = DADiskCreateFromVolumePath(kCFAllocatorDefault, session, volumeURL as CFURL),
                   let bsdName = DADiskGetBSDName(disk) {
                    bsdString = String(cString : bsdName)
                }
                if bsdString != "" {
                    diskProps.append((volumeURL.path, bsdString))
                }
            }
        }
        for each in diskProps {
            let diskID = each.1
            let diskLabel = URL(fileURLWithPath: each.0).lastPathComponent
            retval[diskID] = diskLabel
        }
        for each in retval {
            if each.value == "" || each.value == "/" {
                retval.removeValue(forKey: each.key)
            }
        }
        return retval
    }
    
    private class func checkIfNodeExists(_ node: String) -> Bool {
        var retval = false
        if let session = DASessionCreate(kCFAllocatorDefault) {
            let mountedVolumeURLs = FileManager.default.mountedVolumeURLs(includingResourceValuesForKeys: [.volumeNameKey], options: .skipHiddenVolumes)!
            for volumeURL in mountedVolumeURLs {
                if let disk = DADiskCreateFromVolumePath(kCFAllocatorDefault, session, volumeURL as CFURL),
                   let bsdName = DADiskGetBSDName(disk) {
//                    print(bsdName)
                    if node == String(cString: bsdName) {
                        retval = true
                    }
                }
            }
        }
        return retval
    }

    /// Checks if given disk (set) exists and ready to launch
    /// - Parameter diskLabel: Name of disk
    /// - Returns: "true" if exists, "false" if not
    public class func bcExists(_ diskLabel: String) -> Bool {
        let val = getBootCampVolume(diskLabel: diskLabel)
        switch val.isEmpty {
        case false: return true
        case true: return false
        }
    }
    
    /// Creates one button with pretty complex function
    /// - Parameters:
    ///   - diskLabel: Name of disk
    ///   - password: sudo password
    ///   - nextOnly: If "true" only next Mac start will use BootCamp volume
    ///   - isReboot: If "true" Mac will reboot immediately
    /// - Returns: Just a button
    public class func setBootDevice(diskLabel: String, password: String, nextOnly: Bool, isReboot: Bool) -> some View {
        let exe = "/usr/sbin/bless"
        var args: String
        var retval : AnyView
        if !tryToMount(diskLabel: diskLabel, password: password) {
            let node = getBootCampVolume(diskLabel: diskLabel)
            let tempNode = node.dropLast()
            let lastFromNode = Int(String(node.last!))
            var trueNode = String(tempNode) + String(lastFromNode! - 1)
            if checkIfNodeExists(trueNode) {
                trueNode = String(tempNode) + String(lastFromNode! - 1)
            } else {
                trueNode = String(tempNode) + String(lastFromNode!)
            }
            if getOSType(diskLabel: diskLabel).OSType == "Windows" {
                trueNode = "disk0s1"
            }
            switch nextOnly {
            case true:
                args = "-device /dev/\(trueNode) -mount /Volumes/EFI -setBoot -nextonly"
            case false:
                args = "-device /dev/\(trueNode) -mount /Volumes/EFI -setBoot"
            }
            let label = StringLocalizer("setDevice1.button") + "\n" + diskLabel + "\n" + StringLocalizer("setDevice2.button")
            retval = AnyView(Button(action: {
                let process = Process()
                process.executableURL = URL(filePath: "/bin/bash")
                process.arguments = ["-c", "echo \(SettingsMonitor.password) | sudo -S \(exe) \(args)"]
                do {
                    try process.run()
                } catch let error {
                    NSLog(error.localizedDescription)
                }
                if isReboot {
                    DispatchQueue.main.async {
                        exit(0)
                    }
                    reboot()
                }
            }, label: {
                Text(label).lineLimit(Int(4), reservesSpace: true)
            }))
        } else {
            retval = AnyView(Button("noDisk.button", action: {print("")}).disabled(true))
        }
        return retval
    }
    
    /// Checks for BootCamp volume to be mounted
    /// - Parameters:
    ///   - diskLabel: Name of disk
    ///   - password: sudo password
    /// - Returns: "true" on mount success
    public class func tryToMount(diskLabel: String, password: String) -> Bool {
        let val: String = (Shell.Parcer.sudo("/usr/sbin/diskutil", ["mount", diskLabel], password: password))
        var retval = Bool()
        if val != "Failed to find disk \(diskLabel)\n" {
            retval = false
        } else {
            retval = true
        }
        return retval
    }
    
    fileprivate class func localizer(_ str: String) -> String {
        return NSLocalizedString(str, comment: "")
    }

    
    /// VERY experimental func, gets OS type
    /// - Parameter diskLabel: Disk name
    /// - Returns: "Windows", "Linux" or "macOS"
    public class func getOSType(diskLabel: String) -> (OSType: String, canBoot: Bool) {
        let installerNames = ["Install macOS Monterey.app", "Install macOS Mojave.app", "Install macOS Big Sur.app","Install macOS Catalina.app","Install macOS High Sierra.app","Install OS X El Capitan.app"]
        let windows = "/Volumes/\(diskLabel)/Windows/System32"
        let macOS = "/Volumes/\(diskLabel)/System/Library/Kernels/"
        var isDirectory = ObjCBool(true)
        var isFile = ObjCBool(false)
        var retval = ("", false)
        for each in installerNames {
            if FileManager.default.fileExists(atPath: windows, isDirectory: &isDirectory) {
                retval = ("Windows", true)
                break
            } else if FileManager.default.fileExists(atPath: macOS, isDirectory: &isDirectory) {
                retval = ("macOS", true)
                break
            } else if FileManager.default.fileExists(atPath: "/Volumes/\(diskLabel)/\(each)", isDirectory: &isFile){
                retval = ("macOS Installer", true)
                break
            } else if FileManager.default.fileExists(atPath: "/Volumes/\(diskLabel)/Finish Installation.app"){
                retval = ("Linux", true)
                break
            } else {
                retval = ("\(localizer("undefined.string"))", false)
                break
            }
        }
        return retval
    }
    //MARK: - Initizlizer
    public override init() {}
}
