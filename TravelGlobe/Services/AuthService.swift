//
//  AuthService.swift
//  TravelGlobe
//
//  Created by Qusai Ketah on 2025-12-04.
//

import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import Combine

class AuthService: ObservableObject {

    @Published var userSession: FirebaseAuth.User?
    @Published var isMockLoggedIn = false
    @Published var currentUserProfile: UserProfile?
    private let db = Firestore.firestore()

    static let shared = AuthService()
    
    init() {
        self.userSession = Auth.auth().currentUser
        if let uid = userSession?.uid {
        fetchUserProfile(uid: uid) 
                }
    }
    
    func saveProfile(username: String, age: Int) {
            guard let uid = userSession?.uid else { return }
            
            let profile = UserProfile(username: username, age: age)
            self.currentUserProfile = profile
            do {
                try db.collection("users").document(uid).setData(from: profile)
                print("Profil sparad i Firestore!")
            } catch {
                print("Fel vid sparning av profil: \(error)")
            }
        }
    
    func fetchUserProfile(uid: String) {
            db.collection("users").document(uid).getDocument { snapshot, error in
                if let error = error {
                    print("Kunde inte hämta profil: \(error)")
                    return
                }
                if let snapshot = snapshot, snapshot.exists {
                    do {
                        self.currentUserProfile = try snapshot.data(as: UserProfile.self)
                    } catch {
                        print("Fel vid avkodning av profil")
                    }
                }
            }
        }
    
    func signInMock() {
            print("AuthService: Försöker logga in anonymt...")
            
            Auth.auth().signInAnonymously { result, error in
                if let error = error {
                    print("Misslyckades med anonym inloggning: \(error.localizedDescription)")
                    return
                }
                
                print("Anonym inloggning lyckades! User ID: \(result?.user.uid ?? "N/A")")
                
                DispatchQueue.main.async {
                    self.userSession = result?.user
                    withAnimation {
                        self.isMockLoggedIn = true
                    }
                }
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
