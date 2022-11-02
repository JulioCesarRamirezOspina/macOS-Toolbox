//
//  RAMDiskView.swift
//  MultiTool
//
//  Created by Олег Сазонов on 26.06.2022.
//

import Foundation
import SwiftUI
import xCore

struct RAMDiskView: View {
    @State private var volume = 0
    @State private var diskLabel = ""
    @State private var selection = 2
    @State private var percentage: Float = 0
    @State private var timer: Timer?
    @State private var isRun = false
    @State private var password = SettingsMonitor.password
    @State private var popoverIsPresented = false
    @State private var sheetIsPresented = false
    @State private var noRAMSheetIsPresented = false
    @State private var pickerDisabled = false
    @State private var prevValue = 1
    @State private var arr = [String]()
    @State private var drivesCreated = false
    @State private var count = 0
    @State private var c = ""
    @State private var clensingInProgress = false
    @State private var allRAMData = Memory.RAMData()
    private var textFont: Font {
        get {
            if SettingsMonitor.isInMenuBar {
                return Font.custom("San Francisco", size: NSScreen.main!.frame.size.width / 175)
            } else {
                return Font.body
            }
        }
    }
    private func getLabel(_ value: Int) -> some View {
        Text(value.description + " " + StringLocalizer("gig.string"))
    }
    
    private func isPowerOfTwo(_ n: Int) -> Bool {
        return (n > 0) && (n & (n - 1) == 0)
    }
    
    private func createButton(_ p: Int) -> AnyView{
        var retval = AnyView(EmptyView())
        if !clensingInProgress {
            if isPowerOfTwo(p) && ((p * 1024) < (Int(allRAMData.total) - Int(allRAMData.used))) {
                retval =  AnyView(VStack {Button(p.description + " " + StringLocalizer("gig.string")) {
                    if selection != p {
                        selection = p
                    } else {
                        selection = 0
                    }
                }
                    .buttonStyle(Stylers.ColoredButtonStyle(disabled: pickerDisabled || clensingInProgress, enabled: selection == p, alwaysShowTitle: true ,color: .cyan, backgroundIsNotFill: true))})
            }
        }
        return retval
    }
    
    private struct powerOfTwo: Identifiable {
        let id = UUID()
        var value: Int
    }
    
    private func SelectableInMenuBar() -> some View {
        var powers: [powerOfTwo] = []
        for each in 1...2045 {
            if each.isPowerOfTwo {
                powers.append(.init(value: each))
            }
        }
        return ScrollView(.horizontal, showsIndicators: true) {
            HStack{
                ForEach(powers) { i in
                    createButton(i.value)
                }
            }
        }
    }
    
    private func SelectableInDock() -> some View {
        var powers: [powerOfTwo] = []
        for each in 1...2045 {
            if each.isPowerOfTwo {
                powers.append(.init(value: each))
            }
        }

        return LazyHGrid(rows: [GridItem(.adaptive(minimum:100))]) {
            ForEach(powers) { i in
                createButton(i.value)
            }
        }
    }
    
    private func ejectAll(_ driveArray: [String]) {
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
        count = 0
    }
    
    private func EjectButton() -> some View {
        Button {
            ejectAll(arr)
            drivesCreated = false
            SettingsMonitor().delete(key: "drives")
            SettingsMonitor().delete(key: "lastMount")
        } label: {
            Text("eject.button")
        }
        .disabled(!drivesCreated)
        .buttonStyle(Stylers.ColoredButtonStyle(glyph: "externaldrive.badge.minus", disabled: !drivesCreated, enabled: drivesCreated, color: .red, backgroundIsNotFill: true))
    }
    
    private func Title(width: CGFloat, height: CGFloat) -> some View {
        VStack{
            HStack{
                ZStack{
                    Circle()
                        .stroke(style: .init(lineWidth: 10, lineCap: .round))
                        .frame(width: width / 4 - 20, height: width / 4 - 20, alignment: .center)
                        .foregroundColor(Color(nsColor: NSColor(#colorLiteral(red: 0, green: 0.5113993287, blue: 0.6703954339, alpha: 1))))
                        .blur(radius: 5)
                        .shadow(radius: 5)
                    Circle().trim(from: 0, to: 1 - Double().toPercent(fraction: allRAMData.cachedFiles, total: allRAMData.total))
                        .stroke(style: .init(lineWidth: 10, lineCap: .round))
                        .frame(width: width / 4 - 40, height: width / 4 - 40, alignment: .center)
                        .foregroundColor(Color(.brown))
                        .shadow(radius: 2)
//                        .rotationEffect(.degrees(
//                            toDegrees(fraction: allRAMData.active, total: allRAMData.total) +
//                            toDegrees(fraction: allRAMData.inactive, total: allRAMData.total) +
//                            toDegrees(fraction: allRAMData.wired, total: allRAMData.total) +
//                            toDegrees(fraction: allRAMData.compressed, total: allRAMData.total)
////
////                            toDegrees(fraction: allRAMData.used, total: allRAMData.total)
////                            360 - toDegrees(fraction: allRAMData.cachedFiles, total: allRAMData.total)
//                        ))
                    Circle().trim(from: 0, to: 1 - Double().toPercent(fraction: allRAMData.used, total: allRAMData.total))
                        .stroke(style: .init(lineWidth: 10, lineCap: .round))
                        .frame(width: width / 4 - 20, height: width / 4 - 20, alignment: .center)
                        .foregroundColor(Color(nsColor: NSColor(#colorLiteral(red: 0.850695312, green: 0.7329488397, blue: 0.9988698363, alpha: 1))))
                        .shadow(radius: 2)

                    Circle().trim(from: 0, to: 1 - Double().toPercent(fraction: allRAMData.active, total: allRAMData.total))
                        .stroke(style: .init(lineWidth: 10, lineCap: .round))
                        .frame(width: width / 4 - 20, height: width / 4 - 20, alignment: .center)
                        .foregroundColor(.blue)
                    //                                .rotationEffect(.degrees(
                    //                                    (1 - (allRAMData.total - allRAMData.used) / allRAMData.total) * 360 -
                    //                                    (1 - (allRAMData.total - allRAMData.active) / allRAMData.total) * 360
                    //                                ))
                        .shadow(radius: 2)

                    Circle().trim(from: 0, to: 1 - Double().toPercent(fraction: allRAMData.inactive, total: allRAMData.total))
                        .stroke(style: .init(lineWidth: 10, lineCap: .round))
                        .frame(width: width / 4 - 20, height: width / 4 - 20, alignment: .center)
                        .foregroundColor(.gray)
                        .rotationEffect(.degrees(
                            Double().toDegrees(fraction: allRAMData.active, total: allRAMData.total)
                            //                                    ((1 - (allRAMData.total - allRAMData.used) / allRAMData.total) * 360)
                        ))
                        .shadow(radius: 2)

                    Circle().trim(from: 0, to: 1 - Double().toPercent(fraction: allRAMData.wired, total: allRAMData.total))
                        .stroke(style: .init(lineWidth: 10, lineCap: .round))
                        .frame(width: width / 4 - 20, height: width / 4 - 20, alignment: .center)
                        .foregroundColor(.green)
                        .rotationEffect(.degrees(
                            Double().toDegrees(fraction: allRAMData.active, total: allRAMData.total) +
                            //                                    ((1 - (allRAMData.total - allRAMData.used) / allRAMData.total) * 360) +
                            Double().toDegrees(fraction: allRAMData.inactive, total: allRAMData.total)
                        ))
                        .shadow(radius: 2)

                    Circle().trim(from: 0, to: 1 - Double().toPercent(fraction: allRAMData.compressed, total: allRAMData.total))
                        .stroke(style: .init(lineWidth: 10, lineCap: .round))
                        .frame(width: width / 4 - 20, height: width / 4 - 20, alignment: .center)
                        .foregroundColor(Color(nsColor: NSColor(#colorLiteral(red: 0.6953116059, green: 0.5059728026, blue: 0.9235290885, alpha: 1))))
                        .rotationEffect(.degrees(
                            Double().toDegrees(fraction: allRAMData.active, total: allRAMData.total) +
                            //                                    ((1 - (allRAMData.total - allRAMData.used) / allRAMData.total) * 360) +
                            Double().toDegrees(fraction: allRAMData.inactive, total: allRAMData.total) +
                            Double().toDegrees(fraction: allRAMData.wired, total: allRAMData.total)
                        ))
                        .shadow(radius: 2)

                }
                .padding(.all)
            }
            .animation(SettingsMonitor.secondaryAnimation, value: allRAMData.used)
            .background {
                ZStack{
//                    Circle()
//                        .frame(width: width / 4 - 20, height: width / 4 - 20, alignment: .center)
//                        .foregroundColor(Color(nsColor: NSColor(#colorLiteral(red: 0, green: 0.09670206159, blue: 0.1206974462, alpha: 1))))
                    
                    Circle()
                        .frame(width: width / 4, height: width / 4, alignment: .center)
                        .foregroundStyle(.ultraThinMaterial)
                        .blur(radius: 5)
                        .shadow(radius: 5)
                }
            }
            .overlay(alignment: .center) {
                VStack{
                    HStack{
                        Text("\(StringLocalizer("totalRAM.string")): \(Int(allRAMData.total)) \(StringLocalizer("mib.string"))").monospacedDigit()
                            .foregroundColor(Color(nsColor: NSColor(#colorLiteral(red: 0, green: 0.5113993287, blue: 0.6703954339, alpha: 1))))
                            .font(textFont)
                    }
                    HStack{
                        Text("\(StringLocalizer("used.string")): \(Int(allRAMData.used)) \(StringLocalizer("mib.string"))").monospacedDigit()
                            .foregroundColor(Color(nsColor: NSColor(#colorLiteral(red: 0.850695312, green: 0.7329488397, blue: 0.9988698363, alpha: 1))))
                            .font(textFont)
                    }
                    HStack{
                        Text("\(StringLocalizer("active.string")): \(Int(allRAMData.active)) \(StringLocalizer("mib.string"))").monospacedDigit()
                            .foregroundColor(.blue)
                            .font(textFont)
                    }
                    HStack{
                        Text("\(StringLocalizer("inactive.string")): \(Int(allRAMData.inactive)) \(StringLocalizer("mib.string"))").monospacedDigit()
                            .foregroundColor(.gray)
                            .font(textFont)
                    }
                    HStack{
                        Text("\(StringLocalizer("wired.string")): \(Int(allRAMData.wired)) \(StringLocalizer("mib.string"))").monospacedDigit()
                            .foregroundColor(.green)
                            .font(textFont)
                    }
                    HStack{
                        Text("\(StringLocalizer("compressed.string")): \(Int(allRAMData.compressed)) \(StringLocalizer("mib.string"))").monospacedDigit()
                            .foregroundColor(Color(nsColor: NSColor(#colorLiteral(red: 0.6953116059, green: 0.5059728026, blue: 0.9235290885, alpha: 1))))
                            .font(textFont)
                    }
                    HStack{
                        Text("\(StringLocalizer("cachedFiles.string")): \(Int(allRAMData.cachedFiles)) \(StringLocalizer("mib.string"))").monospacedDigit()
                            .foregroundColor(Color(.brown))
                            .font(textFont)
                    }
                }
            }
        }
    }
        
    private func DiskTextField() -> some View {
        TextField("diskLabel.string", text: $diskLabel, onCommit: {
            Memory().createDisk((diskLabel == "") ? "\(StringLocalizer("drivePlaceholder.string")) \(volume) GB\(count == 0 ? "" : " \(count)")" : diskLabel, volume)
            if !drivesCreated {
                arr.removeAll(keepingCapacity: false)
                arr.append((diskLabel == "") ? "\(StringLocalizer("drivePlaceholder.string")) \(volume) GB\(count == 0 ? "" : " \(count)")" : diskLabel)
                if diskLabel == "" { count += 1 }
            } else {
                arr.append((diskLabel == "") ? "\(StringLocalizer("drivePlaceholder.string")) \(volume) GB\(count == 0 ? "" : " \(count)")" : diskLabel)
                if diskLabel == "" { count += 1 }
            }
            drivesCreated = true
        }).textFieldStyle(Stylers.GlassyTextField())
            .multilineTextAlignment(.center)
            .keyboardShortcut(.defaultAction)
            .disabled(clensingInProgress)
            .padding(.all)
    }
    
    private func CreateDiskButton() -> some View {
        Button {
            Memory().createDisk((diskLabel == "") ? "\(StringLocalizer("drivePlaceholder.string")) \(volume) GB\(count == 0 ? "" : " \(count)")" : diskLabel, volume)
            if !drivesCreated {
                arr.removeAll(keepingCapacity: false)
                arr.append((diskLabel == "") ? "\(StringLocalizer("drivePlaceholder.string")) \(volume) GB\(count == 0 ? "" : " \(count)")" : diskLabel)
                if diskLabel == "" { count += 1 }
            } else {
                arr.append((diskLabel == "") ? "\(StringLocalizer("drivePlaceholder.string")) \(volume) GB\(count == 0 ? "" : " \(count)")" : diskLabel)
                if diskLabel == "" { count += 1 }
            }
            UserDefaults().set(arr, forKey: "drives")
            UserDefaults().set(macOS_Subsystem.uptime().total, forKey: "lastMount")
            drivesCreated = true
            selection = 0
        } label: {
            Text("createDisk.string")
        }
        .buttonStyle(Stylers.ColoredButtonStyle(glyphs: clensingInProgress ? ["externaldrive.badge.plus","line.diagonal"] : ["externaldrive.badge.plus"],disabled: clensingInProgress || selection == 0, enabled: selection != 0, alwaysShowTitle: selection != 0, color: .blue, backgroundIsNotFill: true))
        .keyboardShortcut(.defaultAction)
        .disabled(pickerDisabled || clensingInProgress || selection == 0)
        .onHover { t in
            if pickerDisabled {
                if t {
                    noRAMSheetIsPresented = true
                } else {
                    noRAMSheetIsPresented = false
                }
            }
        }
        .popover(isPresented: $noRAMSheetIsPresented) {
            VStack{
                Text("noRAM.string").padding(.all).multilineTextAlignment(.center)
                
            }.backgroundStyle(.ultraThickMaterial)
        }
    }
    private func ClearRAMButtonSubView() -> some View {
        VStack{
            Text("ramSubview.string")
            Spacer()
            CustomViews.ImageView(imageName: "memorychip", opacity: 1, blurRadius: 0, defaultGradientColors: [.blue, .gray])
            Spacer()
            HStack {
                Button {
                    _ = Shell.Parcer.sudo("/usr/sbin/purge", [], password: password) as String
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//                        allRAMData.availableRAM = Memory().allRAMData.availableRAM
//                    }
                    sheetIsPresented = false
                } label: {
                    Text("clearRAMPages.string")
                }
                .keyboardShortcut(.defaultAction)
                Spacer()
                Button {
                    sheetIsPresented = false
                } label: {
                    Text("cancel.button")
                }
                .keyboardShortcut(.cancelAction)
                Spacer()
                Button {
                    clensingInProgress = true
                    Task {
                        clensingInProgress = await Memory().clearRAM().value
                    }
                    _ = Shell.Parcer.sudo("/usr/sbin/purge", [], password: password) as String
                    sheetIsPresented = false
                } label: {
                    Text("clearRAM.string")
                }
            }.padding(.all)
        }.padding(.all).backgroundStyle(.ultraThickMaterial)
    }
    
    private func CancelRAMClensing(size: CGSize) -> some View {
        Button {
            Memory().ejectAll([StringLocalizer("clear_RAM.string")])
            SettingsMonitor.memoryClensingInProgress = false
            clensingInProgress = false
        } label: {
            Text("cancel.button")
        }
        .buttonStyle(Stylers.ColoredButtonStyle(glyph: "memorychip", disabled: false, enabled: true, alwaysShowTitle: true, width: size.width - 10, height: size.height, color: .green))
    }
    
    private func ClearRAMButton(width: CGFloat, height: CGFloat) -> some View {
        Button {
            if password == "" {
                popoverIsPresented = true
            }
            if password != "" {
                sheetIsPresented = true
            }
        } label: {
            Text(clensingInProgress ? "clensing.string" : "clearRAM.string")
        }
        .buttonStyle(Stylers.ColoredButtonStyle(glyph: "memorychip", disabled: clensingInProgress, enabled: sheetIsPresented, alwaysShowTitle: clensingInProgress, width: width - 10, height: height, color: .green))
        .sheet(isPresented: $popoverIsPresented) {
            CustomViews.NoPasswordView(true, toggle: $popoverIsPresented)
        }
        .sheet(isPresented: $sheetIsPresented) {
            ClearRAMButtonSubView()
        }
        .disabled(clensingInProgress)
    }
    
    var body: some View {
        GroupBox {
            GeometryReader { gp in
                VStack {
                    if isRun {
                        VStack{
                            Group {
                                Title(width: gp.size.width, height: gp.size.height)
                            }
                            Group {
                                GeometryReader(content: { g in
                                    HStack{
                                        if !clensingInProgress {
                                            ClearRAMButton(width: g.size.width, height: g.size.height)
                                        } else {
                                            CancelRAMClensing(size: CGSize(width: g.size.width, height: g.size.height))
                                        }
                                    }
                                })
                                .frame(maxHeight: 100)
                                .padding(.all)
                            }
                            Group {
                                if SettingsMonitor.isInMenuBar {
                                    SelectableInMenuBar()
                                } else {
                                    SelectableInDock()
                                }
                            }
                            Spacer()
                            Group{
                                HStack{
                                    Spacer()
                                    CreateDiskButton()
                                    Spacer()
                                    EjectButton()
                                    Spacer()
                                }.padding(.all)
                            }
                        }
                    } else {
                        Spacer()
                    }
                }
            }
        } label: {
            if isRun {
                CustomViews.AnimatedTextView(Input: "\(StringLocalizer("ramStatus.string")):", TimeToStopAnimation: SettingsMonitor.secAnimDur)
            } else {
                Spacer()
            }
        }
        .groupBoxStyle(Stylers.CustomGBStyle())
        .onChange(of: allRAMData.used, perform: { newValue in
            Task {
                if (allRAMData.total - allRAMData.used) < 2048 {
                    pickerDisabled = true
                } else {
                    pickerDisabled = false
                    noRAMSheetIsPresented = false
                }
                if (allRAMData.total - allRAMData.used) < 2048 {
                    pickerDisabled = true
                } else {
                    pickerDisabled = false
                }
                if allRAMData.used == 1 {
                    pickerDisabled = true
                } else {
                    pickerDisabled = false
                }
            }
            
        })
        .task(priority: .background, {
            repeat {
                allRAMData = await Memory.RAMData()
                try? await Task.sleep(nanoseconds: 1000000000)
            }while(isRun)
        })
        .onAppear {
            if macOS_Subsystem.uptime().total < UserDefaults().integer(forKey: "lastMount") {
                UserDefaults().removeObject(forKey: "drives")
            }
            clensingInProgress = SettingsMonitor.memoryClensingInProgress
            password = SettingsMonitor.password
            let sval = UserDefaults().stringArray(forKey: "drives")
            arr = sval ?? []
            drivesCreated = !arr.isEmpty
            selection = 0
            volume = 2
            isRun = true
        }
        .onChange(of: selection, perform: { newValue in
            volume = newValue
        })
        .onDisappear {
            timer = nil
            password = ""
            isRun = false
        }
        .animation(SettingsMonitor.secondaryAnimation, value: drivesCreated)
        .animation(SettingsMonitor.secondaryAnimation, value: clensingInProgress)
        .animation(SettingsMonitor.secondaryAnimation, value: selection)
    }
}

struct RAMPreview: PreviewProvider {
    static var previews: some View{
        RAMDiskView().frame(width: 500, height: 500, alignment: .center)
    }
}
