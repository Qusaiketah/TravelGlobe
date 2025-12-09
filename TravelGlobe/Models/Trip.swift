//
//  Trip.swift
//  TravelGlobe
//
//  Created by Qusai Ketah on 2025-12-08.
//
import SwiftUI
import CoreLocation

struct Trip: Identifiable {
    let id = UUID()
    let locationName: String
    let coordinate: CLLocationCoordinate2D
    let date: Date
    let imageURL: String?
    let caption: String?
    
    var icon: String = "mappin.circle.fill"
    var color: Color = .blue
}
