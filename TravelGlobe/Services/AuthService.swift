import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import Combine

class AuthService: ObservableObject {

    static let shared = AuthService()
    
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUserProfile: UserProfile?
    @Published var isLoading: Bool = true
    
    private let db = Firestore.firestore()

    init() {
        self.userSession = Auth.auth().currentUser

        if let uid = userSession?.uid {
            fetchUserProfile(uid: uid)
        } else {
            self.isLoading = false

        }
    }
    
    func signInMock() {
        isLoading = true
        print("AuthService: Försöker logga in anonymt...")
        
        Auth.auth().signInAnonymously { result, error in
            if let error = error {
                print("Fel: \(error.localizedDescription)")
                self.isLoading = false
                return
            }
            
            print("Inloggad (Anonymt): \(result?.user.uid ?? "")")
            self.userSession = result?.user

            if let uid = result?.user.uid {
                self.fetchUserProfile(uid: uid)
            } else {
                self.isLoading = false
            }
        }
    }
    
    func saveProfile(username: String, age: Int) {
        guard let uid = userSession?.uid else { return }
        
        let profile = UserProfile(username: username, age: age)
        self.currentUserProfile = profile
        
        do {
            try db.collection("users").document(uid).setData(from: profile)
            print("Profil sparad!")
        } catch {
            print("Kunde inte spara profil: \(error)")
        }
    }
    
    func fetchUserProfile(uid: String) {
        print("📥 Hämtar profil från Firestore...")
        db.collection("users").document(uid).getDocument { snapshot, error in
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let snapshot = snapshot, snapshot.exists {
                    do {
                        self.currentUserProfile = try snapshot.data(as: UserProfile.self)
                        print("Profil hittad: \(self.currentUserProfile?.username ?? "")")
                    } catch {
                        print("Kunde inte avkoda profil.")
                    }
                } else {
                    print("Ingen profil hittades i databasen.")
                }
            }
        }
    }
    
    func signOut() {
        try? Auth.auth().signOut()
        self.userSession = nil
        self.currentUserProfile = nil
        self.isLoading = false
    }
}
