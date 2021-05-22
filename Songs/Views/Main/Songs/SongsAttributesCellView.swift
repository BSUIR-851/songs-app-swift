//
//  SongsDescriptionCellView.swift
//  Songs
//
//  Created by Yura Morozov on 15.05.21.
//

import SwiftUI

struct SongsAttributesCellView: View {
    
    let asset: SongsAsset
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(asset.name)
                HStack {
                    Text(String(asset.year))
                    Text("|")
                    Text(asset.author)
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
            }
            .padding(.leading, 5)
            Spacer()
        }
    }
}

struct SongsAttributesCellView_Previews: PreviewProvider {
    static var previews: some View {
        let asset = SongsAsset(id: "12", name: "Sound of silence", author: "Disturbed", description: "description",year: 2020)
        SongsAttributesCellView(asset: asset)
    }
}
