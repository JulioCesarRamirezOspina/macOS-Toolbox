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
    @State var w: CGFloat = 1
    @State var h: CGFloat = 1
    @State var hovered = false
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
                    Button {
                        if hovered {
                            Void()
                        } else {
                            if SettingsMonitor.isInMenuBar {
                                AppDelegate.tog()
                            } else {
                                Quit(AppDelegate())
                            }
                        }
                    } label: {
                        TimeView(textStyle: .bold, font: .body)
                            .multilineTextAlignment(.center)
                            .lineLimit(3)
                    }
                    .keyboardShortcut(.cancelAction)
                    .buttonStyle(Stylers.ColoredButtonStyle(alwaysShowTitle: true, hideBackground: true))
                    .modifier(CustomViews.DualActionMod(tapAction: {
                        if SettingsMonitor.isInMenuBar {
                            AppDelegate.tog()
                        } else {
                            Quit(AppDelegate())
                        }
                    }, longPressAction: {
                        Quit(AppDelegate())
                    }, frameSize: CGSize(width: 90, height: 90)))
                }
            }
            .background(.ultraThickMaterial)
        }
        .onAppear {
            lowPower = ProcessInfo.processInfo.isLowPowerModeEnabled
        }
        .onHover { t in
            lowPower = ProcessInfo.processInfo.isLowPowerModeEnabled
            hovered = t
        }
    }
}
