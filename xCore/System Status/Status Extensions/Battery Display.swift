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
        @State private var flash = false
        @State private var tempUnit: UnitTemperature = SettingsMonitor.temperatureUnit
        @State private var temp = macOS_Subsystem.BatteryTemperature(TermperatureUnit: SettingsMonitor.temperatureUnit)
        @State private var isInLowPower = ProcessInfo.processInfo.isLowPowerModeEnabled
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
                    }
                    HStack{
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
                        if isInLowPower {
                            HStack{
                                Divider()
                            }.frame(height: 10)
                            Text("batt.lowPowerMode")
                                .font(.footnote)
                                .foregroundColor(hovered2 ? .primary : SettingsMonitor.textColor(cs))
                                .fontWeight(.heavy)
                        }
                        if hovered2 && SettingsMonitor.passwordSaved {
                            HStack{
                                Divider()
                            }.frame(height: 10)
                            Text(isInLowPower ? "batt.disableLowPowerMode" : "batt.enableLowPowerMode")
                                .font(.footnote)
                                .foregroundColor(hovered2 ? .primary : SettingsMonitor.textColor(cs))
                                .fontWeight(.heavy)
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
                            Text(String(Int(Percentage)) + "%")
                        }
                        .font(.footnote)
                        .foregroundColor(SettingsMonitor.textColor(cs))
                    }
                }
                .onHover { t in
                    hovered2 = t
                }
                .animation(SettingsMonitor.secondaryAnimation, value: isInLowPower)
                .padding(.all)
                .background {
                    GeometryReader { g in
                        VStack{
                            if SettingsMonitor.batteryAnimation == false {
                                ZStack{
                                    RoundedRectangle(cornerRadius: 15)
                                        .foregroundColor(hovered2 ? dynamicColor : .clear)
                                        .frame(width: g.size.width, height: g.size.height, alignment: .center)
                                    RoundedRectangle(cornerRadius: 15)
                                        .foregroundStyle(.ultraThinMaterial)
                                        .shadow(radius: 5)
                                        .frame(width: g.size.width, height: g.size.height, alignment: .center)
                                }
                            } else {
                                GeometryReader { bg in
                                    ZStack{
                                        RoundedRectangle(cornerRadius: 15)
                                            .foregroundColor(hovered2 ? dynamicColor : .clear)
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
                        .onAppear {
                            width = g.size.width
                            height = g.size.height
                        }
                        .onChange(of: g.size) { newValue in
                            width = newValue.width
                            height = newValue.height
                        }
                    }
                }
                .glow(color: hovered2 ? dynamicColor : .clear, anim: hovered2)
                .task(priority: .background, {
                    repeat {
                        do {
                            let data = await batteryData().value
                            PowerSource = data.PowerSource
                            ChargingState = data.ChargingState
                            Percentage = Float(data.Percentage)
                            TimeRemaining = data.TimeRemaining
                            isInLowPower = await isInLowPowerUpdate().value
                            flash.toggle()
                            temp = macOS_Subsystem.BatteryTemperature(TermperatureUnit: tempUnit)
                            try await Task.sleep(seconds: 5)
                        } catch _ {}
                        if !isRun {break}
                    }while(isRun)
                })
                .onAppear(perform: {
                    flash = true
                })
                .onChange(of: ChargingState) { n in
                    if n == .charging && isInLowPower {
                        _ = toggleLowPowerMode()
                    }
                }
            }
            .onTapGesture(perform: {
                Task{
                    if SettingsMonitor.passwordSaved {
                        isInLowPower = await toggleLowPowerMode().value
                        ChargingState = await batteryData().value.ChargingState
                    }
                }
            })
        }
    }
}
