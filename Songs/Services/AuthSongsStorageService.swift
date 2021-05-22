//
//  AuthSongStorageService.swift
//  Songs
//
//  Created by Yura Morozov on 15.05.21.
//

import Foundation
import SwiftKeychainWrapper

class AuthSongsStorageService {
    
    static let emailKey = "email"
    static let passwordKey = "password"
    
    static func saveToKeychain(_ songAuth: SongsAuth) {
        KeychainWrapper.standard.set(songAuth.email, forKey: emailKey)
        KeychainWrapper.standard.set(songAuth.password, forKey: passwordKey)
    }
    
    static func deleteFromKeychain() {
        KeychainWrapper.standard.removeObject(forKey: emailKey)
        KeychainWrapper.standard.removeObject(forKey: passwordKey)
    }
    
    static func restoreFromKeychain() -> SongsAuth? {
        if let email = KeychainWrapper.standard.string(forKey: emailKey) {
            if let password = KeychainWrapper.standard.string(forKey: passwordKey) {
                return SongsAuth(email: email, password: password)
            }
        }
        return nil
    }
}
