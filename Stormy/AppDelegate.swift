//
//  AppDelegate.swift
//  Stormy
//
//  Created by Durul Dalkanat on 9/15/14.
//  Copyright (c) 2014 Durul Dalkanat. All rights reserved.
//

import UIKit
import Intents

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    private func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        return true
    }

    // Handling App Launch from Siri
    @nonobjc func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        if #available(iOS 10.0, *) {
            guard let intent = userActivity.interaction?.intent as? INStartWorkoutIntent else {
                return false
            }
            print(intent)
        } else {
            // Fallback on earlier versions
        }
        return true
    }
}
