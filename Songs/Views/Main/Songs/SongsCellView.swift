//
//  SongsCellView.swift
//  Songs
//
//  Created by Yura Morozov on 15.05.21.
//

import SwiftUI

struct SongsCellView: View {
    
    let asset: SongsAsset
    
    var body: some View {
        VStack {
            Divider()
            HStack {
                SongsPhotoView(asset.photoFileData?.downloadURL, 50)
                SongsAttributesCellView(asset: asset)
                Image(systemName: "arrow.right.square")
                    .imageScale(.small)
                    .foregroundColor(.secondary)
            }
            .padding()
            Divider()
        }
    }
}


struct SongsCellView_Previews: PreviewProvider {
    static var previews: some View {
        let asset = SongsAsset(id: "12", name: "Sound of silence", author: "Disturbed", description: "description", year: 2020)
        SongsCellView(asset: asset)
    }
}
