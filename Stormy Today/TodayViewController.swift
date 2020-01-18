//
//  TodayViewController.swift
//  Stormy Today


import UIKit
import NotificationCenter

    // MARK: - UIViewController Properties
class TodayViewController: UIViewController, NCWidgetProviding {
    
    // MARK: - IBOutlets
    @IBOutlet var temperatureLbl: UILabel!
    @IBOutlet var iconImageView: UIImageView!
    
    fileprivate let APIKey = "bec6820ba3d3baeddbae393d2a240e73"

    // MARK: - Super Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        temperatureLbl.text = ""
        iconImageView.image = nil
        
        // use tap gesture on label to launch app
        temperatureLbl.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(TodayViewController.doLaunchApp))
        temperatureLbl.addGestureRecognizer(tapGesture)
    }
    
    // Create custom app URLs
    @objc func doLaunchApp() {
        if let url = URL(string: "Stormy://") {
            self.extensionContext?.open(url, completionHandler: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        getCurrentWeatherData()
        
        completionHandler(NCUpdateResult.newData)
    }
    
    
    func getCurrentWeatherData() {
        
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
            (location, _, error) -> Void in
            
            if error == nil {
                let dataObject = try? Data(contentsOf: location!)
                
                // Parsing incoming data
                do {
                    let weatherDictionary = try JSONSerialization.jsonObject(with: dataObject!, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: AnyObject]
                    
                    let currentWeather = Current(weatherDictionary: weatherDictionary! as NSDictionary)
                    let currentImage = CurrentImage(weatherDictionary: weatherDictionary! as NSDictionary)
                    
                    DispatchQueue.main.async(execute: { () -> Void in
                        self.temperatureLbl.text = "\(currentWeather.temperature)"
                        self.iconImageView.image = currentImage.icon
                    })
                    
                } catch let error as NSError {
                    print(error)
                }
            } else {
                
            }
        })
        
        downloadTask.resume()
    }
}
