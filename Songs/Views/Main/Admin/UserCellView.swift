//
//  UserCellView.swift
//  Songs
//
//  Created by Yura Morozov on 17.05.21.
//

import SwiftUI

struct UserCellView: View {
    
    let user: SongsUser
    
    var body: some View {
        VStack {
            Divider()
            HStack {
                Image(systemName: "person")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(0.5)
                    .frame(width: 50, height: 50)
                
                UserAttributesCellView(user: user)
                Image(systemName: "arrow.right.square")
                    .imageScale(.small)
                    .foregroundColor(.secondary)
            }
            .padding()
            Divider()
        }
    }
}

struct UserCellView_Previews: PreviewProvider {
    static var previews: some View {
        let user = SongsUser(id: "i4934fiu349jg34fif3", email: "mail@gmail.com", isAdmin: false, isBlocked: false)
        UserCellView(user: user)
            .preferredColorScheme(/*@START_MENU_TOKEN@*/.dark/*@END_MENU_TOKEN@*/)
    }
}
