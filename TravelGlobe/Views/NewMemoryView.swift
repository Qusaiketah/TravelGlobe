import SwiftUI
import CoreLocation
import MapKit
import Combine
import PhotosUI 

struct NewMemoryView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = NewMemoryViewModel()
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
                            
                            TextField("Search City (e.g. Tokyo)...", text: $viewModel.locationText)
                                .foregroundColor(.white)
                                .focused($isFocused)
                            
                            Spacer()
                            
                            if !viewModel.locationText.isEmpty {
                                Button(action: viewModel.clearLocation) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                        .font(.body)
                                }
                                .padding(.trailing, 5)
                            }
                            Button(action: viewModel.requestCurrentLocation) {
                                Group {
                                    if viewModel.isLoadingLocation {
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
                        
                        if !viewModel.searchSuggestions.isEmpty && isFocused {
                            ScrollView {
                                VStack(spacing: 0) {
                                    ForEach(viewModel.searchSuggestions, id: \.self) { suggestion in
                                        Button(action: {
                                            viewModel.selectSuggestion(suggestion)
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
                                selection: $viewModel.selectedPhotoItems,
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
                            
                            ForEach(viewModel.selectedImages, id: \.self) { image in
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 80)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            
                            if viewModel.selectedImages.isEmpty {
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
                
                // Caption
                VStack(alignment: .leading, spacing: 8) {
                    Text("CAPTION").font(.caption).foregroundColor(.gray)
                    
                    ZStack(alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.05))
                            .frame(height: 120)
                        
                        if viewModel.caption.isEmpty {
                            Text("Write about your experience...")
                                .foregroundColor(.gray.opacity(0.5))
                                .padding(.horizontal, 16)
                                .padding(.top, 16)
                        }
                        
                        TextEditor(text: $viewModel.caption)
                            .scrollContentBackground(.hidden)
                            .padding(12)
                            .frame(height: 120)
                            .foregroundColor(.white)
                    }
                }
                
                Spacer()
                
                Button(action: {
                    viewModel.saveMemory()
                    dismiss()
                }) {
                    HStack {
                        Text("Pin to Globe")
                        Image(systemName: "mappin")
                    }
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(viewModel.locationText.isEmpty ? Color.gray.opacity(0.3) : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(30)
                }
                .disabled(viewModel.locationText.isEmpty)
                .padding(.bottom)
            }
            .padding()
        }
    }
}

#Preview {
    NewMemoryView()
}
