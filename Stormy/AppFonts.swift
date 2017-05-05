//
//  AppFonts.swift
//  Stormy
//
//  Created by durul dalkanat on 5/5/17.
//  Copyright © 2017 DRL. All rights reserved.
//

import UIKit
import Foundation

class AppFonts: UIFont {
    let currentTimeFont: UIFont
    let temperatureFont: UIFont
    let humidityFont: UIFont
    let precipitationFont: UIFont
    let summaryFont: UIFont
    
    /** 
     * Static property variable, that will be used
     * for accessing the singleton object.
     */
    static let sharedInstance = AppFonts()

    private override init() {
        currentTimeFont = UIFont(name: "HelveticaNeue-Medium", size: 14)!
        temperatureFont = UIFont(name: "HelveticaNeue-Bold", size: 124)!
        humidityFont = UIFont(name: "HelveticaNeue", size: 12)!
        precipitationFont = UIFont(name: "HelveticaNeue-Medium", size: 14)!
        summaryFont = UIFont(name: "HelveticaNeue-Bold", size: 18)!

    }
    
}
