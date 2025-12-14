import SwiftUI

struct AllJourneysView: View {
    @Environment(\.dismiss) var dismiss
    let trips: [Trip]
    @State private var selectedTrip: Trip?
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(alignment: .leading) {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "arrow.left.circle.fill")
                            .font(.title).foregroundColor(.white)
                    }
                    Text("All Journeys").font(.title2).bold().foregroundColor(.white)
                    Spacer()
                }
                .padding()
                
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(trips) { trip in
                            Button(action: { selectedTrip = trip }) {
                                TripCard(trip: trip) 
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .sheet(item: $selectedTrip) { trip in
            TripDetailView(trip: trip)
        }
    }
}
