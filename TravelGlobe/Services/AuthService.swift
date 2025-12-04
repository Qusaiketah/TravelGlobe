//
//  AuthService.swift
//  TravelGlobe
//
//  Created by Qusai Ketah on 2025-12-04.
//

import Foundation
import SwiftUI
import FirebaseAuth
import Combine

class AuthService: ObservableObject {

    @Published var userSession: FirebaseAuth.User?

    static let shared = AuthService()
    
    init() {
        self.userSession = Auth.auth().currentUser
    }
    
    // I will fill this with real Google/Apple logic later
    func signInWithGoogle() {
        print("AuthService: Starting Google Sign In...")
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.userSession = nil
            print("AuthService: Signed out successfully")
        } catch {
            print("AuthService: Error signing out: \(error.localizedDescription)")
        }
    }
}
