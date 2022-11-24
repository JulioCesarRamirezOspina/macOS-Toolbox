//
//  Drive Operations.swift
//  xCore
//
//  Created by Олег Сазонов on 08.09.2022.
//

import Foundation
import SwiftUI

public class DisksDisplay: xCore {
    
    public struct view: View {
        
        @State private var selfHovered: Array<Bool> = Array(repeating: false, count: 99)
        @State private var selfTapped: Array<Bool> = Array(repeating: false, count: 99)
        @State private var caches = ""
        @State private var clearResult = false
        @State private var cachesHover = false
        @State private var showClearCaches = false
        @Binding var emergencyPopover: Bool
        @Binding var isRun: Bool
        @State private var disksData = [DiskData(DiskLabel: "",
                                         FreeSpace: (0, .byte),
                                         UsedSpace: (0, .byte),
                                         TotalSpace: (0, .byte))]
        @Environment(\.colorScheme) var cs

        private func CancelButton(index: Int) -> some View {
            Button {
                selfTapped[index] = false
            } label: {
                Text("cancel.button")
            }
            .buttonStyle(Stylers.ColoredButtonStyle(glyph: "x.circle",
                                                    disabled: clearResult,
                                                    alwaysShowTitle: true,
                                                    color: .blue))
        }
        
        private func CachesButton() -> some View {
            Button {
                Task{
                    clearResult = await Memory().clearCaches().value
                    if !clearResult {
                        emergencyPopover = true
                    }
                }
                delay(after: 10) {
                    clearResult = false
                    showClearCaches = false
                }
            } label: {
                Text("clearCaches.string")
            }
            .onHover { t in
                cachesHover = t
            }
            .disabled(caches == "")
            .buttonStyle(Stylers.ColoredButtonStyle(glyph: "folder.badge.gearshape",
                                                    disabled: caches == "" || clearResult,
                                                    enabled: clearResult,
                                                    alwaysShowTitle: true,
                                                    color: clearResult ? .green : .cyan,
                                                    hideBackground: false,
                                                    backgroundShadow: true))
        }
        
        private func OpenInFinderButton(_ disk: String) -> some View {
            Button {
                let url = URL(filePath: "/Volumes/\(disk)")
                NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: url.path)
            } label: {
                Text("finder.text")
            }
            .buttonStyle(Stylers.ColoredButtonStyle(glyphs: ["faceid", "square"], alwaysShowTitle: true, color: .blue, render: .monochrome))
        }
                
        private func diskCheck() -> Task<[DiskData]?, Never> {
            Task{
                let fm = FileManager.default
                let root = "/Volumes"
                let rootFP = root + "/"
                var retval: [DiskData] = [DiskData(DiskLabel: "", FreeSpace: (0, .byte), UsedSpace: (0, .byte), TotalSpace: (0, .byte))]
                do {
                    let volumes = try fm.contentsOfDirectory(atPath: root)
                    for volume in volumes {
                        let url = URL(filePath: rootFP + volume)
                        let theVolSizeAvail = try url.resourceValues(forKeys: [.volumeSupportsVolumeSizesKey])
                        if let theVolSizeIsAvail = theVolSizeAvail.volumeSupportsVolumeSizes {
                            if theVolSizeIsAvail {
                                let theRes = try url.resourceValues(forKeys: [.volumeAvailableCapacityKey, .volumeTotalCapacityKey])
                                if let theCap = theRes.volumeAvailableCapacity {
                                    if let theTotal = theRes.volumeTotalCapacity {
                                        retval.append(DiskData(DiskLabel: volume,
                                                               FreeSpace: (convertValue(Double(theCap))),
                                                               UsedSpace: (convertValue(Double(theTotal - theCap))),
                                                               TotalSpace: (convertValue(Double(theTotal)))
                                                              ))
                                    }
                                }
                            }
                        }
                    }
                } catch let error {
                    print(error.localizedDescription)
                    return nil
                }
                retval = Array(retval.dropFirst())
                return retval
            }
        }
        
        private func singleToReadable(_ d: (Double, Unit)) -> String {
            return d.0.round(to: 2).description + " " + StringLocalizer(d.1 == Unit.megabyte ? "mib.string" : d.1 == Unit.gigabyte ? "gig.string" : d.1 == Unit.terabyte ? "tib.string" : "")
        }
        
        private func twoToReadable(_ freeData: (Double, Unit), _ totalData: (Double, Unit)) -> String {
            return "\(Int(Double().toPercent(fraction: freeData.1 == .gigabyte ? freeData.0.round(to: 2) * 1024 : freeData.1 == .terabyte ? freeData.0.round(to: 2) * 1024 * 1024 : freeData.0.round(to: 2), total: totalData.1 == .gigabyte ? totalData.0.round(to: 2) * 1024 : totalData.1 == .terabyte ? totalData.0.round(to: 2) * 1024 * 1024 : totalData.0.round(to: 2)) * 100))%"
        }
        
        private func toSingleFracture(_ d: (Double, Unit)) -> Double {
            return d.1 == .gigabyte ? d.0.round(to: 2) * 1024 : d.1 == .terabyte ? d.0.round(to: 2) * 1024 * 1024 : d.0.round(to: 2)
        }
        
        private func diskTile(_ title: String,
                              usedSpace: (Double, Unit),
                              freeSpace: (Double, Unit),
                              totalSpace: (Double, Unit),
                              tintColor: Color) -> some View {
            VStack{
                HStack{
                    Text(title)
                        .shadow(radius: 0)
                    Spacer()
                }
                GeometryReader { g in
                    CustomViews.MultiProgressBar(total: (label: "", value: toSingleFracture(totalSpace)), values: [(label: "", value: toSingleFracture(usedSpace), color: tintColor)], widthFrame: g.size.width, geometry: g.size)
                }
                HStack (spacing: 2) {
                    Group {
                        Text(singleToReadable(usedSpace))
                        TextDivider(height: 10, foregroundColor: SettingsMonitor.textColor(cs))
                        Text(singleToReadable(totalSpace))
                        Spacer()
                        Text(twoToReadable(freeSpace, totalSpace))
                    }
                    .frame(height: 10)
                    .font(.footnote)
                    .foregroundColor(SettingsMonitor.textColor(cs))
                    .monospacedDigit()
                }
            }
        }
        
        
        private func DiskForEach() -> some View {
            @State var h: CGFloat = 10
            @State var w: CGFloat = 10
            return ForEach(disksData.indices, id: \.self, content: { index in
                VStack{
                    if disksData[index].DiskLabel != StringLocalizer("clear_RAM.string") {
                        diskTile(disksData[index].DiskLabel == macOS_Subsystem().macOSDriveName() ?
                                 (caches == "" || caches == "\(StringLocalizer("userCaches.string")): 0 MB" ? "\(disksData[index].DiskLabel)" : "\(disksData[index].DiskLabel) | \(caches)") :
                                    disksData[index].DiskLabel,
                                 usedSpace: disksData[index].UsedSpace,
                                 freeSpace: disksData[index].FreeSpace,
                                 totalSpace: disksData[index].TotalSpace,
                                 tintColor: disksData[index].tintColor)
                        .frame(minWidth: 250, maxWidth: .greatestFiniteMagnitude, alignment: .center)
                        .padding(.all)
                        .onHover(perform: { t in
                            selfHovered[index] = t
                        })
                        .background {
                            ZStack{
                                RoundedRectangle(cornerRadius: 15)
                                    .foregroundColor(selfHovered[index] ? disksData[index].backgroundColor : disksData[index].clearedColor)
                                RoundedRectangle(cornerRadius: 15)
                                    .foregroundStyle(.ultraThinMaterial)
                                    .shadow(radius: 5)
                            }
                        }
                        .animation(SettingsMonitor.secondaryAnimation, value: caches)
                        .animation(SettingsMonitor.secondaryAnimation, value: selfHovered[index])
                        .popover(isPresented: $selfTapped[index]) {
                            DiskSheet(disksData: disksData, index: index)
                        }
                        .onTapGesture {
                            selfTapped[index] = true
                        }
                    }
                }
                .glow(color: selfHovered[index] || (Double().toPercent(fraction: disksData[index].FreeSpace.0, total: disksData[index].TotalSpace.0) * 100 >= 80) ? disksData[index].tintColor : .clear, anim: selfHovered[index])
            })
        }
        
        private func ejectDisk(label: String) {
            do {
                try Biometrics.execute(code: {
                    FileManager.default.unmountVolume(at: URL(filePath: "/Volumes/\(label)")) { err in
                        if err == nil {
                            NSLog("volume \"\(label)\" successfully unmounted")
                        } else {
                            NSLog("drive \"\(label)\": \(String(describing: err?.localizedDescription))")
                        }
                    }
                }, reason: StringLocalizer("eject.reason") + " \(label)")
            } catch let error {
                NSLog(error.localizedDescription)
            }
        }
        
        private func EjectDrive(label: String, _ index: Int) -> some View {
            VStack{
                Button {
                    ejectDisk(label: label)
                    selfTapped[index] = false
                } label: {
                    Text(SettingsMonitor.passwordSaved ? "ejectSingle.button" : "noPassword.string")
                }
                .buttonStyle(Stylers.ColoredButtonStyle(glyph: "eject",
                                                        disabled: !SettingsMonitor.passwordSaved,
                                                        enabled: false,
                                                        alwaysShowTitle: true,
                                                        color: .green,
                                                        hideBackground: false,
                                                        backgroundIsNotFill: true,
                                                        blurBackground: false,
                                                        backgroundShadow: true,
                                                        swapItems: false,
                                                        render: .monochrome))
            }
        }
        
        private func DiskSheet(disksData: [DiskData], index: Int) -> some View {
            VStack{
                if disksData[index].DiskLabel == macOS_Subsystem().macOSDriveName() {
                    VStack{
                        Text("choose.string").padding(.all).font(.title).fontWeight(.bold)
                        Divider()
                        VStack{
                            CachesButton()
                            OpenInFinderButton(disksData[index].DiskLabel)
                            CancelButton(index: index)
                        }.padding(.all)
                    }.backgroundStyle(.ultraThinMaterial)
                } else {
                    VStack{
                        Text("choose.string").padding(.all).font(.title).fontWeight(.bold)
                        Divider()
                        VStack{
                            EjectDrive(label: disksData[index].DiskLabel, index)
                            OpenInFinderButton(disksData[index].DiskLabel)
                            CancelButton(index: index)
                        }.padding(.all)
                    }.backgroundStyle(.ultraThinMaterial)
                }
            }
        }
        
        @State var twoColumns = Array.init(repeating: GridItem.init(.adaptive(minimum: 300, maximum: .greatestFiniteMagnitude),
                                                                 spacing: 0,
                                                                 alignment: .center),
                                        count: 2)
        @State var oneColumn = [GridItem.init(.adaptive(minimum: .greatestFiniteMagnitude, maximum: .greatestFiniteMagnitude),
                                              spacing: 0,
                                              alignment: .center)]

        public var body: some View {
            VStack{
                if disksData == DiskData.isEmpty {
                    HStack{
                        VStack{Divider()}
                        Text("volumesSearch.string").padding(.all)
                        VStack{Divider()}
                    }
                } else {
                    LazyVGrid(columns: disksData.count == 1 ? oneColumn : twoColumns, spacing: 20) {
                        DiskForEach().padding(.all)
                    }
                    .animation(SettingsMonitor.secondaryAnimation, value: disksData)
                }
            }
            .onAppear(perform: {
                isRun = true
            })
            .onDisappear(perform: {
                isRun = false
            })
            .task {
                repeat{
                    do {
                        disksData = await diskCheck().value ?? DiskData.isEmpty
                        try await Task.sleep(seconds: 3)
                    } catch _ {}
                }while(isRun)
            }
            .task {
                repeat{
                    do {
                        caches = await Memory().cachesSize().value
                        try await Task.sleep(seconds: 3)
                    } catch _ {}
                }while(isRun)
            }
        }
    }
}
