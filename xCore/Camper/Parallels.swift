//
//  Parallels.swift
//  BootCamper
//
//  Created by Олег Сазонов on 03.01.2022.
//

import Foundation
import SwiftUI

//MARK: - Parallels
//MARK: Public
/// Managing and launching Parallels VMs
public class Parallels: xCore {
    //MARK: - Functions
    //MARK: Private

    /// For internal use, creates array of vm# = address
    private class func createDickURL() -> [String : URL] {
        let list = getVMList()
        var dick = Dictionary<String, URL>()
        var count = 0
        for each in list {
            dick["vm\(count)"] = each
            count += 1
        }
        return dick
    }
    //MARK: - Functions
    //MARK: Public

    /// Gets list of Parallels virtual machines in given directory
    /// - Returns: Array of addresses of VMs
    public class func getVMList() -> [URL] {
        var contents = [URL(fileURLWithPath: "")]
        let pFolder = SettingsMonitor.parallelsDir
        do {
            contents = try FileManager.default.contentsOfDirectory(at: pFolder, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
        } catch _ {}
        var retval = [String()]
        retval = retval.dropLast()
        for each in contents {
            retval.append(String("\(each)"))
        }
        return contents
    }
    
    /// Returnes dictionary of
    /// - Returns: Dictionary of vm# = Humanized name
    public class func returnVMHumanizedDictionary() -> [String : String] {
        let list = getVMList()
        var dick = Dictionary<String, String>()
        var count = 0
        for each in list {
            let vmName = each.lastPathComponent.split(separator: ".")
            if vmName.last == "pvm" {
                dick["vm\(count)"] = String("\(vmName.first!)")
                count += 1
            }
        }
        return dick
    }
    
    /// Checks if VMs are exist
    /// - Returns: "true" if exist, "false" if not
    public class func vmExists() -> Bool {
        switch returnVMHumanizedDictionary().isEmpty || returnVMHumanizedDictionary().values.first! == "/" {
        case false: return true
        case true: return false
        }
    }
    
    /// Launches cjosen VM
    /// - Parameters:
    ///   - key: vm# of VM to get address
    ///   - quit: if true, application quit on launch of VM, else not
    public class func launchVM(key: String, quit: Bool) {
        let filePath = createDickURL()[key]
        NSWorkspace.shared.open(filePath!)
        if quit {
            exit(0)
        }
    }
    
    /// Opens Finder window where VM contains
    /// - Parameter key: vm# of VM to get address
    /// - Returns: Button with action "Show in Finder" and localized description on button
    public class func showInFinder(_ key: String) -> AnyView {
        let filePath = createDickURL()[key]
        let retval = AnyView(Button {
            NSWorkspace.shared.activateFileViewerSelecting([filePath!])
        } label: {
            Text("finder.text")
        }.padding())
        return retval
    }
    //MARK: - Initializer
    public override init() {}
}
