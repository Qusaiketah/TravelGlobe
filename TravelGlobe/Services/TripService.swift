import Foundation
import SwiftUI
import CoreLocation
import FirebaseFirestore
import FirebaseAuth
import Combine

class TripService: ObservableObject {
    
    static let shared = TripService()
    
    @Published var trips: [Trip] = []
    private let db = Firestore.firestore()
    
    private init() {
        fetchTrips()
    }
    
    func addTrip(locationName: String, coordinate: CLLocationCoordinate2D, image: UIImage?, caption: String) {
        if let image = image {
            StorageService.shared.uploadImage(image) { [weak self] url in
                self?.saveTripToFirestore(name: locationName, coord: coordinate, url: url, caption: caption)
            }
        } else {
            saveTripToFirestore(name: locationName, coord: coordinate, url: nil, caption: caption)
        }
    }
    
    private func saveTripToFirestore(name: String, coord: CLLocationCoordinate2D, url: String?, caption: String) {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("Ingen användare inloggad, kan inte spara till DB")
            return
        }
        
        let newTrip = Trip(
            id: UUID(),
            locationName: name,
            latitude: coord.latitude,
            longitude: coord.longitude,
            date: Date(),
            imageURL: url,
            caption: caption
        )
        
        do {
            try db.collection("users").document(uid).collection("trips").document(newTrip.id.uuidString).setData(from: newTrip)
            print("Resa sparad i Firestore!")
            
            DispatchQueue.main.async {
                self.trips.insert(newTrip, at: 0)
            }
        } catch {
            print("Fel vid sparning av resa: \(error)")
        }
    }
    
    func fetchTrips() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(uid).collection("trips")
            .order(by: "date", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Kunde inte hämta resor: \(error)")
                    return
                }
                
                DispatchQueue.main.async {
                    self.trips = snapshot?.documents.compactMap { doc in
                        try? doc.data(as: Trip.self)
                    } ?? []
                    print("Hämtade \(self.trips.count) resor från Firestore")
                }
            }
    }
}
