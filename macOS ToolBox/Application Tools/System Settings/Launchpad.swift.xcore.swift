//
//  Launchpad.swift
//  SuperStuff
//
//  Created by Олег Сазонов on 08.07.2022.
//

import Foundation

public class LaunchpadManager {
    public init(){}
    deinit{}
    public func reset() {
        Shell.Parcer.oneExecutable(exe: "defaults", args: ["write", "com.apple.dock", "ResetLaunchPad", "-bool", "TRUE"]) as Void
    }
    
    public func setCoord(_ coord: Coord, _ value: Float) {
        switch coord {
        case .x: _ = Shell.Parcer.oneExecutable(exe: "defaults", args: ["write", "com.apple.dock", "springboard-columns", "-int", "\(value)"]) as Void
        case .y: _ = Shell.Parcer.oneExecutable(exe: "defaults", args: ["write", "com.apple.dock", "springboard-rows", "-int", "\(value)"]) as Void
        }
    }
    
    public func getCoord(_ coord: Coord) -> Float {
        var args = [String]()
        switch coord {
        case .y: args = ["read", "com.apple.dock", "springboard-rows", "-int"]
        case .x: args = ["read", "com.apple.dock", "springboard-columns", "-int"]
        }
        let ShellResult: String = Shell.Parcer.oneExecutable(exe: "defaults", args: args) ?? ""
        guard let result = Float(String(ShellResult.replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: " ", with: ""))) else {
            switch coord {
            case .x: return 7
            case .y: return 5
            }
        }
        return result
    }
}
