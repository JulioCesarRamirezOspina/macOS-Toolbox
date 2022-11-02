//
//  main.swift
//  macOS ToolBox
//
//  Created by Олег Сазонов on 02.11.2022.
//

import Foundation
import Combine
import AppKit

// MARK: - Application Entry Point
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate

_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
