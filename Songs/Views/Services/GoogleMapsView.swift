//
//  GoogleMapsView.swift
//  Songs
//
//  Created by Yura Morozov on 15.05.21.
//

import SwiftUI
import GoogleMaps

struct GoogleMapsView: UIViewRepresentable {
    
    @EnvironmentObject var session: Session
    
    let service: GoogleMapsService
    
    let showSongsReleasePins: Bool
    
    func makeCoordinator() -> GoogleMapsViewCoordinator {
        return GoogleMapsViewCoordinator(service: service)
    }
    
    func makeUIView(context: Self.Context) -> GMSMapView {
        let camera = GMSCameraPosition.camera(withLatitude: 0, longitude: 0, zoom: 1)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.delegate = context.coordinator
        service.position = camera.target
        return mapView
    }
    
    func updateUIView(_ mapView: GMSMapView, context: Context) {
        if showSongsReleasePins {
            service.markers.forEach { (marker) in
                marker.map = nil
            }
            
            session.getLocalAssets()?.forEach({ (asset) in
                if let release = asset.release {
                    let marker = GMSMarker()
                    marker.position = CLLocationCoordinate2D(
                        latitude: release.latitude,
                        longitude: release.longitude
                    )
                    marker.title = "\(asset.name)"
                    marker.snippet = release.note
                    marker.map = mapView
                    service.markers.append(marker)
                }
            })
        }
    }
}

class GoogleMapsViewCoordinator: NSObject, GMSMapViewDelegate {
    
    let service: GoogleMapsService
    
    init(service: GoogleMapsService) {
        self.service = service
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        service.position = position.target
    }
}

//struct GoogleMapsView_Previews: PreviewProvider {
//    static var previews: some View {
//        GoogleMapsView()
//    }
//}
