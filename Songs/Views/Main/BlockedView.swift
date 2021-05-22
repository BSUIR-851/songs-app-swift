//
//  BlockedView.swift
//  Songs
//
//  Created by Yura Morozov on 16.05.21.
//

import SwiftUI

struct BlockedView: View {
    @EnvironmentObject var session: Session
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("msg")) {
                    Text("blocked_msg")
                }
                
                Section(header: Text("general")) {
                    Section {
                        Button(action: {
                            session.destroy()
                        }) {
                            Text("log_out")
                        }
                    }
                }
            }
            .navigationBarTitle("msg", displayMode: .inline)
        }
    }
}

//struct BlockedView_Previews: PreviewProvider {
//    static var previews: some View {
//        BlockedView()
//    }
//}
