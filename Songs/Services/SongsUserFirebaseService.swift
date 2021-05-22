//
//  SongsUserFirebaseService.swift
//  Songs
//
//  Created by Yura Morozov on 16.05.21.
//

import Foundation
import Firebase
import AVFoundation


class SongsUserFirebaseService {
    
    let db = Firebase.Firestore.firestore()
    
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    
    func deleteRemoteUser(_ user: SongsUser, completion: @escaping (Error?) -> Void) {
        let document = db.collection(Constants.usersCollectionFirebaseName).document(user.id)
        document.delete { (error) in
            completion(error)
        }
    }
    
    private func uploadUser(_ user: SongsUser, completion: @escaping (Error?) -> Void) {
        do {
            let data = try encoder.encode(user)
            if var json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                json.removeValue(forKey: "id")
                
                let document = db.collection(Constants.usersCollectionFirebaseName).document(user.id)
                document.setData(json) { error in
                    if let error = error {
                        print("Error writing document: \(error)")
                        completion(error)
                    } else {
                        print("Document successfully written!")
                        completion(nil)
                    }
                }
            } else {
                let error = NSError.withLocalizedDescription("Unable to create json object")
                completion(error)
            }
        } catch {
            let error = NSError.withLocalizedDescription("Unable to encode user")
            completion(error)
        }
    }
    
    private func updateRemoteUserRec(_ user: SongsUser, completion: @escaping (SongsUser?, Error?) -> Void) {
        uploadUser(user) { (error) in
            if let error = error {
                completion(nil, error)
            } else {
                completion(user, nil)
            }
        }
    }
    
    func updateRemoteUser(_ user: SongsUser, completion: @escaping (SongsUser?, Error?) -> Void) {
        updateRemoteUserRec(user) { (updatedUser, error) in
            completion(updatedUser, error)
        }
    }
    
    func getRemoteUser(_ user: SongsUser, completion: @escaping (SongsUser?, Error?) -> Void) {
        let docRef = db.collection(Constants.usersCollectionFirebaseName).document(user.id)
        docRef.getDocument { (doc, error) in
            if let error = error {
                completion(nil, error)
            } else if let doc = doc {
                var recvUser: SongsUser = user
                do {
                    var jsonData = doc.data()
                    jsonData!.updateValue(doc.documentID, forKey: "id")
                    
                    if var data = try? JSONSerialization.data(withJSONObject: jsonData) {
                        recvUser = try self.decoder.decode(SongsUser.self, from: data)
                        recvUser.id = doc.documentID
                    } else {
                        print("Can't create json data from firebase document data")
                    }
                } catch {
                    print(error)
                }
                completion(recvUser, nil)
            } else {
                completion(nil, NSError.withLocalizedDescription("Both doc and error in getRemoteUser are nil"))
            }
        }
    }
    
    func getRemoteUsers(completion: @escaping ([SongsUser]?, Error?) -> Void) {
        db.collection(Constants.usersCollectionFirebaseName).getDocuments { (query, error) in
            if let error = error {
                completion(nil, error)
            } else if let query = query {
                var users: [SongsUser] = []
            
                query.documents.forEach { (document) in
                    do {
                        var jsonData = document.data()
                        jsonData.updateValue(document.documentID, forKey: "id")
        
                        if let data = try? JSONSerialization.data(withJSONObject: jsonData) {
                            var user = try self.decoder.decode(SongsUser.self, from: data)
                            user.id = document.documentID
                            users.append(user)
                        } else {
                            print("Can't create json data from firebase document data")
                        }
                    } catch {
                        print(error)
                    }
                }
                
                completion(users, nil)
            } else {
                completion(nil, NSError.withLocalizedDescription("Both query and error in getRemoteUsers are nil"))
            }
        }
    }
}
