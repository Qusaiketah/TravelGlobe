import SwiftUI
import AuthenticationServices

struct LoginView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.2))
                        .blur(radius: 50)
                        .frame(width: 200, height: 200)
                    
                    Image(systemName: "globe.europe.africa.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 140)
                        .foregroundColor(.white)
                        .shadow(color: .blue, radius: 20)
                }
                
                VStack(spacing: 10) {
                    Text("TravelGlobe")
                        .font(.system(size: 42, weight: .bold, design: .serif))
                        .foregroundColor(.white)
                    
                    Text("Document your journey in 3D")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.bottom, 40)
                
                VStack(spacing: 15) {
                    Button(action: {
                        AuthService.shared.signInWithGoogle()
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "g.circle.fill")
                                .font(.system(size: 17))
                            
                            Text("Sign in with Google")
                                .font(.system(size: 20, weight: .semibold))
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 55)
                        .background(Color.white)
                        .cornerRadius(15)
                    }
                    
                    SignInWithAppleButton(
                        onRequest: { request in
                            let nonce = AuthService.shared.randomNonceString()
                            AuthService.shared.currentNonce = nonce
                            request.requestedScopes = [.fullName, .email]
                            request.nonce = AuthService.shared.sha256(nonce)
                        },
                        onCompletion: { result in
                            switch result {
                            case .success(let authResults):
                                switch authResults.credential {
                                case let appleIDCredential as ASAuthorizationAppleIDCredential:
                                    guard let nonce = AuthService.shared.currentNonce else { return }
                                    AuthService.shared.signInWithApple(credential: appleIDCredential, nonce: nonce)
                                default:
                                    break
                                }
                            case .failure(let error):
                                print("Apple Sign-In failed: \(error.localizedDescription)")
                            }
                        }
                    )
                    .signInWithAppleButtonStyle(.white)
                    .frame(height: 55)
                    .cornerRadius(15)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                }
                .padding(.horizontal, 30)
                
                Spacer()
            }
        }
    }
}

#Preview {
    LoginView()
}
