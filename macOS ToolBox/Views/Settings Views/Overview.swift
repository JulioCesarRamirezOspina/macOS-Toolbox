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
    @State private var ParallelsDir = SettingsMonitor.parallelsDir.relativePath
    @State private var UTMDir = SettingsMonitor.utmDir.relativePath
    @State private var maintenanceLastRun = SettingsMonitor.maintenanceLastRun
    @State private var parallelsLabel = "\(StringLocalizer("parallelsDir.string"))\(SettingsMonitor.parallelsDir.relativePath)"
    @State private var utmLabel = "\(StringLocalizer("utmDir.string"))\(SettingsMonitor.utmDir.relativePath)"
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

    private func AutoLaunch() -> some View {
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
    
    private func ShowSerialNumber() -> some View {
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
                                                backgroundShadow: true))
    }
    
    private func IsInMenuBar() -> some View {
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

    private func BatteryButton() -> some View {
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
    
    private func ParallelsButton() ->some View {
        Button {
            do {
                try Shell.Runner(app: "/usr/bin/open", args: [SettingsMonitor.parallelsDir.absoluteString]).process.run()
            } catch _{}
        } label: {
            Text(parallelsLabel)
        }
        .onHover { t in
            if Parallels.vmExists() {
                if t {
                    parallelsLabel = StringLocalizer("finder.text")
                } else {
                    parallelsLabel = "\(StringLocalizer("parallelsDir.string"))\(SettingsMonitor.parallelsDir.relativePath)"
                }
            } else {
                parallelsLabel = "\(StringLocalizer("parallelsDir.string"))\(SettingsMonitor.parallelsDir.relativePath)"
            }
        }
        .disabled(!Parallels.vmExists())
        .buttonStyle(Stylers.ColoredButtonStyle(glyph: "pause",
                                                disabled: !Parallels.vmExists(),
                                                alwaysShowTitle: true,
                                                width: width,
                                                color: .cyan,
                                                hideBackground: false,
                                                backgroundShadow: true))
    }
    
    private func UTMButton() -> some View {
        Button {
            do {
                try Shell.Runner(app: "/usr/bin/open", args: [SettingsMonitor.utmDir.absoluteString]).process.run()
            } catch _{}
        } label: {
            Text(utmLabel)
        }
        .onHover { t in
            if UTM.vmExists() {
                if t {
                    utmLabel = StringLocalizer("finder.text")
                } else {
                    utmLabel = "\(StringLocalizer("parallelsDir.string"))\(SettingsMonitor.utmDir.relativePath)"
                }
            } else {
                utmLabel = "\(StringLocalizer("parallelsDir.string"))\(SettingsMonitor.utmDir.relativePath)"
            }
        }
        .disabled(!UTM.vmExists())
        .buttonStyle(Stylers.ColoredButtonStyle(glyph: "dot.square",
                                                disabled: !UTM.vmExists(),
                                                alwaysShowTitle: true,
                                                width: width,
                                                color: .cyan,
                                                hideBackground: false,
                                                backgroundShadow: true))
    }
    
    private func MaintenanceButton() -> some View {
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
    
    private func PasswordStateButton() -> some View {
        NavigationLink {
            PasswordSettings()
        } label: {
            Text("\(StringLocalizer("passwordState.string")) \(SettingsMonitor.passwordSaved ? StringLocalizer("passwordSavedTrue.string") : StringLocalizer("passwordSavedFalse.string"))")
        }
        .buttonStyle(Stylers.ColoredButtonStyle(glyphs: SettingsMonitor.passwordSaved ? ["key"] : ["key", "line.diagonal"],
                                                enabled: false,
                                                alwaysShowTitle: true,
                                                width: width,
                                                color: SettingsMonitor.passwordSaved ? .green : .red,
                                                hideBackground: false,
                                                backgroundShadow: true))
    }
    
    private func AppTheme() -> some View {
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
                            SwiftUI.ScrollView(.vertical, showsIndicators: true) {
                                LazyVStack{
                                    Spacer()
                                    Group{
                                        ParallelsButton()
                                        UTMButton()
                                        MaintenanceButton()
                                        PasswordStateButton()
                                        BatteryButton()
                                        ShowSerialNumber()
                                        IsInMenuBar()
                                        AutoLaunch()
                                        AppTheme()
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
