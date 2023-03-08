//
//  Battery.swift
//  xCore
//
//  Created by Олег Сазонов on 03.10.2022.
//

import Foundation
import SwiftUI

public class BatteryDisplay: xCore {
    public struct view: View {
        @Environment(\.colorScheme) var cs
        @State private var PowerSource: PowerSource = .unknown
        @State private var ChargingState: ChargingState = .unknown
        @State private var Percentage: Float = 100
        @State private var TotalPercentage: Float = 100
        @State private var TimeRemaining: String = ""
        @State private var hovered2 = false
        @State private var width: CGFloat = 10
        @State private var height: CGFloat = 10
        @State private var tempUnit: UnitTemperature = SettingsMonitor.temperatureUnit
        @State private var temp = macOS_Subsystem.BatteryTemperature(TermperatureUnit: SettingsMonitor.temperatureUnit)
        @State private var isInLowPower = ProcessInfo.processInfo.isLowPowerModeEnabled
        @State private var dummy: Bool = false
        @Binding var isRun: Bool
        var dynamicColor: Color {
            get {
                if isInLowPower && Percentage > 20 {
                    return .mint
                } else if Percentage.inRange(start: 0, end: 20) {
                    return .red
                } else if Percentage.inRange(start: 20, end: 50) {
                    return .blue
                } else if Percentage.inRange(start: 50, end: 80) {
                    return .yellow
                } else if Percentage.inRange(start: 80, end: 100){
                    return .green
                } else {
                    return .clear
                }
            }
        }
        private func isInLowPowerUpdate() async -> Task<(Bool), Never> {
            Task{
                return ProcessInfo.processInfo.isLowPowerModeEnabled
            }
        }
        
        private func toggleLowPowerMode() -> Task<(Bool), Never> {
            Task {
                let lowPowerEnabled = ProcessInfo.processInfo.isLowPowerModeEnabled
                Shell.Parcer.sudo("/bin/bash", ["-c", "pmset -a lowpowermode \(lowPowerEnabled ? Int(0) : Int(1))"], password: SettingsMonitor.password) as Void
                try? await Task.sleep(seconds: 2)
                ChargingState = .unknown
                return ProcessInfo.processInfo.isLowPowerModeEnabled
            }
        }
        
        private func batteryData() async -> Task<(
            PowerSource: PowerSource,
            ChargingState: ChargingState,
            Percentage: Double,
            TimeRemaining: String), Never> {
                Task {
                    return macOS_Subsystem.getBatteryState()
                }
            }
        
        public var body: some View {
            VStack{
                VStack{
                    HStack{
                        Group{
                            Text("powerSource.string")
                            switch PowerSource {
                            case .AC:
                                Text("battstate.onAC")
                            case .Internal:
                                Text("battstate.onInternal")
                            case .unknown:
                                Text("calculating.string")
                            }
                            Spacer()
                        }.shadow(radius: 0)
                    }
                    HStack{
                        if isInLowPower && !hovered2 {
                            Text("batt.lowPowerMode")
                                .font(.footnote)
                                .foregroundColor(hovered2 ? .primary : SettingsMonitor.textColor(cs))
                                .fontWeight(.heavy)
                        } else
                        if hovered2 && SettingsMonitor.passwordSaved {
                            Text(isInLowPower ? "batt.disableLowPowerMode" : "batt.enableLowPowerMode")
                                .font(.footnote)
                                .foregroundColor(hovered2 ? .primary : SettingsMonitor.textColor(cs))
                                .fontWeight(.heavy)
                        } else {
                            Group{
                                switch ChargingState {
                                case .charging:
                                    HStack{
                                        Text("chargingState.string")
                                        Text("batt.on")
                                    }
                                case .charged:
                                    HStack{
                                        Text("chargingState.string")
                                        Text("batt.comp")
                                    }
                                case .discharging:
                                    HStack{
                                        Text("chargingState.string")
                                        Text("batt.dis")
                                    }
                                case .acAttached:
                                    HStack{
                                        Text("chargingState.string")
                                        Text("batt.onAC")
                                    }
                                case .finishingCharge:
                                    HStack{
                                        Text("chargingState.string")
                                        Text("batt.fin")
                                    }
                                case .unknown:
                                    HStack{
                                        Text("chargingState.string")
                                        Text("calculating.string")
                                    }
                                }
                            }
                            .font(.footnote)
                            .foregroundColor(SettingsMonitor.textColor(cs))
                        }
                        Spacer()
                    }
                    .frame(height: 10)
                    .animation(SettingsMonitor.secondaryAnimation, value: hovered2)
                    GeometryReader { g in
                        CustomViews.MultiProgressBar(total: (label: "", value: 100), values: [("", Double(Percentage), dynamicColor)], widthFrame: g.size.width, showDots: false, geometry: g.size, fixTo100: true, dontShowLabels: true)
                    }
                    HStack{
                        Group {
                            switch ChargingState {
                            case .charged: Text("\(StringLocalizer("timeRemaining.string")): ∞")
                            default: Text("\(StringLocalizer("timeRemaining.string")): \(TimeRemaining)")
                            }
                            Spacer()
                            Text(macOS_Subsystem.BatteryTemperature(TermperatureUnit: tempUnit).valueString)
                                .font(.footnote)
                                .foregroundColor(SettingsMonitor.textColor(cs))
                                .bold(macOS_Subsystem.BatteryTemperature(TermperatureUnit: .celsius).value > 36)
                                .onTapGesture {
                                    switch tempUnit {
                                    case .celsius: tempUnit = .fahrenheit
                                    case .fahrenheit: tempUnit = .kelvin
                                    default: tempUnit = .celsius
                                    }
                                }
                            TextDivider(height: 10)
                            Text(String(Int(Percentage)) + "%")
                        }
                        .font(.footnote)
                        .foregroundColor(SettingsMonitor.textColor(cs))
                    }
                }
                .padding(.all)
                .background {
                    VStack{
                        if SettingsMonitor.batteryAnimation == false {
                            ZStack{
                                RoundedRectangle(cornerRadius: 15)
                                    .foregroundStyle(.ultraThinMaterial)
                                    .shadow(radius: 5)
                            }
                        } else {
                            ZStack{
                                RoundedRectangle(cornerRadius: 15)
                                    .foregroundStyle(.ultraThinMaterial)
                                    .pulsingAnimation(Direction: ChargingState == .charging ? .leftToRight :
                                                        ChargingState == .discharging ? .rightToLeft :
                                            .outIn, Color: isInLowPower ? .mint : dynamicColor)
                            }
                            .shadow(radius: 5)
                            .animation(SettingsMonitor.secondaryAnimation, value: hovered2)
                        }
                    }
                }
                .overlayButton(popoverIsPresented: $dummy, action: {
                    Task{
                        if SettingsMonitor.passwordSaved {
                            isInLowPower = await toggleLowPowerMode().value
                            ChargingState = await batteryData().value.ChargingState
                        }
                    }
                }, enabledGlyph: "battery.100.circle.fill", disabledGlyph: "battery.100.circle.fill", enabledColor: .cyan, disabledColor: .green, hoveredColor: .cyan, selfHovered: $hovered2, backwardHovered: $hovered2, enabled: $isInLowPower, showPopover: false)
                .onChange(of: ChargingState) { n in
                    if n == .charging && isInLowPower {
                        _ = toggleLowPowerMode()
                    }
                }
                .task(priority: .background, {
                    repeat {
                        do {
                            let data = await batteryData().value
                            PowerSource = data.PowerSource
                            ChargingState = data.ChargingState
                            Percentage = Float(data.Percentage)
                            TimeRemaining = data.TimeRemaining
                            isInLowPower = await isInLowPowerUpdate().value
                            temp = macOS_Subsystem.BatteryTemperature(TermperatureUnit: tempUnit)
                            try await Task.sleep(seconds: 5)
                        } catch _ {}
                        if !isRun {break}
                    }while(isRun)
                })
                .animation(SettingsMonitor.secondaryAnimation, value: isInLowPower)
            }.padding(.all)
        }
    }
}
