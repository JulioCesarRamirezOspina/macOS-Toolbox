//
//  ContentView.swift
//  BootCamper
//
//  Created by Олег Сазонов on 31.12.2021.
//

import SwiftUI
import Foundation
import xCore

/// This is the main view of the app
struct CamperView: View {
    @Environment(\.locale) var locale
    @State private var password = SettingsMonitor.password
    @State private var passwordSaved = SettingsMonitor.passwordSaved
    @State private var isReboot = SettingsMonitor.bootCampWillRestart
    @State private var nextOnly = SettingsMonitor.bootCampIsNextOnly
    @State private var isBC = BootCampStart.bcExists(SettingsMonitor.bootCampDiskLabel)
    @State private var virtsExist = Virtuals.anyExist
    @State private var diskLabelSet = SettingsMonitor.bootCampDiskLabel
    @State private var showSettings = false
    @State private var dummy = false
    @State private var isRun = false
    
    private func tidIsEnabled() -> Bool {
        let pam = PAMManager.TouchID()
        return pam.analyzePam_d()
    }
    
    public func BootCampView(proxy: CGSize) -> some View {
        ZStack{
            RoundedRectangle(cornerRadius: 15)
                .foregroundStyle(.ultraThinMaterial.shadow(.inner(radius: 15)))
            if BootCampStart.getOSType(diskLabel: diskLabelSet).OSTypeTechnical == .windows {
                CustomViews.ImageView(imageName: "window.vertical.closed")
            } else if BootCampStart.getOSType(diskLabel: diskLabelSet).OSTypeTechnical == .linux {
                CustomViews.LinuxLogo()
            } else if BootCampStart.getOSType(diskLabel: diskLabelSet).OSTypeTechnical == .macos ||
                        BootCampStart.getOSType(diskLabel: diskLabelSet).OSTypeTechnical == .macosinstaller {
                CustomViews.ImageView(imageName: "x.circle.fill")
            }
            HStack{
                VStack{
                    VStack{
                        Text(diskLabelSet)
                            .font(.largeTitle)
                        Divider().padding(.all)
                        Text(BootCampStart.getOSType(diskLabel: diskLabelSet).OSType)
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                    }
                }.frame(width: proxy.width / 2)
                Spacer()
                VStack{
                    VStack{
                        Button {
                            isReboot.toggle()
                        } label: {
                            Text("rebootnow.button")
                        }
                        .buttonStyle(Stylers.ColoredButtonStyle(glyph: "restart.circle",
                                                                enabled: isReboot,
                                                                color: .red))
                        Button {
                            nextOnly.toggle()
                        } label: {
                            Text("nextOnly.toggle")
                        }
                        .buttonStyle(Stylers.ColoredButtonStyle(glyph: "repeat.1.circle",
                                                                enabled: nextOnly,
                                                                color: .blue))
                    }
                    BootCampStart.setBootDevice(diskLabel: diskLabelSet, password: password, nextOnly: nextOnly, isReboot: isReboot).keyboardShortcut(.defaultAction).padding().disabled(!BootCampStart.getOSType(diskLabel: diskLabelSet).canBoot)
                        .buttonStyle(Stylers.ColoredButtonStyle(glyph:
                                                                    isReboot ? "restart" : "externaldrive.badge.checkmark",
                                                                alwaysShowTitle: false,
                                                                color: .blue,
                                                                backgroundShadow: true))
                }
            }
        }
    }
    
    private func nothingFound() -> some View {
        VStack{
            Spacer()
            CustomViews.AnimatedTextView(Input: "empty.warning", Font: .largeTitle, FontWeight: .bold, TimeToStopAnimation: SettingsMonitor.secAnimDur)
            Spacer()
        }.padding()
    }
    
    private func mainTabView() -> some View {
        VStack{
            GeometryReader { proxy in
                ScrollView(.vertical, showsIndicators: true) {
                    Text(" ")
                    if isBC {
                        BootCampView(proxy: proxy.size)
                    }
                    Virtuals.FileSearch().onlyForEachView(width: proxy.size.width)
                }
            }
        }
    }
    private func MainViewWithoutPassword() -> some View {
        return VStack{
            if isBC || virtsExist {
                mainTabView().padding(.all)
            } else {
                nothingFound().padding(.all)
            }
        }
    }
    
    var body: some View {
        GroupBox {
            VStack{
                MainViewWithoutPassword()
                    .environment(\.locale, locale)
            }
        } label: {
            CustomViews.AnimatedTextView(Input: StringLocalizer("camperView.string"), TimeToStopAnimation: SettingsMonitor.secAnimDur)
        }
        .groupBoxStyle(Stylers.CustomGBStyle())
        .onAppear {
            isRun = true
        }
        .task {
            repeat {
                do {
                    try await Task.sleep(nanoseconds: 1000000000)
                } catch _ {}
                _ = BootCampStart.tryToMount(diskLabel: diskLabelSet, password: password)
                isBC = BootCampStart.bcExists(diskLabelSet)
                isReboot = SettingsMonitor.bootCampWillRestart
                nextOnly = SettingsMonitor.bootCampIsNextOnly
                password = SettingsMonitor.password
                passwordSaved = SettingsMonitor.passwordSaved
                diskLabelSet = SettingsMonitor.bootCampDiskLabel
                virtsExist = Virtuals.anyExist
            }while (isRun)
        }
        .onChange(of: isReboot) { newValue in
            SettingsMonitor.bootCampWillRestart = newValue
        }
        .onChange(of: nextOnly) { newValue in
            SettingsMonitor.bootCampIsNextOnly = newValue
        }
        .onDisappear {
            isRun = false
        }
        .animation(SettingsMonitor.secondaryAnimation, value: isReboot)
        .animation(SettingsMonitor.secondaryAnimation, value: isRun)
    }
}


struct camperPreview: PreviewProvider {
    static var previews: some View {
        CamperView()
    }
}

private struct CustomTabView: View {
    
    public enum TabBarPosition { // Where the tab bar will be located within the view
        case top
        case bottom
    }
    
    private let tabBarPosition: TabBarPosition
    private let tabText: [String]
    private let tabIconNames: [String]
    private let tabViews: [AnyView]
    
    @State private var selection = 0
    
    public init(tabBarPosition: TabBarPosition, content: [(tabText: String, tabIconName: String, view: AnyView)]) {
        self.tabBarPosition = tabBarPosition
        self.tabText = content.map{ $0.tabText }
        self.tabIconNames = content.map{ $0.tabIconName }
        self.tabViews = content.map{ $0.view }
    }
    
    public var tabBar: some View {
        
        HStack {
            Spacer()
            ForEach(0..<tabText.count, id: \.self) { index in
                HStack {
                    Image(systemName: self.tabIconNames[index])
                    if self.selection == index {
                        Text(self.tabText[index])
                    }
                }
                .padding(.all)
                .foregroundColor(self.selection == index ? Color.primary : Color.secondary)
                .background(content: {
                    RoundedRectangle(cornerRadius: 15)
                        .foregroundStyle(.ultraThinMaterial)
                })
                .onTapGesture {
                    self.selection = index
                }
                .animation(SettingsMonitor.secondaryAnimation, value: selection)
            }
            Spacer()
        }
        .padding(.all)
        .backgroundStyle(.clear)
        .shadow(color: Color.clear, radius: 0, x: 0, y: 0)
        .backgroundStyle(.clear)
        .shadow(
            color: Color.black.opacity(0.25),
            radius: 3,
            x: 0,
            y: tabBarPosition == .top ? 1 : -1
        )
        .zIndex(99) // Raised so that shadow is visible above view backgrounds
    }
    public var body: some View {
        
        VStack(spacing: 0) {
            
            if (self.tabBarPosition == .top) {
                tabBar
            }
            
            tabViews[selection]
                .padding(0)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            if (self.tabBarPosition == .bottom) {
                tabBar
            }
        }
        .padding(0)
    }
}
