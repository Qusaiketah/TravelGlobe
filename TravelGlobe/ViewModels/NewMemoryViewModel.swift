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
    }
    
    func clearLocation() {
        locationText = ""
        searchCompleter.queryFragment = ""
        searchSuggestions = []
    }
    
    func requestCurrentLocation() {
        isLoadingLocation = true
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    func saveMemory() {
        print("Saving memory: \(locationText) with \(selectedImages.count) photos.")
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
