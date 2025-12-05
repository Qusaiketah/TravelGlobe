import SwiftUI
import MapKit

struct GlobeView: View {
    @State private var position: MapCameraPosition = .camera(
        MapCamera(
            centerCoordinate: CLLocationCoordinate2D(latitude: 48.8566, longitude: 2.3522),
            distance: 4_000_000,
            heading: 0,
            pitch: 0
        )
    )
    
    // Track movement
    @State private var currentCenter = CLLocationCoordinate2D(latitude: 48.8566, longitude: 2.3522)
    @State private var currentDistance: Double = 4_000_000
    
    // Search
    @State private var searchText: String = ""
    @State private var isSearching: Bool = false
    @State private var errorMessage: String?
    
    var body: some View {
        ZStack(alignment: .top) {
            
            Map(position: $position)
                .mapStyle(.hybrid(elevation: .realistic))
                .onMapCameraChange(frequency: .continuous) { context in
                    self.currentCenter = context.camera.centerCoordinate
                    self.currentDistance = context.camera.distance
                }
                .ignoresSafeArea()
            
            VStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search City...", text: $searchText)
                        .foregroundColor(.white)
                        .onSubmit { performSearch() }
                        .submitLabel(.search)
                    
                    if isSearching {
                        ProgressView().tint(.white)
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .background(Color.black.opacity(0.4))
                .clipShape(Capsule())
                .overlay(
                    Capsule().stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(8)
                        .background(Color.black.opacity(0.8))
                        .cornerRadius(8)
                }
                
                Spacer()
            }
            
            VStack {
                Spacer()
                
                HStack {
                    Spacer()

                    VStack(spacing: 0) {
                        Button(action: zoomIn) {
                            Image(systemName: "plus")
                                .font(.title2)
                                .frame(width: 50, height: 50)
                                .foregroundColor(.white)
                                .contentShape(Rectangle())
                        }
                        
                        Divider()
                            .background(Color.white.opacity(0.3))
                            .frame(width: 30)
                        
                        Button(action: zoomOut) {
                            Image(systemName: "minus")
                                .font(.title2)
                                .frame(width: 50, height: 50)
                                .foregroundColor(.white)
                                .contentShape(Rectangle())
                        }
                    }
                    .background(.ultraThinMaterial)
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(15)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                    .padding(.trailing, 20)
                    .padding(.bottom, 40)
                }
            }
        }
    }
    
    
    func zoomIn() {
        withAnimation {
            let newDistance = max(1000, currentDistance * 0.5)
            position = .camera(MapCamera(centerCoordinate: currentCenter, distance: newDistance, heading: 0, pitch: 45))
        }
    }
    
    func zoomOut() {
        withAnimation {
            let newDistance = currentDistance * 2.0
            position = .camera(MapCamera(centerCoordinate: currentCenter, distance: newDistance, heading: 0, pitch: 0))
        }
    }
    
    func performSearch() {
        guard !searchText.isEmpty else { return }
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        
        isSearching = true
        errorMessage = nil
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(searchText) { placemarks, error in
            isSearching = false
            if let place = placemarks?.first, let location = place.location {
                withAnimation(.easeInOut(duration: 2.0)) {
                    position = .camera(MapCamera(
                        centerCoordinate: location.coordinate,
                        distance: 4_000_000, 
                        heading: 0,
                        pitch: 0
                    ))
                }
            } else {
                errorMessage = "Location not found"
            }
        }
    }
}

#Preview {
    GlobeView()
}
