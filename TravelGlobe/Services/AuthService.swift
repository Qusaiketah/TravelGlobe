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

    static let shared = AuthService()
    
    init() {
        self.userSession = Auth.auth().currentUser
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
