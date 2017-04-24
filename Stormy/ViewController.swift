//  ViewController.swift
//  Stormy

import UIKit

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
        
        getCurrentWeatherData()
        
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
        let downloadTask: URLSessionDownloadTask = sharedSession.downloadTask(with: forecastURL, completionHandler: {
            (location, response, error) -> Void in
            
            if (error == nil) {
                let dataObject = try? Data(contentsOf: location!)
                
                // Parsing incoming data
                do {
                    let weatherDictionary = try JSONSerialization.jsonObject(with: dataObject!, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: AnyObject]
                    
                    let currentWeather = Current(weatherDictionary: weatherDictionary! as NSDictionary)
                    let currentImage = CurrentImage(weatherDictionary: weatherDictionary! as NSDictionary)
                    
                    
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
                
                self.present(networkIssueController, animated: true, completion: nil)
                
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
    
    //MARK: - IBActions
    @IBAction func refresh() {
        getCurrentWeatherData()
        
        refreshButton.isHidden = true
        refreshActivityIndicator.isHidden = false
        refreshActivityIndicator.startAnimating()
    }
    
}

