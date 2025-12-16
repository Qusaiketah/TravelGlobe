import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseCore
import Combine
import GoogleSignIn
import AuthenticationServices
import CryptoKit

class AuthService: ObservableObject {

    static let shared = AuthService()
    
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUserProfile: UserProfile?
    @Published var isLoading: Bool = true
    @Published var errorMessage: String?
    
    var currentNonce: String?
    
    private let db = Firestore.firestore()

    init() {
        self.userSession = Auth.auth().currentUser

        if let uid = userSession?.uid {
            fetchUserProfile(uid: uid)
        } else {
            self.isLoading = false
        }
    }
    
    @MainActor
    func signInWithGoogle() {
        isLoading = true
        errorMessage = nil
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            self.isLoading = false
            return
        }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { [weak self] result, error in
            guard let self = self else { return }
            
            if let error = error {
                self.isLoading = false
                return
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                self.isLoading = false
                return
            }
            
            let accessToken = user.accessToken.tokenString
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
            
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                    return
                }
                
                self.userSession = authResult?.user
                if let uid = authResult?.user.uid {
                    self.fetchUserProfile(uid: uid)
                }
            }
        }
    }

    func signInWithApple(credential: ASAuthorizationAppleIDCredential, nonce: String) {
        isLoading = true
        errorMessage = nil
        
        guard let idTokenData = credential.identityToken,
              let idTokenString = String(data: idTokenData, encoding: .utf8) else {
            isLoading = false
            return
        }
        
        let firebaseCredential = OAuthProvider.credential(
                   providerID: .apple,
                   idToken: idTokenString,
                   rawNonce: nonce,
                   accessToken: nil
               )
        
        Auth.auth().signIn(with: firebaseCredential) { [weak self] authResult, error in
            guard let self = self else { return }
            
            if let error = error {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
                return
            }
            
            self.userSession = authResult?.user
            
            if let fullName = credential.fullName {
                let formatter = PersonNameComponentsFormatter()
                let username = formatter.string(from: fullName).isEmpty ? "Explorer" : formatter.string(from: fullName)
                
                if let uid = authResult?.user.uid {
                    self.saveProfile(username: username, age: 0)
                }
            } else if let uid = authResult?.user.uid {
                self.fetchUserProfile(uid: uid)
            }
        }
    }
    
    func saveProfile(username: String, age: Int) {
        guard let uid = userSession?.uid else { return }
        let profile = UserProfile(username: username, age: age)
        self.currentUserProfile = profile
        try? db.collection("users").document(uid).setData(from: profile)
    }
    
    func fetchUserProfile(uid: String) {
        db.collection("users").document(uid).getDocument { snapshot, error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let snapshot = snapshot, snapshot.exists {
                    self.currentUserProfile = try? snapshot.data(as: UserProfile.self)
                }
            }
        }
    }
    
    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        try? Auth.auth().signOut()
        self.userSession = nil
        self.currentUserProfile = nil
        self.isLoading = false
    }

    func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }

            randoms.forEach { random in
                if remainingLength == 0 { return }
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        return result
    }

    func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()

        return hashString
    }
}
