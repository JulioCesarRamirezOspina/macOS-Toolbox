//
//  Main Scene.swift
//  macOS ToolBox
//
//  Created by Олег Сазонов on 12.07.2022.
//

import Foundation
import Combine
import SwiftUI
import xCore

//MARK: - Main App Structure
//@main
struct macOS_ToolBoxApp: App {
    @State var subs = Set<AnyCancellable>() // Cancel onDisappear
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.locale) var locale
    func hideButtons(_ C: Int = 0) {
        for window in NSApplication.shared.windows{
            switch C {
            case 1:
                window.standardWindowButton(.closeButton)?.isHidden = true
                window.standardWindowButton(.closeButton)?.isEnabled = false
            case 2:
                window.standardWindowButton(.miniaturizeButton)?.isHidden = true
                window.standardWindowButton(.miniaturizeButton)?.isEnabled = false
            case 3:
//                window.standardWindowButton(.zoomButton)?.isHidden = true
                window.standardWindowButton(.zoomButton)?.isEnabled = false
            default:
                window.standardWindowButton(.closeButton)?.isHidden = true
                window.standardWindowButton(.closeButton)?.isEnabled = false
                window.standardWindowButton(.miniaturizeButton)?.isHidden = true
                window.standardWindowButton(.miniaturizeButton)?.isEnabled = false
                window.standardWindowButton(.zoomButton)?.isHidden = true
                window.standardWindowButton(.zoomButton)?.isEnabled = false
                window.isReleasedWhenClosed = true
                window.styleMask.remove(.resizable)
            }
        }
    }
    
    func setup() {
        let window = NSApplication.shared.windows.first!
        window.tabbingMode = .disallowed
        //        window.isMovableByWindowBackground = true
        window.titlebarAppearsTransparent = true
        window.titlebarSeparatorStyle = .shadow
//        hideButtons(1);hideButtons(2);
        hideButtons(3)
    }
    //MARK: - Scene builder
    @SceneBuilder
    var body: some Scene {
        WindowGroup {
            MainView()
                .ignoresSafeArea()
                .frame(minWidth: 1090, idealWidth: 1280, maxWidth: .greatestFiniteMagnitude, minHeight: 700, idealHeight: 720, maxHeight: .greatestFiniteMagnitude, alignment: .center)
                .background(Stylers.VisualEffectView()).ignoresSafeArea()
                .onReceive(NotificationCenter.default.publisher(for: NSApplication.willUpdateNotification), perform: { not in
                    setup()
                })
        }
        .commands(content: {
            CommandGroup(replacing: .help) {
                HelpView()
            }
            CommandGroup(replacing: .newItem) {}
        })
        .windowToolbarStyle(.unifiedCompact)
    }
}
