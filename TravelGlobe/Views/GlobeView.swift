import SwiftUI
import MapKit
import Combine
import CoreLocation

struct GlobeView: View {
    @Binding var showSidebar: Bool
    @Binding var showNewTrip: Bool
    
    @StateObject private var viewModel = GlobeViewModel()
    @FocusState private var isFocused: Bool
    
    var body: some View {
        ZStack(alignment: .top) {
            
            Map(position: $viewModel.position) {
                ForEach(viewModel.memoryPins) { pin in
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
                viewModel.updateCameraContext(center: context.camera.centerCoordinate, distance: context.camera.distance)
            }
            .ignoresSafeArea()
            .onTapGesture { isFocused = false }
            
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
                        TextField("Search...", text: $viewModel.searchQuery)
                            .foregroundColor(.white)
                            .focused($isFocused)
                            .onSubmit {
                                viewModel.performSearch()
                                isFocused = false
                            }
                            .submitLabel(.search)
                        
                        if viewModel.isSearching { ProgressView().tint(.white) }
                        
                        if !viewModel.searchQuery.isEmpty {
                            Button(action: { viewModel.searchQuery = "" }) {
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
                
                if !viewModel.searchSuggestions.isEmpty && isFocused {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            ForEach(viewModel.searchSuggestions, id: \.self) { suggestion in
                                Button(action: {
                                    viewModel.searchQuery = suggestion.title + " " + suggestion.subtitle
                                    viewModel.performSearch(completion: suggestion)
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
                                if suggestion != viewModel.searchSuggestions.last {
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
                        Button(action: viewModel.locateUser) {
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
                            Button(action: viewModel.zoomIn) {
                                Image(systemName: "plus").font(.title2)
                                    .frame(width: 50, height: 50).foregroundColor(.white).contentShape(Rectangle())
                            }
                            Divider().background(Color.white.opacity(0.3)).frame(width: 30)
                            Button(action: viewModel.zoomOut) {
                                Image(systemName: "minus").font(.title2)
                                    .frame(width: 50, height: 50).foregroundColor(.white).contentShape(Rectangle())
                            }
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
}

#Preview {
    GlobeView(
        showSidebar: .constant(false),
        showNewTrip: .constant(false)
    )
}
