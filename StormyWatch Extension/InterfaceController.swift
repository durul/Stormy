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
	
	override func awake(withContext context: Any?) {
		super.awake(withContext: context)
    
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

    func connection(_ connection: NSURLConnection!, didFailWithError error: NSError!) {
        print("Error: \(error)")
    }

    func connection(_ connection: NSURLConnection!, didReceiveResponse response: URLResponse!) {
        print("Received response: \(response)")
    }

    func connection(_ connection: NSURLConnection!, didReceiveData data: Data!) {
        print("Received data: \(data)")
    }

	// Replace the string below with your API Key.
	fileprivate let APIKey = "bec6820ba3d3baeddbae393d2a240e73"
	
	func getCurrentWeatherData() {
		
		guard let baseURL = URL(string: "https://api.forecast.io/forecast/\(APIKey)/") else {
			print("Error: cannot create URL")
			return
		}
		
		guard let forecastURL = URL(string: "37.8267,-122.423", relativeTo: baseURL) else {
			print("Error: cannot create URL")
			return
		}
		
		let unwrappedForecastURL = forecastURL
		
		let sharedSession = URLSession.shared
		let downloadTask: URLSessionDownloadTask = sharedSession.downloadTask(with: unwrappedForecastURL, completionHandler: { (location, _, error) -> Void in
			
			if error == nil {
				let dataObject = try? Data(contentsOf: location!)
				
				do {
					let weatherDictionary = try JSONSerialization.jsonObject(with: dataObject!, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
					
					let currentWeather = Current(weatherDictionary: weatherDictionary!)
                    let currentImage = CurrentImage(weatherDictionary: weatherDictionary!)

					DispatchQueue.main.async(execute: { () -> Void in
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

