//
//  GoogleMapsLocationPickerView.swift
//  Songs
//
//  Created by Yura Morozov on 15.05.21.
//

import SwiftUI
import GoogleMaps

struct GoogleMapsLocationPickerView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var latitude: Double?
    @Binding var longitude: Double?
    
    let service: GoogleMapsService = GoogleMapsService()
    
    var body: some View {
        NavigationView {
            ZStack {
                GoogleMapsView(service: service, showSongsReleasePins: false)
                    .edgesIgnoringSafeArea(.all)
                    .navigationBarTitle("pick_location", displayMode: .inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("back") {
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                        
                        ToolbarItem(placement: .confirmationAction) {
                            Button("select") {
                                latitude = service.position?.latitude
                                longitude = service.position?.longitude
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                    }
                Image(systemName: "mappin")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(Color.accentColor)
                    .frame(height: 20)
                    .padding(.bottom, 20)
            }
        }
    }
}

//struct GoogleMapsLocationPickerView_Previews: PreviewProvider {
//    static var previews: some View {
//        GoogleMapsLocationPickerView()
//    }
//}
