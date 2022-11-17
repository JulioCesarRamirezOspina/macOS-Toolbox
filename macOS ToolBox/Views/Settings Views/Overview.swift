//
//  SettingsOverview.swift
//  MultiTool
//
//  Created by Олег Сазонов on 11.06.2022.
//

import Foundation
import SwiftUI
import xCore
import ServiceManagement

struct SettingsOverview: View {
    @State private var maintenanceLastRun = SettingsMonitor.maintenanceLastRun
    @State private var width: CGFloat = (NSApplication.shared.keyWindow?.frame.width)! / 2
    @State private var animateBatteryOverview = SettingsMonitor.batteryAnimation
    @State private var isRun = false
    @State private var showSerialNumber = SettingsMonitor.showSerialNumber
    @State private var isInMenuBar = SettingsMonitor.isInMenuBar
    @Binding var pcs: ColorScheme?
    
    @State private var launchAtLogin = SettingsMonitor.autoLaunch {
        didSet {
            if !launchAtLogin {
                try? SMAppService.mainApp.unregister()
            } else {
                try? SMAppService.mainApp.register()
                SMAppService.loginItem(identifier: Bundle.main.bundleIdentifier!)
            }
        }
    }

    private var AutoLaunch: some View {
        Button {
            SettingsMonitor.autoLaunch = !launchAtLogin
            launchAtLogin = SettingsMonitor.autoLaunch
        } label: {
            Text("autoLaunch.string")
        }
        .buttonStyle(Stylers.ColoredButtonStyle(glyph: "hourglass.bottomhalf.filled",
                                                enabled: launchAtLogin,
                                                alwaysShowTitle: true,
                                                width: width,
                                                color: .cyan,
                                                hideBackground: false,
                                                backgroundShadow: true))
    }
    
    private var ShowSerialNumber: some View {
        Button {
            SettingsMonitor.showSerialNumber = !showSerialNumber
            showSerialNumber = SettingsMonitor.showSerialNumber
        } label: {
            Text("showSerialNumber.string")
        }
        .buttonStyle(Stylers.ColoredButtonStyle(glyph: "barcode",
                                                enabled: showSerialNumber,
                                                alwaysShowTitle: true,
                                                width: width,
                                                color: .blue,
                                                hideBackground: false,
                                                backgroundShadow: true,
                                                glyphBlured: !showSerialNumber))
    }
    
    private var IsInMenuBar: some View {
        Button {
            SettingsMonitor.isInMenuBar = !isInMenuBar
            isInMenuBar = SettingsMonitor.isInMenuBar
        } label: {
            Text("isInMenuBar.string")
        }
        .buttonStyle(Stylers.ColoredButtonStyle(glyph: "menubar.arrow.up.rectangle",
                                                enabled: isInMenuBar,
                                                alwaysShowTitle: true,
                                                width: width,
                                                color: Color(nsColor: .findHighlightColor),
                                                hideBackground: false,
                                                backgroundShadow: true))
    }

    private var BatteryButton: some View {
        Button {
            switch animateBatteryOverview {
            case true:
                SettingsMonitor.batteryAnimation = false
            case false:
                SettingsMonitor.batteryAnimation = true
            }
            animateBatteryOverview = SettingsMonitor.batteryAnimation
        } label: {
            Text("batteryAnimation.string")
        }
        .buttonStyle(Stylers.ColoredButtonStyle(glyph: !SettingsMonitor.batteryAnimation ? "battery.0" : "battery.100",
                                                enabled: SettingsMonitor.batteryAnimation,
                                                alwaysShowTitle: true,
                                                width: width,
                                                color: .green,
                                                hideBackground: false,
                                                backgroundShadow: true))
    }
    
    private var MaintenanceButton: some View {
        Button {
            SettingsMonitor.Maintenance()
            SettingsMonitor.maintenanceLastRun = Date().formatted(date: .complete, time: .standard)
            maintenanceLastRun = SettingsMonitor.maintenanceLastRun
        } label: {
            Text("\(StringLocalizer("maintenance.string")) (\(StringLocalizer("maintenanceLast.string")): \(maintenanceLastRun))")
        }
        .disabled(!SettingsMonitor.passwordSaved)
        .buttonStyle(Stylers.ColoredButtonStyle(glyph: "gear.badge.checkmark",
                                                disabled: !SettingsMonitor.passwordSaved,
                                                alwaysShowTitle: true,
                                                width: width,
                                                color: .cyan,
                                                hideBackground: false,
                                                backgroundShadow: true))
    }
    
    private var PasswordStateButton: some View {
        NavigationLink {
            PasswordSettings()
        } label: {
            Text("\(StringLocalizer("passwordState.string")) \(SettingsMonitor.passwordSaved ? StringLocalizer("passwordSavedTrue.string") : StringLocalizer("passwordSavedFalse.string"))")
        }
        .buttonStyle(Stylers.ColoredButtonStyle(glyphs: SettingsMonitor.passwordSaved ? ["key"] : ["key", "line.diagonal"],
                                                enabled: true,
                                                alwaysShowTitle: true,
                                                width: width,
                                                color: SettingsMonitor.passwordSaved ? .green : .red,
                                                hideBackground: false,
                                                backgroundShadow: true))
    }
    
    private var AppTheme: some View {
        VStack{
            HStack{
                Button {
                    switch pcs {
                    case .dark: pcs = .light
                    case .light: pcs = nil
                    case nil: pcs = .dark
                    case .some(_): pcs = .dark
                    }
                } label: {
                    Text(pcs == .light ? "lightMode.String" : pcs == .dark ? "darkMode.string" : "auto.string")
                }
                .buttonStyle(Stylers.ColoredButtonStyle(
                    glyph: "darkModeGlyph",
                    alwaysShowTitle: true,
                    width: 250,
                    height: 50,
                    color: pcs == .light ? .white :
                        pcs == .dark ? .black :
                            .blue,
                    render: .hierarchical)
                )
            }
        }
    }
    
    var body: some View {
        VStack{
            if isRun {
                HStack{
                    GroupBox {
                        GeometryReader { _ in
                            ScrollView(.vertical, showsIndicators: true) {
                                LazyVStack{
                                    Spacer()
                                    Group{
                                        MaintenanceButton
                                        PasswordStateButton
                                        BatteryButton
                                        ShowSerialNumber
                                        IsInMenuBar
                                        AutoLaunch
                                        AppTheme
                                    }.padding(.all)
                                    Spacer()
                                }.padding(.all)
                            }
                            .ignoresSafeArea(edges: .all)
                        }
                    } label: {
                        HStack{
                            CustomViews.AnimatedTextView(Input: "settingsOverview.string", TimeToStopAnimation: SettingsMonitor.secAnimDur)
                        }
                    }
                    .groupBoxStyle(Stylers.CustomGBStyle())
                    .background {
                        CustomViews.ImageView(imageName: "gear.circle.fill")
                    }
                }
            }
        }
        .preferredColorScheme(pcs)
        .onAppear {
            isRun = true
        }
        .onDisappear {
            isRun = false
        }
        
        .onChange(of: pcs, perform: { newValue in
            Theme.switch(newValue)
        })
        .animation(SettingsMonitor.secondaryAnimation, value: pcs)
        .animation(SettingsMonitor.secondaryAnimation, value: animateBatteryOverview)
        
    }
}
