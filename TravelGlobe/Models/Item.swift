//
//  Item.swift
//  TravelGlobe
//
//  Created by Qusai Ketah on 2025-12-04.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
