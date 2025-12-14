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

    func addTrip(locationName: String, coordinate: CLLocationCoordinate2D, images: [UIImage], caption: String) {
        
        if images.isEmpty {
            saveTripToFirestore(name: locationName, coord: coordinate, urls: nil, caption: caption)
            return
        }
        var uploadedURLs: [String] = []
        let group = DispatchGroup()
        
        for image in images {
            group.enter()
            StorageService.shared.uploadImage(image) { url in
                if let url = url {
                    uploadedURLs.append(url)
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            print("📸 Alla bilder uppladdade: \(uploadedURLs.count) st")
            self?.saveTripToFirestore(name: locationName, coord: coordinate, urls: uploadedURLs, caption: caption)
        }
    }
    
    private func saveTripToFirestore(name: String, coord: CLLocationCoordinate2D, urls: [String]?, caption: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let randomColorName = ["blue", "red", "green", "purple", "pink", "orange"].randomElement() ?? "blue"
        
        let newTrip = Trip(
            id: UUID(),
            locationName: name,
            latitude: coord.latitude,
            longitude: coord.longitude,
            date: Date(),
            imageURLs: urls,
            caption: caption,
            color: randomColorName
        )
        
        do {
            try db.collection("users").document(uid).collection("trips").document(newTrip.id.uuidString).setData(from: newTrip)
            print("Resa sparad i Firestore med \(urls?.count ?? 0) bilder!")
            
            DispatchQueue.main.async {
                self.trips.insert(newTrip, at: 0)
            }
        } catch {
            print("Fel vid sparning: \(error)")
        }
    }
    
    func fetchTrips() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(uid).collection("trips")
            .order(by: "date", descending: true)
            .getDocuments { snapshot, error in
                if let _ = error { return }
                
                DispatchQueue.main.async {
                    self.trips = snapshot?.documents.compactMap { doc in
                        try? doc.data(as: Trip.self)
                    } ?? []
                }
            }
    }
    
    func deleteTrip(_ trip: Trip) {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            
            if let urls = trip.imageURLs {
                for url in urls {
                    StorageService.shared.deleteImage(urlString: url)
                }
            }

            let docRef = db.collection("users").document(uid).collection("trips").document(trip.id.uuidString)
            
            docRef.delete { error in
                if let error = error {
                    print("Kunde inte radera från Firestore: \(error)")
                } else {
                    print("Resa raderad från Firestore!")
                }
            }
            
            DispatchQueue.main.async {
                self.trips.removeAll { $0.id == trip.id }
            }
        }
}
