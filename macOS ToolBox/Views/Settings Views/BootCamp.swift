//
//  BootCamp Settings View.swift
//  MultiTool
//
//  Created by Олег Сазонов on 01.07.2022.
//

import Foundation
import xCore
import SwiftUI

struct BootcampSettings: View {
    @State private var label = ("")
    @State private var selection = ""
    @State private var dissapear = false
    private func labeledView() -> some View {
        GeometryReader { g in
            ScrollView([.vertical, .horizontal], showsIndicators: true) {
                HStack{
                    ForEach(BootCampStart.getMountedDisks().sorted(by: >), id: \.key) {key, value in
                        if BootCampStart.getOSType(diskLabel: value).canBoot {
                            Spacer()
                            ZStack{
                                RoundedRectangle(cornerRadius: 15)
                                    .frame(width: g.size.width / 3, height: g.size.height / 5, alignment: .bottom)
                                    .foregroundStyle(.ultraThickMaterial)
                                    .background {
                                        RoundedRectangle(cornerRadius: 15)
                                            .foregroundColor(selection == value ? .blue : Color.gray.opacity(0.25))
                                    }
                                    .shadow(radius: 10)
                                VStack{
                                    Spacer()
                                    switch BootCampStart.getOSType(diskLabel: value).OSType.description {
                                    case "Windows":
                                        Image(systemName: "window.vertical.closed").font(.custom("San Francisco", size: 80))
                                            .foregroundStyle(RadialGradient(colors:[.blue, .gray, .white], center: .center, startRadius: 0, endRadius: 80)).tag(value)
                                    case "macOS Installer":
                                        Image(systemName: "x.circle.fill").font(.custom("San Francisco", size: 80))
                                            .foregroundStyle(RadialGradient(colors:[.blue, .gray, .white], center: .center, startRadius: 0, endRadius: 80)).tag(value)
                                    case "macOS":
                                        Image(systemName: "x.circle").font(.custom("San Francisco", size: 80))
                                            .foregroundStyle(RadialGradient(colors:[.blue, .gray, .white], center: .center, startRadius: 0, endRadius: 80)).tag(value)
                                    case "Linux / Other":
                                        Image(systemName: "externaldrive.badge.questionmark").font(.custom("San Francisco", size: 80))                .foregroundStyle(RadialGradient(colors:[.blue, .gray, .white], center: .center, startRadius: 0, endRadius: 80)).tag(value)
                                    case "Linux":
                                        Image(systemName: "externaldrive.badge.checkmark").font(.custom("San Francisco", size: 80))                .foregroundStyle(RadialGradient(colors:[.blue, .gray, .white], center: .center, startRadius: 0, endRadius: 80)).tag(value)
                                    default:
                                        Image(systemName: "externaldrive.badge.questionmark").font(.custom("San Francisco", size: 80))                .foregroundStyle(RadialGradient(colors:[.blue, .gray, .white], center: .center, startRadius: 0, endRadius: 80)).tag(value)
                                    }
                                    Text(value).tag(value).font(.custom("San Francisco", size: 30)).scaledToFit().padding(.all)
                                    Spacer()
                                    Spacer()
                                }
                            }.onTapGesture {
                                selection = value
                                SettingsMonitor.bootCampDiskLabel = selection
                            }
                            .frame(width: g.size.width / 3 , height: g.size.height / 3, alignment: .center)
                            Spacer()
                        }
                    }
                }
            }
        }
    }
    
    var body: some View {
        VStack{
            GroupBox {
                if !BootCampStart.getMountedDisks().isEmpty {
                    Group {
                        Text(label.description)
                        Spacer()
                        labeledView()
                        Spacer()
                        Button {
                            SettingsMonitor.bootCampDiskLabel = "BOOTCAMP"
                            selection = SettingsMonitor.bootCampDiskLabel
                        } label: {
                            Text("default.button")
                        }
                        .padding(.all)
                       .buttonStyle(Stylers.ColoredButtonStyle(alwaysShowTitle: true, height: 50, color: .red, backgroundShadow: true))
                       .focusable(false)
                }
                } else {
                    Spacer()
                    CustomViews.AnimatedTextView(Input: StringLocalizer("empty.bcSettings.warning"), Font: .largeTitle, FontWeight: .bold)
                    Spacer()
                }
            } label: {
                CustomViews.AnimatedTextView(Input: "bootcamp.settings")
            }
            .groupBoxStyle(Stylers.CustomGBStyle())
        }
        .background(content: {
            CustomViews.ImageView(imageName: "window.ceiling")
        })
        .animation(.default, value: selection)
        .onAppear {
            dissapear = false
            selection = SettingsMonitor.bootCampDiskLabel
            label = ("\(StringLocalizer("volumeToBoot.string")): \(selection)")
        }
        .onChange(of: selection, perform: { newValue in
            label = ("\(StringLocalizer("volumeToBoot.string")): \(newValue)")
        })
        .onDisappear {
            dissapear = true
        }
    }
}

struct BootCampPreview: PreviewProvider {
    static var previews: some View {
        BootcampSettings()
    }
}
