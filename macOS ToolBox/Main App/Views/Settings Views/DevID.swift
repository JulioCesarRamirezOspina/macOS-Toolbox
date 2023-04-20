//
//  DevID Settings.swift
//  MultiTool
//
//  Created by Олег Сазонов on 01.07.2022.
//

import Foundation
import SwiftUI

struct DevIDSettings: View {
    @State private var devID = ""
    @State private var devIDString = ""
    var body: some View {
        GeometryReader { g in
            GroupBox {
                VStack{
                    Group {
                        HStack{
                            Text("\(StringLocalizer("currentDeveloperIDInstaller.string")):")
                            Text(SettingsMonitor.devID == "" ? StringLocalizer("noDevID.string") : SettingsMonitor.devID)
                        }
                    }
                    Spacer()
                    Group {
                        HStack{
                            Spacer()
                            TextField("newDevID.string", text: $devIDString).textFieldStyle(Stylers.GlassyTextField()).padding(.all)
                            Spacer()
                        }
                    }
                    Spacer()
                    Group {
                        HStack{
                            Button {
                                SettingsMonitor.devID = devIDString
                                devIDString = ""
                            } label: {
                                Text("save.button")
                            }
                            .disabled(devIDString == "")
                            .buttonStyle(Stylers.ColoredButtonStyle(disabled: devIDString == "", enabled: devIDString != "", alwaysShowTitle: true, width: g.size.width / 5, height: 50, color: .cyan, backgroundShadow: true))
                            Spacer()
                            Button {
                                let dev = tryToGetDeveloperIDInstallerSignature()
                                let ex = dev.DevIDExists
                                let id = dev.DevID
                                if ex {
                                    devID = id
                                    devIDString = " "
                                    devIDString = id
                                    SettingsMonitor.devID = id
                                } else {
                                    SettingsMonitor.devID = ""
                                    devID = StringLocalizer("noDevID.string")
                                    devIDString = StringLocalizer("noDevID.string")
                                }
                            } label: {
                                Text(StringLocalizer("autofill.string"))
                            }
                            .buttonStyle(Stylers.ColoredButtonStyle(alwaysShowTitle: true, width: g.size.width / 5, height: 50, color: .green, backgroundShadow: true))
                            Spacer()
                            Button {
                                SettingsMonitor.devID = ""
                                devIDString = ""
                                devID = ""
                            } label: {
                                Text(StringLocalizer("password.remove"))
                            }
                            .buttonStyle(Stylers.ColoredButtonStyle(alwaysShowTitle: true, width: g.size.width / 5, height: 50, color: .red, backgroundShadow: true))
                        }.padding(.all)
                    }
                }
            } label: {
                CustomViews.AnimatedTextView(Input: "Developer ID")
            }
            .groupBoxStyle(Stylers.CustomGBStyle())
            .background(content: {
                if SettingsMonitor.devID != "" || UserDefaults().value(forKey: "devID") != nil {
                    CustomViews.ImageView(imageName: "person.crop.circle.badge.checkmark")
                } else {
                    CustomViews.ImageView(imageName: "person.crop.circle.badge.questionmark")
                }
            })
            .onChange(of: devIDString) { newValue in
                devID = newValue
            }
            .onAppear {
                devID = SettingsMonitor.devID
            }
            .animation(SettingsMonitor.secondaryAnimation, value: devID)
        }
    }
}

struct devIDPreview: PreviewProvider {
    static var previews: some View {
        DevIDSettings()
    }
}
