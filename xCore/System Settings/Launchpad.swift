//
//  Launchpad.swift
//  SuperStuff
//
//  Created by Олег Сазонов on 08.07.2022.
//

import Foundation

public class LaunchpadManager: xCore {
    public override init(){}
    deinit{}
    public func reset() {
        _ = Shell.Parcer.oneExecutable(exe: "/usr/bin/defaults", args: ["write", "com.apple.dock", "ResetLaunchPad", "-bool", "TRUE"]) as Void
    }
    
    public func setCoord(_ coord: Coord, _ value: Float) {
        switch coord {
        case .x: _ = Shell.Parcer.oneExecutable(exe: "/usr/bin/defaults", args: ["write", "com.apple.dock", "springboard-columns", "-int", "\(value)"]) as Void
        case .y: _ = Shell.Parcer.oneExecutable(exe: "/usr/bin/defaults", args: ["write", "com.apple.dock", "springboard-rows", "-int", "\(value)"]) as Void
        }
    }
    
    public func getCoord(_ coord: Coord) -> Float {
        let process = Process()
        let pipe = Pipe()
        process.standardOutput = pipe
        process.executableURL = URL(filePath: "/bin/bash")
        switch coord {
        case .y: process.arguments = ["-c", "defaults read com.apple.dock springboard-rows -int"]
        case .x: process.arguments = ["-c", "defaults read com.apple.dock springboard-columns -int"]
        }
        do {
            try process.run()
            let ShellResult = try String(data: pipe.fileHandleForReading.readToEnd() ?? pipe.fileHandleForReading.availableData, encoding: .utf8)!
            guard let result = Float(String(ShellResult.replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: " ", with: ""))) else {
                switch coord {
                case .x: return 7
                case .y: return 5
                }
            }
            return result
        } catch let error {
            NSLog(error.localizedDescription)
            process.terminate()
            switch coord {
            case .x: return 7
            case .y: return 5
            }
        }
    }
}
