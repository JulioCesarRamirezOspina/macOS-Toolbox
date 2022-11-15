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
    @State private var parallelsSelectedKey = Parallels.returnVMHumanizedDictionary().keys.first ?? ""
    @State private var UTMSelectedKey = UTM.returnVMHumanizedDictionary().keys.first ?? ""
    @State private var parallelsVMs = Parallels.returnVMHumanizedDictionary()
    @State private var utmVMs = UTM.returnVMHumanizedDictionary()
    @State private var isBC = BootCampStart.bcExists(SettingsMonitor.bootCampDiskLabel)
    @State private var isParallelsVM = Parallels.vmExists()
    @State private var isUTMVM = UTM.vmExists()
    @State private var diskLabelSet = SettingsMonitor.bootCampDiskLabel
    @State private var parallelsDirSet = URL(fileURLWithPath: "", isDirectory: true)
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
    
    public func ParallelsView(_ key: String) -> some View {
        VStack(alignment: .center) {
            Text("parallels.title").font(.largeTitle).fontWeight(.light).padding().multilineTextAlignment(.center)
            if Parallels.vmExists() {
                VStack(alignment: .center){
                    HStack(alignment: .center){
                        Picker("parallels.picker", selection: $parallelsSelectedKey) {
                            ForEach(parallelsVMs.sorted(by: >), id: \.key) {key, value in
                                Text(value).tag(key)
                            }.padding()
                        }.disabled(parallelsVMs.isEmpty)
                        Spacer()
                        if !SettingsMonitor.isInMenuBar {
                            Toggle("quit.button", isOn: $isQuit)
                            Spacer()
                        }
                    }.padding()
                    Spacer()
                    HStack(alignment: .center){
                        Spacer()
                        Button {
                            Parallels.launchVM(key: key, quit: isQuit)
                        } label: {
                            Text("launch.button")
                        }.keyboardShortcut(.defaultAction)
                            .buttonStyle(Stylers.ColoredButtonStyle(glyph: "bolt.square", alwaysShowTitle: false, width: 300, height: 50, color: .blue, backgroundShadow: true))
                        Spacer()
                        Parallels.showInFinder(parallelsSelectedKey)
                            .buttonStyle(Stylers.ColoredButtonStyle(glyphs: ["faceid", "square"],alwaysShowTitle: false, width: 300, height: 50, color: .green, backgroundShadow: true))
                        Spacer()
                    }
                }
            } else {
                HStack{
                    Text("novm.text").font(.largeTitle)
                    VStack(alignment: .center){Divider()}
                }.padding()
            }
        }
        .background(content: {
            HStack{
                Image(systemName: "line.diagonal")
                    .rotationEffect(.degrees(-45), anchor: .center)
                    .font(.custom("San Francisco", size: 140))
                    .fontWeight(.light)
                    .frame(width: 20, height: 140, alignment: .center)
                Image(systemName: "line.diagonal")
                    .rotationEffect(.degrees(-45), anchor: .center)
                    .font(.custom("San Francisco", size: 140))
                    .fontWeight(.light)
                    .frame(width: 20, height: 140, alignment: .center)
            }
            .foregroundStyle(RadialGradient(colors: [.blue, .gray, .white], center: .center, startRadius: 0, endRadius: 140))
            .opacity(0.5).blur(radius: 2)
            .shadow(radius: 15)
            .padding(.all)
        })
        .padding()
    }
    
    public func UTMView(_ key: String) -> some View {
        VStack(alignment: .center) {
            Text("utm.title").font(.largeTitle).fontWeight(.light).padding().multilineTextAlignment(.center)
            if UTM.vmExists() {
                VStack(alignment: .center){
                    HStack(alignment: .center){
                        Picker("utm.picker", selection: $UTMSelectedKey) {
                            ForEach(utmVMs.sorted(by: <), id: \.key) {key, value in
                                Text(value).tag(key)
                            }.padding()
                        }.disabled(utmVMs.isEmpty)
                        Spacer()
                        if !SettingsMonitor.isInMenuBar {
                            Toggle("quit.button", isOn: $isQuit)
                            Spacer()
                        }
                    }.padding()
                    Spacer()
                    HStack(alignment: .center){
                        Spacer()
                        Button {
                            UTM.launchVM(key: key, quit: isQuit)
                        } label: {
                            Text("launch.button")
                        }.keyboardShortcut(.defaultAction)
                            .buttonStyle(Stylers.ColoredButtonStyle(glyph: "bolt.square", alwaysShowTitle: false, width: 300, height: 50, color: .blue, backgroundShadow: true))
                        Spacer()
                        UTM.showInFinder(UTMSelectedKey)
                            .buttonStyle(Stylers.ColoredButtonStyle(glyphs: ["faceid", "square"],alwaysShowTitle: false, width: 300, height: 50, color: .green, backgroundShadow: true))
                        Spacer()
                    }
                }
            } else {
                HStack{
                    Text("novm.text").font(.largeTitle)
                    VStack(alignment: .center){Divider()}
                }.padding()
            }
        }
        .background(content: {
            CustomViews.UTMLogo()
        })
        .padding()
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
                if isParallelsVM {
                    ParallelsView(parallelsSelectedKey).tabItem{
                        Text("parallels.button")
                    }
                }
                if isUTMVM {
                    UTMView(UTMSelectedKey).tabItem{
                        Text("utm.button")
                    }
                }
            }
        }
    }
    
    private func MainViewWithoutPassword() -> AnyView {
        return AnyView(
            VStack{
                if isBC || isParallelsVM || isUTMVM {
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
                _ = BootCampStart.tryToMount(diskLabel: diskLabelSet, password: password)
                _ = Parallels.getVMList()
                isBC = BootCampStart.bcExists(diskLabelSet)
                isParallelsVM = Parallels.vmExists()
                parallelsVMs = Parallels.returnVMHumanizedDictionary()
//                parallelsSelectedKey = Parallels.returnVMHumanizedDictionary().keys.first ?? ""
                isUTMVM = UTM.vmExists()
                utmVMs = UTM.returnVMHumanizedDictionary()
//                UTMSelectedKey = UTM.returnVMHumanizedDictionary().keys.first ?? ""
                password = SettingsMonitor.password
                passwordSaved = SettingsMonitor.passwordSaved
                diskLabelSet = SettingsMonitor.bootCampDiskLabel
                do {
                    try await Task.sleep(nanoseconds: 1000000000)
                } catch _ {}
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
