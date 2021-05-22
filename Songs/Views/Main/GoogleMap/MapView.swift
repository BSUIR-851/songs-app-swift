//
//  MapView.swift
//  Songs
//
//  Created by Yura Morozov on 15.05.21.
//

import SwiftUI

struct MapView: View {
    
    let service: GoogleMapsService = GoogleMapsService()
    
    var body: some View {
        NavigationView {
            GoogleMapsView(service: service, showSongsReleasePins: true)
                .edgesIgnoringSafeArea(.all)
                .navigationBarTitle("map", displayMode: .inline)
        }
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}
