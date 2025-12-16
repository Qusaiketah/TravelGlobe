import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import Combine
import GoogleSignIn // 👈 VIKTIGT: Denna måste vara med nu

class AuthService: ObservableObject {

    static let shared = AuthService()
    
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUserProfile: UserProfile?
    @Published var isLoading: Bool = true
    @Published var errorMessage: String? // För att kunna visa fel för användaren
    
    private let db = Firestore.firestore()

    init() {
        self.userSession = Auth.auth().currentUser

        if let uid = userSession?.uid {
            fetchUserProfile(uid: uid)
        } else {
            self.isLoading = false
        }
    }
    
    // MARK: - Google Sign In
    @MainActor
    func signInWithGoogle() {
        isLoading = true
        errorMessage = nil
        
        // 1. Hitta rätt fönster att visa Google-rutan i
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            print("Kunde inte hitta rootViewController")
            self.isLoading = false
            return
        }
        
        // 2. Starta Googles inloggning
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { [weak self] result, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Google Sign-In Error: \(error.localizedDescription)")
                self.isLoading = false
                // Om användaren avbröt själv (t.ex. klickade kryss) är det inget riktigt fel
                return
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                self.isLoading = false
                return
            }
            
            let accessToken = user.accessToken.tokenString
            
            // 3. Skapa bevis (Credential) för Firebase
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: accessToken)
            
            // 4. Logga in i Firebase med beviset
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print("Firebase Sign-In Error: \(error.localizedDescription)")
                    self.errorMessage = "Kunde inte logga in med Google."
                    self.isLoading = false
                    return
                }
                
                print("✅ Inloggad med Google! UID: \(authResult?.user.uid ?? "")")
                self.userSession = authResult?.user
                
                // Hämta eller skapa profil
                if let uid = authResult?.user.uid {
                    self.fetchUserProfile(uid: uid)
                }
            }
        }
    }
    
    // (Behåll din gamla mock-funktion om du vill, men den används inte skarpt sen)
   // func signInMock() {
   //     isLoading = true
    //    Auth.auth().signInAnonymously { result, error in
    //        self.isLoading = false
    //        if let error = error {
    //            print("Fel: \(error.localizedDescription)")
     //           return
     //       }
     //       self.userSession = result?.user
     //       if let uid = result?.user.uid { self.fetchUserProfile(uid: uid) }
      //  }
  //  }
    
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
                    print("Ingen profil hittades i databasen. (Ny användare?)")
                    // Här skulle vi kunna navigera till ProfileSetupView automatiskt
                }
            }
        }
    }
    
    func signOut() {
        GIDSignIn.sharedInstance.signOut() // Logga ut från Google också
        try? Auth.auth().signOut()
        self.userSession = nil
        self.currentUserProfile = nil
        self.isLoading = false
    }
}
