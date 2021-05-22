//
//  SongsListView.swift
//  Songs
//
//  Created by Yura Morozov on 15.05.21.
//

import SwiftUI

struct SongsListView: View {
    @EnvironmentObject var session: Session
    
    @State var showSongsCreator: Bool = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                if let assets = session.getLocalAssets(), !assets.isEmpty {
                    LazyVStack {
                        ForEach(assets) { asset in
                            NavigationLink(
                                destination: SongsDetailsView(asset: asset)
                            ) {
                                SongsCellView(asset: asset)
                                    .padding(.top)
                            }
                            .foregroundColor(.primary)
                        }
                    }
                    .padding()
                } else {
                    Text("there_is_no_songs")
                        .multilineTextAlignment(.center)
                        .padding()
                }
            }
            .navigationBarTitle("songs", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showSongsCreator.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showSongsCreator) {
                SongsFormView(isPresented: $showSongsCreator)
                    .environmentObject(session)
                    .environment(\.locale, Locale(identifier: session.settings.localization.languageCode))
            }
        }
    }
}

struct SongsListView_Previews: PreviewProvider {
    static var previews: some View {
        SongsListView()
    }
}
