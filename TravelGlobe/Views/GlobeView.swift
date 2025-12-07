import SwiftUI
import MapKit
import Combine
import CoreLocation

struct MemoryPin: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let title: String
}

struct GlobeView: View {
    @Binding var showSidebar: Bool
    @Binding var showNewTrip: Bool
    @State private var position: MapCameraPosition = .camera(
        MapCamera(
            centerCoordinate: CLLocationCoordinate2D(latitude: 48.8566, longitude: 2.3522),
            distance: 4_000_000,
            heading: 0,
            pitch: 0
        )
    )
    
    @State private var currentCenter = CLLocationCoordinate2D(latitude: 48.8566, longitude: 2.3522)
    @State private var currentDistance: Double = 4_000_000
    @StateObject private var searchVM = SearchViewModel()
    @StateObject private var locationManager = LocationManager()
    @State private var isSearching: Bool = false
    @State private var errorMessage: String?
    @FocusState private var isFocused: Bool
    
    let memoryPins = [
        MemoryPin(coordinate: CLLocationCoordinate2D(latitude: 48.8566, longitude: 2.3522), title: "Paris")
    ]
    
    var body: some View {
        ZStack(alignment: .top) {
            
            Map(position: $position) {
                ForEach(memoryPins) { pin in
                    Annotation(pin.title, coordinate: pin.coordinate) {
                        ZStack {
                            Circle().fill(.black).frame(width: 40, height: 40).shadow(radius: 5)
                            Image(systemName: "photo.fill").foregroundColor(.white).font(.caption)
                        }
                        .overlay(Circle().stroke(Color.blue, lineWidth: 2))
                    }
                }
            }
            .mapStyle(.hybrid(elevation: .realistic))
            .onMapCameraChange(frequency: .continuous) { context in
                self.currentCenter = context.camera.centerCoordinate
                self.currentDistance = context.camera.distance
            }
            .ignoresSafeArea()
            .onTapGesture { isFocused = false }
            .onReceive(locationManager.$userLocation) { newLocation in
                if let location = newLocation {
                    withAnimation(.easeInOut(duration: 2.0)) {
                        position = .camera(MapCamera(centerCoordinate: location, distance: 10_000, heading: 0, pitch: 60))
                    }
                }
            }
            
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    
                    Button(action: { withAnimation { showSidebar = true } }) {
                        Image(systemName: "line.3.horizontal")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 50, height: 50)
                            .background(.ultraThinMaterial)
                            .background(Color.black.opacity(0.4))
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white.opacity(0.2), lineWidth: 1))
                    }
                    
                    HStack {
                        Image(systemName: "magnifyingglass").foregroundColor(.gray)
                        TextField("Search...", text: $searchVM.query)
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
                    .padding(12)
                    .background(.ultraThinMaterial)
                    .background(Color.black.opacity(0.4))
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Color.white.opacity(0.2), lineWidth: 1))
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
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
                    .padding(.horizontal, 80)
                    .padding(.top, 10)
                }
                
                Spacer()
            }
            
            VStack {
                Spacer()
                HStack(alignment: .bottom) {
                    
                    Button(action: { showNewTrip = true }) {
                        HStack {
                            Image(systemName: "plus")
                            Text("New Trip")
                        }
                        .bold()
                        .foregroundColor(.white)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 20)
                        .background(Color.blue)
                        .clipShape(Capsule())
                        .shadow(color: .blue.opacity(0.4), radius: 10, y: 5)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 12) {
                        Button(action: {
                            locationManager.requestLocation()
                        }) {
                            Image(systemName: "location.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                                .background(.ultraThinMaterial)
                                .background(Color.black.opacity(0.5))
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white.opacity(0.2), lineWidth: 1))
                        }
                        
                        VStack(spacing: 0) {
                            Button(action: zoomIn) { Image(systemName: "plus").font(.title2).frame(width: 50, height: 50).foregroundColor(.white).contentShape(Rectangle()) }
                            Divider().background(Color.white.opacity(0.3)).frame(width: 30)
                            Button(action: zoomOut) { Image(systemName: "minus").font(.title2).frame(width: 50, height: 50).foregroundColor(.white).contentShape(Rectangle()) }
                        }
                        .background(.ultraThinMaterial).background(Color.black.opacity(0.5)).cornerRadius(15)
                        .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.white.opacity(0.2), lineWidth: 1))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
    }
    
    // FUNKTIONER
    func zoomIn() { withAnimation { position = .camera(MapCamera(centerCoordinate: currentCenter, distance: max(1000, currentDistance * 0.5), heading: 0, pitch: 45)) } }
    func zoomOut() { withAnimation { position = .camera(MapCamera(centerCoordinate: currentCenter, distance: currentDistance * 2.0, heading: 0, pitch: 0)) } }
    
    func performSearch(query: String) {
        guard !query.isEmpty else { return }
        isSearching = true; isFocused = false
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        MKLocalSearch(request: request).start { response, error in
            isSearching = false
            if let item = response?.mapItems.first {
                let coordinate = item.placemark.coordinate
                let distance: CLLocationDistance = (item.placemark.region as? CLCircularRegion).map { max(80_000, min(300_000, $0.radius * 6.0)) } ?? 150_000
                withAnimation(.easeInOut(duration: 2.0)) {
                    position = .camera(MapCamera(centerCoordinate: coordinate, distance: max(1000, distance / 4.0), heading: 0, pitch: 60))
                }
            }
        }
    }
}

// KLASSER
class SearchViewModel: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    @Published var query: String = "" { didSet { completer.queryFragment = query } }
    @Published var suggestions: [MKLocalSearchCompletion] = []
    private let completer = MKLocalSearchCompleter()
    override init() { super.init(); completer.delegate = self; completer.resultTypes = .pointOfInterest }
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) { self.suggestions = completer.results.filter { !$0.title.isEmpty } }
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
        manager.stopUpdatingLocation()
        manager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        DispatchQueue.main.async {
            self.userLocation = location.coordinate
        }
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
    GlobeView(
        showSidebar: .constant(false),
        showNewTrip: .constant(false)
    )
}
