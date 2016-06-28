//
//  InterfaceController.swift
//  StormyWatch Extension
//
//  Created by durul dalkanat on 6/28/16.
//  Copyright © 2016 DRL. All rights reserved.
//

import WatchKit
import Foundation

class InterfaceController: WKInterfaceController {
	
	override func awakeWithContext(context: AnyObject?) {
		super.awakeWithContext(context)
    
	}
	
	override func willActivate() {
		// This method is called when watch view controller is about to be visible to user
		super.willActivate()
        getCurrentWeatherData()

	}
	
	@IBOutlet var temperatureLabel: WKInterfaceLabel!
    @IBOutlet var summaryLabel: WKInterfaceLabel!
    @IBOutlet var iconView: WKInterfaceImage!
    
	override func didDeactivate() {
		// This method is called when watch view controller is no longer visible
		super.didDeactivate()
	}
	
	// Replace the string below with your API Key.
	private let APIKey = "bec6820ba3d3baeddbae393d2a240e73"
	
	func getCurrentWeatherData() -> Void {
		
		guard let baseURL = NSURL(string: "https://api.forecast.io/forecast/\(APIKey)/") else {
			print("Error: cannot create URL")
			return
		}
		
		guard let forecastURL = NSURL(string: "37.8267,-122.423", relativeToURL: baseURL) else {
			print("Error: cannot create URL")
			return
		}
		
		let unwrappedForecastURL = forecastURL
		
		let sharedSession = NSURLSession.sharedSession()
		let downloadTask: NSURLSessionDownloadTask = sharedSession.downloadTaskWithURL(unwrappedForecastURL, completionHandler: { (location: NSURL?, response: NSURLResponse?, error: NSError?) -> Void in
			
			if (error == nil) {
				let dataObject = NSData(contentsOfURL: location!)
				
				do {
					let weatherDictionary = try NSJSONSerialization.JSONObjectWithData(dataObject!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
					
					let currentWeather = Current(weatherDictionary: weatherDictionary!)
                    let currentImage = CurrentImage(weatherDictionary: weatherDictionary!)

					dispatch_async(dispatch_get_main_queue(), { () -> Void in
						self.temperatureLabel.setText("\(currentWeather.temperature)")
                        self.summaryLabel.setText("\(currentWeather.summary)")
                        self.iconView.setImage(currentImage.icon)

					})
					
				} catch let error as NSError {
					print(error)
				}
			}
			
		})
		
		downloadTask.resume()
	}
	
}

