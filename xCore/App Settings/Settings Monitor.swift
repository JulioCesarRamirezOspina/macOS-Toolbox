//
//  Observer.swift
//  MultiTool
//
//  Created by Олег Сазонов on 01.07.2022.
//

import Foundation
import Combine
import CommonCrypto
import SwiftUI

/// Handles Application settings
public class SettingsMonitor: xCore {
    private let fm = FileManager.default
    
    public static func Maintenance() {
        if passwordSaved {
            _ = Shell.Parcer.sudo("/bin/bash", ["-c", "sudo periodic daily weekly monthly"], password: password) as String
        }
    }
    
    public static var memoryClensingInProgress: Bool {
        get {
            AppSettings.load(key: "clensingInProgress") ?? false
        }
        set {
            AppSettings.set(key: "clensingInProgress", value: newValue)
        }
    }
    
    public static var isInMenuBar: Bool {
        get {
            AppSettings.load(key: "isInMenuBar") ?? false
        }
        set {
            AppSettings.set(key: "isInMenuBar", value: newValue)
            let task = Process()
            task.launchPath = "/bin/sh"
            task.arguments = ["-c", "sleep \(2); open \"\(Bundle.main.bundlePath)\""]
            task.launch()
            
            NSApp.terminate(self)
            exit(EXIT_SUCCESS)
        }
    }
    
    public class func textColor(_ c: ColorScheme) -> Color {
        if isInMenuBar && c == .dark {
            return .white
        } else if isInMenuBar && c == .light {
            return .black
        } else {
            return .secondary
        }
    }
    
    public func delete(key: String) {
        AppSettings.defaults.removeObject(forKey: key)
    }
    
    public func defaults(_ key: DefaultKey = .All) {
        AppSettings.defaultSettings(key)
    }
    
    /// Initial run
    /// Being used once during first run
    public var initRun: Int? {
        get {
            AppSettings.load(key: "initRun") ?? nil
        } set {
            AppSettings.set(key: "initRun", value: Int.random(in: 0...10))
        }
    }
    
    public var colorSchemeSetting: ColorScheme {
        get {
            @Environment(\.colorScheme) var cs
            if AppSettings.keyExists(key: "colorScheme") {
                return AppSettings.load(key: "colorScheme")
            } else {
                return cs
            }
        }
        set {
            switch newValue {
            case .light: AppSettings.set(key: "colorScheme", value: ".light")
            case .dark: AppSettings.set(key: "colorScheme", value: ".dark")
            @unknown default: AppSettings.set(key: "colorScheme", value: ".light")
            }
            
        }
    }
    
    public static var deviceImage: URL? {
        get {
            if AppSettings.keyExists(key: "deviceImage") {
                return AppSettings.load(key: "deviceImage")
            } else {
                return nil
            }
        }
        set{
            AppSettings.set(key: "deviceImage", value: newValue!)
        }
    }
    
    public static var showSerialNumber: Bool {
        get {
            if AppSettings.keyExists(key: "showSerialNumber") {
                return AppSettings.load(key: "showSerialNumber") ?? false
            } else {
                return false
            }
        }
        set {
            AppSettings.set(key: "showSerialNumber", value: newValue)
        }
    }
    
    public static var batteryAnimation: Bool {
        get {
            AppSettings.load(key: "batteryAnimation") ?? true
        }
        set {
            AppSettings.set(key: "batteryAnimation", value: newValue)
        }
    }
    
    public static var maintenanceLastRun: String {
        get {
            AppSettings.load(key: "maintenanceDate") ?? "—"
        }
        set {
            AppSettings.set(key: "maintenanceDate", value: newValue)
        }
    }
    
    /// being used to set/get navigation fields animation duration
    public static var navigationAnimation: Double {
        get {
            if AppSettings.keyExists(key: "navAnimDur"){
                return AppSettings.load(key: "navAnimDur") ?? 0
            } else {
                return 0
            }
        }
        set {
            AppSettings.set(key: "navAnimDur", value: newValue)
        }
    }
    
    public static var secondaryAnimation: Animation {
        get {
            if ProcessInfo.processInfo.isLowPowerModeEnabled {
                return .linear(duration: 0)
            } else {
                return .spring(response: 0.5, dampingFraction: 1, blendDuration: 1)
            }
        }
    }
    
    public static var mainAnimation: Animation {
        .easeInOut(duration: mainAnimDur)
    }
    
    /// being used to set/get primary animation duration
    public static var mainAnimDur: Double {
        get {
            if AppSettings.keyExists(key: "mainAnimDur"){
                return AppSettings.load(key: "mainAnimDur") ?? 1
            } else {
                return 1
            }
        }
        set {
            AppSettings.set(key: "mainAnimDur", value: newValue)
        }
    }
    
    /// being used to set/get secomdary animation duration
    public static var secAnimDur: Double {
        get {
            if AppSettings.keyExists(key: "secAnimDur"){
                return AppSettings.load(key: "secAnimDur") ?? 0.5
            } else {
                return 0.5
            }
        }
        set {
            AppSettings.set(key: "secAnimDur", value: newValue)
        }
    }
    
    /// being used to set/get bootable drive label
    public static var bootCampDiskLabel: String {
        get {
            AppSettings.load(key: "diskLabel") ?? "BOOTCAMP"
        }
        set {
            AppSettings.set(key: "diskLabel", value: newValue)
        }
    }
    
    /// initialized with existance of currently used parallels working directory
    public static var parallelsDidNotSet: Bool {
        get {
            if AppSettings.load(key: "parallelsDir")?.isEmpty == nil {
                return true
            } else {
                return false
            }
            
        }
    }
    
    /// initialized with existance of currently used UTM working directory
    public static var utmDidNotSet: Bool {
        get {
            if AppSettings.load(key: "utmDir")?.isEmpty == nil {
                return true
            } else {
                return false
            }
        }
    }
    
    /// gets/sets parallels working directory
    public static var parallelsDir: URL {
        get {
            AppSettings.load(key: "parallelsDir") ?? FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Parallels")
        }
        set {
            if newValue == URL(filePath: "") {
                AppSettings.defaultSettings(.Parallels)
            } else {
                AppSettings.set(key: "parallelsDir", value: newValue)
            }
        }
    }
    
    /// gets/sets utm working directory
    public static var utmDir: URL {
        get {
            AppSettings.load(key: "utmDir") ?? FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Library").appendingPathComponent("Containers").appendingPathComponent("com.utmapp.UTM").appendingPathComponent("Data").appendingPathComponent("Documents")
        }
        set {
            if newValue == URL(filePath: "") {
                AppSettings.defaultSettings(.UTM)
            } else {
                AppSettings.set(key: "utmDir", value: newValue)
            }
        }
    }
    
    /// gets/sets developer installed id
    public static var devID: String {
        get {
            AppSettings.load(key: "devID") ?? ""
        }
        set {
            if newValue == "" {
                AppSettings.remove(key: "devID")
            } else {
                AppSettings.set(key: "devID", value: newValue)
            }
        }
    }
    
    /// gets/sets sudo password
    public static var password: String {
        get {
            AppSettings.loadPassword() ?? ""
        }
        set {
            if newValue == "" {
                AppSettings.removePassword()
            } else {
                AppSettings.savePassword(newValue)
            }
        }
    }
    
    /// initialized with existance of currently saved password
    public static var passwordSaved: Bool {
        get {
            if password != "" {
                return true
            } else {
                return false
            }
        }
    }
    public override init() {
    }
}

/// Handles User defaults
fileprivate class AppSettings: xCore {
    // MARK: - Private Defaults
    public static let defaults = UserDefaults.standard
    private static let fm = FileManager.default
    // MARK: - Functions
    // MARK: Public
    /// Sets string values
    /// - Parameters:
    ///   - key: key to set
    ///   - value: value to set
    public class func set(key: String, value: String){
        defaults.set(value, forKey: key)
        defaults.synchronize()
    }
    
    public class func keyExists(key: String) -> Bool {
        let retval = defaults.object(forKey: key)
        if retval == nil {
            return false
        } else {
            return true
        }
    }
    
    /// Sets URL values
    /// - Parameters:
    ///   - key: key to set
    ///   - value: value to set
    public class func set(key: String, value: URL){
        defaults.set(value, forKey: key)
        defaults.synchronize()
    }
    
    /// Sets URL values
    /// - Parameters:
    ///   - key: key to set
    ///   - value: value to set
    public class func set(key: String, value: Bool){
        defaults.set(value, forKey: key)
        defaults.synchronize()
    }

    /// Sets URL values
    /// - Parameters:
    ///   - key: key to set
    ///   - value: value to set
    public class func set(key: String, value: Int){
        defaults.set(value, forKey: key)
        defaults.synchronize()
    }
    
    /// Sets URL values
    /// - Parameters:
    ///   - key: key to set
    ///   - value: value to set
    public class func set(key: String, value: Double){
        defaults.set(value, forKey: key)
        defaults.synchronize()
    }
    
    public class func set(key: String, value: ColorScheme){
        defaults.set(value, forKey: key)
        defaults.synchronize()
    }

    /// Loads string value for key
    /// - Parameter key: Key
    /// - Returns: Value for key
    public class func load(key: String) -> String? {
        return defaults.string(forKey: key)
    }
    
    /// Loads string value for key
    /// - Parameter key: Key
    /// - Returns: Value for key
    public class func load(key: String) -> Bool? {
        return defaults.bool(forKey: key)
    }

    /// Loads string value for key
    /// - Parameter key: Key
    /// - Returns: Value for key
    public class func load(key: String) -> Int? {
        return defaults.integer(forKey: key)
    }
    
    public class func load(key: String) -> ColorScheme {
        @Environment(\.colorScheme) var cs
        let val = defaults.string(forKey: key)
        switch val {
        case ".dark": return .dark
        case ".light": return .light
        default: return cs
        }
    }

    /// Loads string value for key
    /// - Parameter key: Key
    /// - Returns: Value for key
    public class func load(key: String) -> Double? {
        return defaults.double(forKey: key)
    }

    /// Loads URL value for key
    /// - Parameter key: Key
    /// - Returns: Value for key
    public class func load(key: String) -> URL? {
        return defaults.url(forKey: key)
    }
    
    public class func remove(key: String) {
        defaults.removeObject(forKey: key)
    }
    
    /// Sets default values on initial run
    public class func defaultSettings(_ parameter: DefaultKey = .All) {
        switch parameter {
        case .UTM:         defaults.set((fm.homeDirectoryForCurrentUser.appendingPathComponent("Library").appendingPathComponent("Containers").appendingPathComponent("com.utmapp.UTM").appendingPathComponent("Data").appendingPathComponent("Documents")), forKey: "utmDir")
            defaults.synchronize()
        case .Parallels: defaults.set((fm.homeDirectoryForCurrentUser.appendingPathComponent("Parallels")), forKey: "parallelsDir")
        case .BootCamp: defaults.set("BOOTCAMP", forKey: "diskLabel")
            defaults.synchronize()
        case .All:
//            defaults.set("BOOTCAMP", forKey: "diskLabel")
//
//            defaults.set((fm.homeDirectoryForCurrentUser.appendingPathComponent("Parallels")), forKey: "parallelsDir")
//
//            defaults.set((fm.homeDirectoryForCurrentUser.appendingPathComponent("Library").appendingPathComponent("Containers").appendingPathComponent("com.utmapp.UTM").appendingPathComponent("Data").appendingPathComponent("Documents")), forKey: "utmDir")
//            defaults.removeObject(forKey: "password")
//            defaults.set(Int.random(in: 0...10), forKey: "initRun")
//            defaults.removeObject(forKey: "devID")
//            defaults.synchronize()
            defaults.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
            defaults.synchronize()
        }

    }
    // MARK: - AES Structure
    struct AES {
        // MARK: - Values
        // MARK: Private
        private let key: Data
        private let iv: Data
        
        // MARK: - Initialzier
        /// Sets Crypto to given keys
        /// - Parameters:
        ///   - key: AES256 key
        ///   - iv: AES128 key
        init?(key: String, iv: String) {
            guard key.count == kCCKeySizeAES128 || key.count == kCCKeySizeAES256, let keyData = key.data(using: .utf8) else {
//                print("Error: Failed to set a key.")
                return nil
            }
            
            guard iv.count == kCCBlockSizeAES128, let ivData = iv.data(using: .utf8) else {
//                print("Error: Failed to set an initial vector.")
                return nil
            }
            
            
            self.key = keyData
            self.iv  = ivData
        }
        
        // MARK: - Functions
        // MARK: Private
        /// Encrypt
        /// - Parameter string: Message to encrypt
        /// - Returns: Data representation of encrypted message
        private func encrypt(string: String) -> Data? {
            return crypt(data: string.data(using: .utf8), option: CCOperation(kCCEncrypt))
        }
        
        /// Decrypt
        /// - Parameter data: Encrypted data
        /// - Returns: String representation of decrypted message
        private func decrypt(data: Data?) -> String? {
            guard let decryptedData = crypt(data: data, option: CCOperation(kCCDecrypt)) else { return nil }
            return String(bytes: decryptedData, encoding: .utf8)
        }
        
        /// Main Crypt function
        /// - Parameters:
        ///   - data: Data to (en/de)-crypt
        ///   - option: CCOperation(kCCEncrypt) for encryption | CCOperation(kCCDecrypt) for decryption
        /// - Returns: Data representation of processed message
        private func crypt(data: Data?, option: CCOperation) -> Data? {
            guard let data = data else { return nil }
            
            let cryptLength = data.count + kCCBlockSizeAES128
            var cryptData   = Data(count: cryptLength)
            
            let keyLength = key.count
            let options   = CCOptions(kCCOptionPKCS7Padding)
            
            var bytesLength = Int(0)
            
            let status = cryptData.withUnsafeMutableBytes { cryptBytes in
                data.withUnsafeBytes { dataBytes in
                    iv.withUnsafeBytes { ivBytes in
                        key.withUnsafeBytes { keyBytes in
                            CCCrypt(option, CCAlgorithm(kCCAlgorithmAES), options, keyBytes.baseAddress, keyLength, ivBytes.baseAddress, dataBytes.baseAddress, data.count, cryptBytes.baseAddress, cryptLength, &bytesLength)
                        }
                    }
                }
            }
            
            guard UInt32(status) == UInt32(kCCSuccess) else {
//                print("Error: Failed to crypt data. Status \(status)")
                return nil
            }
            
            cryptData.removeSubrange(bytesLength..<cryptData.count)
            return cryptData
        }
        //MARK: - Functions
        //MARK: Public
        /// Data Management
        /// - Parameters:
        ///   - message: String data to perform operation on
        ///   - key128: 16 bytes for AES128
        ///   - key256: 32 bytes for AES256
        ///   - iv: 16 bytes for AES128
        ///   - operation: encode (true) or decode (false)
        /// - Returns: string
        public static func data(
            message: String,
            _ key128: String = "3465232526323667",
            _ key256: String = "32456356356574653453264375468752",
            _ iv: String = "kjhasbdfkjhasdfk",
            operation: Bool = true
        ) -> String? {
            let aes256 = AES(key: key256, iv: iv)
            switch operation {
            case true:
                let encryptedmessage256 = aes256?.encrypt(string: message)
                return encryptedmessage256?.base64EncodedString()
            case false:
                let encryptedmessage256 = aes256?.decrypt(data: Data(base64Encoded: message))
                return encryptedmessage256
            }
        }
    }
    //MARK: - Defaults access functions
    //MARK: Public
    /// Save password
    /// - Parameter pwd: password string
    public class func savePassword(_ pwd: String) {
        defaults.set(AES.data(message: pwd, operation: true)!, forKey: "password")
    }
    
    /// Load password
    /// - Returns: returns password
    public class func loadPassword() -> String? {
        let pwd : String = defaults.string(forKey: "password") ?? ""
        let password = AES.data(message: pwd, operation: false)!
        return password
    }
    
    /// Removes password
    public class func removePassword() {
        defaults.removeObject(forKey: "password")
    }
    //MARK: - Initializer
    public override init() {}
}
