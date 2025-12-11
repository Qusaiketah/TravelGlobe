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
                } else {
                    self?.username = "Explorer"
                }
            }
            .store(in: &cancellables)
    }
    
    func signOut() {
        AuthService.shared.signOut()
    }
}
