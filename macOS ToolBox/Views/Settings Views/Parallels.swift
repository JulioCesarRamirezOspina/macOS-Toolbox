//
//  Parallels Settings View.swift
//  MultiTool
//
//  Created by Олег Сазонов on 01.07.2022.
//

import Foundation
import xCore
import SwiftUI

struct ParallelsSettings: View {
    @State private var showSettings = false
    @State private var parallelsDir = SettingsMonitor.parallelsDir.relativePath
    @State private var dirPicker = SettingsMonitor.parallelsDir
    @State private var label = SettingsMonitor.parallelsDir.relativePath
    var body: some View{
        GeometryReader { g in
            GroupBox {
                VStack(alignment: .center){
                    Spacer()
                    Group {
                        CustomViews.AnimatedTextView(Input: "curr.dir:")
                        Button {
                            dirPicker = FolderPicker(SettingsMonitor.parallelsDir)!
                            SettingsMonitor.parallelsDir = dirPicker
                        } label: {
                            Text(label)
                                .font(.title3)
                                .fontWeight(.light)
                                .padding(.all)
                                .animation(.spring(response: 0.5), value: dirPicker)
                        }
                        .buttonStyle(Stylers.ColoredButtonStyle(alwaysShowTitle: true, width: g.size.width - 50, color: .cyan, backgroundShadow: true))
                        .onHover { t in
                            if t {
                                label = StringLocalizer("select.utmDir")
                            } else {
                                label = SettingsMonitor.parallelsDir.relativePath
                            }
                        }
                    }
                    Spacer()
                    Group {
                        HStack{
                            Button {
                                SettingsMonitor.parallelsDir = URL(filePath: "")
                                dirPicker = SettingsMonitor.parallelsDir
                                label = SettingsMonitor.parallelsDir.relativePath
                            } label: {
                                Text("defaults.string")
                            }
                            .buttonStyle(Stylers.ColoredButtonStyle(alwaysShowTitle: true, width: g.size.width / 5, height: 50, color: .red, backgroundShadow: true))
                        }.padding(.all)
                    }
                }
            } label: {
                CustomViews.AnimatedTextView(Input: "parallels.settings")
            }
            .groupBoxStyle(Stylers.CustomGBStyle())
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
            .onAppear {
                dirPicker = SettingsMonitor.parallelsDir
            }
            .onChange(of: dirPicker, perform: { newValue in
                parallelsDir = SettingsMonitor.parallelsDir.relativePath
            })
        }
    }
}

struct ParallelsPreview: PreviewProvider {
    static var previews: some View {
        ParallelsSettings()
    }
}
