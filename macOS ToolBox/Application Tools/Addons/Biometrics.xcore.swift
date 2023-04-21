//
//  Authentificator.swift
//  xCore
//
//  Created by Олег Сазонов on 02.10.2022.
//

import Foundation
import LocalAuthentication

public class Biometrics {
    
    private static var error: NSError?
    
    @Sendable public class func execute(code: (@escaping @Sendable () -> Void?), reason: String) async throws -> Task<(Bool), Never> {
        Task {
            let context = LAContext()
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometricsOrWatch, error: &error) {
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometricsOrWatch, localizedReason: StringLocalizer(reason)) { success, error in
                    if success {
                        code()
                    }
                }
                return true
            } else if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
                context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) {success, error in
                    if success {
                        code()
                    }
                }
                return true
            } else {
                return false
            }
        }
    }
    
    @Sendable public class func execute(code: (@escaping () -> Void?), reason: String) throws {
        let context = LAContext()
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometricsOrWatch, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometricsOrWatch, localizedReason: StringLocalizer(reason)) { success, error in
                if success {
                    code()
                }
            }
        } else if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, error in
                if success {
                    code()
                }
            }
        }
    }
}
