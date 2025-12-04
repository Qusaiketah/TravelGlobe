//
//  LoginView.swift
//  TravelGlobe
//
//  Created by Qusai Ketah on 2025-12-04.
//

import SwiftUI

struct LoginView: View {
    var body: some View {
        ZStack {
            // 1. OLED Black Background
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                // 2. Hero Image (Globe Icon)
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
                
                // 3. Typography
                VStack(spacing: 10) {
                    Text("TravelGlobe")
                        .font(.system(size: 42, weight: .bold, design: .serif))
                        .foregroundColor(.white)
                    
                    Text("Document your journey in 3D")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.bottom, 40)
                
                // 4. Buttons
                VStack(spacing: 15) {
                    // Google Button
                    Button(action: { print("Login with Google") }) {
                        HStack {
                            Image(systemName: "g.circle.fill")
                            Text("Sign in with Google")
                        }
                        .bold()
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 55)
                        .background(Color.white)
                        .cornerRadius(15)
                    }
                    
                    // Apple Button
                    Button(action: { print("Login with Apple") }) {
                        HStack {
                            Image(systemName: "apple.logo")
                            Text("Sign in with Apple")
                        }
                        .bold()
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 55)
                        .background(.ultraThinMaterial) // Glass Effect
                        .cornerRadius(15)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                    }
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

