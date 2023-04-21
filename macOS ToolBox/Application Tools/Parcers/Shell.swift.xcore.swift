//
//  Shell.swift
//  TORVpn
//
//  Created by Олег Сазонов on 05.06.2022.
//

import Foundation

public class Shell {
    //MARK: - Shell Script Parcer
    //MARK: Public
    /// Parces and executes shell I/O
    public class Parcer {
        //MARK: - Functions
        //MARK: Public
        /// Can execute pipe
        /// - Parameters:
        ///   - firstExe: unix-path to first executable
        ///   - secondExe: unix-path to second executable
        ///   - firstArgs: first executable args
        ///   - secondArgs: second executable args
        /// - Returns: command output
        public class func twoExecutables(firstExe: String, secondExe: String, firstArgs: [String], secondArgs: [String]) -> String {
            let taskOne = Process()
            taskOne.executableURL = URL(fileURLWithPath: firstExe)
            taskOne.arguments = firstArgs
            
            let taskTwo = Process()
            taskTwo.executableURL = URL(fileURLWithPath: secondExe)
            taskTwo.arguments = secondArgs
            
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
                NSLog(error.localizedDescription)
            }
            
            let data = pipeToMe.fileHandleForReading.readDataToEndOfFile()
            let output : String = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String
            return output
        }
        /// Can execute pipe
        /// - Parameters:
        ///   - firstExe: unix-path to first executable
        ///   - secondExe: unix-path to second executable
        ///   - firstArgs: first executable args
        ///   - secondArgs: second executable args
        public class func twoExecutables(firstExe: String, secondExe: String, firstArgs: [String], secondArgs: [String]) -> Void {
            let taskOne = Process()
            taskOne.executableURL = URL(fileURLWithPath: firstExe)
            taskOne.arguments = firstArgs
            
            let taskTwo = Process()
            taskTwo.executableURL = URL(fileURLWithPath: secondExe)
            taskTwo.arguments = secondArgs
            
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
                NSLog(error.localizedDescription)
            }
        }
        
        private static let exePath = URL(filePath: "/bin/bash")
        /// Executes one shell command
        /// - Parameters:
        ///   - exe: path to executable
        ///   - args: args of executable
        /// - Returns: console output
        public class func oneExecutable(exe: String? = nil, args: [String]) -> String? {
            var propExe: URL? = nil
            if exe != nil {
                propExe = RunnerForTorNetworks().getAppPath(exe!)
            }
            let process = Process()
            var output: String? = nil
            let pipe = Pipe()
            var arguments = String()
            args.forEach { arg in
                arguments += (arg + " ")
            }
            let runLine = String(propExe == nil ? arguments : propExe!.path(percentEncoded: false) + " " + arguments).dropLast().description
#if DEBUG
            print("-\(runLine)-")
#endif
            process.executableURL = exePath
            process.arguments = ["-c", runLine]
            process.standardOutput = pipe
            do {
                try process.run()
                if let prep = try pipe.fileHandleForReading.readToEnd() {
                    if let string = String(data: prep, encoding: .utf8) {
                        output = string
                    }
                }
            } catch let error {
                process.interrupt()
                NSLog(error.localizedDescription)
            }
            return output
        }
        
        public class func oneExecutable(exe: String? = nil, args: [String]) -> (success: String?, error: String?) {
            var propExe: URL? = nil
            if exe != nil {
                propExe = RunnerForTorNetworks().getAppPath(exe!)
            }
            let process = Process()
            var output: String? = nil
            var error: String? = nil
            let pipe = Pipe()
            let errorPipe = Pipe()
            var arguments = String()
            args.forEach { arg in
                arguments += (arg + " ")
            }
            let runLine = String(propExe == nil ? arguments : propExe!.path(percentEncoded: false) + " " + arguments).dropLast().description
#if DEBUG
            print("-\(runLine)-")
#endif
            process.executableURL = exePath
            process.arguments = ["-c", runLine]
            process.standardOutput = pipe
            process.standardError = errorPipe
            do {
                try process.run()
                if let prep = try pipe.fileHandleForReading.readToEnd() {
                    if let string = String(data: prep, encoding: .utf8) {
                        output = string
                    }
                }
                if let err = try errorPipe.fileHandleForReading.readToEnd() {
                    if let string = String(data: err, encoding: .utf8) {
                        error = string
                    }
                }
            } catch let error {
                process.interrupt()
                NSLog(error.localizedDescription)
            }
            return (output, error)
        }
        
        /// Executes one shell command
        /// - Parameters:
        ///   - exe: path to executable
        ///   - args: args of executable
        public class func oneExecutable(exe: String? = nil, args: [String]) {
            var propExe: URL? = nil
            if exe != nil {
                propExe = RunnerForTorNetworks().getAppPath(exe!)
            }
            let process = Process()
            let pipe = Pipe()
            var arguments = String()
            args.forEach { arg in
                arguments += (arg + " ")
            }
            let runLine = String(propExe == nil ? arguments : propExe!.path(percentEncoded: false) + " " + arguments).dropLast().description
#if DEBUG
            print("-\(runLine)-")
#endif
            process.executableURL = exePath
            process.arguments = ["-c", runLine]
            process.standardOutput = pipe
            do {
                try process.run()
            } catch let error {
                process.interrupt()
                NSLog(error.localizedDescription)
            }
        }
        
        /// Executes one shell command
        /// - Parameters:
        ///   - exe: path to executable
        ///   - args: args of executable
        /// - Returns: Pipe to process
        public class func oneExecutable(exe: String, args: [String]) -> Pipe {
            let process = Process()
            let pipe = Pipe()
            var arguments = String()
            args.forEach { arg in
                arguments += (arg + " ")
            }
            let runLine = exe + " " + arguments
            process.executableURL = exePath
            process.arguments = [runLine]
            process.standardOutput = pipe
            DispatchQueue.main.async {
                do {
                    try process.run()
                } catch let error {
                    process.interrupt()
                    NSLog(error.localizedDescription)
                }
            }
            return pipe
        }
        
        /// Runs SUDO in swift
        /// - Parameters:
        ///   - exe: path to executable to runn with sudo
        ///   - args: args of executable
        ///   - password: admin password
        /// - Returns: command output
        public class func sudo(_ exe: String, _ args: [String], password: String) -> String {
            let taskOne = Process()
            taskOne.executableURL = URL(fileURLWithPath: "/bin/echo")
            taskOne.arguments = [password]
            
            let taskTwo = Process()
            taskTwo.executableURL = URL(fileURLWithPath: "/usr/bin/sudo")
            let args4Sudo = ["-S", exe] + args
            taskTwo.arguments = args4Sudo
            
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
                NSLog(error.localizedDescription)
            }
            
            let data = pipeToMe.fileHandleForReading.readDataToEndOfFile()
            let output : String = String(data: data, encoding: .utf8) ?? ""
            return output
        }
        
        /// Runs SUDO in swift
        /// - Parameters:
        ///   - exe: path to executable to runn with sudo
        ///   - args: args of executable
        ///   - password: admin password
        public class func sudo(_ exe: String, _ args: [String], password: String) -> Void {
            let taskOne = Process()
            taskOne.executableURL = URL(fileURLWithPath: "/bin/echo")
            taskOne.arguments = [password]
            
            let taskTwo = Process()
            taskTwo.executableURL = URL(fileURLWithPath: "/usr/bin/sudo")
            let args4Sudo = ["-S", exe] + args
            taskTwo.arguments = args4Sudo
            
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
                NSLog(error.localizedDescription)
            }
        }
        
        /// Checks if password provided is correct (use as variable value to eras in case of wrong input)
        /// - Parameter password: admin password
        /// - Returns: true if password is correct, false, if not
        public class func correctPassword(_ password: String) -> Bool {
            let pwd: String = sudo("/bin/cat", ["/etc/sudoers"], password: password)
            switch pwd {
            case
                """
                Password:Sorry, try again.
                Password:
                sudo: no password was provided
                sudo: 1 incorrect password attempt
                
                """
                :
                return false
            default : return true
            }
        }
        
        public class func directLaunchWithoutOutput(ApplicationName appName: String, ApplicationArguments arguments: String?) throws {
            let process = Process()
            process.executableURL = URL(filePath: "/bin/bash")
            process.arguments = ["-c", arguments == nil ? appName : appName + " " + arguments!]
            do {
                try process.run()
            } catch let error {
                NSLog(error.localizedDescription)
                throw error
            }
        }
        
        //MARK: - Initializer
        public init() {}
    }
    
    public class RunnerForTorNetworks {
        //MARK: - INIT and DEINIT
        public init(app: String = "/opt/homebrew/bin/tor", args: [String] = []) {
            func getAppPath(_ app: String) -> URL {
                let p = Process()
                let pi = Pipe()
                p.standardOutput = pi
                p.executableURL = URL(fileURLWithPath: "/usr/bin/which")
                p.arguments = [app]
                var retval = ""
                do {
                    try p.run()
                    retval = String(data: pi.fileHandleForReading.availableData, encoding: .utf8)!
                } catch let error {
                    NSLog(error.localizedDescription)
                    p.interrupt()
                }
                return URL(fileURLWithPath: String(retval.dropLast()))
            }
            appPath = getAppPath(app)
            process = Process()
            pipe = Pipe()
            process.executableURL = appPath
            process.arguments = args
            process.standardOutput = pipe
        }
        public init(appURL: URL, args: [String]) {
            appPath = appURL
            process = Process()
            pipe = Pipe()
            process.executableURL = appURL
            process.arguments = args
            process.standardOutput = pipe
        }
        //MARK: - Vars
        private var appPath: URL = .init(fileURLWithPath: "")
        public var process: Process = Process()
        public var pipe: Pipe = Pipe()
        
        //MARK: - Funcs
        public func getAppPath(_ app: String) -> URL {
            let p = Process()
            let pi = Pipe()
            p.standardOutput = pi
            p.executableURL = URL(fileURLWithPath: "/usr/bin/which")
            p.arguments = [app]
            var retval = ""
            do {
                try p.run()
                retval = String(data: pi.fileHandleForReading.availableData, encoding: .utf8)!
            } catch let error {
                NSLog(error.localizedDescription)
                p.interrupt()
            }
            return URL(fileURLWithPath: String(retval.dropLast()))
        }
        
        public func stopTask() {
            do {
                process.terminate()
                try pipe.fileHandleForReading.close()
            } catch let error {
                NSLog(String(error.localizedDescription))
            }
        }
        
        public func returnAllOutput() -> String {
            var string = Data()
            do{
                try string = pipe.fileHandleForReading.readToEnd() ?? pipe.fileHandleForReading.availableData
            } catch let error {
                NSLog(error.localizedDescription)
            }
            let retval = String(data: string, encoding: .utf8)!
            return retval
        }
    }
}
