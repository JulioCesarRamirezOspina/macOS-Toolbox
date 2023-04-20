//
//  SleepManagerView.swift
//  MultiTool
//
//  Created by Олег Сазонов on 26.06.2022.
//

import Foundation
import SwiftUI

struct SleepManagerView: View {
    @State private var selection = 0
    @State private var sleepInt: Int = SleepManager().getIsSleepEnabled()
    @State private var timer: Timer?
    @State private var password = SettingsMonitor.password
    @State private var timeToStop = SettingsMonitor.secAnimDur
    @State private var caffButtonDisabled = false
    @State private var preventSleep = SleepManager().sleepIsPermitted()
    @State private var sysSleepState = SleepManager().SystemWideSleepStatus()
    @State private var showPopoverUp = false
    @State private var showPopoverDown = false
    @State private var dummy = false
    
    private var setButton: some View {
        Button {
            SleepManager().setHibernationMode(parameter: selection, password: password)
        } label: {
            Text("save.button")
        }
        
    }
    
    private func sleepNow() {
        let process = Process()
        process.executableURL = URL(filePath: "/bin/bash")
        process.arguments = ["-c", "pmset sleepnow"]
        do {
            try process.run()
        } catch let error {
            NSLog(error.localizedDescription)
        }
    }
    
    private var MainButtons: some View {
        GeometryReader { g in
            HStack{
                Button {
                    selection = 0
                } label: {
                    Text(SleepManager().getSleepSetting(0))
                }.buttonStyle(Stylers.ColoredButtonStyle(glyph: "sun.max.fill", disabled: sysSleepState, enabled: selection == 0, width: g.size.width / 3 - 10, color: .blue))
                    .disabled(sysSleepState)
                Spacer()
                Button {
                    selection = 3
                } label: {
                    Text(SleepManager().getSleepSetting(3))
                }.buttonStyle(Stylers.ColoredButtonStyle(glyph: "bed.double.fill", disabled: sysSleepState, enabled: selection == 3, width: g.size.width / 3 - 10, color: .cyan))
                    .disabled(sysSleepState)
                Spacer()
                Button {
                    selection = 25
                } label: {
                    Text(SleepManager().getSleepSetting(25))
                }.buttonStyle(Stylers.ColoredButtonStyle(glyph: "moon.zzz", disabled: sysSleepState, enabled: selection == 25, width: g.size.width / 3 - 10, color: .indigo))
                    .disabled(sysSleepState)
            }
            .frame(height: 100)
        }.padding(.all)
    }
    
    private var SleepImage: some View {
        VStack{
            switch sleepInt {
            case 0:
                CustomViews.ImageView(imageName: "lightbulb.fill", opacity: 1, blurRadius: 0)
            case 3:
                CustomViews.ImageView(imageName: "lightbulb", opacity: 1, blurRadius: 0)
            case 25:
                CustomViews.ImageView(imageName: "lightbulb.slash", opacity: 1, blurRadius: 0, defaultGradientColors: [.gray, .gray, .clear])
            default:  CustomViews.ImageView()
            }
        }
    }
    
    private var FuncButtons: some View {
        GeometryReader { g in
            HStack{
                Button {
                    if !preventSleep {
                        SleepManager().permitSleep( caffButtonDisabled ? .allow : .deny)
                    } else {
                        SleepManager().allowSleep()
                    }
                    preventSleep.toggle()
                } label: {
                    Text("preventSleep.string")
                }.buttonStyle(Stylers.ColoredButtonStyle(glyph: selection == 25 ? "sun.max" : "wake", disabled: (sleepInt == 0 || sysSleepState), enabled: preventSleep, width: g.size.width / 3 - 10, color: .purple))
                    .disabled(sleepInt == 0 || sysSleepState)
                Spacer()
                Button {
                    sleepNow()
                } label: {
                    Text("sleepNow.string")
                }.buttonStyle(Stylers.ColoredButtonStyle(glyph: selection == 25 ? "powersleep" : "sleep", disabled: (preventSleep || sleepInt == 0 || sysSleepState), width: g.size.width / 3 - 10, color: .blue))
                    .disabled(preventSleep || sleepInt == 0 || sysSleepState)
                Spacer()
                Button {
                    caffButtonDisabled.toggle()
                } label: {
                    Text("screenAllowedToSleep.string")
                }.buttonStyle(Stylers.ColoredButtonStyle(glyph: "display.trianglebadge.exclamationmark", disabled: (preventSleep == true || sleepInt == 0 || sysSleepState), enabled: caffButtonDisabled, width: g.size.width / 3 - 10, color: .yellow))
                    .disabled(preventSleep || sleepInt == 0 || sysSleepState)
            }
            .frame(height: 100)
        }.padding(.all)
    }
    
    var body: some View {
        if SettingsMonitor.passwordSaved {
            GroupBox {
                Group {
                    MainButtons.padding(.all)
                        .onHover { t in
                            sysSleepState = SleepManager().SystemWideSleepStatus()
                            if t {
                                if sysSleepState {
                                    showPopoverUp = true
                                } else {
                                    showPopoverUp = false
                                }
                            }
                        }
                }
                Spacer().padding(.all)
                Group {
                    FuncButtons.padding(.all)
                        .onHover { t in
                            sysSleepState = SleepManager().SystemWideSleepStatus()
                            if t {
                                if sysSleepState {
                                    showPopoverDown = true
                                } else {
                                    showPopoverDown = false
                                }
                            }
                        }
                }
            } label: {
                CustomViews.AnimatedTextView(Input: "sleepManager.string",TimeToStopAnimation: timeToStop)
            }
            .groupBoxStyle(Stylers.CustomGBStyle())
            .background(content: {
                SleepImage.popover(isPresented: $showPopoverUp,arrowEdge: .bottom) {
                    VStack{
                        Text("cantSLeep.string").padding(.all).fontWeight(.bold)
                        CustomViews.AppLogo().padding(.all)
                        
                    }
                }
                SleepImage.popover(isPresented: $showPopoverDown,arrowEdge: .top) {
                    VStack{
                        Text("cantSLeep.string").padding(.all).fontWeight(.bold)
                        CustomViews.AppLogo().padding(.all)
                        
                    }
                }
            })
            .onAppear {
                sleepInt = SleepManager().getIsSleepEnabled()
                timeToStop = SettingsMonitor.secAnimDur
                password = SettingsMonitor.password
                if sleepInt == 0 {
                    selection = 0
                }
                selection = SleepManager().getIsSleepEnabled()
                sysSleepState = SleepManager().SystemWideSleepStatus()
                if sysSleepState {
                    showPopoverUp = true
                }
            }
            .onChange(of: showPopoverUp, perform: { newValue in
                sysSleepState = SleepManager().SystemWideSleepStatus()
                if sysSleepState {
                    showPopoverDown = !newValue
                }
            })
            .onChange(of: showPopoverDown, perform: { newValue in
                sysSleepState = SleepManager().SystemWideSleepStatus()
                if sysSleepState {
                    showPopoverUp = !newValue
                }
            })
            .onChange(of: selection, perform: { newValue in
                SleepManager().setHibernationMode(parameter: newValue, password: password)
                selection = newValue
                if selection == 0 {
                    SleepManager().allowSleep()
                    caffButtonDisabled = false
                }
                sleepInt = newValue
                preventSleep = SleepManager().sleepIsPermitted()
            })
            .animation(SettingsMonitor.secondaryAnimation, value: sleepInt)
            .animation(SettingsMonitor.secondaryAnimation, value: selection)
        } else {
            CustomViews.NoPasswordView(false, toggle: $dummy)
        }
    }
}

struct SleepPreview: PreviewProvider {
    static var previews: some View {
        SleepManagerView().frame(width: 500, height: 700, alignment: .center)
    }
}
