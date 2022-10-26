//
//  HomeBrew.swift
//  TORVpn
//
//  Created by Олег Сазонов on 06.06.2022.
//

import Foundation

/// Installs HomeBrew
public class HomeBrew: xCore {
    public override init() {
        print("init")
        switch HomeBrew.isInstalled {
        case true: break
        case false: HomeBrew.installBrew()
        }
    }
    deinit {
        HomeBrew.process = nil
        HomeBrew.mainPipe = nil
        HomeBrew.inPipe = nil
        print("deinit")
    }
    
    private static  var installDirectory: URL? {
        get {
            let newInDir = "/opt/homebrew/bin/brew"
            let oldInDir = "/usr/local/bin/brew"
            if FileManager.default.fileExists(atPath: newInDir) {
                return URL(fileURLWithPath: newInDir)
            } else if FileManager.default.fileExists(atPath: oldInDir) {
                return URL(fileURLWithPath: oldInDir)
            } else {
                return nil
            }
        }
    }
    public  static  var isInstalled: Bool {
        get {
            switch installDirectory {
            case .none:
                return false
            case .some(_):
                return true
            }
        }
        set {}
    }
    private static var process: Process?
    private static var mainPipe: Pipe?
    private static var inPipe: Pipe?
    
    private class func installBrew() {
        process = Process()
        mainPipe = Pipe()
        process?.arguments = ["-c", "/bin/bash -c \"$(/usr/bin/curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""]
        process?.executableURL = URL(fileURLWithPath: "/bin/bash")
        process?.standardOutput = mainPipe
//        process?.standardInput = mainPipe
//        process?.standardError = mainPipe
        do {
            try process?.run()
            process?.waitUntilExit()
            let handler = mainPipe?.fileHandleForReading
            handler?.readabilityHandler = { pipe in
                if let line = String(data: pipe.availableData, encoding: .utf8) {
                    if line.contains("assword") {
                        mainPipe?.fileHandleForWriting.writeabilityHandler = { wr in
                            wr.write(String(SettingsMonitor.password).data(using: .utf8)!)
                            wr.write(String("\n").data(using: .utf8)!)
                        }
                    }
                }
            }
        } catch let error {
            NSLog(error.localizedDescription)
        }
    }
}
