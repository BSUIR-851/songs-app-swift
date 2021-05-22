//
//  SessionService.swift
//  Songs
//
//  Created by Yura Morozov on 15.05.21.
//

import Foundation
import Firebase

class Session: ObservableObject {
    
    @Published var settings: SettingsData = SettingsData.restoreFromDefaultUD()
    @Published private var songsAuth: SongsAuth? = nil
    @Published private var dashboard: SongsDashboard? = nil
    
    @Published var initialized: Bool = false
    
    @Published private var songsUser: SongsUser? = nil
    @Published private var usersDashboard: UsersDashboard? = UsersDashboard()
    
    private let songsUserService = SongsUserFirebaseService()
    private let songsAssetService = SongsAssetFirebaseService()
    
    
    func getLocalAssets() -> [SongsAsset]? {
        return dashboard?.assets
    }
    
    func getLocalAsset(id: String) -> SongsAsset? {
        return getLocalAssets()?.first(where: { (asset) -> Bool in
            asset.id == id
        })
    }
    
    private func deleteLocalAsset(asset: SongsAsset) {
        if let index = getLocalAssets()?.firstIndex(where: { (a) -> Bool in
            a.id == asset.id
        }) {
            dashboard?.assets.remove(at: index)
        }
    }
    
    func deleteRemoteAsset(asset: SongsAsset, completion: @escaping (Error?) -> Void) {
        songsAssetService.deleteRemoteAsset(asset) { (error) in
            if let error = error {
                print(error)
                completion(error)
            } else {
                self.deleteLocalAsset(asset: asset)
                completion(nil)
            }
        }
    }
    
    private func updateLocalAsset(_ asset: SongsAsset) {
        if let index = dashboard?.assets.firstIndex(where: { (a) -> Bool in
            a.id == asset.id
        }) {
            dashboard?.assets[index] = asset
        } else {
            dashboard?.assets.append(asset)
        }
    }
    
    func updateRemoteAsset(asset: SongsAsset, photoNSURL: NSURL?, videoNSURL: NSURL?, completion: @escaping (Error?) -> Void) {
        songsAssetService.updateRemoteAsset(asset, photoNSURL, videoNSURL) { (updatedAsset, error) in
            if let error = error {
                print(error)
                completion(error)
            } else if let updatedAsset = updatedAsset {
                self.updateLocalAsset(updatedAsset)
                completion(nil)
            } else {
                let error = NSError.withLocalizedDescription("Invalid updateRemoteAsset form SongsAssetFirebaseService closure return")
                completion(error)
            }
        }
    }
    
    private func initialize(_ songsAuth: SongsAuth, onCompleted: @escaping () -> Void) {
        self.songsAuth = songsAuth
        
        AuthSongsStorageService.saveToKeychain(songsAuth)
        
        dashboard = SongsDashboard()
        
        syncDashboard {
            self.initialized = true
            onCompleted()
        }
    }
    
    func syncDashboard(onCompleted: @escaping () -> Void) {
        songsAssetService.getRemoteAssets { (assets, error) in
            if let error = error {
                print(error)
                self.dashboard?.assets = []
            } else if let assets = assets {
                self.dashboard?.assets = assets
            } else {
                print("Didn't receive any assets and error")
                self.dashboard?.assets = []
            }
            onCompleted()
        }
    }
    
    func destroy() {
        initialized = false
        
        settings.localization = .system
        AuthSongsStorageService.deleteFromKeychain()
        
        do {
            try Firebase.Auth.auth().signOut()
        } catch {
            print(error)
        }
        songsAuth = nil
        songsUser = nil
        dashboard = nil
        usersDashboard = UsersDashboard()
    }
    
    func restore(completion: @escaping (Error?) -> Void) -> SongsAuth? {
        if let songsAuth = AuthSongsStorageService.restoreFromKeychain() {
            signInEmail(email: songsAuth.email, password: songsAuth.password) { (error) in
                self.handleFirebaseAuthResponse(songsAuth: songsAuth, error: error, completion: completion)
            }
            return songsAuth
        } else {
            let error = NSError.withLocalizedDescription("Unable to restore session")
            completion(error)
            return nil
        }
    }
    
    func signUpEmail(email: String, password: String, completion: @escaping (Error?) -> Void) {
        Firebase.Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            let songsAuth = SongsAuth(email: email, password: password)
            self.handleFirebaseAuthResponse(songsAuth: songsAuth, error: error, completion: completion)
            self.updateRemoteUserAuth(songsAuth: songsAuth, error: error, completion: completion)
        }
    }
    
    func signInEmail(email: String, password: String, completion: @escaping (Error?) -> Void) {
        Firebase.Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            let songsAuth = SongsAuth(email: email, password: password)
            self.handleFirebaseAuthResponse(songsAuth: songsAuth, error: error, completion: completion)
        }
    }
    
    func getSongsUser() -> SongsUser? {
        return songsUser
    }
    
    func getSongsUsers() -> [SongsUser]? {
        return usersDashboard?.users
    }
    
    func getSongsUserById(id: String) -> SongsUser? {
        return getSongsUsers()?.first(where: { (user) -> Bool in
            user.id == id
        })
    }
    
    func syncUsersDashboard(onCompleted: @escaping () -> Void) {
        songsUserService.getRemoteUsers { (users, error) in
            if let error = error {
                print(error)
                self.usersDashboard?.users = []
            } else if let users = users {
                self.usersDashboard?.users = users
            } else {
                print("Didn't receive any users and error")
                self.usersDashboard?.users = []
            }
            onCompleted()
        }
    }
    
    func getRemoteUser(songsAuth: SongsAuth, completion: @escaping (SongsUser?, Error?) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            let error = NSError.withLocalizedDescription("Invalid getRemoteUser form SongsUserFirebaseService closure return")
            completion(nil, error)
            return
        }
        let user = SongsUser(id: userID, email: songsAuth.email)
        songsUserService.getRemoteUser(user) { (recvUser, error) in
            if let error = error {
                print(error)
                completion(nil, error)
            } else if let recvUser = recvUser {
                completion(recvUser, nil)
            } else {
                let error = NSError.withLocalizedDescription("Invalid getRemoteUser form SongsUserFirebaseService closure return")
                completion(nil, error)
            }
        }
    }
    
    func updateRemoteUserAuth(songsAuth: SongsAuth, error: Error?, completion: @escaping (Error?) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            let error = NSError.withLocalizedDescription("Invalid getRemoteUser form SongsUserFirebaseService closure return")
            completion(error)
            return
        }
        let user = SongsUser(id: userID, email: songsAuth.email)
        updateRemoteUser(user, completion: completion)
    }
    
    func updateRemoteUser(_ user: SongsUser, completion: @escaping (Error?) -> Void) {
        if let index = usersDashboard?.users.firstIndex(where: { (a) -> Bool in
            a.id == user.id
        }) {
            usersDashboard?.users[index] = user
        } else {
            usersDashboard?.users.append(user)
        }
        
        songsUserService.updateRemoteUser(user) { (updatedUser, error) in
            if let error = error {
                print(error)
                completion(error)
            } else if let updatedUser = updatedUser {
                completion(nil)
            } else {
                let error = NSError.withLocalizedDescription("Invalid updateRemoteUserAuth form SongsUserFirebaseService closure return")
                completion(error)
            }
        }
    }
    
    
    private func handleFirebaseAuthResponse(songsAuth: SongsAuth, error: Error?, completion: @escaping (Error?) -> Void) {
        guard error == nil else {
            completion(error)
            return
        }
        initialize(songsAuth) {
            if self.initialized {
                self.getRemoteUser(songsAuth: songsAuth) { user, error in
                    if let error = error {
                        completion(error)
                    } else {
                        self.songsUser = user
                        if (user?.isAdmin == true) {
                            self.syncUsersDashboard() {}
                        }
                    }
                    completion(nil)
                }
            } else {
                let error = NSError.withLocalizedDescription("Unable to initialize session")
                completion(error)
            }
        }
    }
}
