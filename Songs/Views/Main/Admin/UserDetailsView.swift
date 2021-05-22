//
//  UserDetailsView.swift
//  Songs
//
//  Created by Yura Morozov on 17.05.21.
//

import SwiftUI

struct UserDetailsView: View {
    @EnvironmentObject var session: Session
    
    @State var user: SongsUser
    private let songsUserService = SongsUserFirebaseService()
    
    @State private var showAlert = false
    
    @State private var titleMsg: String = ""
    @State private var msg: String = ""
    
    var body: some View {
        Form {
            Section(header: Text("id")) {
                Text(user.id)
            }
            
            Section(header: Text("email")) {
                Text(user.email)
            }
            
            Section(header: Text("status")) {
                Picker("", selection: $user.isBlocked) {
                    Text("active")
                        .tag(false)
                    Text("blocked")
                        .tag(true)
                }
                .pickerStyle(SegmentedPickerStyle())
                .onChange(of: user.isBlocked) { tag in
                    updateUser()
                }
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text(titleMsg),
                        message: Text(msg)
                    )
                }
            }
            
            Section(header: Text("role")) {
                Picker("", selection: $user.isAdmin) {
                    Text("user_role")
                        .tag(false)
                    Text("admin_role")
                        .tag(true)
                }
                .pickerStyle(SegmentedPickerStyle())
                .onChange(of: user.isAdmin) { tag in
                    updateUser()
                }
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text(titleMsg),
                        message: Text(msg)
                    )
                }
            }
        }
        .navigationTitle(user.email)
    }
    
    func updateUser() {
        session.updateRemoteUser(user) { (error) in
            titleMsg = NSLocalizedString("success", comment: "")
            msg = NSLocalizedString("success_change", comment: "")
            showAlert = true
            if error != nil {
                titleMsg = NSLocalizedString("error", comment: "")
                msg = NSLocalizedString("something_gone_wrong", comment: "")
            }
        }
    }
}

struct UserDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        let user = SongsUser(id: "12", email: "mail@gmail.com", isAdmin: false, isBlocked: false)
        UserDetailsView(user: user)
    }
}
