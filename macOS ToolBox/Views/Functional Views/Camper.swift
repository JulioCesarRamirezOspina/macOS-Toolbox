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
    @State private var MainView = false
    @State private var isQuit = SettingsMonitor.isInMenuBar ? false : true
    @State private var passwordSaved = SettingsMonitor.passwordSaved
    @State private var isReboot = true
    @State private var wrongPasswordCount = 0
    @State private var nextOnly = true
    @State private var isBC = BootCampStart.bcExists(SettingsMonitor.bootCampDiskLabel)
    @State private var virtsExist = Virtuals.anyExist
    @State private var diskLabelSet = SettingsMonitor.bootCampDiskLabel
    @State private var showSettings = false
    @State private var dummy = false
    @State private var isRun = false
    
    private func tidIsEnabled() -> Bool {
        let pam = Shell.macOS_Auth_Subsystem()
        return pam.analyzePam_d()
    }
    
    public func BootCampView() -> some View {
        VStack{
            GeometryReader { g in
                if !passwordSaved {
                    CustomViews.NoPasswordView(false, toggle: $dummy)
                } else {
                    VStack(alignment: .center){
                        switch BootCampStart.getOSType(diskLabel: diskLabelSet).canBoot {
                        case true:
                            HStack(alignment: .center){
                                Text("bootcamp.title1").font(.largeTitle).fontWeight(.light).multilineTextAlignment(.center)
                                Text(BootCampStart.getOSType(diskLabel: diskLabelSet).OSType).font(.largeTitle).fontWeight(.light).multilineTextAlignment(.center)
                                Text("bootcamp.title2").font(.largeTitle).fontWeight(.light).multilineTextAlignment(.center)
                            }
                        case false:
                            Text("WARNING.STRING").font(.largeTitle).fontWeight(.light).multilineTextAlignment(.center)
                            Text("bootcamp.fail").font(.largeTitle).fontWeight(.light).multilineTextAlignment(.center)
                        }
                        HStack(alignment: .center){
                            HStack{
                                Spacer()
                                Toggle("rebootnow.button", isOn: $isReboot).disabled(!BootCampStart.getOSType(diskLabel: diskLabelSet).canBoot)
                                Toggle("nextOnly.toggle", isOn: $nextOnly).disabled(!BootCampStart.getOSType(diskLabel: diskLabelSet).canBoot)
                                Spacer()
                            }
                        }.padding()
                        Spacer()
                        HStack{
                            BootCampStart.setBootDevice(diskLabel: diskLabelSet, password: password, nextOnly: nextOnly, isReboot: isReboot).keyboardShortcut(.defaultAction)}.padding().disabled(!BootCampStart.getOSType(diskLabel: diskLabelSet).canBoot)
                            .buttonStyle(Stylers.ColoredButtonStyle(glyph: isReboot ? "restart" : "externaldrive.badge.checkmark", alwaysShowTitle: false, width: g.size.width / 4, height: g.size.height / 10, color: .blue, backgroundShadow: true))
                    }.padding()
                }
            }
        }.background {
            CustomViews.ImageView(imageName: "window.vertical.closed")
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
//        HStack(alignment: .center) {
//            TabView {
//                if isBC {
//                    BootCampView().tabItem {
//                        Text("bootcamp.button")
//                    }
//                }
//                if virtsExist {
//                    Virtuals.FileSearch().tabItem {
//                        Text("VMs")
//                    }
//                }
//            }.tabViewStyle(.automatic)
//        }
        CustomTabView(tabBarPosition: .top, content:
            isBC && virtsExist ? [(tabText: StringLocalizer("bootcamp.button"), tabIconName: "window.ceiling", view: AnyView(BootCampView())),
            (tabText: StringLocalizer("VMs"), tabIconName: "text.and.command.macwindow", view: AnyView(Virtuals.FileSearch()))] :
                isBC && !virtsExist ? [(tabText: StringLocalizer("bootcamp.button"), tabIconName: "window.ceiling", view: AnyView(BootCampView()))] :
                !isBC && virtsExist ? [(tabText: StringLocalizer("VMs"), tabIconName: "text.and.command.macwindow", view: AnyView(Virtuals.FileSearch()))] :
                [(tabText: StringLocalizer("VMs"), tabIconName: "text.and.command.macwindow", view: AnyView(Virtuals.FileSearch()))]
        )
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
                password = SettingsMonitor.password
                passwordSaved = SettingsMonitor.passwordSaved
                diskLabelSet = SettingsMonitor.bootCampDiskLabel
                virtsExist = Virtuals.anyExist
            }while (isRun)
        }
        .onDisappear {
            isRun = false
        }
        .animation(SettingsMonitor.secondaryAnimation, value: isReboot)
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
