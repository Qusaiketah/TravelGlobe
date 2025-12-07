import SwiftUI
import CoreLocation
import MapKit
import Combine
import PhotosUI 

struct NewMemoryView: View {
    @Environment(\.dismiss) var dismiss
    @State private var locationText: String = ""
    @State private var caption: String = ""
    @State private var selectedPhotoItems: [PhotosPickerItem] = []
    @State private var selectedImages: [UIImage] = []
    @StateObject private var searchVM = MemorySearchModel()
    @StateObject private var locManager = MemoryLocationManager()
    @FocusState private var isFocused: Bool
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 24) {
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("New Memory")
                            .font(.title2).bold().foregroundColor(.white)
                        Text("Add to your travel log")
                            .font(.caption).foregroundColor(.gray)
                    }
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title).foregroundColor(.gray)
                    }
                }
                .padding(.top, 20)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("LOCATION").font(.caption).foregroundColor(.gray)
                    
                    ZStack(alignment: .topLeading) {
                        HStack(spacing: 10) {
                            Image(systemName: "mappin.and.ellipse").foregroundColor(.red)
                            
                            TextField("Search City (e.g. Tokyo)...", text: $locationText)
                                .foregroundColor(.white)
                                .focused($isFocused)
                                .onChange(of: locationText) { newValue in
                                    searchVM.query = newValue
                                }
                            
                            Spacer()
                            
                            // 2. RENSA-KNAPP (X)
                            if !locationText.isEmpty {
                                Button(action: {
                                    locationText = ""
                                    searchVM.query = ""
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                        .font(.body)
                                }
                                .padding(.trailing, 5)
                            }
                            
                            Button(action: { locManager.requestLocation() }) {
                                Group {
                                    if locManager.isLoading {
                                        ProgressView().tint(.blue)
                                    } else {
                                        Image(systemName: "location.fill")
                                    }
                                }
                                .font(.body)
                                .padding(8)
                                .background(Color.blue.opacity(0.2)).foregroundColor(.blue)
                                .cornerRadius(10)
                            }
                        }
                        .padding(10)
                        .background(Color(UIColor.systemGray6).opacity(0.1))
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.blue.opacity(0.5), lineWidth: 1))
                        .zIndex(1)
                        
                        if !searchVM.suggestions.isEmpty && isFocused {
                            ScrollView {
                                VStack(spacing: 0) {
                                    ForEach(searchVM.suggestions, id: \.self) { suggestion in
                                        Button(action: {
                                            locationText = suggestion.title + ", " + suggestion.subtitle
                                            searchVM.query = ""
                                            isFocused = false
                                        }) {
                                            VStack(alignment: .leading) {
                                                Text(suggestion.title).foregroundColor(.black).font(.body)
                                                if !suggestion.subtitle.isEmpty {
                                                    Text(suggestion.subtitle).foregroundColor(.gray).font(.caption)
                                                }
                                            }
                                            .padding()
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        }
                                        Divider().background(Color.gray.opacity(0.3))
                                    }
                                }
                            }
                            .frame(maxHeight: 200)
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(12)
                            .padding(.top, 60)
                            .shadow(radius: 20)
                            .zIndex(10)
                        }
                    }
                }
                .zIndex(10)
                                VStack(alignment: .leading, spacing: 8) {
                    Text("PHOTOS & VIDEOS").font(.caption).foregroundColor(.gray)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            
                            PhotosPicker(
                                selection: $selectedPhotoItems,
                                maxSelectionCount: 5,
                                matching: .any(of: [.images, .videos])
                            ) {
                                VStack {
                                    Image(systemName: "plus")
                                    Text("Add")
                                }
                                .font(.caption).foregroundColor(.white)
                                .frame(width: 80, height: 80)
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(12)
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(style: StrokeStyle(lineWidth: 1, dash: [5])).foregroundColor(.gray))
                            }
                            .onChange(of: selectedPhotoItems) { newItems in
                                Task {
                                    selectedImages.removeAll()
                                    for item in newItems {
                                        if let data = try? await item.loadTransferable(type: Data.self),
                                           let image = UIImage(data: data) {
                                            selectedImages.append(image)
                                        }
                                    }
                                }
                            }
                            
                            ForEach(selectedImages, id: \.self) { image in
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 80)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            
                            if selectedImages.isEmpty {
                                ForEach(0..<3) { _ in
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white.opacity(0.05))
                                        .frame(width: 80, height: 80)
                                        .overlay(Image(systemName: "photo").foregroundColor(.gray.opacity(0.3)))
                                }
                            }
                        }
                    }
                }
                .zIndex(1)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("CAPTION").font(.caption).foregroundColor(.gray)
                    
                    ZStack(alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.05))
                            .frame(height: 120)
                        
                        if caption.isEmpty {
                            Text("Write about your experience...")
                                .foregroundColor(.gray.opacity(0.5))
                                .padding(.horizontal, 16)
                                .padding(.top, 16)
                        }
                        
                        TextEditor(text: $caption)
                            .scrollContentBackground(.hidden)
                            .padding(12)
                            .frame(height: 120)
                            .foregroundColor(.white)
                    }
                }
                
                Spacer()
                Button(action: {
                    print("Pinning location: \(locationText) with \(selectedImages.count) photos.")
                    dismiss()
                }) {
                    HStack {
                        Text("Pin to Globe")
                        Image(systemName: "mappin")
                    }
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(locationText.isEmpty ? Color.gray.opacity(0.3) : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(30)
                }
                .disabled(locationText.isEmpty)
                .padding(.bottom)
            }
            .padding()
            .onReceive(locManager.$placemarkName) { newName in
                if let name = newName { self.locationText = name }
            }
        }
    }
}

class MemorySearchModel: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    @Published var query: String = "" { didSet { completer.queryFragment = query } }
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
}

class MemoryLocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var placemarkName: String?
    @Published var isLoading = false
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }
    func requestLocation() {
        isLoading = true
        manager.requestWhenInUseAuthorization()
        manager.requestLocation()
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, _ in
            DispatchQueue.main.async {
                self.isLoading = false
                if let place = placemarks?.first {
                    self.placemarkName = "\(place.locality ?? ""), \(place.country ?? "")"
                }
            }
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) { isLoading = false }
}

#Preview {
    NewMemoryView()
}
