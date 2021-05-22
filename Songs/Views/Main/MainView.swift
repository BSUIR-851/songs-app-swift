//
//  MainView.swift
//  Songs
//
//  Created by Yura Morozov on 15.05.21.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var session: Session
    var body: some View {
        if session.getSongsUser()?.isBlocked == true {
            BlockedView()
        } else {
            AccessView()
        }
    }
}

//struct MainView_Previews: PreviewProvider {
//    static var previews: some View {
//        MainView()
//    }
//}
