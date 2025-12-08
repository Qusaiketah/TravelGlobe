//
//  MemoryPin.swift
//  TravelGlobe
//
//  Created by Qusai Ketah on 2025-12-08.
//

import MapKit

struct MemoryPin: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let title: String
}
