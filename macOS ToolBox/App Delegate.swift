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
import Combine

class AppDelegate: NSObject, NSApplicationDelegate {
    //MARK: - Delegate vars
    static var popover: NSPopover!
    static var statusBarItem: NSStatusItem!
    var window: NSWindow!
    static var cs: ColorScheme = macOS_Subsystem.isInDarkMode() == .dark ? .dark : .light

    //MARK: - Additional Funcs
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
        hideButtons(3)
    }
    private func isInDarkMode() {
        let process = Process()
        let pipe = Pipe()
        process.arguments = ["-c", "defaults read -g AppleInterfaceStyle"]
        process.executableURL = URL(filePath: "/bin/bash")
        process.standardOutput = pipe
    }
    func refreshPopoverViewController() {
        if SettingsMonitor.isInMenuBar {
            let screenSize = NSScreen.main!.frame.size
            let contentView = MainView().ignoresSafeArea().backgroundStyle(.bar)
            let popover = NSPopover()
            popover.contentSize = NSSize(width: screenSize.width / 1.8, height: screenSize.height / 1.6)
            popover.behavior = .transient
            popover.contentViewController = NSHostingController(rootView: contentView)
            AppDelegate.popover = popover
        }
    }
    @objc func togglePopover(_ sender: AnyObject?) {
        if let button = AppDelegate.statusBarItem.button {
            if AppDelegate.popover.isShown {
                AppDelegate.popover.performClose(sender)
            } else {
                refreshPopoverViewController()
                AppDelegate.popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
            }
        }
        AppDelegate.popover.contentViewController?.view.window?.becomeKey()
    }
    
    //MARK: - Startup funcs
    func popoverLaunch() {
        hideDock()
        let screenSize = NSScreen.main!.frame.size
        let contentView = MainView()
            .ignoresSafeArea()
            .backgroundStyle(.bar)
        let popover = NSPopover()
        popover.contentSize = NSSize(width: screenSize.width / 1.8, height: screenSize.height / 1.6)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: contentView)
        AppDelegate.popover = popover
        
        AppDelegate.statusBarItem = NSStatusBar.system.statusItem(withLength: CGFloat(NSStatusItem.variableLength))
        
        if let button = AppDelegate.statusBarItem.button {
            let cgImage = NSImage(systemSymbolName: "command.square", accessibilityDescription: "")
            button.image = cgImage
            button.action = #selector(togglePopover(_:))
        }
        hideDock()
    }
    
    func windowLaunch() {
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
        
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 1440, height: 900),
            styleMask: [.miniaturizable, .closable, .resizable, .titled, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.center()
        let screenSize = NSScreen.main!.frame.size
        window.contentMinSize = NSSize(width: screenSize.width - (screenSize.width / 4), height: screenSize.height)
        window.contentMaxSize = NSSize(width: Double.greatestFiniteMagnitude, height: Double.greatestFiniteMagnitude)
        window.contentViewController = NSHostingController(rootView: MainView(colorScheme: AppDelegate.cs)
            .ignoresSafeArea()
            .frame(minWidth: 1090,
                   idealWidth: 1280,
                   maxWidth: .greatestFiniteMagnitude,
                   minHeight: 700,
                   idealHeight: 720,
                   maxHeight: .greatestFiniteMagnitude,
                   alignment: .center)
                .background(Stylers.VisualEffectView()).ignoresSafeArea()
                .onReceive(NotificationCenter.default.publisher(for: NSApplication.willUpdateNotification), perform: { not in
                    self.setup()
                }))
        window.tabbingMode = .disallowed
        window.titlebarAppearsTransparent = true
        window.titlebarSeparatorStyle = .shadow
        window.standardWindowButton(.zoomButton)?.isEnabled = false
        window.title = "macOS ToolBox"
        window.makeKeyAndOrderFront(nil)
        showDock()
    }
    
    public static func tog() {
        self.popover.performClose(nil)
    }

    private func hideDock() {
       NSApplication.Dock.refreshMenuBarVisibiity(method: .viaMenuVisibilityToggle)
        NSApplication.shared.setActivationPolicy(.accessory)
    }

    private func showDock() {
       NSApplication.Dock.refreshMenuBarVisibiity(method: .viaSystemAppActivation)
    }
    
    //MARK: - App LifeCycle Funcs
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        if SettingsMonitor.isInMenuBar {
            return false
        } else {
            return true
        }
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
        AppDelegate.cs = macOS_Subsystem.isInDarkMode() == .dark ? .dark : .light
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        AppDelegate.cs = macOS_Subsystem.isInDarkMode() == .dark ? .dark : .light
        if SettingsMonitor.isInMenuBar {
            popoverLaunch()
        } else {
            windowLaunch()
        }
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        return true
    }
    
    func applicationDidResignActive(_ notification: Notification) {
        AppDelegate.cs = macOS_Subsystem.isInDarkMode() == .dark ? .dark : .light
    }
    
    func applicationDidBecomeActive(_ notification: Notification) {
        AppDelegate.cs = macOS_Subsystem.isInDarkMode() == .dark ? .dark : .light
    }
}

//MARK: - Extensions
extension NSApplication {
   public enum Dock {
   }
}

extension NSApplication.Dock {

   public enum MenuBarVisibiityRefreshMenthod: Int {
      case viaMenuVisibilityToggle, viaSystemAppActivation
   }

   public static func refreshMenuBarVisibiity(method: MenuBarVisibiityRefreshMenthod) {
      switch method {
      case .viaMenuVisibilityToggle:
         DispatchQueue.main.async {
            NSMenu.setMenuBarVisible(false)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
               NSMenu.setMenuBarVisible(true)
               NSRunningApplication.current.activate(options: [.activateAllWindows, .activateIgnoringOtherApps])
            }
         }
      case .viaSystemAppActivation:
         DispatchQueue.main.async {
            if let dockApp = NSRunningApplication.runningApplications(withBundleIdentifier: "com.apple.dock").first {
               dockApp.activate(options: [])
            } else if let finderApp = NSRunningApplication.runningApplications(withBundleIdentifier: "com.apple.finder").first {
               finderApp.activate(options: [])
            } else {
               assertionFailure("Neither Dock.app not Finder.app is found in system.")
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
               NSRunningApplication.current.activate(options: [.activateAllWindows, .activateIgnoringOtherApps])
            }
         }
      }
   }

   public enum AppIconDockVisibilityUpdateMethod: Int {
      case carbon, appKit
   }

   @discardableResult
   public static func setAppIconVisibleInDock(_ shouldShow: Bool, method: AppIconDockVisibilityUpdateMethod = .appKit) -> Bool {
      switch method {
      case .appKit:
         return toggleDockIconViaAppKit(shouldShow: shouldShow)
      case .carbon:
         return toggleDockIconViaCarbon(shouldShow: shouldShow)
      }
   }

   private static func toggleDockIconViaCarbon(shouldShow state: Bool) -> Bool {
      let transformState: ProcessApplicationTransformState
      if state {
         transformState = ProcessApplicationTransformState(kProcessTransformToForegroundApplication)
      } else {
         transformState = ProcessApplicationTransformState(kProcessTransformToUIElementApplication)
      }

      var psn = ProcessSerialNumber(highLongOfPSN: 0, lowLongOfPSN: UInt32(kCurrentProcess))
      let transformStatus: OSStatus = TransformProcessType(&psn, transformState)
      return transformStatus == 0
   }

   private static func toggleDockIconViaAppKit(shouldShow state: Bool) -> Bool {
      let newPolicy: NSApplication.ActivationPolicy = state ? .regular : .accessory
      let result = NSApplication.shared.setActivationPolicy(newPolicy)
      return result
   }
}
