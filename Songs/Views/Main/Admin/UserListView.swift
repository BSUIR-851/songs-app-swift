//
//  UserListView.swift
//  Songs
//
//  Created by Yura Morozov on 17.05.21.
//

import SwiftUI

struct UserListView: View {
    @EnvironmentObject var session: Session
    
    var body: some View {
        NavigationView {
            ScrollView {
                if let users = session.getSongsUsers(), !users.isEmpty {
                    LazyVStack {
                        let currentId = session.getSongsUser()?.id
                        ForEach(users, id: \.email) { user in
                            if currentId != user.id {
                                NavigationLink(
                                    destination: UserDetailsView(user: user)
                                ) {
                                    UserCellView(user: user)
                                        .padding(.top)
                                }
                                .foregroundColor(.primary)
                            }
                        }
                    }
                    .padding()
                } else {
                    Text("there_is_no_users")
                        .multilineTextAlignment(.center)
                        .padding()
                }
            }
            .navigationBarTitle("users", displayMode: .inline)
        }
    }
}

//struct UserListView_Previews: PreviewProvider {
//    static var previews: some View {
//        UserListView()
//    }
//}
