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
        HStack(alignment: .center) {
            TabView {
                if isBC {
                    BootCampView().tabItem {
                        Text("bootcamp.button")
                    }
                }
                if virtsExist {
                    Virtuals.FileSearch().tabItem {
                        Text("VMs")
                    }
                }
            }
        }
    }
    
    private func MainViewWithoutPassword() -> AnyView {
        return AnyView(
            VStack{
                if isBC || virtsExist {
                    mainTabView().padding(.all)
                } else {
                    nothingFound().padding(.all)
                }
            }
        )
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
