//
//  LocationManager.swift

import Foundation
import CoreLocation
import MapKit

//4- This extension coordinate that allows us to initialize the coordinate object with a CLlocation instance.
extension Coordinate {
	init(location: CLLocation) {
		latitude = location.coordinate.latitude
		longitude = location.coordinate.longitude
	}
}

final class LocationManager: NSObject, CLLocationManagerDelegate {
	fileprivate let manager = CLLocationManager()
	
	// 3- We're going to define an optional variable stored property. onLocationFix takes an optional closure of type coordinate to void.
	var onLocationFix: ((Coordinate) -> Void)?
	
	// Above location object that we get down in the delegate method right here converted to a coordinate object Of type coordinate that we created earlier.
	
	override init() {
		super.init()
		manager.delegate = self
		manager.requestLocation()
	}
	
	func getPermission() {
		if CLLocationManager.authorizationStatus() == .notDetermined {
			manager.requestWhenInUseAuthorization()
		}
	}
	
	// MARK: CLLocationManagerDelegate
	
	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		if status == .authorizedWhenInUse {
			manager.requestLocation()
		}
	}
	
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		print(error)
	}
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		// 1- This method returns a location fix immediately after the first one is found. So, the array in the delegate method, the Location argument.
		guard let location = locations.first else { return }
		
		// 2- 5 seconds for called cached result. We simply ignore these cached locations if they are too old.
		if location.timestamp.timeIntervalSinceNow < -5 {
			return
		}
		
		// INFO: We will pass this information on to any other object looking to use it in our case that is the Foursquare client below.
		
		// 6- let coordinate will get a corded point out of the sea a location instance
		
		// will say let coordinate equal, and will use our new initializer and pass in the location, and then after that all we're going to you do is use this coordinate as an argument to the on location fix function because this is an optional function though.
		
		// We'll first make sure we have a value assigned to the property and unwrapped so that we can use. So we'll say let on location fix.
		
		let coordinate = Coordinate(location: location)
		if let onLocationFix = onLocationFix {
			onLocationFix(coordinate)
		}
	}
	
}

