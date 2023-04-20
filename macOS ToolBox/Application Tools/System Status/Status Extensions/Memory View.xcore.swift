//
//  Memory View.swift
//  xCore
//
//  Created by Олег Сазонов on 03.10.2022.
//

import Foundation
import SwiftUI

public class MemoryDisplay {
    public struct view: View {
        @State private var flash = false
        @State private var memory = Memory.RAMData()
        @State private var memoryPressure: MemoryPressure = .undefined
        @State private var sheetIsPresented = false
        @State private var clensingInProgress = false
        @State private var hovered = false
        @State private var width: CGFloat = 10
        @State private var height: CGFloat = 10
        @Binding var isRun: Bool
        @Environment(\.colorScheme) var cs
        var dynamicColor: Color {
            get {
                if memory.free > memory.total / 2 {
                    return .clear
                } else if memory.free <= memory.total / 2 {
                    return .yellow
                } else if memory.free <= memory.total / 4 {
                    return .red
                } else {
                    return .clear
                }
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
                        _ = Shell.Parcer.sudo("/usr/sbin/purge", [], password: SettingsMonitor.password) as String
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
                            _ = Shell.Parcer.sudo("/usr/sbin/purge", [], password: SettingsMonitor.password) as String
                            SettingsMonitor.memoryClensingInProgress = false
                            clensingInProgress = false
                        }
                        sheetIsPresented = false
                    } label: {
                        Text("clearRAM.string")
                    }
                }.padding(.all)
            }.padding(.all).backgroundStyle(.ultraThickMaterial)
        }
        public var body: some View {
            VStack{
                VStack{
                    HStack{
                        Text("ramStatus.string")
                            .shadow(radius: 0)
                        Spacer()
                    }
                    HStack{
                        Group{
                            HStack {
                                if hovered && !clensingInProgress {
                                    Text("clear_RAM.string")
                                        .fontWeight(.heavy)
                                        .shadow(radius: 0)
                                } else
                                if hovered && clensingInProgress {
                                    Text("cancel.button")
                                        .fontWeight(.heavy)
                                        .shadow(radius: 0)
                                } else {
                                    
                                    Text(memoryPressure == .nominal ? StringLocalizer("memPressure.nominal") :
                                            memoryPressure == .warning ? StringLocalizer("memPressure.warning") :
                                            memoryPressure == .critical ? StringLocalizer("memPressure.critical") :
                                            StringLocalizer("memPressure.undefined"))
                                    .fontWeight(memoryPressure == .warning ? .heavy : memoryPressure == .critical ? .black : .regular)
                                    .shadow(radius: 0)
                                }
                            }
                            switch clensingInProgress {
                            case true:
                                TextDivider(height: 10)
                                Text("clensing.string")
                                    .fontWeight(.heavy)
                                    .shadow(radius: 0)
                            case false:
                                EmptyView()
                            }
                        }
                        .font(.footnote)
                        .foregroundColor(hovered ? .primary : SettingsMonitor.textColor(cs))
                        Spacer()
                        HStack{
                            Spacer()
                            Text(Int(memory.used / memory.total * 100).description + "%")
                                .font(.footnote)
                                .bold((Int(memory.used / memory.total * 100)) > 60)
                                .foregroundColor(SettingsMonitor.textColor(cs))
                                .shadow(radius: 0)
                        }
                    }
                    .frame(height: 10)
                    .animation(SettingsMonitor.secondaryAnimation, value: clensingInProgress)
                    VStack{
                        GeometryReader { g in
                            CustomViews.MultiProgressBar(total: (label: !clensingInProgress ? String(Int(memory.used).description + " MB / " + Int(memory.total).description + " MB") : String(Int(memory.used / memory.total * 100).description + "%"), value: !clensingInProgress ? memory.total : 100),
                                                         values: clensingInProgress ? [
                                                            (label: "", value: Double(memory.used / memory.total * 100), color: (Int(memory.used / memory.total * 100)) < 50 ? .blue : .green)
                                                         ] : [
                                                            (label: "active.string", value: Double(memory.active), color: .blue),
                                                            (label: "inactive.string", value: Double(memory.inactive), color: .gray),
                                                            (label: "wired.string", value: Double(memory.wired), color: .green),
                                                            (label: "compressed.string", value: Double(memory.compressed), color: (Color(nsColor: NSColor(#colorLiteral(red: 0.6953116059, green: 0.5059728026, blue: 0.9235290885, alpha: 1))))),
                                                            (label: "cachedFiles.string", value: memory.cachedFiles < (memory.total - (memory.active +
                                                                                                                        memory.inactive +
                                                                                                                        memory.wired +
                                                                                                                        memory.compressed)) ? Double(memory.cachedFiles) :
                                                             Double(memory.total - (memory.active +
                                                                                    memory.inactive +
                                                                                    memory.wired +
                                                                                    memory.compressed)), color: .brown)
                                                         ],
                                                         widthFrame: g.size.width,
                                                         geometry: g.size,
                                                         popOnHover: true)
                        }
                        Spacer()
                    }
                }
                .padding(.all)
                .overlayButton(popover: AnyView(ClearRAMButtonSubView()), popoverIsPresented: $sheetIsPresented, action: {
                    if SettingsMonitor.passwordSaved && !clensingInProgress{
                        sheetIsPresented = true
                    } else if SettingsMonitor.passwordSaved && clensingInProgress {
                        Memory().ejectAll([StringLocalizer("clear_RAM.string")])
                        SettingsMonitor.memoryClensingInProgress = false
                        clensingInProgress = false
                    }
                }, enabledGlyph: "circle.circle.fill", disabledGlyph: "circle.circle.fill", enabledColor: .yellow, disabledColor: .yellow, hoveredColor: .yellow, selfHovered: $hovered, backwardHovered: $hovered, enabled: $clensingInProgress, showPopover: false)
                .background {
                    GeometryReader { g in
                        ZStack{
                            RoundedRectangle(cornerRadius: 15)
                                .foregroundColor(dynamicColor)
                            RoundedRectangle(cornerRadius: 15)
                                .foregroundStyle(.ultraThinMaterial)
                                .shadow(radius: 5)
                        }.onAppear {
                            width = g.size.width
                            height = g.size.height
                        }
                        .onChange(of: g.size) { newValue in
                            width = newValue.width
                            height = newValue.height
                        }
                    }
                }
                .onAppear(perform: {
                    clensingInProgress = SettingsMonitor.memoryClensingInProgress
                })
                .task(priority: .background, {
                    repeat {
                        do {
                            memory = await Memory.RAMData()
                            try await Task.sleep(seconds: clensingInProgress ? 1 : 2)
                        } catch _ {}
                        if !isRun {break}
                    }while(isRun)
                })
                .task(priority: .background, {
                    repeat {
                        do {
                            memoryPressure = await Memory().memoryPressure().value
                            try await Task.sleep(seconds: clensingInProgress ? 1 : 2)
                        } catch _ {}
                        if !isRun {break}
                    }while(isRun)
                })
                .animation(SettingsMonitor.secondaryAnimation, value: hovered)
                .onChange(of: SettingsMonitor.memoryClensingInProgress) { V in
                    clensingInProgress = V
                }
            }
            .padding(.all)
            .animation(SettingsMonitor.secondaryAnimation, value: clensingInProgress)
        }
    }
}
