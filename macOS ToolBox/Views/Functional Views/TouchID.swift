//
//  TouchID.swift
//  MultiTool
//
//  Created by Олег Сазонов on 10.06.2022.
//

import Foundation
import SwiftUI
import xCore

struct TouchIDView: View {
    
    @State private var password = SettingsMonitor.password
    @State private var passwordExists = SettingsMonitor.passwordSaved
    @State private var status = false
    @State private var loading = true
    @State private var dummy = false
    func run() -> Void {
        Shell.macOS_Auth_Subsystem().switchState(password)
        status = Shell.macOS_Auth_Subsystem().analyzePam_d()
    }
    
    func img(_ colors: [Color]) -> some View {
        Image(systemName: "touchid")
            .font(.custom("San Francisco", size: 140))
            .foregroundStyle(
                RadialGradient(
                    colors: colors,
                    center: .top,
                    startRadius: 0,
                    endRadius: 140))
            .shadow(color: .black, radius: 7, x: 0, y: 5)
//            .animation(
//                .easeInOut(duration: timeToStop),
//                value: DispatchTime.now())
            .padding(.all)
    }
    
    private let enabledColors: [Color] = [.blue, .purple, .red]
    private let disabledColors: [Color] = [.gray, .gray, .gray, .clear]
    @State private var dq = DispatchQueue(label: "tidView")
    
    var body: some View {
        if SettingsMonitor.passwordSaved {
            GroupBox {
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
                                    .buttonStyle(Stylers.ColoredButtonStyle(glyph: !status ? "power.circle" : "poweroff", enabled: status, color: !status ? .blue : .green, hideBackground: false, backgroundIsNotFill: true))
                                Spacer()
                            }.padding(.all)
                        }
                    } else {
                        Spacer()
                    }
                }
            } label: {
                CustomViews.AnimatedTextView(Input: "tid.title", TimeToStopAnimation: SettingsMonitor.secAnimDur)
            }
            .groupBoxStyle(Stylers.CustomGBStyle())
            .background(content: {
                if status {
                    img(enabledColors)
                } else {
                    img(disabledColors)
                }
            })
            .onAppear {
                status = Shell.macOS_Auth_Subsystem().analyzePam_d()
                loading = false
                passwordExists = SettingsMonitor.passwordSaved
                
            }
            .onChange(of: status, perform: { newValue in
                passwordExists = SettingsMonitor.passwordSaved
            })
            .animation(SettingsMonitor.secondaryAnimation, value: status)
        } else {
            CustomViews.NoPasswordView(false, toggle: $dummy)
        }
    }
}


struct TidPreivew: PreviewProvider {
    static var previews: some View {
        TouchIDView()
    }
}
