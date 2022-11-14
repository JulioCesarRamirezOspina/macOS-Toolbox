//
//  BetaSeedView.swift
//  MultiTool
//
//  Created by Олег Сазонов on 07.06.2022.
//

import Foundation
import SwiftUI
import xCore

// MARK: - Beta Seed View
struct BetaSeedView: View {
    //MARK: - State vars
    @Environment(\.locale) var locale
    @State private var password = SettingsMonitor.password
    @State private var pwdExists = SettingsMonitor.passwordSaved
    @State private var currentSeed = 0
    @State private var openSetting = false
    @State private var isQuit = false
    @State private var enrolled: Bool? = false
    @State private var loading = true
    @State private var imageSeed = 0
    @State private var selection = 0
    @State private var dummy = false
    @State private var width: CGFloat = 1
    
    private func updateVars() {
        password = SettingsMonitor.password
        pwdExists = SettingsMonitor.passwordSaved
        enrolled = SeedUtil.getSeedBool(password)
        imageSeed = SeedUtil.getSeedInt(password)
        selection = SeedUtil.getSeedInt(password)
    }
    
    private var BetaImage: some View {
        VStack{
            CustomViews.SymbolView(symbol: (imageSeed == 2) ?
                       "𝛼" : (imageSeed == 1) ?
                       "β" : "ω", blurRadius: 5,
                       defaultGradientColors: enrolled! ? [.blue, .blue, .clear] :
                        [.gray, .gray, .clear])
            .shadow(color: .black, radius: 7, x: 0, y: 5)
            .font(.custom("San Francisco", size: 140))
        }
    }
    
    private var BetaView: some View {
        VStack(alignment: .center) {
            HStack(alignment: .center){
                Text("seed.current"); Text("\(SeedUtil.getSeed(password))")
            }.padding()
            VStack{
                CustomViews.AnimatedTextView(Input: "selectprogram.text", TimeToStopAnimation: SettingsMonitor.secAnimDur)
                HStack(alignment: .center) {
                    GeometryReader { g in
                        HStack{
                            Button {
                                selection = 1
                                SeedUtil.setSeed(selection, password: password, openSetting)
                                updateVars()
                                if isQuit == true {
                                    Quit(AppDelegate())
                                }
                                openSetting = false
                            } label: {
                                Text("seed.public")
                            }.buttonStyle(Stylers.ColoredButtonStyle(glyph: "β", enabled: selection == 1, width: g.size.width / 3 - 10, color: .blue))
                            Spacer()
                            Button {
                                selection = 2
                                SeedUtil.setSeed(selection, password: password, openSetting)
                                updateVars()
                                if isQuit == true {
                                    Quit(AppDelegate())
                                }
                                openSetting = false
                            } label: {
                                Text("seed.dev")
                            }.buttonStyle(Stylers.ColoredButtonStyle(glyph: "𝛼", enabled: selection == 2, width: g.size.width / 3 - 10, color: .cyan))
                            Spacer()
                            Button {
                                selection = 0
                                SeedUtil.unenroll(password)
                                updateVars()
                                if isQuit == true {
                                    Quit(AppDelegate())
                                }
                            } label: {
                                Text(selection == 0 ? "seed.none" : "unenroll.button")
                            }.buttonStyle(Stylers.ColoredButtonStyle(glyph: "ω", enabled: selection == 0, width: g.size.width / 3 - 10, color: .red))
                        }
                        .onAppear {
                            width = g.size.width
                        }
                        .onChange(of: g.size) { newValue in
                            width = newValue.width
                        }
                    }.frame(height: 100)
                }.padding()
            }
            Spacer()
            Spacer()
            macOSUpdate.view(Geometry: CGSize(width: width, height: 200), HalfScreen: true, ShowTitle: false)
                .frame(width: width - width / 10)
            Spacer()
        }
    }
    
    private var Title: some View {
        VStack{
            if !enrolled! {
                CustomViews.AnimatedTextView(Input: "main.title", FontWeight: .bold, TimeToStopAnimation: SettingsMonitor.secAnimDur)
            } else {
                CustomViews.AnimatedTextView(Input: "change.title", FontWeight: .bold, TimeToStopAnimation: SettingsMonitor.secAnimDur)
            }
        }
    }
    
    //MARK: - View body
    var body: some View {
        if SettingsMonitor.passwordSaved {
            GroupBox {
                BetaView
            } label: {
                Title
            }
            .groupBoxStyle(Stylers.CustomGBStyle())
            .background(content: {
                BetaImage
            })
            .onChange(of: imageSeed, perform: { newValue in
                password = SettingsMonitor.password
                enrolled = SeedUtil.getSeedBool(password)
                loading = false
                imageSeed = SeedUtil.getSeedInt(password)
            })
            .onAppear {
                updateVars()
                if selection == 0 {
                    selection = 0
                }
                currentSeed = SeedUtil.getSeedInt(password)
            }
            .onChange(of: selection) { newValue in
                currentSeed = newValue
            }
            .onChange(of: currentSeed) { newValue in
                if newValue != 0 {
                    selection = newValue
                } else {
                    selection = 0
                }
            }
            .environment(\.locale, locale)
            .animation(SettingsMonitor.secondaryAnimation, value: selection)
            .animation(SettingsMonitor.secondaryAnimation, value: imageSeed)
            .animation(SettingsMonitor.secondaryAnimation, value: currentSeed)
        } else {
            CustomViews.NoPasswordView(false, toggle: $dummy)
        }
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        BetaSeedView()
    }
}

