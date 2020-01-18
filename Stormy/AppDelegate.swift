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
    var hasAlreadyLaunched: Bool!
    
    internal func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        //retrieve value from local store, if value doesn't exist then false is returned
        hasAlreadyLaunched = UserDefaults.standard.bool(forKey: "hasAlreadyLaunched")
        
        //check first launched
        if hasAlreadyLaunched {
            hasAlreadyLaunched = true
        } else {
            UserDefaults.standard.set(true, forKey: "hasAlreadyLaunched")
        }
        
        return true
    }
    
    func sethasAlreadyLaunched() {
        hasAlreadyLaunched = true
    }
    
    // Handling App Launch from Siri
    private func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
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
