//
//  Current.swift
//  Stormy

// MARK : Modeling the Current Weather

import Foundation
import UIKit

// conform to the equitable protocol, and provide an implementation for double equals.
extension Current: Equatable {
    static func ==(lhs: Current, rhs: Current) -> Bool {
        return lhs.currentTime == rhs.currentTime && lhs.temperature == rhs.temperature && lhs.humidity == rhs.humidity && lhs.precipProbability == rhs.precipProbability && lhs.summary == rhs.summary
    }
}

struct Current {
	
    //MARK: - Properties
	var currentTime: String?
	var temperature: NSNumber
	var humidity: Int
	var precipProbability: Int
	var summary: String

    //MARK: Initialization
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
