//
//  UTM.swift
//  MultiTool
//
//  Created by Олег Сазонов on 01.07.2022.
//

import Foundation
import SwiftUI
import xCore

struct UTMSettings: View {
    @State private var UTMDir = SettingsMonitor.utmDir.relativePath
    @State private var dirPicker = SettingsMonitor.utmDir
    @State private var label = SettingsMonitor.utmDir.relativePath
    var body: some View {
        GeometryReader { g in
            GroupBox {
                VStack(alignment: .center){
                    Spacer()
                    Group {
                        CustomViews.AnimatedTextView(Input: "curr.dir:")
                        Button {
                            dirPicker = FolderPicker(SettingsMonitor.utmDir)!
                            SettingsMonitor.utmDir = dirPicker
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
                                label = SettingsMonitor.utmDir.relativePath
                            }
                        }
                    }
                    Spacer()
                    Group {
                        HStack {
                            Button {
                                SettingsMonitor.utmDir = URL(filePath: "")
                                dirPicker = SettingsMonitor.utmDir
                                label = SettingsMonitor.utmDir.relativePath
                            } label: {
                                Text("defaults.string")
                            }
                            .buttonStyle(Stylers.ColoredButtonStyle(alwaysShowTitle: true, width: g.size.width / 5, height: 50, color: .red, backgroundShadow: true))
                        }.padding(.all)
                    }
                }
            } label: {
                CustomViews.AnimatedTextView(Input: "utm.settings")
            }
            .groupBoxStyle(Stylers.CustomGBStyle())
            .background(content: {
                CustomViews.UTMLogo()
            })
            .onAppear {
                dirPicker = SettingsMonitor.utmDir
            }
            .onChange(of: dirPicker, perform: { newValue in
                UTMDir = SettingsMonitor.utmDir.relativePath
            })
        }
    }
}

struct UTMPreview: PreviewProvider {
    static var previews: some View {
        UTMSettings()
    }
}
