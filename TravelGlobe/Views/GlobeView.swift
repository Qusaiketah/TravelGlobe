import SwiftUI
import MapKit
import Combine
import CoreLocation

struct GlobeView: View {
    // 1. Kamera
    @State private var position: MapCameraPosition = .camera(
        MapCamera(
            centerCoordinate: CLLocationCoordinate2D(latitude: 48.8566, longitude: 2.3522),
            distance: 4_000_000,
            heading: 0,
            pitch: 0
        )
    )
    
    // Spåra rörelser
    @State private var currentCenter = CLLocationCoordinate2D(latitude: 48.8566, longitude: 2.3522)
    @State private var currentDistance: Double = 4_000_000
    
    // 2. Managers
    @StateObject private var searchVM = SearchViewModel()
    @StateObject private var locationManager = LocationManager()
    
    @State private var isSearching: Bool = false
    @State private var errorMessage: String?
    @FocusState private var isFocused: Bool
    
    var body: some View {
        ZStack(alignment: .top) {
            
            // LAGER 1: KARTA
            Map(position: $position)
                .mapStyle(.hybrid(elevation: .realistic))
                .onMapCameraChange(frequency: .continuous) { context in
                    self.currentCenter = context.camera.centerCoordinate
                    self.currentDistance = context.camera.distance
                }
                .ignoresSafeArea()
                .onTapGesture { isFocused = false }
                .onChange(of: locationManager.userLocation) { newLocation in
                    if let location = newLocation {
                        withAnimation(.easeInOut(duration: 2.0)) {
                            position = .camera(MapCamera(
                                centerCoordinate: location,
                                distance: 10_000,
                                heading: 0,
                                pitch: 60
                            ))
                        }
                    }
                }
            
            // --- LAGER 2: SÖKFÄLT (TOPPEN) ---
            VStack(spacing: 0) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Sök stad...", text: $searchVM.query)
                        .foregroundColor(.white)
                        .focused($isFocused)
                        .onSubmit { performSearch(query: searchVM.query) }
                        .submitLabel(.search)
                    
                    if isSearching { ProgressView().tint(.white) }
                    
                    if !searchVM.query.isEmpty {
                        Button(action: { searchVM.query = "" }) {
                            Image(systemName: "xmark.circle.fill").foregroundColor(.gray)
                        }
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .background(Color.black.opacity(0.4))
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Color.white.opacity(0.2), lineWidth: 1))
                .padding(.horizontal, 20)
                .padding(.top, 20)
                

                if !searchVM.suggestions.isEmpty && isFocused {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            ForEach(searchVM.suggestions, id: \.self) { suggestion in
                                Button(action: {
                                    let fullText = suggestion.title + " " + suggestion.subtitle
                                    searchVM.query = fullText
                                    performSearch(query: fullText)
                                    isFocused = false
                                }) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(suggestion.title).foregroundColor(.white)
                                        if !suggestion.subtitle.isEmpty {
                                            Text(suggestion.subtitle).foregroundColor(.gray).font(.caption)
                                        }
                                    }
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 20)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                if suggestion != searchVM.suggestions.last {
                                    Divider().background(Color.white.opacity(0.1)).padding(.horizontal, 20)
                                }
                            }
                        }
                    }
                    .background(.ultraThinMaterial)
                    .background(Color.black.opacity(0.8))
                    .cornerRadius(15)
                    .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.white.opacity(0.2), lineWidth: 1))
                    .frame(maxHeight: 250)
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                }
                
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(8)
                        .background(Color.black.opacity(0.8))
                        .cornerRadius(8)
                        .padding(.top, 10)
                }
                
                Spacer()
            }
            

            VStack {
                Spacer()
                HStack {
                    Spacer()

                    VStack(spacing: 12) {

                        Button(action: {
                            locationManager.requestLocation()
                            if let userLoc = locationManager.userLocation {
                                withAnimation(.easeInOut(duration: 2.0)) {
                                    position = .camera(MapCamera(
                                        centerCoordinate: userLoc,
                                        distance: 10_000,
                                        heading: 0,
                                        pitch: 60
                                    ))
                                }
                            }
                        }) {
                            Image(systemName: "location.fill")
                                .font(.title2)
                                .frame(width: 50, height: 50)
                                .foregroundColor(.white)
                                .background(.ultraThinMaterial)
                                .background(Color.black.opacity(0.5))
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white.opacity(0.2), lineWidth: 1))
                        }

                        // 2. Zoomreglage (Underst)
                        VStack(spacing: 0) {
                            Button(action: zoomIn) {
                                Image(systemName: "plus")
                                    .font(.title2)
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(.white)
                                    .contentShape(Rectangle())
                            }
                            Divider().background(Color.white.opacity(0.3)).frame(width: 30)
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
                        .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.white.opacity(0.2), lineWidth: 1))
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 40)
                }
            }
        }
    }
    
    // --- FUNKTIONER ---
    
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
    
    func performSearch(query: String) {
        guard !query.isEmpty else { return }
        isSearching = true
        errorMessage = nil
        isFocused = false
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            isSearching = false
            
            guard error == nil,
                  let item = response?.mapItems.first,
                  let boundingRegion = response?.boundingRegion else {
                errorMessage = "Platsen hittades inte"
                return
            }
            
            let coordinate = item.placemark.coordinate
            
            let metersPerLat = 111_000.0
            let metersPerLon = cos(coordinate.latitude * .pi / 180) * 111_000.0
            let widthMeters = boundingRegion.span.longitudeDelta * metersPerLon
            let heightMeters = boundingRegion.span.latitudeDelta * metersPerLat
            let regionSize = max(widthMeters, heightMeters)
            let targetDistance = regionSize * 2.5
            let clampedDistance = max(800, min(targetDistance, 50_000_000))
            
            withAnimation(.easeInOut(duration: 2.0)) {
                position = .camera(MapCamera(
                    centerCoordinate: coordinate,
                    distance: clampedDistance,
                    heading: 0,
                    pitch: 60
                ))
            }
        }
    }
}


class SearchViewModel: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    @Published var query: String = "" {
        didSet { completer.queryFragment = query }
    }
    @Published var suggestions: [MKLocalSearchCompletion] = []
    private let completer = MKLocalSearchCompleter()
    
    override init() {
        super.init()
        completer.delegate = self
        completer.resultTypes = .pointOfInterest
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        self.suggestions = completer.results.filter { !$0.title.isEmpty }
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {}
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var userLocation: CLLocationCoordinate2D?
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    func requestLocation() {
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        DispatchQueue.main.async {
            self.userLocation = location.coordinate
        }
        manager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("GPS Error: \(error.localizedDescription)")
    }
}


extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

#Preview {
    GlobeView()
}
