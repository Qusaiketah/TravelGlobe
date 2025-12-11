import SwiftUI

struct ProfileSetupView: View {
    @Binding var isComplete: Bool
    @State private var username: String = ""
    @State private var age: Int = 18
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                LinearGradient(
                    colors: [Color.blue.opacity(0.2), Color.clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 300)
                .ignoresSafeArea()
                Spacer()
            }

            VStack(spacing: 30) {
                Spacer()
                
                VStack(spacing: 12) {
                    Text("Welcome to TravelGlobe")
                        .font(.system(size: 32, weight: .regular, design: .serif))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("Set up your profile to begin your journey")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("USERNAME").font(.caption).tracking(1).foregroundColor(.gray).padding(.leading, 4)
                        
                        TextField("Enter your username", text: $username)
                            .padding(.horizontal)
                            .frame(height: 55)
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.1), lineWidth: 1))
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("AGE").font(.caption).tracking(1).foregroundColor(.gray).padding(.leading, 4)
                        
                        HStack {
                            Text("\(age)").font(.body).foregroundColor(.white).padding(.leading, 16)
                            Spacer()
                            HStack(spacing: 0) {
                                Button(action: { if age > 13 { age -= 1 } }) {
                                    Rectangle().fill(Color.clear).frame(width: 50, height: 55)
                                        .overlay(Image(systemName: "minus").foregroundColor(.gray))
                                }
                                Divider().background(Color.white.opacity(0.1)).frame(height: 25)
                                Button(action: { if age < 100 { age += 1 } }) {
                                    Rectangle().fill(Color.clear).frame(width: 50, height: 55)
                                        .overlay(Image(systemName: "plus").foregroundColor(.white))
                                }
                            }
                        }
                        .frame(height: 55)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.1), lineWidth: 1))
                    }
                }
                
                Button(action: {
                    if !username.isEmpty {
                        AuthService.shared.saveProfile(username: username, age: age)
                        withAnimation {
                            isComplete = true
                        }
                    }
                }) {
                    Text("Start Exploring")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 55)
                        .background(username.isEmpty ? Color.gray : Color(red: 0/255, green: 122/255, blue: 255/255))
                        .cornerRadius(30)
                        .shadow(color: Color.blue.opacity(0.5), radius: 20, x: 0, y: 10)
                }
                .disabled(username.isEmpty)
                .padding(.top, 10)
                
                Spacer()
            }
            .padding(.horizontal, 24)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

#Preview {
    ProfileSetupView(isComplete: .constant(false))
}
