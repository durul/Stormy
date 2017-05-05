//
//  TemperatureLabel.swift
//  Stormy
//
//  Created by durul dalkanat on 5/5/17.
//  Copyright © 2017 DRL. All rights reserved.
//

import UIKit
import Foundation

class TemperatureLabel: UILabel {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // Font for question label text.
        let appFonts = AppFonts.sharedInstance
        self.font = appFonts.temperatureFont
        
    }
    
}
