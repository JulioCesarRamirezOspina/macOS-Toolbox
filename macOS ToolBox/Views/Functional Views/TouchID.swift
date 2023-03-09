//
//  TouchID.swift
//  MultiTool
//
//  Created by Олег Сазонов on 10.06.2022.
//

import Foundation
import SwiftUI
import xCore
import LocalAuthentication

struct TouchIDView: View {
    
    @State private var password = SettingsMonitor.password
    @State private var passwordExists = SettingsMonitor.passwordSaved
    @State private var status = false
    @State private var loading = true
    @State private var dummy = false
    func run() -> Void {
        PAMManager.TouchID().switchState(password)
        status = PAMManager.TouchID().analyzePam_d()
    }
    
    func img(_ colors: [Color], name: String) -> some View {
        Image(systemName: name)
            .font(.custom("San Francisco", size: 140))
            .foregroundStyle(
                RadialGradient(
                    colors: colors,
                    center: .top,
                    startRadius: 0,
                    endRadius: 140))
            .shadow(color: .black, radius: 7, x: 0, y: 5)
            .padding(.all)
    }
    
    private let enabledColors: [Color] = [.blue, .purple, .red]
    private let disabledColors: [Color] = [.gray, .gray, .gray, .clear]
    @State private var dq = DispatchQueue(label: "tidView")
    @State private var AuthType = LAContext().biometricType
    
    var noTouchID: some View {
        VStack{
            Spacer()
            Spacer()
            CustomViews.AnimatedTextView(Input: "noTouchIDInstalled.string", Font: .largeTitle, FontWeight: .black, TimeToStopAnimation: SettingsMonitor.secAnimDur)
            Spacer()
        }
        .background(content: {
            if status {
                img(enabledColors, name: "touchid")
            } else {
                img(disabledColors, name: "touchid")
            }
        })
    }
    
    func isDisabledUpdate() -> Bool {
        return (PAMManager.SystemAuthData().sudoContents.state == .enable) == sudoNew && screensaverNew == (PAMManager.SystemAuthData().screensaverContents.state == .enable)
    }
    
    var allUp: Bool {
        return PAMManager.SystemAuthData().sudoContents.state == .enable && PAMManager.SystemAuthData().screensaverContents.state == .enable
    }
    
    var data = PAMManager.SystemAuthData()
    @State var sudoOld = PAMManager.SystemAuthData().sudoContents.state == .enable
    @State var screensaverOld = PAMManager.SystemAuthData().screensaverContents.state == .enable
    @State var sudoNew = PAMManager.SystemAuthData().sudoContents.state == .enable
    @State var screensaverNew = PAMManager.SystemAuthData().screensaverContents.state == .enable
    @State var isDisabled = true
    @State var showPAM = false
    var touchIDExists: some View {
        VStack {
            if SettingsMonitor.passwordSaved {
                VStack{
                    if !loading {
                        Spacer()
                        Group {
                            
                            HStack(alignment: .center){
                                Spacer()
                                
                                Button {
                                    run()
                                } label: {
                                    Text(!status ? StringLocalizer("enable.string") : StringLocalizer("disable.string"))
                                }.keyboardShortcut(.defaultAction)
                                    .buttonStyle(Stylers.ColoredButtonStyle(glyph: !status ? "touchid" : "poweroff", enabled: status, color: !status ? .blue : .green, hideBackground: false, backgroundIsNotFill: true))
                                
                                Spacer()
                            }.padding(.all)
                        }
                    } else {
                        Spacer()
                    }
                }
                .onChange(of: status, perform: { newValue in
                    passwordExists = SettingsMonitor.passwordSaved
                })
                .animation(SettingsMonitor.secondaryAnimation, value: status)
            } else {
                CustomViews.NoPasswordView(false, toggle: $dummy)
            }
        }
        .background(content: {
            HStack{
                if status {
                    img(enabledColors, name: "touchid")
                } else {
                    img(disabledColors, name: "touchid")
                }
                
            }
        })
    }
    
    var PAMView: some View {
        VStack{
            Spacer()
            HStack{
                Spacer()
                Button {
                    showPAM.toggle()
                } label: {
                    Text("hwkey.string")
                }.popover(isPresented: $showPAM) {
                    PAMSubView.padding()
                }
                .buttonStyle(Stylers.ColoredButtonStyle(glyph: "key", enabled: sudoOld || screensaverOld, color: sudoOld || screensaverOld ? .blue : .gray, hideBackground: false, backgroundIsNotFill: true))
                Spacer()
            }.padding(.all)
        }
        .background(content: {
            HStack{
                if allUp {
                    img(enabledColors, name: "key.fill")
                } else {
                    img(disabledColors, name: "key.fill")
                }
                
            }
        })
    }
    
    var PAMSubView: some View {
        ZStack {
            VStack{
                if data.notInstalled() {
                    Text(data.localizedErrorReturner(1))
                }
                HStack(alignment: .center) {
                    Spacer()
                    Button {
                        screensaverNew.toggle()
                    } label: {
                        Text(StringLocalizer("screensaver.string"))
                    }
                    .buttonStyle(Stylers.ColoredButtonStyle(glyph: screensaverNew ? "person.badge.key" : "person.badge.key.fill", enabled: screensaverNew, color: screensaverNew ? .blue : .gray, hideBackground: false, backgroundIsNotFill: true))
                    
                    
                    Button {
                        sudoNew.toggle()
                    } label: {
                        Text(StringLocalizer("sudo.string"))
                    }
                    .buttonStyle(Stylers.ColoredButtonStyle(glyph: sudoNew ? "person.fill.checkmark" : "person.fill.questionmark", enabled: sudoNew, color: sudoNew ? .blue : .gray, hideBackground: false, backgroundIsNotFill: true))
                    Spacer()
                }
                
                HStack{
                    Button { [self] in
                        data.edit(!sudoNew ? .disable : .enable, .sudo, password)
                        data.edit(!screensaverNew ? .disable : .enable, .screensaver, password)
                        screensaverOld = PAMManager.SystemAuthData().screensaverContents.state == .enable
                        sudoOld = PAMManager.SystemAuthData().sudoContents.state == .enable
                        isDisabled = isDisabledUpdate()
                        showPAM.toggle()
                    } label: {
                        Text(StringLocalizer("save.button"))
                    }.disabled(isDisabled || data.notInstalled())
                        .buttonStyle(Stylers.ColoredButtonStyle(glyph: "key", disabled: isDisabled ||  data.notInstalled(), enabled: sudoNew != sudoOld || screensaverNew != screensaverOld, color: .blue, hideBackground: false, backgroundIsNotFill: true))
                    
                    Button { [self] in
                        screensaverNew = screensaverOld
                        sudoNew = sudoOld
                        showPAM.toggle()
                    } label: {
                        Text(StringLocalizer("cancel.button"))
                    }
                    .buttonStyle(Stylers.ColoredButtonStyle(glyph: "escape", color: .red, hideBackground: false, backgroundIsNotFill: true))
                    
                }
                
            }
        }
        .onChange(of: sudoOld) { newValue in
            isDisabled = isDisabledUpdate()
        }.onChange(of: screensaverOld) { newValue in
            isDisabled = isDisabledUpdate()
        }.onChange(of: sudoNew) { newValue in
            isDisabled = isDisabledUpdate()
        }.onChange(of: screensaverNew) { newValue in
            isDisabled = isDisabledUpdate()
        }
        .animation(SettingsMonitor.secondaryAnimation, value: sudoNew)
        .animation(SettingsMonitor.secondaryAnimation, value: screensaverNew)
        .animation(SettingsMonitor.secondaryAnimation, value: isDisabled)
    }
    
    var body: some View {
        GroupBox {
            if SettingsMonitor.passwordSaved {
                if !loading {
                    HStack{
                        if AuthType == .faceID || AuthType == .touchID {
                            touchIDExists
                        } else {
                            noTouchID
                        }
                        Spacer()
                        PAMView
                    }
                } else {
                    Spacer()
                }
            } else {
                CustomViews.NoPasswordView(false, toggle: $dummy)
            }
        } label: {
            CustomViews.AnimatedTextView(Input: "tid.title", TimeToStopAnimation: SettingsMonitor.secAnimDur)
        }
        .groupBoxStyle(Stylers.CustomGBStyle())
        .onChange(of: status, perform: { newValue in
            passwordExists = SettingsMonitor.passwordSaved
        })
        .animation(SettingsMonitor.secondaryAnimation, value: status)
        .onAppear {
            status = PAMManager.TouchID().analyzePam_d()
            loading = false
            passwordExists = SettingsMonitor.passwordSaved
            
        }
    }
}


struct TidPreivew: PreviewProvider {
    static var previews: some View {
        TouchIDView()
    }
}
