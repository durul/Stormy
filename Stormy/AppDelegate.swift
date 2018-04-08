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

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        return true
    }

    // Handling App Launch from Siri
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
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
