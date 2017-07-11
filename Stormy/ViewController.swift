//  ViewController.swift
//  Stormy

import UIKit
import Intents

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
    
    var localDataObjects = NSArray() // NSArray because Swift arrays don't have objectAtIndex
    
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
    }
    
    func didChangePowerMode(notification: NSNotification) {
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

        guard let forecastURL = URL(string: "37.8267,-122.423", relativeTo: baseURL) else {
            print("Error: cannot create URL")
            return
        }
            
        let config = URLSessionConfiguration.default
        let sharedSession = URLSession(configuration: config)
        
        // Sending request to the server.
        let downloadTask: URLSessionDownloadTask = sharedSession.downloadTask(with: forecastURL, completionHandler: { (location, response, error) -> Void in
            
            // Checking internet connection availability
            if Reachability.isConnectedToNetwork() {

                let dataObject = try? Data(contentsOf: location!)
                
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

// We’re doing the loading off the main thread, and then coming back onto the main thread to update the UI.        
                    DispatchQueue.main.async(execute: { () -> Void in
                        self.temperatureLabel.text = "\(currentWeather.temperature)"
                        self.iconView.image = currentImage.icon!
                        self.currentTimeLabel.text = "At \(currentWeather.currentTime!) it is"
                        self.humidityLabel.text = "\(currentWeather.humidity)%"
                        self.precipitationLabel.text = "\(currentWeather.precipProbability)%"
                        self.summaryLabel.text = "\(currentWeather.summary)"
                        
                        // Stop refresh animation
                        self.refreshActivityIndicator.stopAnimating()
                        self.refreshActivityIndicator.isHidden = true
                        self.refreshButton.isHidden = false
                        
                    })
                    
                    
                } catch let error as NSError {
                    print(error)
                }
            }
                
            else {
                let networkIssueController = UIAlertController(title: "Error",
                                                               message: "Unable to load data. Connectivity error!", preferredStyle: .alert)
                
                let okButton = UIAlertAction(title: "OK", style: .default, handler: nil)
                networkIssueController.addAction(okButton)
                
                let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                networkIssueController.addAction(cancelButton)
                
                self.present(networkIssueController, animated: true, completion: { () in
                    print("Done🔨", ServiceError.noInternetConnection)
                })
                
                DispatchQueue.main.async(execute: { () -> Void in
                    // Stop refresh animation
                    self.refreshActivityIndicator.stopAnimating()
                    self.refreshActivityIndicator.isHidden = true
                    self.refreshButton.isHidden = false
                })
                
            }
        })
        
        downloadTask.resume()
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

