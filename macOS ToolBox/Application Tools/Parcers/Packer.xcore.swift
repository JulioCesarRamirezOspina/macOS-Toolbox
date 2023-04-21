//
//  Packer.swift
//  MultiTool
//
//  Created by Олег Сазонов on 19.06.2022.
//

import Foundation
import Combine
import AppKit

/// Packs app into PKG
public class Packer {
    private class func cutNAdd(_ str: String) -> String {
        var retval = str
        while retval.last != "." {
            retval = String(retval.dropLast())
        }
        retval = String(retval.dropLast())
        return retval + ".pkg"
    }
    
    /// Open file location in Finder
    /// - Parameter filePath: Path to file
    public class func openFileLocation(_ filePath: String) {
        Shell.Parcer.OneExecutable.withNoOutput(exe: "open", args: [filePath])
    }
    
    /// RUN FUNC
    /// - Parameters:
    ///   - iPath: Install path
    ///   - app: App name
    ///   - saveLoc: Save location
    ///   - pkgName: PKG name
    ///   - password: sudo password
    public class func run(_ iPath: String, _ app: String, _ saveLoc: String, _ pkgName: String, _ password: String) {
        let processingString = saveLoc + "/" + pkgName
        let outputFile = cutNAdd(processingString)
        
        Shell.Parcer.OneExecutable.withNoOutput(args: ["echo \(SettingsMonitor.password) | sudo -S /usr/bin/pkgbuild --install-location \"\(iPath)\" -- component \(app), \(outputFile)"])
    }
    
    /// Signs PKG
    /// - Parameters:
    ///   - saveLoc: PKG save location
    ///   - pkgName: PKG name
    ///   - devID: Developer Installer ID
    ///   - password: sudo password
    public class func SignPackage(_ saveLoc: String, _ pkgName: String, devID: String, _ password: String) {
        let tempDir = "/Users/Shared"
        let ps1 = cutNAdd(tempDir + "/" + pkgName)
        let ps2 = cutNAdd(saveLoc + "/" + pkgName)
        Shell.Parcer.OneExecutable.withNoOutput(args: ["echo \(password) | sudo -S mv \"\(ps2)\" \"\(ps1)\" && productsign --sign \"Developer ID Installer: \(devID)\" \"\(ps1)\" \"\(ps2)\" && echo \(password) | sudo -S rm \"\(ps1)\""])
    }
}
