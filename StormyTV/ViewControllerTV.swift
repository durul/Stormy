//
//  ViewControllerTV.swift

import UIKit
import CoreLocation

    //MARK: - UIViewController Properties
class ViewControllerTV: UIViewController {
	
    //MARK: - Private Properties
    // Replace the string below with your API Key.
	fileprivate let APIKey = "bec6820ba3d3baeddbae393d2a240e73"
	
    //MARK: - IBOutlets
	@IBOutlet weak var iconView: UIImageView!
	@IBOutlet weak var currentTimeLabel: UILabel!
	@IBOutlet weak var temperatureLabel: UILabel!
	@IBOutlet weak var humidityLabel: UILabel!
	@IBOutlet weak var precipitationLabel: UILabel!
	@IBOutlet weak var summaryLabel: UILabel!
	@IBOutlet weak var refreshButton: UIButton!
	@IBOutlet weak var refreshActivityIndicator: UIActivityIndicatorView!

    let manager = LocationManager()
    var myCoordinate: Coordinate? = nil
    let geoCoder = CLGeocoder()

    //MARK: - Super Methods
	override func viewDidLoad() {
		super.viewDidLoad()
		
		refreshActivityIndicator.isHidden = true
		
		getCurrentWeatherData()
	}
	
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        currentTimeLabel.center.x  -= view.bounds.width
        summaryLabel.center.x -= view.bounds.width
        temperatureLabel.center.x -= view.bounds.width
        
        summaryLabel.alpha = 0.0
        currentTimeLabel.alpha = 0.0
        temperatureLabel.alpha = 0.0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 0.5, animations: {
            self.currentTimeLabel.center.x += self.view.bounds.width
        })
        
        UIView.animate(withDuration: 0.5, delay: 0.3, usingSpringWithDamping: 0.2, initialSpringVelocity: 0.0, options: [], animations: {
            self.summaryLabel.center.x += self.view.bounds.width
        }, completion: nil)
        
        UIView.animate(withDuration: 0.5, delay: 0.4, usingSpringWithDamping: 0.2, initialSpringVelocity: 0.0, options: [], animations: {
            self.temperatureLabel.center.x += self.view.bounds.width
        }, completion: nil)
        
        
        UIView.animate(withDuration: 0.5, delay: 0.3, options: [], animations: {
            self.summaryLabel.alpha = 1.0
        }, completion: nil)
        
        UIView.animate(withDuration: 0.5, delay: 0.4, options: [], animations: {
            self.currentTimeLabel.alpha = 1.0
        }, completion: nil)
        
        UIView.animate(withDuration: 0.5, delay: 0.5, options: [], animations: {
            self.temperatureLabel.alpha = 1.0
        }, completion: nil)
        
    }

    func getCurrentWeatherData() -> Void {

        guard let baseURL = URL(string: "https://api.forecast.io/forecast/\(APIKey)/") else {
            print("Error: cannot create URL")
            return
        }

        manager.onLocationFix = { [weak self] coordinate in
            self?.myCoordinate = coordinate

            guard let forecastURL = URL(string: "\(coordinate.latitude),\(coordinate.longitude)", relativeTo: baseURL) else {
                print("Error: cannot create forecastURL")
                return
            }

            let config = URLSessionConfiguration.default
            let sharedSession = URLSession(configuration: config)

            // Sending request to the server.
            let downloadTask: URLSessionDownloadTask = sharedSession.downloadTask(with: forecastURL, completionHandler: { (data, response, error) -> Void in

                // Checking internet connection availability
                if Reachability.isConnectedToNetwork() {

                    let dataObject = try? Data(contentsOf: data!)

                    if let httpResponse = response as? HTTPURLResponse, (200..<300) ~= httpResponse.statusCode {
                        print(httpResponse)
                    } else {
                        print(ServiceError.other)
                    }

                    // Parsing incoming data
                    do {
                        let weatherDictionary = try JSONSerialization.jsonObject(with: dataObject!, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: AnyObject]

                        let currentWeather = Current(weatherDictionary: weatherDictionary! as NSDictionary)
                        let currentImage = CurrentImage(weatherDictionary: weatherDictionary! as NSDictionary)
                        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)


                        self?.geoCoder.reverseGeocodeLocation(location) { (placemarks, error) -> Void in

                            let placeArray = placemarks as [CLPlacemark]!

                            // Place details
                            var placeMark: CLPlacemark!
                            placeMark = placeArray?[0]

                            // Address dictionary
                            print(placeMark.addressDictionary!)

                            // Location name
                            if let locationName = placeMark.addressDictionary?["City"] as? NSString
                            {
                                self?.currentTimeLabel.text = locationName as String
                            }
                        }

                        // We’re doing the loading off the main thread, and then coming back onto the main thread to update the UI.
                        DispatchQueue.main.async(execute: { () -> Void in
                            self?.temperatureLabel.text = "\(currentWeather.temperature)"
                            self?.iconView.image = currentImage.icon!
                            self?.summaryLabel.text = "\(currentWeather.summary)"

                            // Stop refresh animation
                            self?.refreshActivityIndicator.stopAnimating()
                            self?.refreshActivityIndicator.isHidden = true
                            self?.refreshButton.isHidden = false
                        })

                    } catch let error as NSError {
                        print(error)
                    }
                } else {
                    let networkIssueController = UIAlertController(title: "Error", message: "Unable to load data. Connectivity error!", preferredStyle: .alert)

                    let okButton = UIAlertAction(title: "OK", style: .default, handler: nil)
                    networkIssueController.addAction(okButton)

                    let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                    networkIssueController.addAction(cancelButton)

                    self?.present(networkIssueController, animated: true, completion: { () in
                        print("Done🔨", ServiceError.noInternetConnection)
                    })

                    DispatchQueue.main.async(execute: { () -> Void in
                        // Stop refresh animation
                        self?.refreshActivityIndicator.stopAnimating()
                        self?.refreshActivityIndicator.isHidden = true
                        self?.refreshButton.isHidden = false
                    })
                    
                }
            })
            
            downloadTask.resume()
        }
    }

    //MARK: - IBActions
	@IBAction func refresh() {
		getCurrentWeatherData()
		
		refreshButton.isHidden = true
		refreshActivityIndicator.isHidden = false
		refreshActivityIndicator.startAnimating()
	}
	
}

