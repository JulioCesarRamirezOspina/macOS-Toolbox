//
//  Memory View.swift
//  xCore
//
//  Created by Олег Сазонов on 03.10.2022.
//

import Foundation
import SwiftUI
import Charts

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
//                HStack{
//                    Text("RAM")
//                    Spacer()
//                }
                VStack{
                    HStack{
                        Text("ramStatus.string")
                        Spacer()
                    }
                    HStack{
                        Group{
                            switch memoryPressure {
                            case .normal:
                                HStack{
                                    Text("memPressure")
                                    Text("memPressure.nominal")
                                }
                            case .warning:
                                HStack{
                                    Text("memPressure").fontWeight(.bold)
                                    Text("memPressure.warning").fontWeight(.bold)
                                }
                            case .critical:
                                HStack{
                                    Text("memPressure").fontWeight(.heavy)
                                    Text("memPressure.critical").fontWeight(.heavy)
                                }
                            case .undefined:
                                Text("memPressure.undefined")
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
                        .foregroundColor(.secondary)
                        Spacer()
                    }
                    .frame(height: 10)
                    .animation(SettingsMonitor.secondaryAnimation, value: clensingInProgress)
                    Chart {
                        Plot{
                            BarMark(
                                xStart: .value("Active", 0),
                                xEnd: .value("Active", Int(memory.total)),
                                y: .value("", 0),
                                height: 6
                            )
                            .foregroundStyle(Color(nsColor: NSColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.1)))
                            BarMark(
                                xStart: .value("Active", 0),
                                xEnd: .value("Active", Int(memory.active)),
                                y: .value("", 0),
                                height: 6
                            )
                            .foregroundStyle(.blue)
                            BarMark(
                                xStart: .value("Inactive", Int(memory.active)),
                                xEnd: .value("Inactive", Int(memory.inactive) + Int(memory.active)),
                                y: .value("", 0),
                                height: 6
                            )
                            .foregroundStyle(.gray)
                            BarMark(
                                xStart: .value("Wired", Int(memory.inactive) + Int(memory.active)),
                                xEnd: .value("Wired", Int(memory.inactive) + Int(memory.active) + Int(memory.wired)),
                                y: .value("", 0),
                                height: 6
                            )
                            .foregroundStyle(.green)
                            BarMark(
                                xStart: .value("Compressed", Int(memory.inactive) + Int(memory.active) + Int(memory.wired)),
                                xEnd: .value("Compressed", Int(memory.inactive) + Int(memory.active) + Int(memory.wired) + Int(memory.compressed)),
                                y: .value("", 0),
                                height: 6
                            )
                            .foregroundStyle(Color(nsColor: NSColor(
                                #colorLiteral(red: 0.6953116059, green: 0.5059728026, blue: 0.9235290885, alpha: 1)
                            )))
                            BarMark(
                                xStart: .value("Cached", Int(memory.inactive) + Int(memory.active) + Int(memory.wired) + Int(memory.compressed)),
                                xEnd: .value("Cached", Int(memory.inactive) + Int(memory.active) + Int(memory.wired) + Int(memory.compressed) + Int(memory.cachedFiles)),
                                y: .value("", 0),
                                height: 6
                            )
                            .foregroundStyle(.brown)
                        }
                    }
                    .chartXAxis(.hidden)
                    .chartYAxis(.hidden)
                    .shadow(radius: 2)
                    .frame(height: 10)
                    .animation(SettingsMonitor.secondaryAnimation, value: memory.used)
                    HStack{
                        Group{
                            Text(Int(memory.used).description + " MB / " + Int(memory.total).description + " MB")
                            Spacer()
                            Text("\(Int(Double().toPercent(fraction: memory.free, total: memory.total) * 100))%")
                        }
                        .monospacedDigit()
                        .font(.footnote)
                        .fontWeight(.light)
                        .foregroundColor(.secondary)
                    }
                    HStack{
                        HStack{
                            Rectangle()
                                .frame(width: 10, height: 10, alignment: .center)
                                .foregroundColor(.blue).shadow(radius: 2)
                            Text("\(StringLocalizer("active.string")): \(Int(memory.active).description) \(StringLocalizer("mib.string"))")
                                .monospacedDigit()
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                        HStack{
                            Rectangle()
                                .frame(width: 10, height: 10, alignment: .center)
                                .foregroundColor(.gray).shadow(radius: 2)
                            Text("\(StringLocalizer("inactive.string")): \(Int(memory.inactive).description) \(StringLocalizer("mib.string"))")
                                .monospacedDigit()
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                        HStack{
                            Rectangle()
                                .frame(width: 10, height: 10, alignment: .center)
                                .foregroundColor(.green).shadow(radius: 2)
                            Text("\(StringLocalizer("wired.string")): \(Int(memory.wired).description) \(StringLocalizer("mib.string"))")
                                .monospacedDigit()
                                .font(.footnote)
                                .foregroundColor(.secondary)
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
                                .foregroundColor(.secondary)
                        }
                        HStack{
                            Rectangle()
                                .frame(width: 10, height: 10, alignment: .center)
                                .foregroundColor(.brown).shadow(radius: 2)
                            Text("\(StringLocalizer("cachedFiles.string")): \(Int(memory.cachedFiles).description) \(StringLocalizer("mib.string"))")
                                .monospacedDigit()
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
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
