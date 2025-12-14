import SwiftUI

struct ProfileSetupView: View {
    @State private var name: String = ""
    @State private var age: String = ""
    @State private var showError = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 30) {
                VStack(spacing: 10) {
                    Image(systemName: "person.crop.circle.badge.plus")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                        .padding(.bottom, 10)
                    
                    Text("Welcome Explorer!")
                        .font(.largeTitle).bold()
                        .foregroundColor(.white)
                    
                    Text("Set up your profile to start tracking your journeys.")
                        .font(.body)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 50)

                VStack(spacing: 20) {
                    TextField("Username", text: $name)
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(0.2), lineWidth: 1))
                    
                    TextField("Age", text: $age)
                        .keyboardType(.numberPad)
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(0.2), lineWidth: 1))
                }
                .padding(.horizontal, 30)
                
                if showError {
                    Text("Please enter both name and age.")
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                Spacer()

                Button(action: saveProfile) {
                    HStack {
                        Text("Start Exploring")
                            .font(.headline)
                        Image(systemName: "arrow.right")
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isValid ? Color.blue : Color.gray.opacity(0.3))
                    .cornerRadius(15)
                }
                .disabled(!isValid)
                .padding(.horizontal, 30)
                .padding(.bottom, 50)
            }
        }
    }
    
    var isValid: Bool {
        !name.isEmpty && !age.isEmpty
    }
    
    func saveProfile() {
        guard let ageInt = Int(age), !name.isEmpty else {
            showError = true
            return
        }
        
        AuthService.shared.saveProfile(username: name, age: ageInt)

    }
}

#Preview {
    ProfileSetupView()
}
