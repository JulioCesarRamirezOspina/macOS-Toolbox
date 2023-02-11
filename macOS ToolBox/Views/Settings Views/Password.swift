//
//  Password Settings View.swift
//  MultiTool
//
//  Created by Олег Сазонов on 01.07.2022.
//

import Foundation
import xCore
import SwiftUI

struct PasswordSettings: View {
    @State private var showSheet = false
    @State public var password = ""
    @State private var passwordSaved = SettingsMonitor.passwordSaved
    @State private var passwordIsInCorrect = false
    private func checkPassword(password: String) {
        if Shell.Parcer.correctPassword(password) != true {
            passwordIsInCorrect = true
            SettingsMonitor.password = ""
            self.password = ""
        } else {
            SettingsMonitor.password = password
            passwordIsInCorrect = false
            passwordSaved = SettingsMonitor.passwordSaved
            self.password = ""
        }
    }
    var body: some View {
        GeometryReader { g in
            GroupBox {
                VStack{
                    Group {
                        Text("password.info")
                    }
                    Spacer()
                    Group {
                        HStack{
                            Spacer()
                            SecureField("password.text", text: $password, onCommit: {
                                checkPassword(password: password)
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
                                checkPassword(password: password)
                                passwordSaved = SettingsMonitor.passwordSaved
                                password = ""
                            } label: {
                                Text("password.save")
                            }
                            .keyboardShortcut(.defaultAction).disabled(password == "")
                            .buttonStyle(Stylers.ColoredButtonStyle(disabled: password == "", enabled: password != "", alwaysShowTitle: true, width: g.size.width / 5, height: 50, color: .cyan, backgroundShadow: true))
                            Spacer()
                            Button {
                                SettingsMonitor.password = ""
                                passwordSaved = SettingsMonitor.passwordSaved
                                password = ""
                            } label: {
                                Text("password.remove")
                            }
                            .disabled(!passwordSaved)
                            .buttonStyle(Stylers.ColoredButtonStyle(disabled: !passwordSaved, alwaysShowTitle: true, width: g.size.width / 5, height: 50, color: .red, backgroundShadow: true))

                        }.padding(.all)
                    }
                }
            } label: {
                CustomViews.AnimatedTextView(Input: "password.settings")
            }
            .groupBoxStyle(Stylers.CustomGBStyle())
            .background(content: {
                if SettingsMonitor.passwordSaved {
                    CustomViews.ImageView(imageName: "key")
                } else {
                    ZStack {
                        CustomViews.ImageView(imageName: "key")
                        CustomViews.ImageView(imageName: "line.diagonal")
                    }
                }
            })
            .onDisappear {
                password = ""
            }
            .sheet(isPresented: $passwordIsInCorrect) {
                ZStack{
                    CustomViews.ImageView()
                    VStack{
                        Text("incorrectPassword.string").font(.largeTitle).fontWeight(.bold).padding(.all)
                        CustomViews.AppLogo().padding(.all)
                        Button {
                            passwordIsInCorrect.toggle()
                        } label: {
                            Text("ok.button")
                        }.keyboardShortcut(.defaultAction).padding(.all)
                    }
                }.padding(.all)
            }
            .onChange(of: passwordIsInCorrect) { newValue in
                showSheet = newValue
            }
            .onAppear {
                password = ""
                passwordSaved = SettingsMonitor.passwordSaved
            }
            .animation(SettingsMonitor.secondaryAnimation, value: passwordSaved)
        }
    }
}

struct PasswordPreview: PreviewProvider {
    static var previews: some View {
        PasswordSettings()
    }
}
