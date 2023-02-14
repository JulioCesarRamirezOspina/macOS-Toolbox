//
//  SysUpdate View.swift
//  xCore
//
//  Created by Олег Сазонов on 29.09.2022.
//

import Foundation
import SwiftUI

public class macOSUpdate: xCore {
    
    //MARK: - Beta Settings
    private struct BetaSeedSettingsView: View {
        //MARK: - State vars
        @State private var password = SettingsMonitor.password
        @State private var pwdExists = SettingsMonitor.passwordSaved
        @State private var currentSeed = 0
        @State private var openSetting = false
        @State private var isQuit = false
        @State private var enrolled: Bool? = false
        @State private var loading = true
        @State private var imageSeed = 0
        @State private var selection = 0
        @State private var dummy = false
        @State private var width: CGFloat = 1
        @Binding public var BindingPopover: Bool
        @Binding public var actuallyChangedSettings: Bool
        
        private func updateVars() {
            password = SettingsMonitor.password
            pwdExists = SettingsMonitor.passwordSaved
            enrolled = SeedUtil.getSeedBool(password)
            imageSeed = SeedUtil.getSeedInt(password)
            selection = SeedUtil.getSeedInt(password)
        }
        
        private var BetaImage: some View {
            VStack{
                CustomViews.SymbolView(symbol: (imageSeed == 2) ?
                                       "𝛼" : (imageSeed == 1) ?
                                       "β" : "ω", blurRadius: 5,
                                       defaultGradientColors: enrolled! ? [.blue, .blue, .clear] :
                                        [.gray, .gray, .clear])
                .shadow(color: .black, radius: 7, x: 0, y: 5)
                .font(.custom("San Francisco", size: 140))
            }
        }
        
        //MARK: - Generated View
        private var BetaView: some View {
            VStack(alignment: .center) {
                HStack(alignment: .center){
                    Text("seed.current"); Text("\(SeedUtil.getSeed(password))")
                }.padding()
                VStack{
                    CustomViews.AnimatedTextView(Input: "selectprogram.text", TimeToStopAnimation: SettingsMonitor.secAnimDur)
                    HStack(alignment: .center) {
                        GeometryReader { g in
                            HStack{
                                Button {
                                    selection = 1
                                    SeedUtil.setSeed(selection, password: password, openSetting)
                                    updateVars()
                                    openSetting = false
                                    BindingPopover = false
                                    actuallyChangedSettings = true
                                } label: {
                                    Text("seed.public")
                                }.buttonStyle(Stylers.ColoredButtonStyle(glyph: "β", enabled: selection == 1, width: g.size.width / 3 - 10, color: .blue))
                                Spacer()
                                Button {
                                    selection = 2
                                    SeedUtil.setSeed(selection, password: password, openSetting)
                                    updateVars()
                                    openSetting = false
                                    BindingPopover = false
                                    actuallyChangedSettings = true
                                } label: {
                                    Text("seed.dev")
                                }.buttonStyle(Stylers.ColoredButtonStyle(glyph: "𝛼", enabled: selection == 2, width: g.size.width / 3 - 10, color: .cyan))
                                Spacer()
                                Button {
                                    selection = 0
                                    SeedUtil.unenroll(password)
                                    updateVars()
                                    BindingPopover = false
                                    actuallyChangedSettings = true
                                } label: {
                                    Text(selection == 0 ? "seed.none" : "unenroll.button")
                                }.buttonStyle(Stylers.ColoredButtonStyle(glyph: "ω", enabled: selection == 0, width: g.size.width / 3 - 10, color: .red))
                            }
                            .onAppear {
                                width = g.size.width
                            }
                            .onChange(of: g.size) { newValue in
                                width = newValue.width
                            }
                        }.frame(height: 100)
                    }.padding()
                }
            }
        }
        
        //MARK: - Beta Settings View
        var body: some View {
            VStack{
                if SettingsMonitor.passwordSaved {
                    BetaView
                        .background(content: {
                            BetaImage
                        })
                        .onChange(of: imageSeed, perform: { newValue in
                            password = SettingsMonitor.password
                            enrolled = SeedUtil.getSeedBool(password)
                            loading = false
                            imageSeed = SeedUtil.getSeedInt(password)
                        })
                        .onAppear {
                            updateVars()
                            if selection == 0 {
                                selection = 0
                            }
                            currentSeed = SeedUtil.getSeedInt(password)
                        }
                        .onChange(of: selection) { newValue in
                            currentSeed = newValue
                        }
                        .onChange(of: currentSeed) { newValue in
                            if newValue != 0 {
                                selection = newValue
                            } else {
                                selection = 0
                            }
                        }
                        .animation(SettingsMonitor.secondaryAnimation, value: selection)
                        .animation(SettingsMonitor.secondaryAnimation, value: imageSeed)
                        .animation(SettingsMonitor.secondaryAnimation, value: currentSeed)
                } else {
                    CustomViews.NoPasswordView(false, toggle: $dummy)
                }
            }
            .frame(width: NSScreen.main!.frame.width / 2.5, height: NSScreen.main!.frame.width / 3.5, alignment: .center)
        }
    }
    
    //MARK: - macOS Update
    public struct view: View {
        //MARK: - INIT
        public init(
            Geometry: CGSize,
            HalfScreen: Bool = true,
            Alignment: HorizontalAlignment = .center,
            ShowTitle: Bool = true
        ) {
            geometry = Geometry
            halfScreen = HalfScreen
            alignment = Alignment
            showTitle = ShowTitle
        }
        //MARK: - Vars
        @State private var sysUpdateAvailable: OSUpdateStatus = SeedUtil.getSeedBool(SettingsMonitor.password) ? .searching : .standby
        @State private var hovered = false
        @State private var hovered2 = false
        @State private var hovered3 = false
        @State private var animate = false
        @State private var isInLowPower = ProcessInfo.processInfo.isLowPowerModeEnabled
        @State private var updateData: (label: String, buildNumber: String) = ("", "")
        @State private var showOSSettings = false
        @State private var actuallyChangedSettings = false
        @State private var osIsBeta = macOS_Subsystem.osIsBeta()
        @Environment(\.colorScheme) var cs
        private var dynamicColor: Color {
            get {
                switch sysUpdateAvailable {
                case .available:
                    return .green
                case .noConnection:
                    return .red
                default:
                    return .blue
                }
            }
        }
        
        private var geometry: CGSize
        private var halfScreen: Bool = true
        private var alignment: HorizontalAlignment
        private var showTitle: Bool
        private let currentOSVerbatium = "\(StringLocalizer("currentOS.string")): " + macOS_Subsystem.osVersion().shortened
        private let OSUpdateAvailable = StringLocalizer("sysUpdateAvailable.string") //+
        private let OSBeta = SettingsMonitor.passwordSaved ? SeedUtil.getSeedString(SettingsMonitor.password) : ""
        private let OSUpdateCheckInProgress = StringLocalizer("sysUpdateInProgress.string")
        private let OSUpdateNotAvailable = StringLocalizer("sysUpdateNotAvailable.string")
        private let OSUpdateNoInternet = StringLocalizer("sysUpdateNoInternet.string")
        private let OSReCheck = StringLocalizer("sysUpdateCheck.string")
        private let OSShowSettings = StringLocalizer("settings.string")
        private var animation: Animation {
            Animation.linear(duration: SettingsMonitor.secAnimDur * 2).repeatForever(autoreverses: false)
        }
        //MARK: - Funcs
        private func update() async {
            let data = await SeedUtil.sysupdateAvailable()
            sysUpdateAvailable = data.0
            updateData = data.1
            osIsBeta = macOS_Subsystem.osIsBeta()
            hovered3 = false
            switch sysUpdateAvailable {
            case .available:
                await LocalNotificationManager().sendNotification(title: "macOS ToolBox", subtitle: nil, body: OSUpdateAvailable, badge: 1)
            case .noConnection:
                LocalNotificationManager().clear()
                hovered = false
            default:
                LocalNotificationManager().clear()
            }
            delay(after: 2) {
                hovered2 = false
            }
        }
        
        //MARK: - macOS Update View
        public var body: some View {
            VStack(alignment: alignment){
                ZStack{
                    RoundedRectangle(cornerRadius: 15)
                        .foregroundStyle(.clear)
                    switch sysUpdateAvailable {
                    case .available:
                        if !isInLowPower {
                            RoundedRectangle(cornerRadius: 15)
                                .rainbowAnimation()
                                .shadow(radius: 5)
                        } else {
                            RoundedRectangle(cornerRadius: 15)
                                .foregroundStyle(.green)
                                .shadow(radius: 5)
                        }
                    case .noConnection:
                        RoundedRectangle(cornerRadius: 15)
                            .foregroundStyle(.red)
                            .shadow(radius: 5)
                    default:
                        RoundedRectangle(cornerRadius: 15)
                            .foregroundStyle(.ultraThinMaterial)
                            .shadow(radius: 5)
                    }
                    HStack{
                        VStack(alignment: alignment){
                            Text(currentOSVerbatium)
                                .foregroundColor(sysUpdateAvailable == .available ? .black : .primary)
                            if !halfScreen {
                                HStack{
                                    if osIsBeta {
                                        Text("osIsBeta.string")
                                            .font(.footnote)
                                            .foregroundColor(sysUpdateAvailable == .available ? .black : SettingsMonitor.textColor(cs))
                                    }
                                    if osIsBeta && SettingsMonitor.passwordSaved {
                                        if SeedUtil.getSeedBool(SettingsMonitor.password) {
                                            Divider().foregroundColor(sysUpdateAvailable == .available ? .black : SettingsMonitor.textColor(cs))
                                        }
                                    }
                                    if SettingsMonitor.passwordSaved {
                                        if SeedUtil.getSeedBool(SettingsMonitor.password) {
                                            Text(SeedUtil.getSeedString(SettingsMonitor.password))
                                                .font(.footnote)
                                                .foregroundColor(sysUpdateAvailable == .available ? .black : SettingsMonitor.textColor(cs))
                                        }
                                    }
                                    Spacer()
                                }
                            }
                            Divider().foregroundColor(sysUpdateAvailable == .available ? .black : SettingsMonitor.textColor(cs))
                            if (hovered2 && sysUpdateAvailable != .searching) {
                                Text(OSReCheck)
                                    .foregroundColor(sysUpdateAvailable == .available ? .black : SettingsMonitor.textColor(cs))
                                    .shadow(radius: 0)
                            } else if (hovered3 && sysUpdateAvailable != .searching && sysUpdateAvailable != .available) {
                                Text(OSShowSettings)
                                    .foregroundColor(sysUpdateAvailable == .available ? .black : SettingsMonitor.textColor(cs))
                                    .shadow(radius: 0)
                            } else {
                                switch sysUpdateAvailable {
                                case .available:
                                    HStack{
                                        if updateData.buildNumber != "" {
                                            Text(OSUpdateAvailable)
                                                .foregroundColor(sysUpdateAvailable == .available ? .black : SettingsMonitor.textColor(cs))
                                                .shadow(radius: 0)
                                            TextDivider(height: 10)
                                                .shadow(radius: 0)
                                        }
                                        Text(updateData.label + " " + (updateData.buildNumber == "" ? "" : StringLocalizer("bn.string")) + " " + updateData.buildNumber)
                                            .foregroundColor(sysUpdateAvailable == .available ? .black : SettingsMonitor.textColor(cs))
                                    }
                                    .animation(SettingsMonitor.secondaryAnimation, value: osIsBeta)
                                case .notAvailable:
                                    Text(OSUpdateNotAvailable)
                                        .shadow(radius: 0)
                                case .searching:
                                    Text(OSUpdateCheckInProgress)
                                        .shadow(radius: 0)
                                case .noConnection:
                                    Text(OSUpdateNoInternet)
                                        .shadow(radius: 0)
                                case .standby:
                                    Text(OSUpdateNotAvailable)
                                        .shadow(radius: 0)
                                }
                            }
                        }
                        switch alignment {
                        case .leading: Spacer()
                        default: EmptyView()
                        }
                    }.padding(.all)
                }
//                .glow(color: (hovered || hovered2 || hovered3) && sysUpdateAvailable != .searching ? dynamicColor : .clear, anim: hovered)
                .frame(height: halfScreen ? geometry.height / 2 : geometry.height)
                .onChange(of: actuallyChangedSettings, perform: { nV in
                    if nV {
                        sysUpdateAvailable = .searching
                        Task{
                            await update()
                        }
                        actuallyChangedSettings = false
                        hovered3 = false
                    }
                })
                //MARK: - Overlay
                .overlay(alignment: .topTrailing) {
                    ZStack{
                        HStack(spacing: 0){
                            if hovered && !halfScreen && SettingsMonitor.passwordSaved && sysUpdateAvailable != .searching && SettingsMonitor.isInMenuBar {
                                ZStack{
                                    Image(systemName: !showOSSettings ? "gear.circle.fill" : "xmark.circle.fill")
                                        .symbolRenderingMode(.palette)
                                        .font(.custom("San Francisco", size: 20))
                                        .foregroundStyle(.white, (showOSSettings ? .red : .blue))
                                        .rotationEffect(Angle(radians: showOSSettings ? 0.01 : 2 * .pi))
                                        .animation(SettingsMonitor.secondaryAnimation, value: showOSSettings)
                                        .shadow(radius: 2)
                                }
                                .popover(isPresented: $showOSSettings, content: {
                                    BetaSeedSettingsView(BindingPopover: $showOSSettings, actuallyChangedSettings: $actuallyChangedSettings)
                                })
                                .onHover(perform: { h in
                                    if !showOSSettings {
                                        hovered3 = h
                                    }
                                })
                                .onTapGesture(perform: {
                                    showOSSettings = true
                                    hovered = true
                                })
                                .padding(.all)
                                .transition(.move(edge: hovered ? .trailing : .leading))
                            }
                            ZStack{
                                Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
                                    .symbolRenderingMode(.palette)
                                    .font(.custom("San Francisco", size: 20))
                                    .foregroundStyle(.white, .blue)
                                    .rotationEffect(Angle(radians: animate ? .pi * 2 : 0.01))
                                    .animation(animation, value: animate)
                                    .scaleEffect(sysUpdateAvailable != .searching ? 0.001 : 1)
                                    .shadow(radius: 2)
                                Image(systemName: sysUpdateAvailable == .available ? "info.circle.fill" : sysUpdateAvailable == .notAvailable ? "checkmark.circle.fill" : sysUpdateAvailable == .noConnection ? "exclamationmark.circle.fill" : "arrow.clockwise.circle.fill")
                                    .symbolRenderingMode(.palette)
                                    .font(.custom("San Francisco", size: 20))
                                    .foregroundStyle(.white, sysUpdateAvailable == .available || sysUpdateAvailable == .noConnection ? .red : .green)
                                    .scaleEffect(sysUpdateAvailable == .searching ? 0.001 : 1)
                                    .shadow(radius: 2)
                                    .onHover(perform: { Bool in
                                        if sysUpdateAvailable != .searching {
                                            hovered2 = Bool
                                            hovered = true
                                        }
                                    })
                                    .onTapGesture(perform: {
                                        if sysUpdateAvailable != .searching {
                                            sysUpdateAvailable = .searching
                                            Task{
                                                await update()
                                            }
                                        }
                                    })
                            }
                            .padding(.all)
                        }
                        .background {
                            ZStack{
                                if SettingsMonitor.isInMenuBar {
                                    RoundedRectangle(cornerRadius: 15)
                                        .foregroundStyle(hovered && sysUpdateAvailable != .searching ? .blue : .clear)
                                        .animation(SettingsMonitor.secondaryAnimation, value: hovered)
                                        .padding(.all)
                                }
                                RoundedRectangle(cornerRadius: 15)
                                    .foregroundStyle(.ultraThickMaterial)
                                    .opacity(0.5)
                                    .animation(SettingsMonitor.secondaryAnimation, value: hovered)
                                    .padding(.all)
                            }
                            .glow(color: (hovered) && sysUpdateAvailable != .searching ? .blue : .clear, anim: hovered)
                        }
                    }
                    .onHover(perform: { Bool in
                        if !showOSSettings {
                            if sysUpdateAvailable != .noConnection {
                                hovered = Bool
                            }
                        }
                    })
                }
            }
            // MARK: - View Settings
            .onTapGesture(perform: {
                if sysUpdateAvailable == .available {
                    SeedUtil.checkUpdates()
                }
            })
            .task {
                await update()
                isInLowPower = ProcessInfo.processInfo.isLowPowerModeEnabled
            }
            .onAppear(perform: {
                sysUpdateAvailable = .searching
                animate = true
            })
            .onChange(of: showOSSettings, perform: { newValue in
                if !showOSSettings {
                    hovered = false
                    hovered2 = false
                    hovered3 = false
                }
            })
            .animation(SettingsMonitor.secondaryAnimation, value: sysUpdateAvailable)
            .animation(SettingsMonitor.secondaryAnimation, value: hovered)
            .animation(SettingsMonitor.secondaryAnimation, value: hovered2)
            .animation(SettingsMonitor.secondaryAnimation, value: hovered3)
            .padding(.all)
        }
    }
    deinit{}
}
