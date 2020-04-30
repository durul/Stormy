//  ViewController.swift
//  Stormy

import UIKit
import Intents
import CoreLocation
import os.log
import os.signpost

// MARK: - UIViewController Properties
class ViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var precipitationLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var refreshActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var currentLocationLabel: UILabel!
    
    // MARK: - Properties
    var localDataObjects = NSArray() // NSArray because Swift arrays don't have objectAtIndex
    let manager = LocationManager()
    var myCoordinate: Coordinate?
    let geoCoder = CLGeocoder()
    
    let logger = OSLog(subsystem: "com.stormy", category: "weather")
    var count = 0
    weak var appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    let userLicenseAgreement  = """
    Effect of USA and the following with the distribution. The name DD must not be deemed a waiver of future enforcement of that collection of files distributed by that Contributor and the date You accept this license. Here is an example of such Contributor, if any, in source and free culture, all users contributing to Wikimedia projects are available under terms that differ significantly from those contained in the Standard Version, including, but not limited to the terms and conditions of this License.
    This customary commercial license in technical data rights in the page or pages you are thus distributing it and "any later version", you have fulfilled the obligations of Section 3.1-3.5 have been properly granted shall survive any termination of this License will not be used to control compilation and installation of an aggregate software distribution provided that Apple did not first commence an action for patent infringement claim (excluding declaratory judgment actions) against Initial Developer and the Program in a reasonable period of time after becoming aware of such damages. MAINTENANCE OF THE LICENSED PROGRAM OR THE EXERCISE OF ANY COVERED CODE WILL BE UNINTERRUPTED OR ERROR-FREE, OR THAT DEFECTS IN THE SOFTWARE. Preamble The licenses for most software companies keep you at the time the Contribution is contributed, it may be distributed under Clause 2 above, as long as such will be useful, but WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, ANY WARRANTIES OF TITLE, NON-INFRINGEMENT, MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL DD ``AS IS'' AND ANY EXPRESSED OR IMPLIED INCLUDING, WITHOUT LIMITATION, DAMAGES FOR LOSS OF GOODWILL, WORK STOPPAGE, COMPUTER FAILURE OR MALFUNCTION, OR ANY DISTRIBUTOR OF LICENSED PRODUCT IS WITH YOU.
    SHOULD ANY COVERED CODE WILL MEET YOUR REQUIREMENTS, THAT THE COVERED CODE, THAT THE COVERED CODE WILL BE UNINTERRUPTED OR ERROR-FREE, OR THAT DEFECTS IN THE COVERED CODE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY REMEDY. SOME JURISDICTIONS DO NOT ALLOW THE LIMITATION OF LIABILITY. UNDER NO LEGAL THEORY, WHETHER TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE PROGRAM IS WITH YOU. SHOULD LICENSED PRODUCT PROVE DEFECTIVE IN ANY WAY OUT OF THE PROGRAM TO OPERATE WITH ANY OTHER USERS OF THE COVERED CODE IS AUTHORIZED HEREUNDER EXCEPT UNDER THIS DISCLAIMER. TERMINATION. 8.1. This License Agreement shall terminate if it is not possible to put such notice in Exhibit A, which is freely accessible, which conforms with the `Work' referring to freedom, not price. Our General Public License from time to time.
    """
    
    // MARK: - Super Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        print("efwfwef \(Bundle.main.infoDictionary?["API_KEY"] as? String ?? "")")
        
        refreshActivityIndicator.isHidden = true
        
        if #available(iOS 10.0, *) {
            siriAuthorizing()
        } else {
            // Fallback on earlier versions
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(didChangePowerMode), name: NSNotification.Name.NSProcessInfoPowerStateDidChange, object: nil)
        
        getCurrentWeatherData()
        manager.getPermission()
        
        if #available(iOS 12.0, *) {
            os_signpost(.event, log: SignpostLog.pointsOfInterest, name: "ViewController-viewDidLoad")
        } else {
            // Fallback on earlier versions
        }
        
        registerForThermalNotifications()
    }
    
    @objc func didChangePowerMode(notification: NSNotification) {
        if ProcessInfo.processInfo.isLowPowerModeEnabled {
            refreshActivityIndicator.isHidden = true
            refreshButton.isHidden = true
            
            // low power mode on
            let alertController = UIAlertController(title: "Low power mode ON", message: "You can't get current information data", preferredStyle: UIAlertController.Style.alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
                print("you have pressed the Cancel button")
            }
            alertController.addAction(cancelAction)
            
            let OKAction = UIAlertAction(title: "OK", style: .default) { _ in
                print("you have pressed OK button")
            }
            alertController.addAction(OKAction)
            
            self.present(alertController, animated: true, completion: { () -> Void in
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
        
        if #available(iOS 12.0, *) {
            os_signpost(.event, log: SignpostLog.pointsOfInterest, name: "ViewController-viewWillAppear")
        } else {
            // Fallback on earlier versions
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !appDelegate!.hasAlreadyLaunched {
            
            //set hasAlreadyLaunched to false
            appDelegate?.sethasAlreadyLaunched()
            //display user agreement license
            displayLicenAgreement(message: self.userLicenseAgreement)
        }
        
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
        
        if #available(iOS 12.0, *) {
            os_signpost(.event, log: SignpostLog.pointsOfInterest, name: "ViewController-viewDidAppear")
        } else {
            // Fallback on earlier versions
        }
    }
    
    // MARK: - Public Method
    fileprivate func networkIssueAlertFunc() {
        let networkIssueController = UIAlertController(title: "Error", message: "Unable to load data. Connectivity error!", preferredStyle: .alert)
        
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
    
    func getCurrentWeatherData() {
        // https://api.forecast.io/forecast/bec6820ba3d3baeddbae393d2a240e73/37.8267,-122.423
        let APIKey = Bundle.main.infoDictionary?["API_KEY"] as? String
        
        guard let baseURL = URL(string: "https://api.darksky.net/forecast/\(APIKey ?? "")/") else {
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
            
            let cache = URLCache(memoryCapacity: 16384, diskCapacity: 268435456, diskPath: diskPath)
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
                        
                        
                        self?.geoCoder.reverseGeocodeLocation(location) { (placemarks, _) -> Void in
                            
                            let placeArray = placemarks as [CLPlacemark]?
                            
                            // Place details
                            var placeMark: CLPlacemark!
                            placeMark = placeArray?[0]
                            
                            // Address dictionary
                            print(placeMark.addressDictionary!)
                            
                            // Location name
                            if let locationName = placeMark.addressDictionary?["City"] as? NSString {
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
                    self?.networkIssueAlertFunc()
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
            @unknown default:
                fatalError()
            }
        }
    }
    
    //Registering for Thermal Change notifications
    private func registerForThermalNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(responseToHeat(_:)),
                                               name: ProcessInfo.thermalStateDidChangeNotification,
                                               object: nil)
    }
    
    
    @objc private func responseToHeat(_ notification: Notification ) {
        
        let state = ProcessInfo.processInfo.thermalState
        switch state {
        case .nominal:
            print("nominal")
        case .fair:
            print("Starts getting heated up. Try reducing CPU expensive operations.")
        case .serious:
            print("Time to reduce the CPU usage and make sure you are not burning more")
        case .critical:
            print("Reduce every operations and make initiate device cool down.")
        @unknown default:
            fatalError()
        }
    }
    
    // MARK: - IBActions
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

// Detecting the first launch
extension ViewController {
    func displayLicenAgreement(message: String) {
        
        //create alert
        let alert = UIAlertController(title: "License Agreement", message: message, preferredStyle: .alert)
        
        //create Decline button
        let declineAction = UIAlertAction(title: "Decline", style: .destructive) { (_) -> Void in
        }
        
        //create Accept button
        let acceptAction = UIAlertAction(title: "Accept", style: .default) { (_) -> Void in
        }
        
        //add task to tableview buttons
        alert.addAction(declineAction)
        alert.addAction(acceptAction)
        self.present(alert, animated: true, completion: nil)
    }
}


#if canImport(SwiftUI) && DEBUG

import SwiftUI

struct ViewControllerRepresentable: UIViewRepresentable {
    
    func makeUIView(context: Context) -> UIView {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        return makeUIView(context: context, storyboard: storyboard, identifier: "ViewController")
    }
    
    func updateUIView(_ view: UIView, context: Context) {
        
    }
}

@available(iOS 13.0, *)
struct ViewControllerPreview: PreviewProvider {
    
    static var previews: some View {
        Group {
            ViewControllerRepresentable()
                .colorScheme(.light)
                .previewDisplayName("Light Mode")
            ViewControllerRepresentable()
                .colorScheme(.dark)
                .previewDisplayName("Dark Mode")
        }
    }
}

#endif
