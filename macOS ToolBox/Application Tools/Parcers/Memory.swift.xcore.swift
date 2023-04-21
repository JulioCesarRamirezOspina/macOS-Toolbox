//
//  RAM Manager.swift
//  MultiTool
//
//  Created by Олег Сазонов on 26.06.2022.
//

import Foundation
import AppKit
import SwiftUI

/// RAM Manager + RAM Disk Creator
final public class Memory: @unchecked Sendable {
    
    /// All RAM Data
    private var allRAMData: memoryValues {
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
    
    public init() {}
    
    public actor RAMData {
//    public struct RAMData {
        public init() {
            total = 1
            free = 0.01
            wired = 0.01
            used = 0.01
            compressed = 0.01
            active = 0.01
            inactive = 0.01
            cachedFiles = 0.01
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

    private func RAMData() async -> Task<memoryValues, Never> {
        Task {
            return allRAMData
        }
    }
    public func ejectAll(_ driveArray: [String]) {
        for each in driveArray {
            Shell.Parcer.OneExecutable.withNoOutput(exe: "unmount", args: ["-f", "/Volumes/\(each)\""])
            Shell.Parcer.OneExecutable.withNoOutput(exe: "diskutil", args: ["eject", "\"\(each)\""])
        }
    }
    
    /// Uses internal algorythm to clear RAM
    public func clearRAM() async -> Task<(Bool), Never> {
        Task {
            SettingsMonitor.memoryClensingInProgress = true
            let diskName = StringLocalizer("clear_RAM.string")
            let fileName = "ramFiller.deleteMe"
            let fileSize = Int(macOS_Subsystem.physicalMemory(.megabyte))
            var objCBool = ObjCBool(true)
            createDisk(diskName, Int(macOS_Subsystem.physicalMemory(.gigabyte)))
            repeat {
                try? await Task.sleep(seconds: 1)
                #if DEBUG
                print("waiting for volume to appear...")
                #endif
            } while (!FileManager.default.fileExists(atPath: "/Volumes/\(diskName)", isDirectory: &objCBool))
            Shell.Parcer.OneExecutable.withNoOutput(exe: "touch", args: ["\"/Volumes/\(diskName)/\(fileName)\""])
            Shell.Parcer.OneExecutable.withNoOutput(args: ["echo \(SettingsMonitor.password) | sudo -S /bin/dd if=/dev/random of=\"/Volumes/\(diskName)/\(fileName)\" bs=2M count=\(fileSize)"])
            repeat {
                try? await Task.sleep(seconds: 1)
            } while await Memory().memoryPressure().value != .warning
            Shell.Parcer.OneExecutable.withNoOutput(args: ["echo \(SettingsMonitor.password) | sudo -S killall dd"])
            ejectAll(["\(diskName)"])
            Shell.Parcer.SUDO.withoutOutput("/usr/sbin/purge", [""], password: SettingsMonitor.password)
            try? await Task.sleep(seconds: 3)
            Shell.Parcer.SUDO.withoutOutput("/bin/bash", ["-c", "killall coreaudiod"], password: SettingsMonitor.password)
            SettingsMonitor.memoryClensingInProgress = false
            if !Task.isCancelled {
                Shell.Parcer.OneExecutable.withNoOutput(args: ["echo \(SettingsMonitor.password) | sudo -S killall dd"])
                ejectAll(["\(diskName)"])
            }
            return false
        }
    }
    
    /// Create RAM Disk
    /// - Parameters:
    ///   - diskLabel: Disk label
    ///   - volume: Disk volume (in gigs)
    ///   - open: Open disk in Finder
    public func createDisk(_ diskLabel: String, _ volume: Int, _ open: Bool = false) {
        Shell.Parcer.OneExecutable.withNoOutput(args: ["$(diskutil eraseVolume JHFS+ \"\(diskLabel)\" $(hdiutil attach -nomount ram://\(volume * 1000 * 2000)))"])
        if open {
            NSWorkspace.shared.open(URL(filePath: "/Volumes/\(diskLabel.replacingOccurrences(of: " ", with: "\\ "))"))
        }
    }
    
    public func memoryPressure() async -> Task<MemoryPressure, Never> {
        Task {
            var output: MemoryPressure = .undefined
            var num = 3
            if let processResult = Shell.Parcer.OneExecutable.withOptionalString(exe: "sysctl", args: ["-a", "kern.memorystatus_vm_pressure_level"]) {
                let resultArray = processResult.byWords.last ?? ""
                num = Int(resultArray) ?? 3
                switch num {
                case 1: output = .nominal
                case 2: output = .warning
                case 4: output = .critical
                default: output = .undefined
                }
            }
            return output
        }
    }
    
    private func TimeMachineClear() async {
        Task{
            Shell.Parcer.OneExecutable.withNoOutput(exe: "tmutil", args: ["deletelocalsnapshots", "/"])
        }
    }
    
    public func TimeMachineCount() -> Int {
        if let out = Shell.Parcer.OneExecutable.withOptionalString(exe: "tmutil", args: ["listlocalsnapshots", "/"]) {
            let arr = out.byLines.count - 1
            return arr
        } else {
            return 0
        }
    }
    
    public struct TimeMachineControls: View {
        @Binding var toggle: Bool
        public var body: some View {
            Button {
                Task{
                    toggle.toggle()
                    await Memory().TimeMachineClear()
                }
            } label: {
                Text("clearTM.string")
            }
            .disabled(Memory().TimeMachineCount() < 1)
            .buttonStyle(Stylers.ColoredButtonStyle(glyph: "clock.arrow.circlepath",
                                                    disabled: Memory().TimeMachineCount() < 1,
                                                    enabled: false,
                                                    alwaysShowTitle: true,
                                                    color: .blue,
                                                    glow: true))
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
            let xcodeDir = URL.homeDirectory.appending(path: "Library").appending(path: "Developer").appending(path: "Xcode")
            let derivedDir = xcodeDir.appending(path: "DerivedData")
            let iOSDL = xcodeDir.appending(path: "iOS Device Logs")
            let iOSDS = xcodeDir.appending(path: "iOS DeviceSupport")
            let macOSDS = xcodeDir.appending(path: "macOS DeviceSupport")
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
        let xcodeDir = fm.homeDirectoryForCurrentUser.appending(path: "Library").appending(path: "Developer").appending(path: "Xcode")
        let iOSDL = xcodeDir.appending(path: "iOS Device Logs")
        let iOSDS = xcodeDir.appending(path: "iOS DeviceSupport")
        let macOSDS = xcodeDir.appending(path: "macOS DeviceSupport")
        let derivedDir = xcodeDir.appending(path: "DerivedData")
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
    
    public func diskAccess() -> Bool {
        switch FileManager.default.isReadableFile(atPath: "/Library/Preferences/com.apple.TimeMachine.plist") {
        case true: return true
        case false: return false
        }
    }
}
