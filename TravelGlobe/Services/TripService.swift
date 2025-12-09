import Foundation
import SwiftUI
import CoreLocation
import Combine

class TripService: ObservableObject {
    
    static let shared = TripService()
    
    @Published var trips: [Trip] = []
    
    private init() {}
    
    // Funktion för ny resa
    func addTrip(locationName: String, coordinate: CLLocationCoordinate2D, image: UIImage?, caption: String) {
        
        print("🌍 TripService: Startar att spara resa till \(locationName)...")
        
        // ladda upp bild först till AWS
        if let image = image {
            StorageService.shared.uploadImage(image) { [weak self] downloadedURL in
                self?.createAndAppendTrip(
                    locationName: locationName,
                    coordinate: coordinate,
                    imageURL: downloadedURL,
                    caption: caption
                )
            }
        } else {
            // spara utan url när det ingen bild
            createAndAppendTrip(
                locationName: locationName,
                coordinate: coordinate,
                imageURL: nil,
                caption: caption
            )
        }
    }
    
    private func createAndAppendTrip(locationName: String, coordinate: CLLocationCoordinate2D, imageURL: String?, caption: String) {
        
        let newTrip = Trip(
            locationName: locationName,
            coordinate: coordinate,
            date: Date(),
            imageURL: imageURL,
            caption: caption,
            color: .random()
        )
        
        DispatchQueue.main.async {
            self.trips.insert(newTrip, at: 0)
            print("TripService: Resa sparad! Antal resor: \(self.trips.count)")
        }
    }
}

extension Color {
    static func random() -> Color {
        return Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1)
        )
    }
}
