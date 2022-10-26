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
public class Packer: xCore {
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
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/open")
        process.arguments = [filePath]
        do {
            try process.run()
        } catch let error {
            NSLog(error.localizedDescription)
        }
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
        
        let taskOne = Process()
        taskOne.executableURL = URL(fileURLWithPath: "/bin/echo")
        taskOne.arguments = [password]
        
        let taskTwo = Process()
        taskTwo.executableURL = URL(fileURLWithPath: "/usr/bin/sudo")
        taskTwo.arguments = ["-S","/usr/bin/pkgbuild","--install-location", iPath, "--component", app, outputFile]
        
        let pipeBetween:Pipe = Pipe()
        taskOne.standardOutput = pipeBetween
        taskTwo.standardInput = pipeBetween
        
        let pipeToMe = Pipe()
        taskTwo.standardOutput = pipeToMe
        taskTwo.standardError = pipeToMe
        
        do {
            try taskOne.run()
            try taskTwo.run()
        } catch let error {
            print(error.localizedDescription)
        }
        
        let data = pipeToMe.fileHandleForReading.readDataToEndOfFile()
        let _ : String = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String
//        print(output)
    }
    
    /// Signs PKG
    /// - Parameters:
    ///   - saveLoc: PKG save location
    ///   - pkgName: PKG name
    ///   - devID: Developer Installer ID
    ///   - password: sudo password
    public class func SignPackage(_ saveLoc: String, _ pkgName: String, devID: String, _ password: String) {
        let process = Process()
        let tempDir = "/Users/Shared"
        let ps1 = cutNAdd(tempDir + "/" + pkgName)
        let ps2 = cutNAdd(saveLoc + "/" + pkgName)
        process.standardOutput = nil
        process.executableURL = URL(filePath: "/usr/bin/env")
        process.arguments = ["bash", "-c", "echo \(password) | sudo -S mv \"\(ps2)\" \"\(ps1)\" && productsign --sign \"Developer ID Installer: \(devID)\" \"\(ps1)\" \"\(ps2)\" && echo \(password) | sudo -S rm \"\(ps1)\""]
        do {
            try process.run()
        } catch let error {
            NSLog(error.localizedDescription)
        }
    }

}
