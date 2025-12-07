import SwiftUI

struct ContentView: View {
    @StateObject var auth = AuthService.shared
    @State private var showMenu = false
    @State private var showNewTrip = false
    @State private var hasProfile = false
    
    var body: some View {
        ZStack {
            if auth.userSession == nil && !auth.isMockLoggedIn {
                LoginView()
            } else if !hasProfile {
                ProfileSetupView(isComplete: $hasProfile)
            } else {
                

                ZStack {
                    GlobeView(showSidebar: $showMenu, showNewTrip: $showNewTrip)
                    
                    if showMenu {
                        SidebarView(isOpen: $showMenu)
                            .zIndex(2)
                            .transition(.move(edge: .leading))
                    }
                }
                .sheet(isPresented: $showNewTrip) {
                    NewMemoryView()
                        .presentationDetents([.large])
                        .presentationDragIndicator(.visible)
                }
                .onChange(of: showMenu) { newValue in
                    print("ShowMenu ändrades till: \(newValue)")
                }
                .onChange(of: showNewTrip) { newValue in
                    print("ShowNewTrip ändrades till: \(newValue)")
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
