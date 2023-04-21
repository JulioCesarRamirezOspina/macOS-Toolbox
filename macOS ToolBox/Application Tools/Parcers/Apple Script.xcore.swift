//
//  Apple Script.swift
//  BootCamper
//
//  Created by Олег Сазонов on 03.01.2022.
//

import Foundation

//MARK: - AppleScript Processing
//MARK: Public
/// Parces and executes AppleScript I/O
public class ScriptProcessing {
    //MARK: - Value
    //MARK: Private
    static private var error: NSDictionary?
    
    //MARK: - Functions
    //MARK: Public
    /// Launches AppleScript
    /// - Parameter script: AppleScript ONELINER
    public class func launcher(script: String) {
        if let oaScript = NSAppleScript(source: script) {
            if let outputString = oaScript.executeAndReturnError(&error).stringValue {
                print(outputString)
            } else if (error != nil) {
                print("error: ", error!)
            }
        }
    }
    
    /// Launches AppleScript
    /// - Parameter script: AppleScript ONELINER
    /// - Returns: Value returned from AppleScript
    public class func returner(script: String) -> String {
        var output: String?
        if let oaScript = NSAppleScript(source: script) {
            if let outputString = oaScript.executeAndReturnError(&error).stringValue {
                print(outputString)
                output = outputString
            } else if (error != nil) {
                print("error: ", error!)
                output = "\(error!)"
            }
        }
        return output!
    }
    //MARK: - Initizlizer
    public init() {}
}
