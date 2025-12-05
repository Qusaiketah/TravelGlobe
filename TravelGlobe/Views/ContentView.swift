import SwiftUI

struct ContentView: View {
    @StateObject var auth = AuthService.shared
    
    // State to control the sidebar
    @State private var showMenu = false
    @State private var showNewTrip = false
    
    // Temporary state to simulate profile completion
    @State private var hasProfile = false
    
    var body: some View {
        ZStack {
            // 1. Routing Logic
            if auth.userSession == nil {
                LoginView()
            } else if !hasProfile {
                ProfileSetupView()
                    .onTapGesture { hasProfile = true }
            } else {
                // 2. MAIN APP
                ZStack {
                    // A. The 3D Map (Placeholder)
                    Color.black.ignoresSafeArea()
                    VStack {
                        Spacer()
                        Image(systemName: "globe.europe.africa.fill")
                            .resizable().scaledToFit().frame(width: 300)
                            .foregroundColor(.blue.opacity(0.2))
                            .blur(radius: 10)
                        Spacer()
                    }
                    
                    // B. Floating Controls
                    VStack {
                        // --- TOP ROW ---
                        HStack {
                            // 🟢 OPEN MENU BUTTON (Arrow Right)
                            Button(action: {
                                withAnimation(.spring()) { showMenu = true }
                            }) {
                                Image(systemName: "arrow.right") // The Icon you wanted
                                    .font(.title2)
                                    .bold()
                                    .foregroundColor(.white)
                                    .frame(width: 50, height: 50)
                                    .background(.ultraThinMaterial) // Glass Effect
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle().stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                                    .shadow(color: .black.opacity(0.3), radius: 10)
                            }
                            
                            Spacer()
                        }
                        .padding(.top, 60)
                        .padding(.leading, 20)
                        
                        Spacer()
                        
                        // --- BOTTOM ROW ---
                        Button(action: { showNewTrip = true }) {
                            HStack {
                                Image(systemName: "plus")
                                Text("New Trip")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.vertical, 16)
                            .padding(.horizontal, 24)
                            .background(Color.blue)
                            .cornerRadius(30)
                            .shadow(color: .blue.opacity(0.5), radius: 20)
                        }
                        .padding(.bottom, 20)
                    }
                    
                    // C. The Sidebar Overlay
                    if showMenu {
                        SidebarView(isOpen: $showMenu)
                            .transition(.move(edge: .leading))
                            .zIndex(10)
                    }
                }
                .sheet(isPresented: $showNewTrip) {
                    NewTripSheet()
                        .presentationDetents([.fraction(0.6)])
                        .presentationDragIndicator(.visible)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
