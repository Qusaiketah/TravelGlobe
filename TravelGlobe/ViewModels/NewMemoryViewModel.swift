import SwiftUI
import MapKit
import PhotosUI
import CoreLocation
import Combine

class NewMemoryViewModel: NSObject, ObservableObject, MKLocalSearchCompleterDelegate, CLLocationManagerDelegate {
    
    @Published var locationText: String = "" {
        didSet {
            if !skipSearchTrigger {
                searchCompleter.queryFragment = locationText
            }
        }
    }
    @Published var caption: String = ""
    @Published var selectedPhotoItems: [PhotosPickerItem] = [] {
        didSet { loadImages() }
    }
    
    @Published var searchSuggestions: [MKLocalSearchCompletion] = []
    @Published var selectedImages: [UIImage] = []
    @Published var isLoadingLocation: Bool = false
    
    private var currentCoordinate: CLLocationCoordinate2D?
    
    private let searchCompleter = MKLocalSearchCompleter()
    private let locationManager = CLLocationManager()
    private var skipSearchTrigger = false
    
    override init() {
        super.init()
        searchCompleter.delegate = self
        searchCompleter.resultTypes = .pointOfInterest
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    
    func selectSuggestion(_ suggestion: MKLocalSearchCompletion) {
        skipSearchTrigger = true
        locationText = suggestion.title + ", " + suggestion.subtitle
        searchCompleter.queryFragment = ""
        searchSuggestions = []
        skipSearchTrigger = false
        
        let request = MKLocalSearch.Request(completion: suggestion)
        let search = MKLocalSearch(request: request)
        search.start { [weak self] response, _ in
            if let item = response?.mapItems.first {
                self?.currentCoordinate = item.placemark.coordinate
                print("📍 Hittade koordinater för sökning: \(item.placemark.coordinate)")
            }
        }
    }
    
    func clearLocation() {
        locationText = ""
        searchCompleter.queryFragment = ""
        searchSuggestions = []
        currentCoordinate = nil
    }
    
    func requestCurrentLocation() {
        isLoadingLocation = true
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    func saveMemory() {
        guard !locationText.isEmpty else { return }
        
        print("💾 Sparar minne: \(locationText)")
        
        let coord = currentCoordinate ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)
        
        TripService.shared.addTrip(
            locationName: locationText,
            coordinate: coord,
            image: selectedImages.first,
            caption: caption
        )
    }
    
    private func loadImages() {
        Task {
            var images: [UIImage] = []
            for item in selectedPhotoItems {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    images.append(image)
                }
            }
            DispatchQueue.main.async {
                self.selectedImages = images
            }
        }
    }
    
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        self.searchSuggestions = completer.results.filter { !$0.title.isEmpty }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        self.currentCoordinate = location.coordinate
        
        CLGeocoder().reverseGeocodeLocation(location) { [weak self] placemarks, _ in
            DispatchQueue.main.async {
                self?.isLoadingLocation = false
                if let place = placemarks?.first {
                    self?.skipSearchTrigger = true
                    self?.locationText = "\(place.locality ?? ""), \(place.country ?? "")"
                    self?.skipSearchTrigger = false
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
        DispatchQueue.main.async { self.isLoadingLocation = false }
    }
}
