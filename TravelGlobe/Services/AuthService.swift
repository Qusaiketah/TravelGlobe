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
    @Published var isMockLoggedIn = false
    @Published var currentUserProfile: UserProfile?

    static let shared = AuthService()
    
    init() {
        self.userSession = Auth.auth().currentUser
    }
    
    func saveProfile(username: String, age: Int) {
            self.currentUserProfile = UserProfile(username: username, age: age)
            print("✅ AuthService: Profil sparad: \(username), \(age)")
        }
    
    func signInMock() {
        print("AuthService: Fake signing in...")
        withAnimation {
            self.isMockLoggedIn = true
        }
    }
    
    func signInWithGoogle() {
        print("AuthService: Starting Google Sign In...")
        signInMock()
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.userSession = nil
            withAnimation {
                self.isMockLoggedIn = false
            }
            print("AuthService: Signed out successfully")
        } catch {
            print("AuthService: Error signing out: \(error.localizedDescription)")
        }
    }
}
