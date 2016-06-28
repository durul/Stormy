//
//  AppDelegate.swift
//  Stormy
//
//  Created by Durul Dalkanat on 9/15/14.
//  Copyright (c) 2014 Durul Dalkanat. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        application.setStatusBarHidden(true, withAnimation: .None)
        return true
    }

}
