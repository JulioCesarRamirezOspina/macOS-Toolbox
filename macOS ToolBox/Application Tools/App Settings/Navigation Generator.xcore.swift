//
//  NavigationGenerator.swift
//  MultiTool
//
//  Created by Олег Сазонов on 25.06.2022.
//

import Foundation
import SwiftUI

public struct ViewForGenerator: Identifiable {
    public init (
        view: AnyView = AnyView(EmptyView()),
        label: String = "",
        font: Font = .body,
        fontWeight: Font.Weight = .regular,
        typeOf: ViewType = .spacer,
        enabled: Bool = false
    ) {
        self.view = view
        self.label = label
        self.font = font
        self.fontWeight = fontWeight
        self.typeOf = typeOf
        self.enabled = enabled
    }
    public var view: AnyView = AnyView(EmptyView())
    public var label: String = ""
    public var font: Font = .body
    public var fontWeight: Font.Weight = .regular
    public var typeOf: ViewType = .link
    public var enabled: Bool = false
    public var id = UUID()
}

public func LinkGlyph(_ label: String) -> String {
    switch label {
    case "BootCamp": return "window.vertical.closed"
    case "Camper": return "window.vertical.closed"
    case "Tor VPN" : return "network.badge.shield.half.filled"
    case "macOS Beta": return "β"
    case "TouchID": return "touchid"
    case "packer.name": return "doc.zipper"
    case "Launchpad": return "app.dashed"
    case "Dock": return "dock.rectangle"
    case "sleepManager.string": return "sleep"
    case "RAM + RAM Disk": return "memorychip"
    case "settings.string": return "gear"
    case "bootcamp.settings": return "externaldrive.badge.checkmark"
    case "anim.settings": return "line.3.crossed.swirl.circle"
    case "password.settings": return "key"
    case "pin.settings": return "lock"
    case "Developer ID": return "person"
    case "defaults.string": return "exclamationmark.triangle"
    case "parallels.settings": return "pause"
    case "utm.settings": return "dot.square"
    default: return ""
    }
}

/// USE ONLY IN NAVIGATION LIST VIEW
public struct NavigationLinkGenerator: View {
    public init(Views: [ViewForGenerator]) {
        views = Views
    }
    @State public var views: [ViewForGenerator]
    @State private var inLowPower = ProcessInfo.processInfo.isLowPowerModeEnabled
    public var body: some View {
        ForEach(0..<views.count, id: \.self) {index in
            switch views[index].typeOf {
            case .link:
                NavigationLink(destination: {
                    views[index].view
                }, label: {
                    Text(StringLocalizer(views[index].label))
                })
                .buttonStyle(Stylers.ColoredButtonStyle(
                    glyph: LinkGlyph(views[index].label),
                    disabled: false,
                    enabled: views[index].enabled,
                    alwaysShowTitle: inLowPower ? true : views[index].enabled ? true : false,
                    color: views[index].enabled ? .green : .blue,
                    hideBackground: true,
                    backgroundIsNotFill: true,
                    blurBackground: true,
                    backgroundShadow: true,
                    render: .monochrome,
                    alwaysGlow: views[index].enabled)
                )
                .simultaneousGesture(TapGesture().onEnded({ _ in
                    for ind in 0..<views.count {
                        if ind == index {
                            views[ind].enabled = true
                        } else {
                            views[ind].enabled = false
                        }
                    }
                    delay(after: 2) {
                        for i in 0..<views.count {
                            views[i].enabled = false
                        }
                    }
                }))
                .animation(SettingsMonitor.secondaryAnimation, value: views[index].enabled)
                .font(views[index].font)
                .fontWeight(views[index].fontWeight)
                .id(index)
                .onChange(of: ProcessInfo.processInfo.isLowPowerModeEnabled) { newValue in
                    inLowPower = ProcessInfo.processInfo.isLowPowerModeEnabled
                }
                .onHover { Bool in
                    inLowPower = ProcessInfo.processInfo.isLowPowerModeEnabled
                }
                .focusable(false)
            case .spacer:
                Spacer()
            case .divider:
                Divider()
            case .empty:
                EmptyView()
            }
        }
    }
}

