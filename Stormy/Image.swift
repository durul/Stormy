//
//  Image.swift
//  Stormy
//
//  Created by durul dalkanat on 6/28/16.
//  Copyright © 2016 DRL. All rights reserved.
//

import Foundation
import UIKit

struct CurrentImage {
    
    var icon: UIImage?
    
    init(weatherDictionary: NSDictionary) {
        let currentWeather = weatherDictionary["currently"] as! NSDictionary
        let iconString = currentWeather["icon"] as! String
        icon = weatherIconFromString(iconString)
    }
}

func weatherIconFromString(stringIcon: String) -> UIImage? {
    var imageName: String
    
    switch stringIcon {
    case "clear-day":
        imageName = "clear-day"
    case "clear-night":
        imageName = "clear-night"
    case "rain":
        imageName = "rain"
    case "snow":
        imageName = "snow"
    case "sleet":
        imageName = "sleet"
    case "wind":
        imageName = "wind"
    case "fog":
        imageName = "fog"
    case "cloudy":
        imageName = "cloudy"
    case "partly-cloudy-day":
        imageName = "partly-cloudy"
    case "partly-cloudy-night":
        imageName = "cloudy-night"
    default:
        imageName = "default"
    }
    
    let iconName = UIImage(named: imageName)
    return iconName
}