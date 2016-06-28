//
//  ViewController.swift
//  Stormy
//
//  Created by Durul Dalkanat on 9/15/14.
//  Copyright (c) 2014 Durul Dalkanat. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
	
	// Replace the string below with your API Key.
	private let APIKey = "bec6820ba3d3baeddbae393d2a240e73"
	
	@IBOutlet weak var iconView: UIImageView!
	@IBOutlet weak var currentTimeLabel: UILabel!
	@IBOutlet weak var temperatureLabel: UILabel!
	@IBOutlet weak var humidityLabel: UILabel!
	@IBOutlet weak var precipitationLabel: UILabel!
	@IBOutlet weak var summaryLabel: UILabel!
	@IBOutlet weak var refreshButton: UIButton!
	@IBOutlet weak var refreshActivityIndicator: UIActivityIndicatorView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		refreshActivityIndicator.hidden = true
		
		getCurrentWeatherData()
	}
	
	func getCurrentWeatherData() -> Void {
		// https://api.forecast.io/forecast/bec6820ba3d3baeddbae393d2a240e73/37.8267,-122.423
		
		guard let baseURL = NSURL(string: "https://api.forecast.io/forecast/\(APIKey)/") else {
			print("Error: cannot create URL")
			return
		}
		
		guard let forecastURL = NSURL(string: "37.8267,-122.423", relativeToURL: baseURL) else {
			print("Error: cannot create URL")
			return
		}
		
		// let sharedSession = NSURLSession.sharedSession()
        
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let sharedSession = NSURLSession(configuration: config)

		let downloadTask: NSURLSessionDownloadTask = sharedSession.downloadTaskWithURL(forecastURL, completionHandler: { (location: NSURL?, response: NSURLResponse?, error: NSError?) -> Void in
			
			if (error == nil) {
				let dataObject = NSData(contentsOfURL: location!)
				
				do {
					let weatherDictionary = try NSJSONSerialization.JSONObjectWithData(dataObject!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
					
					let currentWeather = Current(weatherDictionary: weatherDictionary!)
                    let currentImage = CurrentImage(weatherDictionary: weatherDictionary!)

					dispatch_async(dispatch_get_main_queue(), { () -> Void in
						self.temperatureLabel.text = "\(currentWeather.temperature)"
						self.iconView.image = currentImage.icon!
						self.currentTimeLabel.text = "At \(currentWeather.currentTime!) it is"
						self.humidityLabel.text = "\(currentWeather.humidity)%"
						self.precipitationLabel.text = "\(currentWeather.precipProbability)%"
						self.summaryLabel.text = "\(currentWeather.summary)"
						
						// Stop refresh animation
						self.refreshActivityIndicator.stopAnimating()
						self.refreshActivityIndicator.hidden = true
						self.refreshButton.hidden = false
					})
					
				} catch let error as NSError {
					let networkIssueController = UIAlertController(title: "Error", message: "Unable to load data. Connectivity error!", preferredStyle: .Alert)
					
					let okButton = UIAlertAction(title: "OK", style: .Default, handler: nil)
					networkIssueController.addAction(okButton)
					
					let cancelButton = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
					networkIssueController.addAction(cancelButton)
					
					self.presentViewController(networkIssueController, animated: true, completion: nil)
					
					dispatch_async(dispatch_get_main_queue(), { () -> Void in
						// Stop refresh animation
						self.refreshActivityIndicator.stopAnimating()
						self.refreshActivityIndicator.hidden = true
						self.refreshButton.hidden = false
					})
					print(error)
				}
			}
			
		})
		
		downloadTask.resume()
	}
	
	@IBAction func refresh() {
		getCurrentWeatherData()
		
		refreshButton.hidden = true
		refreshActivityIndicator.hidden = false
		refreshActivityIndicator.startAnimating()
	}
	
}

