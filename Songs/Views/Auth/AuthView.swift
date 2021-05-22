//
//  AuthView.swift
//  Songs
//
//  Created by Yura Morozov on 15.05.21.
//

import SwiftUI

struct AuthView: View {
    @EnvironmentObject var session: Session
    
    @State var email: String = ""
    @State var password: String = ""
    
    @State var errorText: LocalizedStringKey = ""
    @State var progress: Bool = false
    
    let lightGreyColor = Color(red: 239.0/255.0, green: 243.0/255.0, blue: 244.0/255.0, opacity: 1.0)
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                ScrollView(showsIndicators: false) {
                    VStack {
                        VStack {
                            Text("welcome_exclamation_mark")
                                .font(.largeTitle)
                                .fontWeight(.semibold)
                            
                            Image("welcome_image")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 150, height: 150)
                                .clipped()
                                .cornerRadius(150)
                                .padding(.bottom, 30)
                        }
                        
                        VStack(spacing: 10) {
                            TextField("email", text: $email)
                                .disableAutocorrection(true)
                                .autocapitalization(.none)
                                .padding()
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(Constants.uiCornerRadius)
                                .padding(.bottom, 10)
                        
                            SecureField("password", text: $password)
                                .disableAutocorrection(true)
                                .autocapitalization(.none)
                                .padding()
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(Constants.uiCornerRadius)
                        }
                        .padding(.bottom, 25)
                        
                        VStack {
                            Button(action: {
                                signInTap()
                            }) {
                                Text("sign_in")
                                    .padding()
                                    .frame(maxWidth: 200)
                                    .background(Color(.secondarySystemBackground))
                                    .cornerRadius(Constants.uiCornerRadius + 25)
                                    .foregroundColor(.white)
                                    .padding(5)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: Constants.uiCornerRadius + 25)
                                            .stroke(Color(.secondarySystemBackground), lineWidth: 4)
                                    )
                            }
                            
                            Button(action: {
                                signUpTap()
                            }) {
                                Text("sign_up")
                                    .padding()
                                    .frame(maxWidth: 200)
                                    .background(Color(.secondarySystemBackground))
                                    .cornerRadius(Constants.uiCornerRadius + 25)
                                    .foregroundColor(.white)
                                    .padding(5)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: Constants.uiCornerRadius + 25)
                                            .stroke(Color(.secondarySystemBackground), lineWidth: 4)
                                    )
                            }
                        }
                        .padding(.bottom, 25)
                        
                        Text(errorText)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .frame(width: geometry.size.width)
                    .frame(minHeight: geometry.size.height)
                }
            }
            
            
            if progress {
                ProgressView()
            }
        }
        .allowsHitTesting(!progress)
        .onAppear {
            restoreSession()
        }
    }
    
    func validateEmailPassword() -> Bool {
        return !(email.isEmpty || password.isEmpty)
    }
    
    func restoreSession() {
        withAnimation {
            progress = true
        }

        if let authData = session.restore(completion: { (error) in
            withAnimation {
                progress = false
            }

            if error != nil {
                print("Unable to restore session")
//                self.errorText = "something_went_wrong"
            }
        }) {
            email = authData.email
            password = authData.password
        }
    }
    
    func signInTap() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)

        if validateEmailPassword() {
            withAnimation {
                progress = true
            }

            session.signInEmail(email: email, password: password) { (error) in
                withAnimation {
                    progress = false
                }

                if error != nil {
                    self.errorText = "something_went_wrong"
                }
            }
        } else {
            self.errorText = "email_and_password_must_be_not_empty"
        }
    }
    
    func signUpTap() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)

        if validateEmailPassword() {
            withAnimation {
                progress = true
            }

            session.signUpEmail(email: email, password: password) { (error) in
                withAnimation {
                    progress = false
                }

                if error != nil {
                    self.errorText = "something_went_wrong"
                }
            }
        } else {
            self.errorText = "email_and_password_must_be_not_empty"
        }
    }
}

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView()
            .preferredColorScheme(/*@START_MENU_TOKEN@*/.dark/*@END_MENU_TOKEN@*/)
            
    }
}
