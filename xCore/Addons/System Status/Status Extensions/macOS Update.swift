//
//  SysUpdate View.swift
//  xCore
//
//  Created by Олег Сазонов on 29.09.2022.
//

import Foundation
import SwiftUI

public class macOSUpdate: xCore {
    
    public struct view: View {
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
        
        @State private var sysUpdateAvailable: OSUpdateStatus = SeedUtil.getSeedBool(SettingsMonitor.password) ? .searching : .standby
        @State private var hovered = false
        @State private var hovered2 = false
        @State private var animate = false
        
        @State private var updateData: (label: String, buildNumber: String) = ("", "")
        
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
        private let currentOSVerbatium = "\(StringLocalizer("currentOS.string")): " + macOS_Subsystem.osVersion()
        private let OSUpdateAvailable = StringLocalizer("sysUpdateAvailable.string") //+ 
        private let OSBeta = SettingsMonitor.passwordSaved ? SeedUtil.getSeedString(SettingsMonitor.password) : ""
        private let OSUpdateCheckInProgress = StringLocalizer("sysUpdateInProgress.string")
        private let OSUpdateNotAvailable = StringLocalizer("sysUpdateNotAvailable.string")
        private let OSUpdateNoInternet = StringLocalizer("sysUpdateNoInternet.string")
        private let OSReCheck = StringLocalizer("sysUpdateCheck.string")
        private var animation: Animation {
            Animation.linear(duration: SettingsMonitor.secAnimDur * 2).repeatForever(autoreverses: false)
        }
        
        private func update() async {
            let data = await SeedUtil.sysupdateAvailable()
            sysUpdateAvailable = data.0
            updateData = data.1
            switch sysUpdateAvailable {
            case .available:
                await LocalNotificationManager().sendNotification(title: "macOS ToolBox", subtitle: nil, body: OSUpdateAvailable, badge: 1)
            case .noConnection:
                LocalNotificationManager().clear()
                hovered = false
            default:
                LocalNotificationManager().clear()
            }
        }
        
        public var body: some View {
            VStack(alignment: alignment){
                if showTitle {
                    VStack{
                        Text("macOSUpdate.string")
                    }
                }
                ZStack{
                    RoundedRectangle(cornerRadius: 15)
                        .foregroundStyle(hovered && sysUpdateAvailable != .searching ? .blue : .clear)
                    switch sysUpdateAvailable {
                    case .available:
                        RoundedRectangle(cornerRadius: 15)
                            .foregroundStyle(.green)
                            .shadow(radius: 5)
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
                            if !halfScreen {
                                HStack{
                                    if macOS_Subsystem.osIsBeta() {
                                        Text("osIsBeta.string")
                                            .font(.footnote)
                                            .foregroundColor(.secondary)
                                    }
                                    if macOS_Subsystem.osIsBeta() && SettingsMonitor.passwordSaved {
                                        if SeedUtil.getSeedBool(SettingsMonitor.password) {
                                            Divider()
                                        }
                                    }
                                    if SettingsMonitor.passwordSaved {
                                        if SeedUtil.getSeedBool(SettingsMonitor.password) {
                                            Text(SeedUtil.getSeedString(SettingsMonitor.password))
                                                .font(.footnote)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    Spacer()
                                }
                            }
                            Divider()
                            if (hovered && sysUpdateAvailable != .searching && sysUpdateAvailable != .available) || (hovered2 && sysUpdateAvailable != .searching) {
                                Text(OSReCheck)
                            } else {
                                switch sysUpdateAvailable {
                                case .available:
                                    HStack{
                                        Text(OSUpdateAvailable)
                                        Divider().frame(height: 10)
                                        Text(updateData.label + " " + StringLocalizer("bn.string") + " " + updateData.buildNumber)
                                    }
                                case .notAvailable:
                                    Text(OSUpdateNotAvailable)
                                case .searching:
                                    Text(OSUpdateCheckInProgress)
                                case .noConnection:
                                    Text(OSUpdateNoInternet)
                                case .standby:
                                    Text(OSUpdateNotAvailable)
                                }
                            }
                        }
                        switch alignment {
                        case .leading: Spacer()
                        default: EmptyView()
                        }
                    }.padding(.all)
                }
                .glow(color: (hovered || hovered2) && sysUpdateAvailable != .searching ? dynamicColor : .clear, anim: hovered)
                .frame(height: halfScreen ? geometry.height / 2 : geometry.height)
                .onHover(perform: { Bool in
                    if sysUpdateAvailable != .noConnection {
                        hovered = Bool
                    }
                })
                .onTapGesture {
                    if sysUpdateAvailable == .available {
                        SeedUtil.checkUpdates()
                    } else if sysUpdateAvailable == .notAvailable || sysUpdateAvailable == .noConnection || sysUpdateAvailable == .standby {
                        sysUpdateAvailable = .searching
                        Task{
                            await update()
                        }
                    }
                }
                .overlay(alignment: .topTrailing) {
                    ZStack{
                        Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
                            .symbolRenderingMode(.palette)
                            .font(.custom("San Francisco", size: 20))
                            .foregroundStyle(.white, .blue)
                            .rotationEffect(Angle(degrees: animate ? 360 : 0))
                            .animation(animation, value: animate)
                            .scaleEffect(sysUpdateAvailable != .searching ? 0 : 1)
                            .shadow(radius: 2)
                        Image(systemName: sysUpdateAvailable == .available ? "info.circle.fill" : sysUpdateAvailable == .notAvailable ? "checkmark.circle.fill" : sysUpdateAvailable == .noConnection ? "exclamationmark.circle.fill" : "arrow.clockwise.circle.fill")
                            .symbolRenderingMode(.palette)
                            .font(.custom("San Francisco", size: 20))
                            .foregroundStyle(.white, sysUpdateAvailable == .available || sysUpdateAvailable == .noConnection ? .red : .green)
                            .scaleEffect(sysUpdateAvailable != .searching ? 1 : 0)
                            .shadow(radius: 2)
                            .onHover(perform: { Bool in
                                if sysUpdateAvailable != .searching {
                                    hovered2 = Bool
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
            }
            .task {
                await update()
            }
            .onAppear(perform: {
                animate = true
            })
            .animation(SettingsMonitor.secondaryAnimation, value: sysUpdateAvailable)
            .animation(SettingsMonitor.secondaryAnimation, value: hovered)
            .animation(SettingsMonitor.secondaryAnimation, value: hovered2)
        }
    }
    deinit{}
}

struct SysUpPreview: PreviewProvider {
    static var previews: some View {
        macOSUpdate.view(Geometry: CGSize(width: 800, height: 200))
    }
}
