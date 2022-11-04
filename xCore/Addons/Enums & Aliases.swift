//
//  Enums.swift
//  xCore
//
//  Created by Олег Сазонов on 04.08.2022.
//

import Foundation

// MARK: - Enums
public enum ViewType{
    case spacer
    case divider
    case link
    case empty
}

public enum DefaultKey {
    case Parallels
    case UTM
    case BootCamp
    case All
}

public enum spacerType {
    case wide
    case narrow
}

public enum orientation {
    case left
    case right
    case bottom
}

public enum DockBoolKeys {
    case singleAppEnabled
    case singleAppDisabled
    case autohideEnabled
    case autohideDisabled
    case magnificationEnabled
    case magnificationDisabled
    case hiddenAppsGrayedOutEnabled
    case hiddenAppsGrayedOutDisabled
}

public enum DockFloatKeys {
    case animationSpeed
    case popDelay
}

public enum DockStringKeys {
    case typeOfAnimation
    case orientation
}

public enum AnimationTypes {
    case suck
    case scale
    case genie
}

public enum Coord {
    case x
    case y
}

public enum DisplaySleep {
    case allow
    case deny
}

public enum ChargingState {
    case charging
    case charged
    case discharging
    case acAttached
    case finishingCharge
    case unknown
}

public enum PowerSource {
    case AC
    case Internal
    case unknown
}

public enum Unit : Double {
    // For going from byte to -
    case byte     = 1
    case kilobyte = 1024
    case megabyte = 1048576
    case gigabyte = 1073741824
    case terabyte = 1099511627776
}


/// Options for loadAverage()
public enum LOAD_AVG {
    /// 5, 30, 60 second samples
    case short
    
    /// 1, 5, 15 minute samples
    case long
}


/// For thermalLevel()
public enum ThermalLevel: String {
    // Comments via <IOKit/pwr_mgt/IOPM.h>

    /// Under normal operating conditions
    case Normal = "Normal"
    /// Thermal pressure may cause system slowdown
    case Danger = "Danger"
    /// Thermal conditions may cause imminent shutdown
    case Crisis = "Crisis"
    /// Thermal warning level has not been published
    case NotPublished = "Not Published"
    /// The platform may define additional thermal levels if necessary
    case Unknown = "Unknown"
}

public enum ThermalPressure {
    case nominal
    case fair
    case serious
    case critical
    case undefined
    case noPassword
}

public enum MemoryPressure {
    case nominal
    case warning
    case critical
    case undefined
}

public enum DiskSpace {
    case free
    case total
    case used
}

public enum MoveDirection {
    case leftToRight
    case rightToLeft
    case inOut
    case outIn
}

public enum OSUpdateStatus {
    case available
    case notAvailable
    case searching
    case noConnection
    case standby
}

public enum SeedReadableString {
    case DeveloperBeta
    case PublicBeta
    case NotEnrolled
}

public enum GlowIntensity {
    case slight
    case normal
    case moderate
    case hdr
    case extreme
}

public enum deviceType {
    case iMac
    case macMini
    case macPro
    case macBook
    case macBookAir
    case macBookPro
    case xserve
    case unknown
}

public enum Size {
    case screen11Inch
    case screen12Inch
    case screen13Inch
    case screen15Inch
    case screen16Inch
    case screen17Inch
    case screen20Inch
    case screen21_5Inch
    case screen24Inch
    case screen27Inch
    case unknownSize
}

public enum platform {
    case AppleSilicon
    case AppleSiliconRosetta
    case Intel
}

// MARK: - Type Aliases
public typealias StringData = (label: String, value: String)
