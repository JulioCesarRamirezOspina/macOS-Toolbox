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
                Divider()
                Button {
                    if SettingsMonitor.isInMenuBar {
                        AppDelegate.tog()
                    } else {
                        Quit(AppDelegate())
                    }
                } label: {
                    TimeView(textStyle: .bold, font: .body).multilineTextAlignment(.center).lineLimit(3)
                }
                .buttonStyle(Stylers.ColoredButtonStyle(alwaysShowTitle: true, hideBackground: true))
                .keyboardShortcut(.cancelAction)
            }.background(.ultraThickMaterial)
        }
        .onAppear {
            lowPower = ProcessInfo.processInfo.isLowPowerModeEnabled
        }
        .onHover { _ in
            lowPower = ProcessInfo.processInfo.isLowPowerModeEnabled
        }
    }
}
