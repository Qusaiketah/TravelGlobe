//
//  NewTripSheet.swift
//  TravelGlobe
//
//  Created by Qusai Ketah on 2025-12-04.
//

import SwiftUI

struct NewTripSheet: View {
    @State private var caption: String = ""
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 20) {
                // مقبض صغير
                Capsule().frame(width: 40, height: 5).foregroundColor(.gray).padding(.top)
                
                Text("New Memory").font(.title2).bold().foregroundColor(.white)
                
                // حقل المكان
                HStack {
                    Image(systemName: "mappin.circle.fill").foregroundColor(.red)
                    Text("Paris, France").foregroundColor(.white)
                    Spacer()
                }
                .padding().background(Color.white.opacity(0.1)).cornerRadius(12)
                
                // زر الحفظ
                Button(action: { print("Saved") }) {
                    Text("Pin to Globe 📍")
                        .bold().foregroundColor(.white)
                        .frame(maxWidth: .infinity).frame(height: 55)
                        .background(Color.blue).cornerRadius(28)
                }
                
                Spacer()
            }
            .padding()
        }
    }
}
