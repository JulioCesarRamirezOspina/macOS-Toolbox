//
//  CPU View.swift
//  xCore
//
//  Created by Олег Сазонов on 07.10.2022.
//

import Foundation
import SwiftUI
import Charts

public class CPUDisplay: xCore {
    public struct view: View {
        @State private var cpuValue: (user: Double, system: Double, idle: Double, total: Double) = (0,0,0,0)
        @Binding var isRun: Bool
        
        private func loadData() async -> Task<(user: Double, system: Double, idle: Double, total: Double), Never> {
            Task{
                let data = macOS_Subsystem().getCPURealUsage()
                return (user: data.user, system: data.system, idle: data.idle, total: data.total)
            }
        }
        
        public var body: some View {
            VStack{
                HStack {
                    Text("CPU")
                    Spacer()
                }
                ZStack{
                    VStack{
                        HStack{
                            Text(StringLocalizer("cpuLoad.string"))
                            Spacer()
                        }
                        HStack{
                            Text(macOS_Subsystem().cpuName())
                                .font(.footnote)
                                .foregroundColor(.secondary)
                                .monospacedDigit()
                            HStack{
                                Divider()
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                                    .monospacedDigit()
                            }.frame(height: 10)
                            Text("\(StringLocalizer("coresCount.string")): \(macOS_Subsystem.logicalCores())")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                                .monospacedDigit()
                            Spacer()
                        }
                        Chart {
                            Plot {
                                BarMark(
                                    xStart: .value("total", 0),
                                    xEnd: .value("total", 100),
                                    y: .value("", 0),
                                    height: 6
                                )
                                .foregroundStyle(Color(nsColor: NSColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.1)))
                                BarMark(
                                    xStart: .value("user", 0),
                                    xEnd: .value("user", Int(cpuValue.user)),
                                    y: .value("", 0),
                                    height: 6
                                )
                                .foregroundStyle(.blue)
                                BarMark(
                                    xStart: .value("system", Int(cpuValue.user)),
                                    xEnd: .value("system", Int(cpuValue.user) + Int(cpuValue.system)),
                                    y: .value("", 0),
                                    height: 6
                                )
                                .foregroundStyle(.red)
                                
                            }
                        }
                        .chartXAxis(.hidden)
                        .chartYAxis(.hidden)
                        .shadow(radius: 2)
                        .frame(height: 10)
                        .animation(SettingsMonitor.secondaryAnimation, value: cpuValue.user)
                        HStack{
                            Text(StringLocalizer("load.string") + ": " + (Double(cpuValue.user * 100 + cpuValue.system * 100) / 100).description + "%" )
                                .font(.footnote)
                                .foregroundColor(.secondary)
                                .monospacedDigit()
                            HStack{
                                Divider()
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                                    .monospacedDigit()
                            }.frame(height: 10)
                            Text(StringLocalizer("user.string") + ": \(cpuValue.user)%")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                                .monospacedDigit()
                            HStack{
                                Divider()
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                                    .monospacedDigit()
                            }.frame(height: 10)
                            Text(StringLocalizer("system.string") + ": \(cpuValue.system)%")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                                .monospacedDigit()
                            Spacer()
                            Text("100%")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                                .monospacedDigit()
                        }
                    }
                    .padding(.all)
                }
                .background {
                    RoundedRectangle(cornerRadius: 15)
                        .foregroundStyle(.ultraThinMaterial)
                        .shadow(radius: 5)
                }
                .task {
                    repeat {
                        cpuValue = await loadData().value
                        do {
                            try await Task.sleep(seconds: 1)
                        } catch _ {}
                        if !isRun {break}
                    }while(isRun)
                }
            }
        }
    }
}
