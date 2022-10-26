//
//  System Status.swift
//  xCore
//
//  Created by Олег Сазонов on 07.08.2022.
//

import Foundation
import SwiftUI

public class SystemStatus: xCore {
    
    public override init() { }
    
    typealias stringData = (label: String, value: String)
    
    //MARK: - Read-only calculated variables
    private static var modelName: stringData {
        get {
            let d = macOS_Subsystem.MacPlatform()
            let model = d.model
            let screenSize = d.screenSize
            let year = macOS_Subsystem.getModelYear().localizedString
            return (model, screenSize + ", \(year)")
        }
    }
    private static var processor: stringData {
        get {
            let p = macOS_Subsystem().cpuName()
            return (StringLocalizer("chip.string"), p)
        }
    }
    private static var memory: stringData {
        get {
            return (StringLocalizer("memory.string"), "\(Int(macOS_Subsystem.physicalMemory(.gigabyte))) \(StringLocalizer("gig.string"))")
        }
    }
    private static var bootDrive: stringData {
        get {
            return (StringLocalizer("bootDrive.string"), macOS_Subsystem().macOSDriveName()!)
        }
    }
    private static var macOSVer: stringData {
        get {
            return (StringLocalizer("macOS.string"), macOS_Subsystem.osVersion())
        }
    }
    private static var graphics: stringData {
        get {
            let GPUs = macOS_Subsystem().gpuName()
            var gpuLabels = ""
            
            for gpu in GPUs {
                gpuLabels += gpu + " "
            }
            
            return (StringLocalizer("graphics.string"), gpuLabels)
        }
    }
    private static var serial: stringData? {
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
    // MARK: - functions
    private static func deviceLogo() -> some View {
        let device = macOS_Subsystem.MacPlatform().modelType
        var imageName = "person.and.background.dotted"
        let desktop = "desktopcomputer"
        let book = "laptopcomputer"
        let mini = "macmini"
        let pro = "macpro.gen3"
        switch device {
        case .iMac: imageName = desktop
        case .macBook, .macBookAir, .macBookPro: imageName = book
        case .macMini: imageName = mini
        case .macPro: imageName = pro
        default: imageName = "questionmark"
        }
        return CustomViews.ImageView(imageName: imageName, opacity: 1, blurRadius: 0)
    }
    
    private static func deviceImage() -> Image {
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
            
            var image = Image(systemName: "questionmark")
            for each in iconCache! {
                if each.absoluteString.contains(deviceString){
                    if each.absoluteString.contains(screenSize) {
                        if each.absoluteString.contains(manuYear) {
                            image = Image(nsImage: NSImage(contentsOf: each)!)
                            SettingsMonitor.deviceImage = each
                        }
                    }
                }
            }
            return image
        } else {
            return Image(nsImage: NSImage(contentsOf: SettingsMonitor.deviceImage!)!)
        }
    }
    
    private struct SystemDataView: View {
        @State var stringDataArray: [stringData]
        @State var hovered = false
        var body: some View {
            ForEach(0..<stringDataArray.count, id: \.self) { index in
                HStack{
                    HStack{
                        Spacer()
                        Text(stringDataArray[index].label).shadow(radius: 5)
                    }
                    HStack{
                        Text(stringDataArray[index].value).foregroundColor(.secondary).shadow(radius: 5).blur(radius: !hovered && index == stringDataArray.count - 1 ? 5 : 0).animation(SettingsMonitor.secondaryAnimation, value: hovered)
                        Spacer()
                    }
                    .onHover { b in
                        if index == stringDataArray.count - 1 {
                            hovered = b
                        }
                    }
                }
            }
        }
    }
    // MARK: - Info View
    public struct InfoView: View {
        public init() {}
        @State var hovered = false
        public var body: some View {
            VStack{
                Spacer().frame(height: 50)
                deviceImage().shadow(radius: 15).padding(.all)
                Text(modelName.label).font(.largeTitle)
                Text(modelName.value).font(.title3).foregroundColor(.secondary)
                Spacer()
                SystemDataView(stringDataArray: [processor, graphics, memory, bootDrive, macOSVer, serial!], hovered: hovered)
                Spacer()
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
        
        public var body: some View {
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
                        .foregroundColor(.secondary)
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
        public init(toggleViews: Binding<Bool>) {
            _toggle = toggleViews
        }
        @Binding var toggle: Bool
        public var body: some View {
            VStack{
                if toggle {
                    StatusView().transition(.asymmetric(insertion: .push(from: .top), removal: .push(from: .bottom)))
                } else {
                    InfoView().transition(.asymmetric(insertion: .push(from: .top), removal: .push(from: .bottom)))
                }
            }
            .background(content: {
                if toggle {
                    RoundedRectangle(cornerRadius: 15)
                        .foregroundStyle(.ultraThinMaterial)
                        .shadow(radius: 5)
                        .transition(.asymmetric(insertion: .push(from: .top), removal: .push(from: .bottom)))
                }
            })
            .animation(SettingsMonitor.secondaryAnimation, value: toggle)
        }
    }

}

struct SystemStatusPreview: PreviewProvider {
    static var previews: some View {
        SystemStatus.StatusView()
    }
}
