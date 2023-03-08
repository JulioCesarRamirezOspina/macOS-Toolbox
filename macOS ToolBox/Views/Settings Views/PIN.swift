//
//  PIN.swift
//  macOS ToolBox
//
//  Created by Олег Сазонов on 08.03.2023.
//  Copyright © 2023 ~X~ Lab. All rights reserved.
//

import Foundation
import xCore
import SwiftUI

struct PINSettings: View {
    @State private var showSheet = false
    @State public var pin = ""
    @State private var pinSaved = SettingsMonitor.pinSaved
    @State private var pinIsInCorrect = false
    private func checkpin(pin: String) {
        if Shell.Parcer.correctPassword(pin) != true {
            pinIsInCorrect = true
            SettingsMonitor.pin = ""
            self.pin = ""
        } else {
            SettingsMonitor.pin = pin
            pinIsInCorrect = false
            pinSaved = SettingsMonitor.pinSaved
            self.pin = ""
        }
    }
    var body: some View {
        GeometryReader { g in
            GroupBox {
                VStack{
                    Group {
                        Text("pin.info")
                    }
                    Spacer()
                    Group {
                        HStack{
                            Spacer()
                            SecureField("pin.text", text: $pin, onCommit: {
                                checkpin(pin: pin)
                            })
                            .textFieldStyle(Stylers.GlassySecureField())
                            .padding(.all)
                            .keyboardShortcut(.defaultAction)
                            Spacer()
                        }
                    }
                    Spacer()
                    Group {
                        HStack(alignment: .center) {
                            Button {
                                checkpin(pin: pin)
                                pinSaved = SettingsMonitor.pinSaved
                                pin = ""
                            } label: {
                                Text("pin.save")
                            }
                            .keyboardShortcut(.defaultAction).disabled(pin == "")
                            .buttonStyle(Stylers.ColoredButtonStyle(disabled: pin == "", enabled: pin != "", alwaysShowTitle: true, width: g.size.width / 5, height: 50, color: .cyan, backgroundShadow: true))
                            Spacer()
                            Button {
                                SettingsMonitor.pin = ""
                                pinSaved = SettingsMonitor.pinSaved
                                pin = ""
                            } label: {
                                Text("pin.remove")
                            }
                            .disabled(!pinSaved)
                            .buttonStyle(Stylers.ColoredButtonStyle(disabled: !pinSaved, alwaysShowTitle: true, width: g.size.width / 5, height: 50, color: .red, backgroundShadow: true))

                        }.padding(.all)
                    }
                }
            } label: {
                CustomViews.AnimatedTextView(Input: "pin.settings")
            }
            .groupBoxStyle(Stylers.CustomGBStyle())
            .background(content: {
                if SettingsMonitor.pinSaved {
                    CustomViews.ImageView(imageName: "lock")
                } else {
                    ZStack {
                        CustomViews.ImageView(imageName: "lock")
                        CustomViews.ImageView(imageName: "line.diagonal")
                    }
                }
            })
            .onDisappear {
                pin = ""
            }
            .sheet(isPresented: $pinIsInCorrect) {
                ZStack{
                    CustomViews.ImageView()
                    VStack{
                        Text("incorrectpin.string").font(.largeTitle).fontWeight(.bold).padding(.all)
                        CustomViews.AppLogo().padding(.all)
                        Button {
                            pinIsInCorrect.toggle()
                        } label: {
                            Text("ok.button")
                        }.keyboardShortcut(.defaultAction).padding(.all)
                    }
                }.padding(.all)
            }
            .onChange(of: pinIsInCorrect) { newValue in
                showSheet = newValue
            }
            .onAppear {
                pin = ""
                pinSaved = SettingsMonitor.pinSaved
            }
            .animation(SettingsMonitor.secondaryAnimation, value: pinSaved)
        }
    }
}
