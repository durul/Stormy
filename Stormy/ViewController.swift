//  ViewController.swift
//  Stormy

import UIKit
import Intents
import CoreLocation

//MARK: - UIViewController Properties
class ViewController: UIViewController {
    
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
    @IBOutlet weak var currentLocationLabel: UILabel!
    
    //MARK: - Properties
    var localDataObjects = NSArray() // NSArray because Swift arrays don't have objectAtIndex
    let manager = LocationManager()
    var myCoordinate: Coordinate? = nil
    let geoCoder = CLGeocoder()
    
    //MARK: - Super Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshActivityIndicator.isHidden = true
        
        if #available(iOS 10.0, *) {
            siriAuthorizing()
        } else {
            // Fallback on earlier versions
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(didChangePowerMode), name: NSNotification.Name.NSProcessInfoPowerStateDidChange, object: nil)
        
        getCurrentWeatherData()
        manager.getPermission()
        
    }
    
    @objc func didChangePowerMode(notification: NSNotification) {
        if ProcessInfo.processInfo.isLowPowerModeEnabled {
            refreshActivityIndicator.isHidden = true
            refreshButton.isHidden = true
            
            // low power mode on
            let alertController = UIAlertController(title: "Low power mode ON", message: "You can't get current information data", preferredStyle:UIAlertControllerStyle.alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
                print("you have pressed the Cancel button");
            }
            alertController.addAction(cancelAction)
            
            let OKAction = UIAlertAction(title: "OK", style: .default) { _ in
                print("you have pressed OK button");
            }
            alertController.addAction(OKAction)
            
            self.present(alertController, animated: true, completion:{ () -> Void in
                //your code here
            })
        } else {
            getCurrentWeatherData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        currentTimeLabel.center.x  -= view.bounds.width
        humidityLabel.center.x -= view.bounds.width
        temperatureLabel.center.x -= view.bounds.width
        
        humidityLabel.alpha = 0.0
        currentTimeLabel.alpha = 0.0
        temperatureLabel.alpha = 0.0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 0.5, animations: {
            self.currentTimeLabel.center.x += self.view.bounds.width
        })
        
        UIView.animate(withDuration: 0.5, delay: 0.3, usingSpringWithDamping: 0.2, initialSpringVelocity: 0.0, options: [], animations: {
            self.humidityLabel.center.x += self.view.bounds.width
        }, completion: nil)
        
        UIView.animate(withDuration: 0.5, delay: 0.4, usingSpringWithDamping: 0.2, initialSpringVelocity: 0.0, options: [], animations: {
            self.temperatureLabel.center.x += self.view.bounds.width
        }, completion: nil)
        
        
        UIView.animate(withDuration: 0.5, delay: 0.3, options: [], animations: {
            self.humidityLabel.alpha = 1.0
        }, completion: nil)
        
        UIView.animate(withDuration: 0.5, delay: 0.4, options: [], animations: {
            self.currentTimeLabel.alpha = 1.0
        }, completion: nil)
        
        UIView.animate(withDuration: 0.5, delay: 0.5, options: [], animations: {
            self.temperatureLabel.alpha = 1.0
        }, completion: nil)
        
    }
    
    //MARK: - Public Method
    func getCurrentWeatherData() -> Void {
        // https://api.forecast.io/forecast/bec6820ba3d3baeddbae393d2a240e73/37.8267,-122.423
        
        guard let baseURL = URL(string: "https://api.forecast.io/forecast/\(APIKey)/") else {
            print("Error: cannot create URL")
            return
        }
        
        manager.onLocationFix = { [weak self] coordinate in
            self?.myCoordinate = coordinate
            
            let config = URLSessionConfiguration.default
            // Helping to energy impact and it is optimizing
            // This will allow to know when you connect to the server of your choice.
            
            if #available(iOS 11.0, *) {
                config.waitsForConnectivity = true
            } else {
                // Fallback on earlier versions
            }
            
            // Set discretionary property
            config.isDiscretionary = true
            
            let cachesDirectoryURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
            
            let cacheURL = cachesDirectoryURL.appendingPathComponent("MyCache")
            let diskPath = cacheURL.path
            
            let cache = URLCache(memoryCapacity:16384, diskCapacity: 268435456, diskPath: diskPath)
            config.urlCache = cache
            config.requestCachePolicy = .useProtocolCachePolicy
            
            let forecastURL = URL(string: "\(coordinate.latitude),\(coordinate.longitude)", relativeTo: baseURL)
            
            var request = URLRequest(url: forecastURL!)
            request.httpMethod = "GET"
            request.networkServiceType = .responsiveData // Prioritize
            
            let sharedSession = URLSession(configuration: config)
            
            
            // Sending request to the server.
            let downloadTask: URLSessionDownloadTask = sharedSession.downloadTask(with: forecastURL!, completionHandler: { (data, response, error) -> Void in
                
                
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
                                self?.currentLocationLabel.text = locationName as String
                            }
                        }
                        
                        // We’re doing the loading off the main thread, and then coming back onto the main thread to update the UI.
                        DispatchQueue.main.async(execute: { () -> Void in
                            self?.temperatureLabel.text = "\(currentWeather.temperature)"
                            self?.iconView.image = currentImage.icon!
                            self?.currentTimeLabel.text = "At \(currentWeather.currentTime!) it is"
                            self?.humidityLabel.text = "\(currentWeather.humidity)%"
                            self?.precipitationLabel.text = "\(currentWeather.precipProbability)%"
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
            
            if #available(iOS 11.0, *) {
                // This will help us indicate the system the best time to do
                // These are sent to data an effecient way. 
                // Set time window
                downloadTask.earliestBeginDate = Date(timeIntervalSinceNow: 2 * 60 * 60)
                
                // Set workload size
                downloadTask.countOfBytesClientExpectsToSend = 80
                downloadTask.countOfBytesClientExpectsToReceive = 2048
                
            } else {
                // Fallback on earlier versions
            }
            
            
            downloadTask.resume()
        }
    }
    
    @available(iOS 10.0, *)
    func siriAuthorizing() {
        INPreferences.requestSiriAuthorization {
            switch $0 {
            case .authorized:
                print("authorized")
                break
                
            case .notDetermined:
                print("notDetermined")
                break
                
            case .restricted:
                print("restricted")
                break
                
            case .denied:
                print("denied")
                break
            }
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

extension ViewController {
    
    
    // MARK: - Layout-related methods
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        print("viewWillLayoutSubviews")
    }
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        print("viewWillTransition")
    }
    
    override func viewLayoutMarginsDidChange() {
        if #available(iOS 11.0, *) {
            super.viewLayoutMarginsDidChange()
        } else {
            // Fallback on earlier versions
        }
        print("viewLayoutMarginsDidChange")
    }
    
    override func viewSafeAreaInsetsDidChange() {
        if #available(iOS 11.0, *) {
            super.viewSafeAreaInsetsDidChange()
        } else {
            // Fallback on earlier versions
        }
        print("viewSafeAreaInsetsDidChange")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print("viewDidLayoutSubviews")
        
        if #available(iOS 11.0, *) {
            dump(systemMinimumLayoutMargins)
        } else {
            
        }
        
        dump(view.layoutMargins)
    }
}
