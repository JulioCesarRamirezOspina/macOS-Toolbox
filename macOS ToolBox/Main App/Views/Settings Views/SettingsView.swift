//
//  SettingsView.swift
//  MultiTool
//
//  Created by Олег Сазонов on 07.06.2022.
//

import Foundation
import SwiftUI

struct SettingsView: View {
    @Environment(\.locale) var locale
    @State private var width: CGFloat?
    @State private var secondaryScreenAnimDur = SettingsMonitor.secAnimDur
    @Binding var colorScheme: ColorScheme?
    var body: some View{
        GeometryReader { g in
            VStack{
//                withAnimation(.easeInOut(duration: Observer().secAnimDur)) {
                NavigationSplitView {
                    Text("settings.string").font(.largeTitle).padding(.all)
                        .frame(minWidth: 200)
                    Divider()
                    GeometryReader { g in
                        VStack{
                            ScrollView(.vertical, showsIndicators: true) {
                                NavigationLinkGenerator(Views: [
                                    ViewForGenerator(
                                        view: AnyView(BootcampSettings()),
                                        label: "bootcamp.settings",
                                        typeOf: ViewType.link),
                                    ViewForGenerator(
                                        view: (!checkIfSecurityKeyPersists() ? AnyView(PasswordSettings()) : AnyView(PINSettings())),
                                        label: !checkIfSecurityKeyPersists() ? "password.settings" : "pin.settings",
                                        typeOf: ViewType.link),
                                    ViewForGenerator(
                                        view: AnyView(DevIDSettings()),
                                        label: "Developer ID",
                                        typeOf: ViewType.link),
                                    ViewForGenerator(
                                        view: AnyView(Defaults()),
                                        label: "defaults.string",
                                        typeOf: ViewType.link)
                                ])
                            }
                        }.frame(width: g.size.width, height: g.size.height, alignment: .center)
                    }
                    Spacer()
                    VStack{
                        Divider()
                        NavigationLink("\n\(StringLocalizer("backToOverview.settings"))\n", destination: {
                            SettingsOverview(pcs: $colorScheme)
                        })
                        .buttonStyle(Stylers.ColoredButtonStyle(alwaysShowTitle: true, hideBackground: true, render: .monochrome))
                    }
                    .background(.ultraThickMaterial)
                } detail: {
                    SettingsOverview(pcs: $colorScheme)
                }
                .navigationSplitViewStyle(.automatic)
                .toolbar(.hidden, for: .windowToolbar)
                .animation(SettingsMonitor.secondaryAnimation, value: colorScheme)
            }
        }
        .environment(\.locale, locale)
    }
}
