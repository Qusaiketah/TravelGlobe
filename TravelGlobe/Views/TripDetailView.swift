import SwiftUI

struct TripDetailView: View {
    let trip: Trip
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    
                    if let urls = trip.imageURLs, !urls.isEmpty {
                        TabView {
                            ForEach(urls, id: \.self) { urlString in
                                AsyncImage(url: URL(string: urlString)) { image in
                                    image.resizable().scaledToFill()
                                } placeholder: {
                                    Rectangle().fill(Color.gray.opacity(0.2)).overlay(ProgressView())
                                }
                            }
                        }
                        .tabViewStyle(PageTabViewStyle())
                        .frame(height: 400)
                        .clipped()
                    } else {
                        Rectangle().fill(trip.uiColor.opacity(0.3)).frame(height: 250)
                            .overlay(Image(systemName: "map.fill").font(.system(size: 60)).foregroundColor(.white))
                    }
                    
                    VStack(alignment: .leading, spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(trip.locationName).font(.title).bold().foregroundColor(.white)
                            HStack {
                                Image(systemName: "calendar")
                                Text(trip.date.formatted(date: .long, time: .shortened))
                            }.foregroundColor(.gray)
                        }
                        
                        Divider().background(Color.white.opacity(0.2))
                        
                        if let caption = trip.caption, !caption.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("MEMORY").font(.caption).bold().foregroundColor(.gray)
                                Text(caption).font(.body).foregroundColor(.white).lineSpacing(4)
                            }
                        }
                    }
                    .padding(24)
                }
            }
            
            VStack {
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 36)).foregroundColor(.white).shadow(radius: 5)
                    }
                    .padding()
                }
                Spacer()
            }
        }
    }
}
