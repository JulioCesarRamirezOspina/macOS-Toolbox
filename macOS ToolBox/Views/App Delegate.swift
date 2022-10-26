//
//  Funcs.swift
//  TORVpn
//
//  Created by Олег Сазонов on 28.05.2022.
//

import Foundation
import SwiftUI
import xCore
import SensorKit
import UserNotifications


/// App Delegate
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        Memory().ejectAll([StringLocalizer("clear_RAM.string")])
        TorView().stop()
    }
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        if SettingsMonitor().initRun == nil {
            SettingsMonitor().defaults(.All)
        }
        if SettingsMonitor.utmDidNotSet {
            SettingsMonitor().defaults(.UTM)
        }
        if SettingsMonitor.parallelsDidNotSet {
            SettingsMonitor().defaults(.Parallels)
        }
        SettingsMonitor.memoryClensingInProgress = false
        Memory().ejectAll([StringLocalizer("clear_RAM.string")])
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        if SettingsMonitor().initRun == nil {
            SettingsMonitor().defaults(.All)
        }
        if SettingsMonitor.utmDidNotSet {
            SettingsMonitor().defaults(.UTM)
        }
        if SettingsMonitor.parallelsDidNotSet {
            SettingsMonitor().defaults(.Parallels)
        }
        SettingsMonitor.memoryClensingInProgress = false
        Memory().ejectAll([StringLocalizer("clear_RAM.string")])
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        return true
    }
}
