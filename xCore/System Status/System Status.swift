//
//  System Status.swift
//  xCore
//
//  Created by Олег Сазонов on 07.08.2022.
//

import Foundation
import SwiftUI

public class SystemStatus: xCore {
    
    // MARK: - Power Buttons
    private struct Power {
        private enum activities {
            case shutDown
            case reboot
            case sleep
            case displayOff
        }
        
        private func actions(_ t: activities) {
            let pre = "tell application \"Finder\" to "
            var post = ""
            switch t {
            case .shutDown:
                post = "shut down"
                ScriptProcessing.launcher(script: pre + post)
            case .reboot:
                post = "restart"
                ScriptProcessing.launcher(script: pre + post)
            case .sleep:
                post = "sleep"
                ScriptProcessing.launcher(script: pre + post)
            case .displayOff:
                Shell.Parcer.oneExecutable(exe: "/bin/bash", args: ["-c", "pmset displaysleepnow"]) as Void
            }
        }
        
        private struct actionsStruct: Identifiable {
            var activity: activities
            var glyph: String
            var color: Color
            var description: String
            var actionDealy: Double
            let id = UUID()
        }
        
        public func buttons() -> some View {
            let buttons: [actionsStruct] = [
                .init(activity: .shutDown, glyph: "power", color: .red, description: "", actionDealy: 5),
                .init(activity: .reboot, glyph: "restart", color: .yellow, description: "", actionDealy: 5),
                .init(activity: .sleep, glyph: "sleep", color: .cyan, description: "", actionDealy: 1),
                .init(activity: .displayOff, glyph: "lock.display", color: .gray, description: "", actionDealy: 0)
            ]
            
            return ForEach(buttons) { button in
                if button.activity != .displayOff {
                    Button {} label: {}
                        .modifier(CustomViews.DualActionMod(tapAction: { Void() }, longPressAction: {
                            actions(button.activity)
                        },
                                                            frameSize: CGSize(width: 50, height: 50),
                                                            ltActionDelay: button.actionDealy))
                        .buttonStyle(Stylers.ColoredButtonStyle(glyph: button.glyph,
                                                                alwaysShowTitle: false,
                                                                width: 50, height: 50,
                                                                color: button.color,
                                                                hideBackground: true))
                } else {
                    Button { actions(button.activity) } label: { }
                        .buttonStyle(Stylers.ColoredButtonStyle(glyph: button.glyph,
                                                                alwaysShowTitle: false,
                                                                width: 50,
                                                                height: 50,
                                                                color: button.color,
                                                                hideBackground: true))
                }
            }
        }
    }
    
    public override init() { }
    //MARK: - Read-only calculated variables
    private static var modelName: StringData {
        get {
            let d = macOS_Subsystem.MacPlatform()
            let model = d.model
            let screenSize = d.screenSize
            let year = macOS_Subsystem.getModelYear().localizedString
            let yearString = year == "" ? "" : ", \(year)"
            return (model, screenSize + yearString)
        }
    }
    private static var processor: StringData {
        get {
            let p = macOS_Subsystem().cpuName()
            return (StringLocalizer("chip.string"), p)
        }
    }
    private static var memory: StringData {
        get {
            return (StringLocalizer("memory.string"), "\(Int(macOS_Subsystem.physicalMemory(.gigabyte))) \(StringLocalizer("gig.string"))")
        }
    }
    private static var bootDrive: StringData {
        get {
            return (StringLocalizer("bootDrive.string"), macOS_Subsystem().macOSDriveName()!)
        }
    }
    private static var macOSVer: StringData {
        get {
            return (StringLocalizer("macOS.string"), macOS_Subsystem.osVersion())
        }
    }
    private static var graphics: StringData {
        get {
            let GPUs = macOS_Subsystem.gpuName()
            var gpuLabels = ""
            
            for gpu in GPUs {
                gpuLabels += gpu + " "
            }
            
            return (StringLocalizer("graphics.string"), gpuLabels)
        }
    }
    private static var serial: StringData? {
        get {
            let platformExpert = IOServiceGetMatchingService(kIOMainPortDefault, IOServiceMatching("IOPlatformExpertDevice") )
            guard platformExpert > 0 else {
                return nil
            }
            guard let serialNumber = (IORegistryEntryCreateCFProperty(platformExpert, kIOPlatformSerialNumberKey as CFString, kCFAllocatorDefault, 0).takeUnretainedValue() as? String)?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) else {
                return nil
            }
            IOObjectRelease(platformExpert)
            return (StringLocalizer("serial.string"), serialNumber)
        }
    }
    //MARK: - Device Logo
    private static func deviceImage(scale: Double = 1) -> (image: Image, size: CGSize) {
        func resize(image: NSImage, w: Int, h: Int) -> NSImage {
            let destSize = NSMakeSize(CGFloat(w), CGFloat(h))
            let newImage = NSImage(size: destSize)
            newImage.lockFocus()
            image.draw(in: NSMakeRect(0, 0, destSize.width, destSize.height), from: NSMakeRect(0, 0, image.size.width, image.size.height), operation: .sourceOver, fraction: CGFloat(1))
            newImage.unlockFocus()
            newImage.size = destSize
            return NSImage(data: newImage.tiffRepresentation!)!
        }
        if SettingsMonitor.deviceImage == nil {
            let platform = macOS_Subsystem.MacPlatform()
            let device = platform.modelType
            let screenSize = String(platform.screenSizeInt)
            let manuYear = macOS_Subsystem.getModelYear().serviceData
            var deviceString = ""
            
            let prepend = "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/com.apple."
            
            switch device {
            case .iMac: deviceString = "imac"
            case .macBook: deviceString = "macbook"
            case .macBookAir: deviceString = "macbookair"
            case .macBookPro: deviceString = "macbookpro"
            case .macMini: deviceString = "macmini"
            case .macPro: deviceString = "macpro"
            default: deviceString = "questionmark"
            }
            
            let filesDirecory = URL(filePath: String(prepend.dropLast(10)))
            let iconCache = try? FileManager().contentsOfDirectory(at: filesDirecory, includingPropertiesForKeys: [])
            var height: CGFloat = 0
            var width: CGFloat = 0
            var imageSet = false
            var image = Image(systemName: "questionmark")
            var nsImage = NSImage(systemSymbolName: "quistionmark", variableValue: 1, accessibilityDescription: nil)
            for each in iconCache! {
                if each.absoluteString.contains(deviceString){
                    if each.absoluteString.contains(screenSize) {
                        if each.absoluteString.contains(manuYear) {
                            image = Image(nsImage: NSImage(contentsOf: each)!)
                            nsImage = NSImage(contentsOf: each)!
                            height = NSImage(contentsOf: each)!.size.height
                            width = NSImage(contentsOf: each)!.size.width
                            SettingsMonitor.deviceImage = each
                            imageSet = true
                        }
                    }
                }
            }
            if !imageSet {
                for each in iconCache! {
                    if each.absoluteString.contains(deviceString){
                        if each.absoluteString.contains(screenSize) {
                            image = Image(nsImage: NSImage(contentsOf: each)!)
                            nsImage = NSImage(contentsOf: each)!
                            height = NSImage(contentsOf: each)!.size.height
                            width = NSImage(contentsOf: each)!.size.width
                            SettingsMonitor.deviceImage = each
                        }
                    }
                }
            }
            NSLog("Image saved")
            if SettingsMonitor.isInMenuBar {
                return (image: Image(nsImage: resize(image: nsImage!, w: Int(nsImage!.size.width / scale), h: Int(nsImage!.size.height / scale))), size: CGSize(width: nsImage!.size.width, height: nsImage!.size.height))
            } else {
                return (image: image, size: CGSize(width: width, height: height))
            }
        } else {
            var height: CGFloat = NSImage(contentsOf: SettingsMonitor.deviceImage!)!.size.height
            var width: CGFloat = NSImage(contentsOf: SettingsMonitor.deviceImage!)!.size.width
            let nsImage = NSImage(contentsOf: SettingsMonitor.deviceImage!)
            if SettingsMonitor.isInMenuBar {
                height /= scale
                width /= scale
            }
            return (image: SettingsMonitor.isInMenuBar ? Image(nsImage: resize(image: nsImage!, w: Int(nsImage!.size.width / scale), h: Int(nsImage!.size.height / scale))) : Image(nsImage: NSImage(contentsOf: SettingsMonitor.deviceImage!)!), size: CGSize(width: width, height: height))
        }
    }
    
    // MARK: - Info View
    public struct InfoView: View {
        public init(toggle: Binding<Bool>, withButton: Bool = false) {
            _isMore = toggle
            self.showButton = withButton
        }
        @State var hovered = false
        @State var showSerial = SettingsMonitor.showSerialNumber
        @Binding var isMore: Bool
        @Environment(\.colorScheme) var cs
        var showButton: Bool
        
        private func viewGenerator() -> some View {
            VStack{
                if !SettingsMonitor.isInMenuBar {
                    Spacer().frame(height: 50)
                }
                ZStack{
                    deviceImage(scale: SettingsMonitor.isInMenuBar ? 2 : 1).image
                        .shadow(radius: 15)
                    if showButton {
                        Button {
                            isMore.toggle()
                        } label: {
                            Text("\(StringLocalizer("more.string").uppercased())")
                                .font(.title2)
                                .bold()
                                .shadow(radius: 5)
                                .foregroundColor(SettingsMonitor.textColor(cs))
                            //                                        .padding(.all)
                        }
                        .buttonStyle(Stylers.ColoredButtonStyle(alwaysShowTitle: false,
                                                                width: deviceImage(scale: SettingsMonitor.isInMenuBar ? 2 : 1).size.width / 1.5,
                                                                height: deviceImage(scale: SettingsMonitor.isInMenuBar ? 2 : 1).size.height / 2,
                                                                hideBackground: true))
                    }
                }.padding(.all)
                Text(modelName.label).font(.largeTitle)
                Text(modelName.value).font(.title3).foregroundColor(SettingsMonitor.textColor(cs))
                if !SettingsMonitor.isInMenuBar {
                    Spacer()
                }
                VStack{
                    HStack{
                        HStack{
                            Spacer()
                            Text(processor.label).shadow(radius: 5)
                        }
                        HStack{
                            Text(processor.value).shadow(radius: 5)
                                .foregroundColor(SettingsMonitor.textColor(cs))
                                .shadow(radius: 5)
                            Spacer()
                        }
                    }
                    HStack{
                        HStack{
                            Spacer()
                            Text(graphics.label).shadow(radius: 5)
                        }
                        HStack{
                            Text(graphics.value).shadow(radius: 5)
                                .foregroundColor(SettingsMonitor.textColor(cs))
                                .shadow(radius: 5)
                            Spacer()
                        }
                    }
                    HStack{
                        HStack{
                            Spacer()
                            Text(memory.label).shadow(radius: 5)
                        }
                        HStack{
                            Text(memory.value).shadow(radius: 5)
                                .foregroundColor(SettingsMonitor.textColor(cs))
                                .shadow(radius: 5)
                            Spacer()
                        }
                    }
                    HStack{
                        HStack{
                            Spacer()
                            Text(bootDrive.label).shadow(radius: 5)
                        }
                        HStack{
                            Text(bootDrive.value).shadow(radius: 5)
                                .foregroundColor(SettingsMonitor.textColor(cs))
                                .shadow(radius: 5)
                            Spacer()
                        }
                    }
                    HStack{
                        HStack{
                            Spacer()
                            Text(macOSVer.label).shadow(radius: 5)
                        }
                        HStack{
                            Text(macOSVer.value).shadow(radius: 5)
                                .foregroundColor(SettingsMonitor.textColor(cs))
                                .shadow(radius: 5)
                            Spacer()
                        }
                    }
                    HStack{
                        HStack{
                            Spacer()
                            Text(serial!.label).shadow(radius: 5)
                        }
                        HStack{
                            Text(serial?.value ?? "NaN").shadow(radius: 5)
                                .foregroundColor(SettingsMonitor.textColor(cs))
                                .shadow(radius: 5)
                                .blur(radius: showSerial || hovered ? 0 : 5)
                                .animation(SettingsMonitor.secondaryAnimation, value: hovered)
                                .onAppear(perform: {
                                    showSerial = SettingsMonitor.showSerialNumber
                                })
                                .onHover { b in
                                    hovered = b
                                }
                            Spacer()
                        }
                    }
                    Spacer()
                    if SettingsMonitor.isInMenuBar {
                        HStack{
                            Power().buttons().padding(.all)
                        }
                    }
                    if !SettingsMonitor.isInMenuBar {
                        Spacer()
                    }
                }
            }
        }
        
        private func inMenuBar() -> some View {
            viewGenerator()
        }
        
        private func inDock() -> some View {
            GeometryReader { g in
                SwiftUI.ScrollView(.vertical, showsIndicators: true) {
                    viewGenerator()
                }
            }
        }
        public var body: some View {
            if SettingsMonitor.isInMenuBar {
                inMenuBar()
            } else {
                inDock()
            }
        }
    }
    // MARK: - Status View
    public struct StatusView: View {
        public init(){}
        @State var isRun = false
        @State var width: CGFloat = 1
        @State var height: CGFloat = 50
        @State var emergencyPopover = false
        @Environment(\.colorScheme) var cs
        
        public var body: some View {
            Spacer().frame(height: 50)
            GeometryReader { g in
                VStack{
                    SwiftUI.ScrollView(.vertical, showsIndicators: true) {
                        DisksDisplay.view(emergencyPopover: $emergencyPopover, isRun: $isRun)
                            .padding(.all)
                        Divider()
                        CPUDisplay.view(isRun: $isRun)
                            .padding(.all)
                        Divider()
                        MemoryDisplay.view(isRun: $isRun)
                            .padding(.all)
                        Divider()
                        macOSUpdate.view(Geometry: CGSize(width: width, height: 100),
                                         HalfScreen: false,
                                         Alignment: .leading,
                                         ShowTitle: true)
                        .padding(.all)
                        Divider()
                        BatteryDisplay.view(isRun: $isRun)
                            .padding(.all)
                    }
                    .onAppear(perform: {
                        height = g.size.height / 12
                    })
                    .onChange(of: g.size.height, perform: { newValue in
                        height = newValue / 12
                    })
                    .frame(width: g.size.width, height: g.size.height, alignment: .center)
                }
            }
            .sheet(isPresented: $emergencyPopover, content: {
                VStack{
                    ZStack{
                        RoundedRectangle(cornerRadius: 15)
                            .foregroundStyle(.radialGradient(colors: [.blue, .blue, .cyan], center: .center, startRadius: 0, endRadius: 40))
                            .frame(width: 75, height: 75, alignment: .center)
                            .shadow(radius: 15)
                        Image(systemName: "lock.trianglebadge.exclamationmark.fill")
                            .symbolRenderingMode(.multicolor)
                            .foregroundStyle(.mint, .yellow)
                            .font(Font.custom("San Francisco", size: 40))
                    }
                    .padding(.all)
                    Spacer()
                    Text("NODISKACCESS")
                        .font(.title2)
                        .padding(.all)
                    Text("justForCaches.string")
                        .font(.title3)
                        .foregroundColor(SettingsMonitor.textColor(cs))
                        .padding(.all)
                    HStack{
                        Button {
                            Memory().openSecurityPrefPane()
                            emergencyPopover = false
                            exit(0)
                        } label: {
                            Text("openDiskAccessPrefPane.string")
                        }
                        .keyboardShortcut(.defaultAction)
                        Spacer()
                        Button {
                            emergencyPopover = false
                        } label: {
                            Text("cancel.button")
                        }
                        .keyboardShortcut(.cancelAction)
                    }.padding(.all)
                }
                .padding(.all)
                .backgroundStyle(.ultraThinMaterial)
            })
            .padding(.all)
            .onAppear(perform: {
                isRun = true
            })
            .onDisappear(perform: {
                isRun = false
            })
        }
    }
    // MARK: - Switcher View
    public struct Switcher: View {
        public init(toggleViews: Binding<Bool>, withButton: Bool) {
            _toggle = toggleViews
            self.withButton = withButton
        }
        @Binding var toggle: Bool
        var withButton: Bool
        public var body: some View {
            VStack{
                if toggle {
                    StatusView().transition(.push(from: toggle ? .top : .bottom))
                } else {
                    InfoView(toggle: $toggle, withButton: withButton).transition(.push(from: toggle ? .top : .bottom))
                }
            }
            .background(content: {
                if toggle {
                    RoundedRectangle(cornerRadius: 15)
                        .foregroundStyle(.ultraThinMaterial)
                        .shadow(radius: 5)
                        .transition(.push(from: toggle ? .top : .bottom))
                        .padding(.all)
                }
            })
            .animation(SettingsMonitor.secondaryAnimation, value: toggle)
        }
    }
}
