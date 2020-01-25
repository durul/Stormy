//
//  Current.swift
//  Stormy

// MARK: Modeling the Current Weather

import Foundation
import UIKit

struct Current {
	
    // MARK: - Properties
	var currentTime: String?
	var temperature: NSNumber
	var humidity: Int
	var precipProbability: Int
	var summary: String

    // MARK: Initialization
	init(weatherDictionary: NSDictionary) {
		let currentWeather = weatherDictionary["currently"] as! NSDictionary
		
        temperature = currentWeather["temperature"] as! NSNumber
		let humidityFloat = currentWeather["humidity"] as! Double
		humidity = Int(humidityFloat * 100)
		
		let precipFloat = currentWeather["precipProbability"] as! Double
		precipProbability = Int(precipFloat * 100)
		
		summary = currentWeather["summary"] as! String
		
		let currentTimeIntVale = currentWeather["time"] as! Int
		currentTime = dateStringFromUnixTime(currentTimeIntVale)

	}
	
	func dateStringFromUnixTime(_ unixTime: Int) -> String {
		let timeInSeconds = TimeInterval(unixTime)
		let weatherDate = Date(timeIntervalSince1970: timeInSeconds)
		
		let dateFormatter = DateFormatter()
		dateFormatter.timeStyle = .short
		
		return dateFormatter.string(from: weatherDate)
	}
	
}
