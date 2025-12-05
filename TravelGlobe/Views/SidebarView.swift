import SwiftUI

struct SidebarView: View {
    @Binding var isOpen: Bool
    @ObservedObject var auth = AuthService.shared
    
    // User Data (Dynamic)
    let username: String = "Jane Doe"
    let age: Int = 24
    
    // Dummy Trips Data
    let trips = [
        Trip(id: 1, location: "Paris, France", year: "2024", icon: "building.columns.fill", color: .purple),
        Trip(id: 2, location: "Tokyo, Japan", year: "2023", icon: "tram.fill", color: .pink),
        Trip(id: 3, location: "New York, USA", year: "2023", icon: "building.2.fill", color: .blue)
    ]
    
    var body: some View {
        GeometryReader { geometry in
            let sidebarWidth = geometry.size.width * 0.85
            ZStack(alignment: .leading) {
                // 1. Dimmed Background (Tap to close)
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
                    .background(.ultraThinMaterial)
                    .onTapGesture {
                        withAnimation { isOpen = false }
                    }
                
                // 2. The Sidebar Content
                VStack(alignment: .leading, spacing: 0) {
                    
                    // --- TOP BAR (Close Button) ---
                    HStack {
                        Spacer()
                        Button(action: { withAnimation { isOpen = false } }) {
                            Image(systemName: "arrow.left")
                                .font(.title3).bold().foregroundColor(.white)
                                .frame(width: 44, height: 44)
                                .background(Color.white.opacity(0.1))
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white.opacity(0.1), lineWidth: 1))
                        }
                    }
                    .padding(.top, 32)
                    .padding(.trailing, 24)
                    
                    // --- HEADER (Profile) ---
                    VStack(alignment: .leading, spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 80, height: 80)
                                .shadow(color: .blue.opacity(0.3), radius: 10, y: 5)
                            
                            Text(String(username.prefix(2)).uppercased())
                                .font(.title)
                                .bold()
                                .foregroundColor(.white)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(username), \(age)")
                                .font(.title3)
                                .bold()
                                .foregroundColor(.white)
                            
                            Text("Traveler since 2025")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, -8)
                    .padding(.bottom, 16)
                    
                    // --- STATS ROW (THE PART YOU WANTED BACK) ---
                    HStack(spacing: 0) {
                        StatBox(number: "0", label: "Countries") // Set to 0
                        Divider().background(Color.white.opacity(0.1))
                        StatBox(number: "0", label: "Cities")    // Set to 0
                        Divider().background(Color.white.opacity(0.1))
                        StatBox(number: "0", label: "Photos")    // Set to 0
                    }
                    .frame(height: 80)
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
                    .padding(.horizontal, 24)
                    .padding(.bottom, 30)
                    
                    // --- JOURNEYS LIST ---
                    VStack(alignment: .leading, spacing: 15) {
                        Text("YOUR JOURNEYS")
                            .font(.caption)
                            .tracking(2)
                            .foregroundColor(.gray.opacity(0.6))
                            .padding(.horizontal, 24)
                        
                        ScrollView {
                            VStack(spacing: 12) {
                                ForEach(trips) { trip in
                                    Button(action: {
                                        print("Opening trip details for \(trip.location)")
                                    }) {
                                        TripCard(trip: trip)
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                    }
                    
                    Spacer()
                    
                    // --- SIGN OUT ---
                    VStack {
                        Divider().background(Color.white.opacity(0.1))
                        Button(action: { auth.signOut() }) {
                            HStack(spacing: 12) {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                Text("Sign Out")
                            }
                            .font(.headline)
                            .foregroundColor(Color(red: 1.0, green: 0.4, blue: 0.4))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.red.opacity(0.05))
                            .cornerRadius(12)
                        }
                        .padding(24)
                    }
                }
                .frame(width: sidebarWidth)
                .background(Color.black.opacity(0.95))
                .edgesIgnoringSafeArea(.vertical)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// --- SUBVIEWS ---

struct StatBox: View {
    let number: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(number)
                .font(.title3)
                .bold()
                .foregroundColor(.white)
            Text(label)
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
}

struct TripCard: View {
    let trip: Trip
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Color.white.opacity(0.1)
                Image(systemName: trip.icon)
                    .foregroundColor(trip.color)
                    .font(.system(size: 20))
            }
            .frame(width: 56, height: 56)
            .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(trip.location)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white)
                Text(trip.year)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.gray.opacity(0.5))
        }
        .padding(12)
        .background(Color.white.opacity(0.03))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }
}

struct Trip: Identifiable {
    let id: Int
    let location: String
    let year: String
    let icon: String
    let color: Color
}

#Preview {
    SidebarView(isOpen: .constant(true))
}
