//
//  SignpostLog.swift
//  Stormy
//
//  Created by Durul Dalkanat on 10/30/18.
//  Copyright © 2018 DRL. All rights reserved.
//

import Foundation
import os.log

@available(iOS 12.0, *)
struct SignpostLog {
    static var pointsOfInterest = OSLog(subsystem: "com.durul.Stormy", category: .pointsOfInterest)
    static var general: OSLog {
        if ProcessInfo.processInfo.environment.keys.contains("SIGNPOST_ENABLED") {
            return OSLog(subsystem: "com.durul.Stormy", category: "weather")
        } else {
            return .disabled
        }
    }
    static var json = OSLog(subsystem: "com.durul.Stormy", category: "json")
}
