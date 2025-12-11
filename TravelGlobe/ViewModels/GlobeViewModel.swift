import SwiftUI
import MapKit
import Combine
import CoreLocation

class GlobeViewModel: NSObject, ObservableObject, MKLocalSearchCompleterDelegate, CLLocationManagerDelegate {
    @Published var position: MapCameraPosition = .camera(MapCamera(centerCoordinate: CLLocationCoordinate2D(latitude: 48.8566, longitude: 2.3522), distance: 4_000_000, heading: 0, pitch: 0))
    
    @Published var searchQuery: String = "" { didSet { searchCompleter.queryFragment = searchQuery } }
    @Published var searchSuggestions: [MKLocalSearchCompletion] = []
    @Published var isSearching: Bool = false
    @Published var errorMessage: String?
    @Published var memoryPins: [Trip] = []
    
    private var cancellables = Set<AnyCancellable>()
    private let searchCompleter = MKLocalSearchCompleter()
    private let locationManager = CLLocationManager()
    var currentCenter = CLLocationCoordinate2D(latitude: 48.8566, longitude: 2.3522)
    var currentDistance: Double = 4_000_000
    
    override init() {
        super.init()
        searchCompleter.delegate = self
        locationManager.delegate = self
        
        TripService.shared.$trips
            .assign(to: \.memoryPins, on: self)
            .store(in: &cancellables)
    }
    
    func performSearch(completion: MKLocalSearchCompletion? = nil) {
        let query = completion?.title.appending(" " + (completion?.subtitle ?? "")) ?? searchQuery
        guard !query.isEmpty else { return }
        isSearching = true; errorMessage = nil
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        MKLocalSearch(request: request).start { [weak self] response, error in
            DispatchQueue.main.async {
                self?.isSearching = false
                guard let item = response?.mapItems.first else { self?.errorMessage = "Kunde inte hitta platsen."; return }
                self?.animateCamera(to: item)
            }
        }
    }
    
    func locateUser() { locationManager.requestWhenInUseAuthorization(); locationManager.startUpdatingLocation() }
    
    func zoomIn() { withAnimation { position = .camera(MapCamera(centerCoordinate: currentCenter, distance: max(1000, currentDistance * 0.5), heading: 0, pitch: 45)) } }
    
    func zoomOut() { withAnimation { position = .camera(MapCamera(centerCoordinate: currentCenter, distance: currentDistance * 2.0, heading: 0, pitch: 0)) } }
    
    func updateCameraContext(center: CLLocationCoordinate2D, distance: Double) { self.currentCenter = center; self.currentDistance = distance }
    
    private func animateCamera(to item: MKMapItem) {
        let coordinate = item.placemark.coordinate
        withAnimation(.easeInOut(duration: 2.0)) { position = .camera(MapCamera(centerCoordinate: coordinate, distance: 10_000, heading: 0, pitch: 60)) }
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) { self.searchSuggestions = completer.results.filter { !$0.title.isEmpty } }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        locationManager.stopUpdatingLocation()
        withAnimation(.easeInOut(duration: 2.0)) { position = .camera(MapCamera(centerCoordinate: location.coordinate, distance: 10_000, heading: 0, pitch: 60)) }
    }
}
