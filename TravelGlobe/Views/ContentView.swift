import SwiftUI

struct ContentView: View {
    @StateObject private var authService = AuthService.shared
    @State private var showSidebar = false
    @State private var showNewTrip = false
    
    var body: some View {
        Group {
            if authService.isLoading {
                ZStack {
                    Color.black.ignoresSafeArea()
                    VStack(spacing: 20) {
                        ProgressView()
                            .tint(.white)
                            .scaleEffect(1.5)
                        Text("Loading your world...")
                            .foregroundColor(.gray)
                            .font(.caption)
                    }
                }
            }
            else if authService.userSession == nil {
                LoginView()
            }
            else if authService.currentUserProfile == nil {
                ProfileSetupView()
            }
            else {
                ZStack(alignment: .leading) {
                    GlobeView(showSidebar: $showSidebar, showNewTrip: $showNewTrip)
                        .sheet(isPresented: $showNewTrip) {
                            NewMemoryView()
                        }
                    
                    if showSidebar {
                        SidebarView(isOpen: $showSidebar)
                            .transition(.move(edge: .leading))
                            .zIndex(2)
                    }
                }
            }
        }
        .animation(.easeInOut, value: authService.isLoading)
    }
}

#Preview {
    ContentView()
}
