//
//  SidebarViewModel.swift
//  TravelGlobe
//
//  Created by Qusai Ketah on 2025-12-08.
//

import SwiftUI
import Combine

class SidebarViewModel: ObservableObject {
    @Published var username: String = "Jane Doe"
    @Published var age: Int = 24
    
    @Published var trips: [Trip] = [
        Trip(id: 1, location: "Paris, France", year: "2024", icon: "building.columns.fill", color: .purple),
        Trip(id: 2, location: "Tokyo, Japan", year: "2023", icon: "tram.fill", color: .pink),
        Trip(id: 3, location: "New York, USA", year: "2023", icon: "building.2.fill", color: .blue)
    ]
    
    func signOut() {
        AuthService.shared.signOut()
    }
}
