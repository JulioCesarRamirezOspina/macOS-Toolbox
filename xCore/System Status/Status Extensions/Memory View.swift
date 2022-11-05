//
//  Memory View.swift
//  xCore
//
//  Created by Олег Сазонов on 03.10.2022.
//

import Foundation
import SwiftUI

public class MemoryDisplay: xCore {
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
                    return .blue
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
                        Spacer()
                    }
                    HStack{
                        Group{
                            HStack {
                                Text(memoryPressure == .nominal ? StringLocalizer("memPressure.nominal") :
                                        memoryPressure == .warning ? StringLocalizer("memPressure.warning") :
                                        memoryPressure == .critical ? StringLocalizer("memPressure.critical") :
                                        StringLocalizer("memPressure.undefined"))
                                .fontWeight(memoryPressure == .warning ? .heavy : memoryPressure == .critical ? .black : .regular)
                            }
                            switch clensingInProgress {
                            case true:
                                HStack{
                                    Divider()
                                }.frame(height: 10)
                                Text("clensing.string").fontWeight(.heavy)
                            case false:
                                EmptyView()
                            }
                            if hovered && !clensingInProgress {
                                HStack {
                                    Divider()
                                }.frame(height: 10)
                                Text("clear_RAM.string")
                                    .fontWeight(.heavy)
                            }
                            if hovered && clensingInProgress {
                                HStack {
                                    Divider()
                                }.frame(height: 10)
                                Text("cancel.button")
                                    .fontWeight(.heavy)
                            }
                        }
                        .font(.footnote)
                        .foregroundColor(SettingsMonitor.textColor(cs))
                        Spacer()
                        HStack{
                            Spacer()
                            Text(Int(memory.used / memory.total * 100).description + "%")
                                .font(.footnote)
                                .bold((Int(memory.used / memory.total * 100)) > 60)
                                .foregroundColor(SettingsMonitor.textColor(cs))
                        }
                    }
                    .frame(height: 10)
                    .animation(SettingsMonitor.secondaryAnimation, value: clensingInProgress)
                    VStack{
                        GeometryReader { g in
                            CustomViews.MultiProgressBar(total: (label: !clensingInProgress ? String(Int(memory.used).description + " MB / " + Int(memory.total).description + " MB") : String(Int(memory.used / memory.total * 100).description + "%"), value: !clensingInProgress ? memory.total : 100),
                                                         values: clensingInProgress ? [
                                                            (label: "", value: Double(memory.used / memory.total * 100), color: (Int(memory.used / memory.total * 100)) < 50 ? .blue : .green)
                                                         ] : [],
                                                         intValues: !clensingInProgress ? [
                                                            (label: "active.string", value: Int(memory.active), color: .blue),
                                                            (label: "inactive.string", value: Int(memory.inactive), color: .gray),
                                                            (label: "wired.string", value: Int(memory.wired), color: .green),
                                                            (label: "compressed.string", value: Int(memory.compressed), color: (Color(nsColor: NSColor(#colorLiteral(red: 0.6953116059, green: 0.5059728026, blue: 0.9235290885, alpha: 1))))),
                                                            (label: "cachedFiles.string", value: Int(memory.cachedFiles), color: .brown)
                                                         ] : [],
                                                         widthFrame: g.size.width,
                                                         geometry: g.size)
                        }
                        Spacer()
                    }
                    HStack{
                        if !clensingInProgress {
                            HStack{
                                Rectangle()
                                    .frame(width: 10, height: 10, alignment: .center)
                                    .foregroundColor(.blue).shadow(radius: 2)
                                Text("\(StringLocalizer("active.string")): \(Int(memory.active).description) \(StringLocalizer("mib.string"))")
                                    .monospacedDigit()
                                    .font(.footnote)
                                    .foregroundColor(SettingsMonitor.textColor(cs))
                            }
                            HStack{
                                Rectangle()
                                    .frame(width: 10, height: 10, alignment: .center)
                                    .foregroundColor(.gray).shadow(radius: 2)
                                Text("\(StringLocalizer("inactive.string")): \(Int(memory.inactive).description) \(StringLocalizer("mib.string"))")
                                    .monospacedDigit()
                                    .font(.footnote)
                                    .foregroundColor(SettingsMonitor.textColor(cs))
                            }
                            HStack{
                                Rectangle()
                                    .frame(width: 10, height: 10, alignment: .center)
                                    .foregroundColor(.green).shadow(radius: 2)
                                Text("\(StringLocalizer("wired.string")): \(Int(memory.wired).description) \(StringLocalizer("mib.string"))")
                                    .monospacedDigit()
                                    .font(.footnote)
                                    .foregroundColor(SettingsMonitor.textColor(cs))
                            }
                            HStack{
                                Rectangle()
                                    .frame(width: 10, height: 10, alignment: .center)
                                    .foregroundColor(Color(nsColor: NSColor(
                                        #colorLiteral(red: 0.6953116059, green: 0.5059728026, blue: 0.9235290885, alpha: 1)
                                    ))).shadow(radius: 2)
                                Text("\(StringLocalizer("compressed.string")): \(Int(memory.compressed).description) \(StringLocalizer("mib.string"))")
                                    .monospacedDigit()
                                    .font(.footnote)
                                    .foregroundColor(SettingsMonitor.textColor(cs))
                            }
                            HStack{
                                Rectangle()
                                    .frame(width: 10, height: 10, alignment: .center)
                                    .foregroundColor(.brown).shadow(radius: 2)
                                Text("\(StringLocalizer("cachedFiles.string")): \(Int(memory.cachedFiles).description) \(StringLocalizer("mib.string"))")
                                    .monospacedDigit()
                                    .font(.footnote)
                                    .foregroundColor(SettingsMonitor.textColor(cs))
                            }
                            Spacer()
                        }
                    }
                }
                .padding(.all)
                .popover(isPresented: $sheetIsPresented, content: {
                    withAnimation(SettingsMonitor.secondaryAnimation) {
                        ClearRAMButtonSubView()
                    }
                })
                .background {
                    GeometryReader { g in
                        ZStack{
                            RoundedRectangle(cornerRadius: 15)
                                .foregroundColor(clensingInProgress ? .green : memory.free > memory.total / 2 && !hovered ? .clear : dynamicColor)
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
                .onHover { t in
                    if SettingsMonitor.passwordSaved {
                        hovered = t
                    }
                }
                .onAppear(perform: {
                    clensingInProgress = SettingsMonitor.memoryClensingInProgress
                })
                .onTapGesture {
                    if SettingsMonitor.passwordSaved && !clensingInProgress{
                        sheetIsPresented = true
                    } else if SettingsMonitor.passwordSaved && clensingInProgress {
                        Memory().ejectAll([StringLocalizer("clear_RAM.string")])
                        SettingsMonitor.memoryClensingInProgress = false
                        clensingInProgress = false
                    }
                }
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
                .glow(color: hovered && !clensingInProgress ? dynamicColor : .clear, anim: hovered)
                .animation(SettingsMonitor.secondaryAnimation, value: hovered)
                .onChange(of: SettingsMonitor.memoryClensingInProgress) { V in
                    clensingInProgress = V
                }
            }
            .animation(SettingsMonitor.secondaryAnimation, value: clensingInProgress)
        }
    }
}
