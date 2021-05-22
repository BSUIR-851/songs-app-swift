//
//  AccessView.swift
//  Songs
//
//  Created by Yura Morozov on 16.05.21.
//

import SwiftUI

struct AccessView: View {
    @EnvironmentObject var session: Session
    @State var selection = 2
    var body: some View {
        TabView(selection: $selection) {
            MapView()
                .tabItem {
                    Label("map", systemImage: "map")
                }
                .tag(1)
            
            SongsListView()
                .tabItem {
                    Label("songs", systemImage: "folder")
                }
                .tag(2)
            
            SettingsView()
                .tabItem {
                    Label("settings", systemImage: "gearshape")
                }
                .tag(3)
            
            if session.getSongsUser()?.isAdmin == true {
                AdminView()
                    .tabItem {
                        Label("admin_panel", systemImage: "key")
                    }
                    .tag(4)
            }
        }
    }
}

struct AccessView_Previews: PreviewProvider {
    static var previews: some View {
        AccessView()
    }
}
