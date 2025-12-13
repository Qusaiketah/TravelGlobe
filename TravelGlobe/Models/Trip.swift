//
//  Trip.swift
//  TravelGlobe
//
//  Created by Qusai Ketah on 2025-12-08.
//
import SwiftUI
import CoreLocation

struct Trip: Identifiable, Codable {
    let id: UUID
    let locationName: String
    let latitude: Double
    let longitude: Double
    let date: Date
    let imageURL: String?
    let caption: String?
    var color: String = "blue"
    var icon: String = "mappin.circle.fill"
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var uiColor: Color {
        switch color {
        case "red": return .red
        case "blue": return .blue
        case "green": return .green
        case "purple": return .purple
        case "pink": return .pink
        case "orange": return .orange
        default: return .blue
        }
    }
}
