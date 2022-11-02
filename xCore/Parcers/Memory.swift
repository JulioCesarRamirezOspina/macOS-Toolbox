//
//  RAM Manager.swift
//  MultiTool
//
//  Created by Олег Сазонов on 26.06.2022.
//

import Foundation
import AppKit

/// RAM Manager + RAM Disk Creator
public class Memory: xCore {
    
    /// All RAM Data
    private var allRAMData: (
        free        : Double,
        active      : Double,
        inactive    : Double,
        wired       : Double,
        compressed  : Double,
        total       : Double,
        used        : Double,
        cachedFiles : Double
    ) {
        get {
            return (
                free        : macOS_Subsystem.memoryUsage(.megabyte).free,
                active      : macOS_Subsystem.memoryUsage(.megabyte).active,
                inactive    : macOS_Subsystem.memoryUsage(.megabyte).inactive,
                wired       : macOS_Subsystem.memoryUsage(.megabyte).wired,
                compressed  : macOS_Subsystem.memoryUsage(.megabyte).compressed,
                total       : macOS_Subsystem.memoryUsage(.megabyte).total,
                used        :
                macOS_Subsystem.memoryUsage(.megabyte).active +
                macOS_Subsystem.memoryUsage(.megabyte).inactive +
                macOS_Subsystem.memoryUsage(.megabyte).compressed +
                macOS_Subsystem.memoryUsage(.megabyte).wired,
                
                cachedFiles : macOS_Subsystem.memoryUsage(.megabyte).cachedFiles
            )
        }
    }
    
    public override init() {}
    
    public actor RAMData {
//    public struct RAMData {
        public init() {
            total = 1
            free = 1
            wired = 1
            used = 1
            compressed = 1
            active = 1
            inactive = 1
            cachedFiles = 1
        }
        public init() async {
            total = await Memory().RAMData().value.total
            free = await Memory().RAMData().value.free
            wired = await Memory().RAMData().value.wired
            used = await Memory().RAMData().value.used
            compressed = await Memory().RAMData().value.compressed
            active = await Memory().RAMData().value.active
            inactive = await Memory().RAMData().value.inactive
            cachedFiles = await Memory().RAMData().value.cachedFiles
        }
        deinit {
            _defaultActorDestroy(self)
        }
        public nonisolated let total: Double
        public nonisolated let free: Double
        public nonisolated let wired: Double
        public nonisolated let used: Double
        public nonisolated let compressed: Double
        public nonisolated let active: Double
        public nonisolated let inactive: Double
        public nonisolated let cachedFiles: Double
    }

    private func RAMData() async -> Task<(
        free        : Double,
        active      : Double,
        inactive    : Double,
        wired       : Double,
        compressed  : Double,
        total       : Double,
        used        : Double,
        cachedFiles : Double
    ), Never> {
        Task {
            return allRAMData
        }
    }
    public func ejectAll(_ driveArray: [String]) {
        for each in driveArray {
            let process = Process()
            process.executableURL = URL(filePath: "/usr/bin/env")
            process.arguments = ["bash", "-c", "umount -f \"/Volumes/\(each)\" && diskutil eject \"\(each)\""]
            do {
                try process.run()
            } catch let error {
                NSLog(error.localizedDescription)
                do {
                    try process.run()
                } catch let err {
                    NSLog(err.localizedDescription)
                    process.terminate()
                }
            }
        }
    }
    
    /// Uses internal algorythm to clear RAM
    public func clearRAM() async -> Task<(Bool), Never> {
        Task(operation: {
            SettingsMonitor.memoryClensingInProgress = true
            let diskName = StringLocalizer("clear_RAM.string")
            let fileName = "ramFiller.deleteMe"
            let fileSize = Int(macOS_Subsystem.physicalMemory(.megabyte))
            createDisk(diskName, Int(macOS_Subsystem.physicalMemory(.gigabyte)))
            do {
                try await Task.sleep(seconds: 5)
            } catch _ {}
            let arg = "touch \"/Volumes/\(diskName)/\(fileName)\" ; echo \(SettingsMonitor.password) | sudo -S dd if=/dev/random of=\"/Volumes/\(diskName)/\(fileName)\" bs=2M count=\(fileSize)"
            let process = Process()
            process.executableURL = URL(filePath: "/bin/bash")
            process.arguments = ["-c", arg]
            do {
                try process.run()
                repeat {
                    try await Task.sleep(seconds: 1)
                } while (process.isRunning)
                ejectAll([diskName])
            } catch let error {
                NSLog(error.localizedDescription)
            }
            Shell.Parcer.sudo("/usr/sbin/purge", [""], password: SettingsMonitor.password) as Void
            try? await Task.sleep(seconds: 3)
            Shell.Parcer.sudo("/bin/bash", ["-c", "killall coreaudiod"], password: SettingsMonitor.password) as Void
            SettingsMonitor.memoryClensingInProgress = false
            return false
        })
    }
    
    /// Create RAM Disk
    /// - Parameters:
    ///   - diskLabel: Disk label
    ///   - volume: Disk volume (in gigs)
    ///   - open: Open disk in Finder
    public func createDisk(_ diskLabel: String, _ volume: Int, _ open: Bool = false) {
        let process = Process()
        let pipe = Pipe()
        process.standardOutput = pipe
        process.executableURL = URL(filePath: "/bin/bash")
        process.arguments = ["-c", "$(diskutil eraseVolume JHFS+ \"\(diskLabel)\" $(hdiutil attach -nomount ram://\(volume * 1000 * 2000)))"]
        do {
            try process.run()
        } catch let error {
            NSLog(error.localizedDescription)
        }
        if open {
            NSWorkspace.shared.open(URL(filePath: "/Volumes/\(diskLabel.replacingOccurrences(of: " ", with: "\\ "))"))
        }
    }
    
    public func memoryPressure() async -> Task<MemoryPressure, Never> {
        Task {
            let process = Process()
            let pipe = Pipe()
            var output: MemoryPressure
            var num = 3
            process.executableURL = URL(filePath: "/usr/sbin/sysctl")
            process.arguments = ["-a", "kern.memorystatus_vm_pressure_level"]
            process.standardOutput = pipe
            do {
                try process.run()
                let processResult = try String(data: pipe.fileHandleForReading.readToEnd() ?? pipe.fileHandleForReading.availableData, encoding: .utf8) ?? "3"
                process.waitUntilExit()
                let resultArray = processResult.byWords.last ?? ""
                num = Int(resultArray) ?? 3
                switch num {
                case 1: output = .nominal
                case 2: output = .warning
                case 4: output = .critical
                default: output = .undefined
                }
            } catch let error {
                print(error.localizedDescription)
                output = .undefined
            }
            return output
        }
    }
    
    public func cachesSize() async -> Task<String, Never> {
        Task(priority: .background, operation: {
            var retval: Int = 0
            var retvalCache: Int = 0
            var retvalDerived: Int = 0
            var iOSDLsize: Int = 0
            var iOSDSsize: Int = 0
            var macOSDSsize: Int = 0
            var CSC: Int = 0
            let fm = FileManager.default
            let cachesDir = URL.cachesDirectory
            let derivedDir = URL.homeDirectory.appending(path: "Library").appending(path: "Developer").appending(path: "Xcode").appending(path: "DerivedData")
            let iOSDL = URL.homeDirectory.appending(path: "Library").appending(path: "Developer").appending(path: "Xcode").appending(path: "iOS Device Logs")
            let iOSDS = URL.homeDirectory.appending(path: "Library").appending(path: "Developer").appending(path: "Xcode").appending(path: "iOS DeviceSupport")
            let macOSDS = URL.homeDirectory.appending(path: "Library").appending(path: "Developer").appending(path: "Xcode").appending(path: "macOS DeviceSupport")
            let CoreSimulatorCaches = URL.homeDirectory.appending(path: "Library").appending(path: "Developer").appending(path: "CoreSimulator").appending(path: "Caches")
            retvalCache = fm.directorySize(cachesDir) ?? 0
            retvalDerived = fm.directorySize(derivedDir) ?? 0
            iOSDLsize = fm.directorySize(iOSDL) ?? 0
            iOSDSsize = fm.directorySize(iOSDS) ?? 0
            macOSDSsize = fm.directorySize(macOSDS) ?? 0
            CSC = fm.directorySize(CoreSimulatorCaches) ?? 0
            let div: Int = 1024 * 1024
            retval = (retvalCache / div) + (retvalDerived / div) + (iOSDLsize / div) + (iOSDSsize / div) + (macOSDSsize / div) + (CSC / div)
            return "\(StringLocalizer("userCaches.string")): \(retval) MB"
        })
    }
    
    private func clensing(fm: FileManager) {
        var foldersToRemove = [URL]()
        let iOSDL = fm.homeDirectoryForCurrentUser.appending(path: "Library").appending(path: "Developer").appending(path: "Xcode").appending(path: "iOS Device Logs")
        let iOSDS = fm.homeDirectoryForCurrentUser.appending(path: "Library").appending(path: "Developer").appending(path: "Xcode").appending(path: "iOS DeviceSupport")
        let macOSDS = fm.homeDirectoryForCurrentUser.appending(path: "Library").appending(path: "Developer").appending(path: "Xcode").appending(path: "macOS DeviceSupport")
        let derivedDir = fm.homeDirectoryForCurrentUser.appending(path: "Library").appending(path: "Developer").appending(path: "Xcode").appending(path: "DerivedData")
        let cachesDir = fm.homeDirectoryForCurrentUser.appending(path: "Library").appending(path: "Caches")
        let CoreSimulatorCaches = fm.homeDirectoryForCurrentUser.appending(path: "Library").appending(path: "Developer").appending(path: "CoreSimulator").appending(path: "Caches")

        let contentsOfCaches = try? fm.contentsOfDirectory(at: cachesDir, includingPropertiesForKeys: [.fileSizeKey])
        let contentsOfDerived = try? fm.contentsOfDirectory(at: derivedDir, includingPropertiesForKeys: [.fileSizeKey])
        let contentsOfiOSSupport = try? fm.contentsOfDirectory(at: iOSDS, includingPropertiesForKeys: [.fileSizeKey])
        let contentsOfmacOSSupport = try? fm.contentsOfDirectory(at: macOSDS, includingPropertiesForKeys: [.fileSizeKey])
        let contentsOfiOSLogs = try? fm.contentsOfDirectory(at: iOSDL, includingPropertiesForKeys: [.fileSizeKey])
        let contentsOfCSC = try? fm.contentsOfDirectory(at: CoreSimulatorCaches, includingPropertiesForKeys: [.fileSizeKey])
        
        for each in contentsOfCaches ?? [] {
            if !each.description.contains("AudioUnitCache") {
                foldersToRemove.append(each)
            }
        }
        
        for each in contentsOfCSC ?? [] {
            foldersToRemove.append(each)
        }
    
        for each in contentsOfmacOSSupport ?? [] {
            foldersToRemove.append(each)
        }
        
        for each in contentsOfDerived ?? [] {
            foldersToRemove.append(each)
        }
        
        for each in contentsOfiOSLogs ?? [] {
            foldersToRemove.append(each)
        }
        
        for each in contentsOfiOSSupport ?? [] {
            foldersToRemove.append(each)
        }
        
        for each in foldersToRemove {
            do {
                try fm.removeItem(at: each)
            } catch _ {}
        }
    }
    
    private func NoTIDClear() async throws -> Task<(Bool), Never> {
        Task {
            do {
                let reason = try await NSWorkspace().requestAuthorization(to: .replaceFile)
                clensing(fm: FileManager(authorization: reason))
                return true
            } catch _ {return false}
        }
    }
    
    private func TIDClear() async throws -> Task<(Bool), Never> {
        do {
            return try await Biometrics.execute(code: {
                Memory().clensing(fm: FileManager())
            }, reason: localizedReason())
        } catch _ {
            return Task<(Bool), Never> {return false}
        }
    }
    
    private func localizedReason() ->String {
        return StringLocalizer("cachesClear.reason")
    }
    
    fileprivate enum Errors: Error {
    case noDiskAccess
    }
    
    public func clearCaches() async -> Task<(Bool), Never> {
        Task {
            if diskAccess() {
                do {
                    if diskAccess() {
                        try await _ = TIDClear()
                        return true
                    } else {
                        throw Errors.noDiskAccess
                    }
                } catch _ {
                    do {
                        if diskAccess() {
                            try await _ = NoTIDClear()
                            return true
                        } else {
                            throw Errors.noDiskAccess
                        }
                    } catch _ {
                        return false
                    }
                }
            } else {
                return false
            }
        }
    }
    
    public func openSecurityPrefPane() {
        let prefPaneURL = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles")
        NSWorkspace.shared.open(prefPaneURL!)
    }
    
    private func diskAccess() -> Bool {
        switch FileManager.default.isReadableFile(atPath: "/Library/Preferences/com.apple.TimeMachine.plist") {
        case true: return true
        case false: return false
        }
    }
}
