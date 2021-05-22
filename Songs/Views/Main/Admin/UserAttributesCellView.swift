//
//  UserAttributesCellView.swift
//  Songs
//
//  Created by Yura Morozov on 17.05.21.
//

import SwiftUI

struct UserAttributesCellView: View {
    
    let user: SongsUser
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(user.email)
                Text(user.id)
                    .foregroundColor(.secondary)
                HStack {
                    Text(user.isAdmin ? "admin_role" : "user_role")
                    Text("|")
                    Text(user.isBlocked ? "blocked" : "active")
                }
                .foregroundColor(.secondary)
            }
            .padding(.leading, 5)
            Spacer()
        }
    }
}

struct UserAttributesCellView_Previews: PreviewProvider {
    static var previews: some View {
        let user = SongsUser(id: "fe1fkewfoeweewf2", email: "mail@gmail.com", isAdmin: false, isBlocked: false)
        UserAttributesCellView(user: user)
            .preferredColorScheme(/*@START_MENU_TOKEN@*/.dark/*@END_MENU_TOKEN@*/)
    }
}
