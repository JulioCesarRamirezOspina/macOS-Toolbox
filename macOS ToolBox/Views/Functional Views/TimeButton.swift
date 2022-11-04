//
//  TimeButton.swift
//  MultiTool
//
//  Created by Олег Сазонов on 01.07.2022.
//

import Foundation
import SwiftUI
import xCore

struct TimeAndQuit: View {
    @Binding var colorScheme: ColorScheme?
    @State var lowPower = ProcessInfo.processInfo.isLowPowerModeEnabled
    @State var hold = false
    @State var w: CGFloat = 1
    @State var h: CGFloat = 1
    var color: Color {
        get {
            switch timeLeft {
//            case 3...4: return colorScheme == .dark ? .white : SettingsMonitor.isInMenuBar ? .black : .secondary
            case 30...40:
                if SettingsMonitor.isInMenuBar {
                    if colorScheme == .dark {
                        return .white
                    } else {
                        return .gray
                    }
                } else {
                    if colorScheme == .dark {
                        return .white
                    } else {
                        return .secondary
                    }
                }
            case 20...30: return .blue
            case 10...20: return .red
            default: return .clear
            }
        }
    }
    @State var timer: Timer?
    @State var timeLeft: Double = 40
    var body: some View {
        VStack{
            VStack(){
                Divider()
                NavigationLink {
                    SettingsView(colorScheme: $colorScheme)
                } label: {
                    Text("settings.string")
                }
                .buttonStyle(Stylers.ColoredButtonStyle(glyph: "gear",
                                                        alwaysShowTitle: lowPower ? true : false,
                                                        color: .blue,
                                                        hideBackground: true,
                                                        backgroundIsNotFill: true,
                                                        blurBackground: true,
                                                        backgroundShadow: true,
                                                        render: .monochrome,
                                                        glow: false))
            }
            VStack{
                VStack{
                    Divider()
                    if !hold {
                        Button {
                            if SettingsMonitor.isInMenuBar {
                                AppDelegate.tog()
                            } else {
                                Quit(AppDelegate())
                            }
                        } label: {
                            TimeView(textStyle: .bold, font: .body)
                                .multilineTextAlignment(.center)
                                .lineLimit(3)
                        }
                        .keyboardShortcut(.cancelAction)
                        .buttonStyle(Stylers.ColoredButtonStyle(alwaysShowTitle: true, hideBackground: true))
                        .transition(.scale)
                    } else {
                        ZStack{
                            Circle()
                                .trim(from: (timeLeft / 10 - 1) / 3, to: hold ? 1 : 0.01)
                                .stroke(style: .init(lineWidth: 5, lineCap: .round, lineJoin: .round))
                                .foregroundColor(color)
                                .frame(width: 75, height: 75, alignment: .center)
                                .blur(radius: 1 / timeLeft)
                                .glow(color: color, anim: hold, glowIntensity: .normal)
                                .padding(.all)
                            Text(((timeLeft - 10) / 10) >= 2 ? Int((timeLeft - 10) / 10).description : ((timeLeft - 10) / 10).description)
                                .fontWeight(.black)
                                .glow(color: color)
                        }
                        .animation(SettingsMonitor.secondaryAnimation, value: timeLeft)
                        .transition(.scale)
                    }
                }
                .animation(SettingsMonitor.secondaryAnimation, value: hold)
            }
            .onTapGesture {
                if SettingsMonitor.isInMenuBar {
                    AppDelegate.tog()
                } else {
                    Quit(AppDelegate())
                }
            }
            .onLongPressGesture(minimumDuration: 3, maximumDistance: 200) {
                Quit(AppDelegate())
            } onPressingChanged: { h in
                hold = h
                switch hold {
                case true:
                    timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { t in
                        timeLeft -= 1
                    })
                case false:
                    timer?.invalidate()
                    timer = nil
                    timeLeft = 40
                }
            }
            .background(.ultraThickMaterial)
        }
        .onAppear {
            lowPower = ProcessInfo.processInfo.isLowPowerModeEnabled
        }
        .onHover { _ in
            lowPower = ProcessInfo.processInfo.isLowPowerModeEnabled
        }
    }
}
