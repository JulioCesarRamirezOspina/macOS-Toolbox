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

public enum macOSMode {
    case light
    case dark
}

public enum platform {
    case AppleSilicon
    case AppleSiliconRosetta
    case Intel
}

public enum directionalFlip {
    case horizontal
    case vertical
    case none
}

public enum pamTask {
    case enable
    case disable
}

public enum pamFile {
    case sudo
    case screensaver
}

public enum pamWhatIsEnabled {
    case sudo
    case screensaver
    case both
    case neither
}


// MARK: - Type Aliases
public typealias StringData = (label: String, value: String)
public typealias ThermalData = (label: String, state: ThermalPressure)
public typealias volumeData = (volumeURL: String, bsdString: String, capacity: (Double, Unit))
public typealias memoryValues = (
    free        : Double,
    active      : Double,
    inactive    : Double,
    wired       : Double,
    compressed  : Double,
    total       : Double,
    used        : Double,
    cachedFiles : Double
)

public typealias cpuValues = (system: Double, user: Double, idle: Double, total: Double)
public typealias platformData = (model: String,
                                 screenSize: String,
                                 modelType: deviceType,
                                 screenSizeInt: Int,
                                 platform: String,
                                 platformServiceData: platform)
public typealias file = (name: String, path: URL, fileExtension: String)

// MARK: - Structs
public struct VMPropertiesList: Identifiable, Comparable {
    public static func < (lhs: VMPropertiesList, rhs: VMPropertiesList) -> Bool {
        lhs.name < rhs.name
    }
    public static func > (lhs: VMPropertiesList, rhs: VMPropertiesList) -> Bool {
        lhs.name < rhs.name
    }
    public static func == (lhs: VMPropertiesList, rhs: VMPropertiesList) -> Bool {
        lhs.name < rhs.name
    }

    public var name: String
    public var path: URL
    public var fileExtension: String
    public var creationDate: String
    public var lastAccessDate: String
    public let id = UUID()
    
}
