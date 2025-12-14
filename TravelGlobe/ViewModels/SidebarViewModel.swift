//
//  SidebarViewModel.swift
//  TravelGlobe
//
//  Created by Qusai Ketah on 2025-12-08.
//

import SwiftUI
import Combine

class SidebarViewModel: ObservableObject {
    @Published var username: String = "Explorer"
    @Published var age: Int = 0
    @Published var trips: [Trip] = []
    
    private var cancellables = Set<AnyCancellable>()
    var tripCount: Int { trips.count }

    var cityCount: Int {
        let uniqueLocations = Set(trips.map { $0.locationName })
        return uniqueLocations.count
    }
    
    var photoCount: Int {
            trips.reduce(0) { $0 + ($1.imageURLs?.count ?? 0) }
        }
    
    var hasTrips: Bool { !trips.isEmpty }
    
    var recentTrips: [Trip] {
        Array(trips.prefix(3))
    }
    
    var showViewAllButton: Bool {
        trips.count > 3
    }
    
    init() {
        TripService.shared.$trips
            .receive(on: DispatchQueue.main)
            .assign(to: \.trips, on: self)
            .store(in: &cancellables)
        
        AuthService.shared.$currentUserProfile
            .receive(on: DispatchQueue.main)
            .sink { [weak self] profile in
                if let profile = profile {
                    self?.username = profile.username
                    self?.age = profile.age
                }
            }
            .store(in: &cancellables)
    }
    
    func signOut() {
        AuthService.shared.signOut()
    }
    
        
    func deleteTrip(_ trip: Trip) {
            TripService.shared.deleteTrip(trip)
        }
}
