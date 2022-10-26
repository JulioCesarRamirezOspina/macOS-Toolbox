//
//  Dark Mode.swift
//  xCore
//
//  Created by Олег Сазонов on 02.08.2022.
//

import Foundation
import SwiftUI
import Combine

public class Theme: xCore {
    public override init(){}
    private static let def = UserDefaults()
    
    public class var colorScheme: ColorScheme? {
        get {
            return load()
        }
        set {
            if newValue != nil {
                save(newValue!)
            } else {
                def.removeObject(forKey: "colorScheme")
            }
        }
    }
        
    
    private class func save(_ key: ColorScheme) {
        def.set("\(key)", forKey: "colorScheme")
    }
        
    private class func load() -> ColorScheme? {
        let rval = def.string(forKey: "colorScheme")
        switch rval {
        case "dark": return .dark
        case "light": return .light
        default: return nil
        }
    }
    
    public class func `switch`(_ mode: ColorScheme?) {
        switch mode {
        case .dark:
            colorScheme = .dark
        case .light:
            colorScheme = .light
        case nil:
            colorScheme = .none
        case .some(_):
            colorScheme = .none
        }
    }
}

