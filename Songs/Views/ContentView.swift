//
//  ContentView.swift
//  Songs
//
//  Created by Yura Morozov on 14.05.21.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var session: Session
    var body: some View {
        AuthView()
            .font(.custom(session.settings.fontName, size: session.settings.fontSize))
            .fullScreenCover(isPresented: $session.initialized) {
                MainView()
                    .environmentObject(session)
                    .environment(\.locale, Locale(identifier: session.settings.localization.languageCode))
                    .font(.custom(session.settings.fontName, size: session.settings.fontSize))
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
