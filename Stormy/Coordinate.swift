//
//  Coordinate.swift
//  Stormy

import Foundation
import CoreLocation

struct Coordinate {
    let latitude: Double
    let longitude: Double
}

// We need to get a string out of this coordinate so in an extension of Coordinate, we're going to conform to CustomStringConvertible, which is a standard library protocol that requires we provide a textual description of the instance. Return here just create an interpolated string.
extension Coordinate: CustomStringConvertible {
    var description: String {
        return "\(latitude),\(longitude)"
    }
}
