//
//  TemperatureLabel.swift
//  Stormy

import UIKit
import Foundation

class TemperatureLabel: UILabel {

    // MARK: - Super Methods
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // Font for question label text.
        let appFonts = AppFonts.sharedInstance
        self.font = appFonts.temperatureFont
        
    }
    
}
