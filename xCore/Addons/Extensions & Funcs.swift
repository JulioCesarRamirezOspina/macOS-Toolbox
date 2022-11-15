//
//  Extensions.swift
//  BootCamper
//
//  Created by Олег Сазонов on 03.01.2022.
//

import Foundation
import SwiftUI
import LocalAuthentication

public extension Double {
    func toDegrees(fraction: Double, total: Double) -> Double {
        return (1 - toPercent(fraction: fraction, total: total)) * 360
    }
    func toPercent(fraction: Double, total: Double) -> Double {
        return (total - fraction) / total
    }
    func inRange(start: Double, end: Double) -> Bool {
        return (start...end).contains(self)
    }
}

public extension Float {
    func inRange(start: Float, end: Float) -> Bool {
        return (start...end).contains(self)
    }
}

extension Double {
    func round(to places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

//extension Double {
func convertValueRounded(_ v: Double, _ u: Unit = .byte) -> (Double, Unit) {
    var bytes = v
    switch u {
    case .byte:
        break
    case .kilobyte:
        bytes = bytes * 1000
    case .megabyte:
        bytes = bytes * 1000 * 1000
    case .gigabyte:
        bytes = bytes * 1000 * 1000 * 1000
    case .terabyte:
        bytes = bytes * 1000 * 1000 * 1000 * 1000
    }
    var kilobytes: Double {
        return Double(bytes) / 1000
    }
    
    var megabytes: Double {
        return kilobytes / 1000
    }
    
    var gigabytes: Double {
        return megabytes / 1000
    }
    
    var terabyte: Double {
        return gigabytes / 1000
    }

    switch bytes {
    case 0..<1000:
        return (bytes.rounded(), Unit.byte)
    case 1000..<(1000 * 1000):
        return (kilobytes.rounded(), Unit.kilobyte)
    case 1000..<(1000 * 1000 * 1000):
        return (megabytes.rounded(), Unit.megabyte)
    case 1000..<(1000 * 1000 * 1000 * 1000):
        return (gigabytes.rounded(), Unit.gigabyte)
    case (1000 * 1000 * 1000 * 1000)...(Double.greatestFiniteMagnitude):
        return (terabyte.rounded(), Unit.terabyte)
    default:
        return (bytes.rounded(), Unit.byte)
    }
}

func convertValue(_ v: Double) -> (Double, Unit) {
    let bytes = v
    var kilobytes: Double {
        return Double(bytes) / 1_024
    }
    
    var megabytes: Double {
        return kilobytes / 1_024
    }
    
    var gigabytes: Double {
        return megabytes / 1_024
    }
    
    var terabyte: Double {
        return gigabytes / 1_024
    }

    switch bytes {
    case 0..<1_024:
        return (bytes, Unit.byte)
    case 1_024..<(1_024 * 1_024):
        return (kilobytes, Unit.kilobyte)
    case 1_024..<(1_024 * 1_024 * 1_024):
        return (megabytes, Unit.megabyte)
    case 1_024..<(1_024 * 1_024 * 1_024 * 1_024):
        return (gigabytes, Unit.gigabyte)
    case (1_024 * 1_024 * 1_024 * 1_024)...(Double.greatestFiniteMagnitude):
        return (terabyte, Unit.terabyte)
    default:
        return (bytes, Unit.byte)
    }
}
//}

public extension StringProtocol {
    
    var byLines: [SubSequence] { components(separated: .byLines) }
    var byWords: [SubSequence] { components(separated: .byWords) }
    
    func components(separated options: String.EnumerationOptions)-> [SubSequence] {
        var components: [SubSequence] = []
        enumerateSubstrings(in: startIndex..., options: options) { _, range, _, _ in components.append(self[range]) }
        return components
    }
    
    /// Returns first word of string
    var firstWord: SubSequence? {
        var word: SubSequence?
        enumerateSubstrings(in: startIndex..., options: .byWords) { _, range, _, stop in
            word = self[range]
            stop = true
        }
        return word
    }
    /// Returns first line of multiline string
    var firstLine: SubSequence? {
        var line: SubSequence?
        enumerateSubstrings(in: startIndex..., options: .byLines) { _, range, _, stop in
            line = self[range]
            stop = true
        }
        return line
    }
}

public extension Bundle {
    var displayName: String? {
            return object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ??
                object(forInfoDictionaryKey: "CFBundleName") as? String
    }
}

extension URL {
    var fileSize: Int? { // in bytes
        do {
            let val = try self.resourceValues(forKeys: [.totalFileAllocatedSizeKey, .fileAllocatedSizeKey])
            return val.totalFileAllocatedSize ?? val.fileAllocatedSize
        } catch {
            return nil
        }
    }
    
    var isDirectory: Bool {
       (try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
    }
}

extension FileManager {
    func directorySize(_ dir: URL) -> Int? { // in bytes
        if let enumerator = self.enumerator(at: dir, includingPropertiesForKeys: [.totalFileAllocatedSizeKey, .fileAllocatedSizeKey], options: [], errorHandler: { (_, error) -> Bool in
//            print(error)
            return false
        }) {
            var bytes = 0
            for case let url as URL in enumerator {
                bytes += url.fileSize ?? 0
            }
            return bytes
        } else {
            return nil
        }
    }
}

/// needed for metronome app
public struct Config {
    let minimumValue: CGFloat
    let maximumValue: CGFloat
    let totalValue: CGFloat
    let knobRadius: CGFloat
    let radius: CGFloat
}

#if os(macOS)
protocol ScrollViewDelegateProtocol {
    /// Informs the receiver that the mouse’s scroll wheel has moved.
    func scrollWheel(with event: NSEvent);
}

/// The AppKit view that captures scroll wheel events
class AppKitScrollView: NSView {
    /// Connection to the SwiftUI view that serves as the interface to our AppKit view.
    var delegate: ScrollViewDelegateProtocol!
    /// Let the responder chain know we will respond to events.
    override var acceptsFirstResponder: Bool { true }
    /// Informs the receiver that the mouse’s scroll wheel has moved.
    override func scrollWheel(with event: NSEvent) {
        // pass the event on to the delegate
        delegate.scrollWheel(with: event)
    }
}
#endif

/// Generates UTM App logo


/// Wrapper to get other view's isCollapsed property
public struct SplitViewAccessor: NSViewRepresentable {
    public init(isCollapsed: Binding<Bool>){
        sideCollapsed = isCollapsed
    }
//    @Binding var sideCollapsed: Bool
    var sideCollapsed: Binding<Bool>
    public func makeNSView(context: Context) -> some NSView {
        let view = MyView()
        view.sideCollapsed = sideCollapsed
        return view
    }
    
    public func updateNSView(_ nsView: NSViewType, context: Context) {
    }
    
    class MyView: NSView {
        var sideCollapsed: Binding<Bool>?
        
        weak private var controller: NSSplitViewController?
        private var observer: Any?
        
        override func viewDidMoveToWindow() {
            super.viewDidMoveToWindow()
            var sview = self.superview
            
            // find split view through hierarchy
            while sview != nil, !sview!.isKind(of: NSSplitView.self) {
                sview = sview?.superview
            }
            guard let sview = sview as? NSSplitView else { return }
            
            controller = sview.delegate as? NSSplitViewController   // delegate is our controller
            if let sideBar = controller?.splitViewItems.first {     // now observe for state
                observer = sideBar.observe(\.isCollapsed, options: [.new]) { [weak self] _, change in
                    if let value = change.newValue {
                        self?.sideCollapsed?.wrappedValue = value    // << here !!
                    }
                }
            }
        }
    }
}




/// Delays execution of inserted code block
/// - Parameters:
///   - time: time delay
///   - codeBlock: code block
public func delay(after time: Double, execute codeBlock: @escaping () -> ()) {
    DispatchQueue.main.asyncAfter(deadline: .now() + time) {
        codeBlock()
    }
}

/// Gets Developer Installer ID if exists
/// - Returns: DevID and true/false value
public func tryToGetDeveloperIDInstallerSignature() -> (DevID: String, DevIDExists: Bool) {
    let process = Process()
    let pipe = Pipe()
    process.executableURL = URL(filePath: "/bin/bash")
    process.arguments = ["-c", "security find-identity -p basic -v"]
    process.standardOutput = pipe
    var retval = (DevID: "nil", DevIDExists: false)
    do {
        try process.run()
        process.waitUntilExit()
        let shellResult = String(data: pipe.fileHandleForReading.availableData, encoding: .utf8)!
        let parcing = shellResult.byLines
        for line in parcing {
            switch line.contains("Installer") {
            case true:
                let exactLine = line
                let indexOfDot = exactLine.firstIndex(of: ":")
                let suffix = exactLine.suffix(from: indexOfDot!)
                let readySuffix = String(suffix.dropFirst(2))
                retval = (DevID: String(readySuffix.dropLast(1)), DevIDExists: true)
            case false:
                break
            }
        }
        process.terminate()
    } catch let error {
        NSLog(error.localizedDescription)
    }
    return retval
}

public var devIDInstallerSignature: String? {
    get {
        let process = Process()
        let pipe = Pipe()
        var rv: String? = nil
        process.executableURL = URL(filePath: "/bin/bash")
        process.arguments = ["-c", "security find-identity -p basic -v"]
        process.standardOutput = pipe
        do {
            try process.run()
            process.waitUntilExit()
            let shellResult = String(data: pipe.fileHandleForReading.availableData, encoding: .utf8)!
            let parcing = shellResult.byLines
            for line in parcing {
                switch line.contains("Installer") {
                case true:
                    let exactLine = line
                    let indexOfDot = exactLine.firstIndex(of: ":")
                    let suffix = exactLine.suffix(from: indexOfDot!)
                    let readySuffix = String(suffix.dropFirst(2))
                    rv = String(readySuffix.dropLast(1))
                case false:
                    break
                }
            }
            process.terminate()
        } catch let error {
            NSLog(error.localizedDescription)
        }
        return rv
    }
}

/// Pops window with DIRECTORY ONLY selection
/// - Returns: folder URL
public func FolderPicker(_ defaultURL: URL) -> URL? {
    let panel = NSOpenPanel()
    let homeFolder = FileManager.default.homeDirectoryForCurrentUser
    var retval : URL = URL(fileURLWithPath: "", isDirectory: true)
    panel.allowsMultipleSelection = false
    panel.canChooseDirectories = true
    panel.canChooseFiles = false
    panel.directoryURL = homeFolder
    if panel.runModal() == .OK {
        retval = panel.url!
    } else {
        retval = defaultURL
    }
    return retval
}

/// Localizes string key
/// - Parameter str: string key to be localized (provide such key in Localizable.string file)
/// - Returns: localized string
public func StringLocalizer(_ str: String) -> String {
    return NSLocalizedString(str, comment: "")
}

public func Quit(_ AppDelegate: NSApplicationDelegate) {
    AppDelegate.applicationWillTerminate!(.init(name: NSApplication.willTerminateNotification, object: .none, userInfo: .none))
    exit(EXIT_SUCCESS)
}

extension Task where Success == Never, Failure == Never {
    static func sleep(seconds: Double) async throws {
        let duration = UInt64(seconds * 1_000_000_000)
        try await Task.sleep(nanoseconds: duration)
    }
}

func showInFinder(url: URL?) {
    guard let url = url else { return }
    
    if url.isDirectory {
        NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: url.path(percentEncoded: false))
    } else {
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }
}

public struct DiskData: Identifiable, Equatable {
    public static func == (lhs: DiskData, rhs: DiskData) -> Bool {
        return lhs.DiskLabel == rhs.DiskLabel &&
        lhs.TotalSpace == rhs.TotalSpace &&
        lhs.UsedSpace == rhs.UsedSpace &&
        lhs.tintColor == rhs.tintColor &&
        lhs.FreeSpace == rhs.FreeSpace
    }
    
    init(
        DiskLabel: String,
        FreeSpace: (Double, Unit),
        UsedSpace: (Double, Unit),
        TotalSpace: (Double, Unit)
    ) {
        func convertToG(_ x: (Double, Unit)) -> Double {
            switch x.1 {
            case .byte:
                return x.0 / 1024 / 1024 / 1024
            case .kilobyte:
                return x.0 / 1024 / 1024
            case .megabyte:
                return x.0 / 1024
            case .gigabyte:
                return x.0
            case .terabyte:
                return x.0 * 1024
            }
        }
        self.DiskLabel = DiskLabel
        self.FreeSpace = FreeSpace
        self.UsedSpace = UsedSpace
        self.TotalSpace = TotalSpace
        let percentage = Double().toPercent(fraction: convertToG(UsedSpace), total: convertToG(TotalSpace))
        if percentage < (1 - 0.8) {
            self.tintColor = .red
            self.backgroundColor = .brown
        } else if percentage < (1 - 0.5) {
            self.tintColor = .yellow
            self.backgroundColor = .orange
        } else {
            self.tintColor = Color(nsColor: NSColor(#colorLiteral(red: 0, green: 0.9767891765, blue: 0, alpha: 1)))
            self.backgroundColor = .blue
        }
    }
    public static let isEmpty = [DiskData(DiskLabel: "", FreeSpace: (0, .byte), UsedSpace: (0, .byte), TotalSpace: (0, .byte))]
    var DiskLabel: String
    var FreeSpace: (Double, Unit)
    var UsedSpace: (Double, Unit)
    var TotalSpace: (Double, Unit)
    var tintColor: Color
    var backgroundColor: Color = .blue
    var clearedColor: Color = .clear
    var tapped: Bool = false
    public let id = UUID()
}

extension BinaryInteger {
    public var isPowerOfTwo: Bool {
        return (self > 0) && (self & (self - 1) == 0)
    }
}

extension View {
   public func glow(color c: Color = .clear, anim: Bool = false, glowIntensity: GlowIntensity = .normal) -> some View {
        switch glowIntensity {
        case .normal:
            return self
                .shadow(color: ProcessInfo.processInfo.isLowPowerModeEnabled ? .clear : c, radius: ProcessInfo.processInfo.isLowPowerModeEnabled ? 0 : .pi)
                .shadow(color: ProcessInfo.processInfo.isLowPowerModeEnabled ? .clear : c, radius: ProcessInfo.processInfo.isLowPowerModeEnabled ? 0 : .pi)
                .shadow(color: ProcessInfo.processInfo.isLowPowerModeEnabled ? .clear : c, radius: ProcessInfo.processInfo.isLowPowerModeEnabled ? 0 : .pi)
                .animation(SettingsMonitor.secondaryAnimation, value: anim)
                .animation(SettingsMonitor.secondaryAnimation, value: c)

        case .moderate:
            return self
                .shadow(color: ProcessInfo.processInfo.isLowPowerModeEnabled ? .clear : c, radius: ProcessInfo.processInfo.isLowPowerModeEnabled ? 0 : .pi * 2)
                .shadow(color: ProcessInfo.processInfo.isLowPowerModeEnabled ? .clear : c, radius: ProcessInfo.processInfo.isLowPowerModeEnabled ? 0 : .pi * 2)
                .shadow(color: ProcessInfo.processInfo.isLowPowerModeEnabled ? .clear : c, radius: ProcessInfo.processInfo.isLowPowerModeEnabled ? 0 : .pi * 2)
                .animation(SettingsMonitor.secondaryAnimation, value: anim)
                .animation(SettingsMonitor.secondaryAnimation, value: c)

        case .hdr:
            return self
                .shadow(color: ProcessInfo.processInfo.isLowPowerModeEnabled ? .clear : c, radius: ProcessInfo.processInfo.isLowPowerModeEnabled ? 0 : .pi * 3)
                .shadow(color: ProcessInfo.processInfo.isLowPowerModeEnabled ? .clear : c, radius: ProcessInfo.processInfo.isLowPowerModeEnabled ? 0 : .pi * 3)
                .shadow(color: ProcessInfo.processInfo.isLowPowerModeEnabled ? .clear : c, radius: ProcessInfo.processInfo.isLowPowerModeEnabled ? 0 : .pi * 3)
                .animation(SettingsMonitor.secondaryAnimation, value: anim)
                .animation(SettingsMonitor.secondaryAnimation, value: c)

        case .extreme:
            return self
                .shadow(color: ProcessInfo.processInfo.isLowPowerModeEnabled ? .clear : c, radius: ProcessInfo.processInfo.isLowPowerModeEnabled ? 0 : .pi * 4)
                .shadow(color: ProcessInfo.processInfo.isLowPowerModeEnabled ? .clear : c, radius: ProcessInfo.processInfo.isLowPowerModeEnabled ? 0 : .pi * 4)
                .shadow(color: ProcessInfo.processInfo.isLowPowerModeEnabled ? .clear : c, radius: ProcessInfo.processInfo.isLowPowerModeEnabled ? 0 : .pi * 4)
                .animation(SettingsMonitor.secondaryAnimation, value: anim)
                .animation(SettingsMonitor.secondaryAnimation, value: c)

        case .slight:
            return self
                .shadow(color: ProcessInfo.processInfo.isLowPowerModeEnabled ? .clear : c, radius: ProcessInfo.processInfo.isLowPowerModeEnabled ? 0 : .pi / 2)
                .shadow(color: ProcessInfo.processInfo.isLowPowerModeEnabled ? .clear : c, radius: ProcessInfo.processInfo.isLowPowerModeEnabled ? 0 : .pi / 2)
                .shadow(color: ProcessInfo.processInfo.isLowPowerModeEnabled ? .clear : c, radius: ProcessInfo.processInfo.isLowPowerModeEnabled ? 0 : .pi / 2)
                .animation(SettingsMonitor.secondaryAnimation, value: anim)
                .animation(SettingsMonitor.secondaryAnimation, value: c)

        }
    }
}

public extension View {
    func onReceiveNotification(_ name: Notification.Name,
                   center: NotificationCenter = .default,
                   object: AnyObject? = nil,
                   perform action: @escaping (Notification) -> Void) -> some View {
        self.onReceive(
            center.publisher(for: name, object: object), perform: action
        )
    }
}

public extension View {
    func flipped(_ axis: directionalFlip = .horizontal, anchor: UnitPoint = .center) -> some View {
        switch axis {
        case .horizontal:
            return self.scaleEffect(CGSize(width: -1, height: 1), anchor: anchor)
        case .vertical:
            return self.scaleEffect(CGSize(width: 1, height: -1), anchor: anchor)
        case .none: return self.scaleEffect(CGSize(width: 1, height: 1), anchor: anchor)
        }
    }
}

public extension LAContext {
    enum BiometricType: String {
        case none
        case touchID
        case faceID
    }
    
    var biometricType: BiometricType {
        var error: NSError?
        
        guard self.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return .none
        }
        
        switch self.biometryType {
        case .none:
            return .none
        case .touchID:
            return .touchID
        case .faceID:
            return .faceID
        @unknown default:
            return .none
        }
    }
}
