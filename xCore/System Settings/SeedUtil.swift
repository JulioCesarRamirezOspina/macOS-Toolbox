//
//  SeedUtil.swift
//  SuperStuff
//
//  Created by Олег Сазонов on 19.06.2022.
//

import Foundation
import AppKit

/// Enrolls or unenrolls current Mac into or from macOS Beta. Almost the same as Profiles in iOS
public class SeedUtil: xCore {
    private static let executablePath = "/System/Library/PrivateFrameworks/Seeding.framework/Versions/A/Resources/seedutil"
    
    /// Gets current seed
    /// - Parameter password: sudo password
    /// - Returns: String description of seed
    public class func getSeed(_ password: String) -> String {
        let input = Shell.Parcer.sudo(executablePath, ["current"], password: password).firstLine?.byWords.last
        switch input {
        case "DeveloperSeed" : return NSLocalizedString("seed.dev", comment: "")
        case "PublicSeed" : return NSLocalizedString("seed.public", comment: "")
        default : return NSLocalizedString("pending.string", comment: "")
        }
    }
    
    /// Basically returns the same integer as terminal util
    /// - Parameter password: sudo password
    /// - Returns: Integer value
    public class func getSeedInt(_ password: String) -> Int {
        let input = Shell.Parcer.sudo(executablePath, ["current"], password: password).firstLine?.byWords.last
        switch input {
        case "DeveloperSeed" : return 2
        case "PublicSeed" : return 1
        default : return 0
        }
    }
    
    /// Gets if Mac is enrolled
    /// - Parameter password: sudo password
    /// - Returns: true, if enrolled in any seed, false otherwise
    public class func getSeedBool(_ password: String) -> Bool {
        let input = getSeed(password)
        switch input {
        case "None" : return false
        case NSLocalizedString("pending.string", comment: "") : return false
        default : return true
        }
    }
    
    public class func getSeedType(_ password: String) -> SeedReadableString {
        switch getSeedInt(password) {
        case 2: return .DeveloperBeta
        case 1: return .PublicBeta
        default: return .NotEnrolled
        }
    }
    
    public class func getSeedString(_ password: String) -> String {
        switch getSeedType(password) {
        case .DeveloperBeta:
            return StringLocalizer("channel.dev")
        case .PublicBeta:
            return StringLocalizer("channel.public")
        case .NotEnrolled:
            return StringLocalizer("channel.none")
        }
    }
    
    /// Unenrolls from any beta
    /// - Parameter password: sudo password
    public class func unenroll(_ password: String) {
        _ = Shell.Parcer.sudo(executablePath, ["unenroll"], password: password) as Void
        Task{
            await SendNotification("un.not")
        }
    }
    
    /// Enrolls Mac in selected seed
    /// - Parameters:
    ///   - caseNum: 1 — Public Beta Seed; 2 — Developer Beta Seed
    ///   - password: sudo password
    ///   - openUpdates: If needed to open update setting for update check
    public class func setSeed(_ caseNum: Int, password: String, _ openUpdates: Bool) {
        switch caseNum {
        case 1: _ = Shell.Parcer.sudo(executablePath, ["enroll", "PublicSeed"], password: password) as Void
            Task {
                await SendNotification("pb.not")
            }
        case 2: _ = Shell.Parcer.sudo(executablePath, ["enroll", "DeveloperSeed"], password: password) as Void
            Task {
                await SendNotification("db.not")
            }
        default: _ = Shell.Parcer.sudo(executablePath, ["unenroll"], password: password) as Void
            Task {
                await SendNotification("un.not")
            }
        }
        if openUpdates {
            checkUpdates()
        }
    }
    
    private class func getUpdateInfo(input s: String) -> (label: String, buildNumber: String) {
        let mPart = String(s.split(separator: "*")[1].dropFirst(8).split(separator: "T")[0].dropLast(2))
        let s = mPart.split(separator: "-")
        let label = String(s[0])
        let bN = String(s[1])
        return (label: label, buildNumber: bN)
    }
    
    public class func sysupdateAvailable() async -> (OSUpdateStatus, (label: String, buildNumber: String)) {
        let process = Process()
        let mainPipe = Pipe()
        let errorPipe = Pipe()
        process.executableURL = URL(filePath: "/usr/sbin/softwareupdate")
        process.arguments = ["-l", "-a"]
        process.standardOutput = mainPipe
        process.standardError = errorPipe
        var output = ""
        var error = ""
        do {
            try process.run()
            if let line = try mainPipe.fileHandleForReading.readToEnd() {
                output += String(data: line, encoding: .utf8) ?? ""
            }
            if let line = try errorPipe.fileHandleForReading.readToEnd() {
                error += String(data: line, encoding: .utf8) ?? ""
            }
            if output.contains("Software Update found the following new or updated software") {
                let updateData = getUpdateInfo(input: output)
                return (.available, updateData)
            } else if error.contains("No new software available.") {
                return (.notAvailable, ("", ""))
            } else {
                return (.noConnection, ("", ""))
            }
        } catch let error {
            print(error)
            return (.noConnection, ("", ""))
        }
    }

    
    public class func checkUpdates() {
        NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preferences.softwareupdate?client=softwareupdateapp")!)
    }
    
    /// Send user notification
    /// - Parameter body: notification text
    public class func SendNotification(_ body: String) async {
        let not = LocalNotificationManager()
        await not.sendNotification(title: "app.name", subtitle: nil, body: body)
    }
}
