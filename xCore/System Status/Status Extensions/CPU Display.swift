//
//  CPU View.swift
//  xCore
//
//  Created by Олег Сазонов on 07.10.2022.
//

import Foundation
import SwiftUI

public class CPUDisplay: xCore {
    public struct view: View {
        @Environment(\.colorScheme) var cs
        @State private var cpuValue: (user: Double, system: Double, idle: Double, total: Double) = (0,0,0,0)
        @Binding var isRun: Bool
        @State private var thermals: ThermalData = ("", state: .undefined)
        private var dynamicColor: Color {
            switch thermals.state {
            case .nominal:
                return .clear
            case .fair:
                return .yellow
            case .serious:
                return .orange
            case .critical:
                return .red
            case .undefined:
                return .clear
            case .noPassword:
                return .clear
            }
        }
        
        private func loadData() async -> Task<(user: Double, system: Double, idle: Double, total: Double), Never> {
            Task{
                let data = macOS_Subsystem().getCPURealUsage()
                return (user: data.user, system: data.system, idle: data.idle, total: data.total)
            }
        }

        public var body: some View {
            VStack{
                ZStack{
                    VStack{
                        HStack{
                            Text(StringLocalizer("cpuLoad.string"))
                            Spacer()
                        }
                        HStack{
                            Text(macOS_Subsystem().cpuName())
                                .font(.footnote)
                                .foregroundColor(SettingsMonitor.textColor(cs))
                                .monospacedDigit()
                            HStack{
                                Divider()
                                    .font(.footnote)
                                    .foregroundColor(SettingsMonitor.textColor(cs))
                                    .monospacedDigit()
                            }.frame(height: 10)
                            Text("\(StringLocalizer("coresCount.string")): \(macOS_Subsystem.logicalCores())")
                                .font(.footnote)
                                .foregroundColor(SettingsMonitor.textColor(cs))
                                .monospacedDigit()
                            if SettingsMonitor.passwordSaved {
                                HStack{
                                    Divider()
                                        .font(.footnote)
                                        .foregroundColor(SettingsMonitor.textColor(cs))
                                        .monospacedDigit()
                                }.frame(height: 10)
                                Text(thermals.label)
                                    .font(.footnote)
                                    .bold(thermals.state == .fair || thermals.state == .critical || thermals.state == .serious)
                                    .foregroundColor(SettingsMonitor.textColor(cs))
                                    .monospacedDigit()
                            }
                            Spacer()
                        }
                        VStack{
                            GeometryReader { g in
                                CustomViews.MultiProgressBar(total: (label: "load.string", value: cpuValue.user + cpuValue.system), values: [("user.string", cpuValue.user, .blue), ("system.string", cpuValue.system, .red)], widthFrame: g.size.width, showDots: false, geometry: g.size)
                            }
                            Spacer()
                        }
                    }
                    .padding(.all)
                }
                .background {
                    RoundedRectangle(cornerRadius: 15)
                        .foregroundColor(dynamicColor)
                    RoundedRectangle(cornerRadius: 15)
                        .foregroundStyle(.ultraThinMaterial)
                        .shadow(radius: 5)
                }
                .glow(color: dynamicColor, anim: true, glowIntensity:
                        thermals.state == .nominal ? .normal :
                        thermals.state == .fair ? .normal :
                        thermals.state == .serious ? .moderate : .extreme)
                .task {
                    repeat {
                        cpuValue = await loadData().value
                        do {
                            try await Task.sleep(seconds: 1)
                        } catch _ {}
                        if !isRun {break}
                    }while(isRun)
                }
                .task {
                    repeat {
                        thermals = await macOS_Subsystem.ThermalMonitor().asyncRun().value
                        try? await Task.sleep(seconds: 5)
                        if !isRun {break}
                    } while(isRun)
                }
                .animation(SettingsMonitor.secondaryAnimation, value: thermals.state)
            }
        }
    }
}
