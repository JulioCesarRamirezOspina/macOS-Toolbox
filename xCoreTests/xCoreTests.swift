//
//  xCoreTests.swift
//  xCoreTests
//
//  Created by Олег Сазонов on 26.10.2022.
//

import XCTest
import SwiftUI
@testable import xCore

final class xCoreTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformance_getModelYear() throws {
        // This is an example of a performance test case.
        self.measure {
            print(macOS_Subsystem.getModelYear())
        }
    }
    func testPerformance_MacPlatform() throws {
        self.measure {
            print(macOS_Subsystem.MacPlatform())
        }
    }
    func testPerformance_getBatteryState() throws {
        self.measure {
            print(macOS_Subsystem.getBatteryState())
        }
    }
    func testPerformance_osVersion() throws {
        self.measure {
            print(macOS_Subsystem.osVersion())
        }
    }
    func testPerformance_memoryUsage() throws {
        self.measure {
            print(macOS_Subsystem.memoryUsage(.gigabyte))
        }
    }
    func testPerformance_thermalLevel() throws {
        self.measure {
            print(macOS_Subsystem.thermalLevel())
        }
    }

}
