//
//  SongsDetailsView.swift
//  Songs
//
//  Created by Yura Morozov on 15.05.21.
//

import SwiftUI
import AVKit
import URLImage


struct SongsDetailsView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    let asset: SongsAsset
    
    @State var showSongsEditor: Bool = false
    
    var body: some View {
        Form {
            Section(header: Text("photo")) {
                SongsFullImageView(asset.photoFileData?.downloadURL, 300)
            }
            
            Section(header: Text("author")) {
                Text(asset.author)
                    .multilineTextAlignment(.leading)
            }
            
            Section(header: Text("description")) {
                Text(asset.description)
                    .multilineTextAlignment(.leading)
            }
            
            Section(header: Text("year")) {
                Text(String(asset.year))
            }
            
            if let urlString = asset.videoFileData?.downloadURL,
               let url = URL(string: urlString) {
                let videoPlayer: AVPlayer = AVPlayer(url: url)
                
                Section(header: Text("video")) {
                    VideoPlayer(player: videoPlayer)
                        .aspectRatio(16.0/9.0, contentMode: .fit)
                        .onDisappear(perform: {
                            videoPlayer.pause()
                        })
                }
            }
            
            if let releaseData = asset.release {
                Section(header: Text("release")) {
                    Text(releaseData.note)
                        .multilineTextAlignment(.leading)
                    HStack {
                        Text("latitude")
                        Spacer()
                        Text(String(releaseData.latitude))
                    }
                    .foregroundColor(.secondary)
                    
                    HStack {
                        Text("longitude")
                        Spacer()
                        Text(String(releaseData.longitude))
                    }
                    .foregroundColor(.secondary)
                }
            }
            
        }
        .navigationTitle(asset.name)
        .sheet(isPresented: $showSongsEditor, content: {
            SongsFormView(
                assetToEdit: asset,
                onDelete: {
                    presentationMode.wrappedValue.dismiss()
                },
                isPresented: $showSongsEditor)
        })
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showSongsEditor.toggle()
                } label: {
                    Image(systemName: "pencil")
                }
            }
        }
    }
}

//struct SongsDetailsView_Previews: PreviewProvider {
//    static var previews: some View {
//        SongsDetailsView()
//    }
//}
