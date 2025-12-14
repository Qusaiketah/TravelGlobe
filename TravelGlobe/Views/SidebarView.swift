import SwiftUI

struct SidebarView: View {
    @Binding var isOpen: Bool
    @StateObject private var viewModel = SidebarViewModel()
    
    @State private var showAllJourneys = false
    @State private var selectedTrip: Trip?
    
    var body: some View {
        ZStack(alignment: .leading) {
            Color.black.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .center) {
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 80, height: 80)
                                .shadow(color: .blue.opacity(0.3), radius: 10, y: 5)
                            
                            Text(String(viewModel.username.prefix(2)).uppercased())
                                .font(.title2).bold().foregroundColor(.white)
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text(viewModel.username).font(.title3).bold().foregroundColor(.white)
                            Text("\(viewModel.age)").font(.subheadline).foregroundColor(.gray)
                        }
                    }
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
                .padding(.top, 10).padding(.horizontal, 24)
                
                
                HStack(spacing: 0) {
                    StatBox(number: "\(viewModel.photoCount)", label: "Photos")
                    Divider().background(Color.white.opacity(0.1))
                    StatBox(number: "\(viewModel.cityCount)", label: "Cities")
                    Divider().background(Color.white.opacity(0.1))
                    StatBox(number: "\(viewModel.tripCount)", label: "Trips")
                }
                .frame(height: 75)
                .background(Color.white.opacity(0.05))
                .cornerRadius(16)
                .padding(.horizontal, 12).padding(.top, 70).padding(.bottom, 15)
                
                Text("YOUR JOURNEYS")
                    .font(.caption).tracking(2)
                    .foregroundColor(.gray.opacity(0.6))
                    .padding(.horizontal, 19)
                    .padding(.bottom, 10)

                List {
                    if !viewModel.hasTrips {
                        Text("No trips yet...")
                            .foregroundColor(.gray)
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                    } else {
                        ForEach(viewModel.recentTrips) { trip in
                            Button(action: { selectedTrip = trip }) {
                                TripCard(trip: trip)
                            }
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 6, leading: 24, bottom: 6, trailing: 24))
                            
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    withAnimation {
                                        viewModel.deleteTrip(trip)
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                
                Spacer()
                
                VStack {
                    Divider().background(Color.white.opacity(0.1))
                    Button(action: { viewModel.signOut() }) {
                        HStack(spacing: 12) {
                            Image(systemName: "rectangle.portrait.and.arrow.right"); Text("Sign Out")
                        }
                        .font(.headline).foregroundColor(Color.red.opacity(0.9))
                        .frame(maxWidth: .infinity).padding(.vertical, 16)
                        .background(Color.red.opacity(0.1)).cornerRadius(12)
                    }
                    .padding(24).padding(.bottom, 20)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color.black)
        .fullScreenCover(isPresented: $showAllJourneys) {
            AllJourneysView(trips: viewModel.trips)
        }
        .sheet(item: $selectedTrip) { trip in
            TripDetailView(trip: trip)
        }
    }
}

struct TripCard: View {
    let trip: Trip
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Color.white.opacity(0.1)
                if let firstUrl = trip.imageURLs?.first, let url = URL(string: firstUrl) {
                    AsyncImage(url: url) { i in i.resizable().scaledToFill() } placeholder: { ProgressView().scaleEffect(0.5) }
                } else {
                    Image(systemName: trip.icon).foregroundColor(trip.uiColor).font(.system(size: 20))
                }
            }
            .frame(width: 60, height: 60).clipShape(RoundedRectangle(cornerRadius: 12))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(trip.locationName).font(.system(size: 15, weight: .medium)).foregroundColor(.white).lineLimit(1)
                Text(trip.date.formatted(date: .abbreviated, time: .omitted)).font(.caption).foregroundColor(.gray)
            }
            Spacer()
            Image(systemName: "chevron.right").font(.caption).foregroundColor(.gray.opacity(0.5))
        }
        .padding(12).background(Color.white.opacity(0.05)).cornerRadius(16).overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.1), lineWidth: 1))
    }
}

struct StatBox: View {
    let number: String; let label: String
    var body: some View { VStack(spacing: 2) { Text(number).font(.headline).bold().foregroundColor(.white); Text(label).font(.caption).foregroundColor(.gray) }.frame(maxWidth: .infinity) }
}


#Preview {
    SidebarView(isOpen: .constant(true))
}
