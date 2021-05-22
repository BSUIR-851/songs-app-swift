//
//  SongRecordFirebaseService.swift
//  Songs
//
//  Created by Yura Morozov on 15.05.21.
//

import Foundation
import Firebase
import AVFoundation


class SongsAssetFirebaseService {
    
    let db = Firebase.Firestore.firestore()
    let storage = Storage.storage()
    
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    
    func deleteRemoteAsset(_ asset: SongsAsset, completion: @escaping (Error?) -> Void) {
        if let photoFile = asset.photoFileData {
            deleteFile(file: photoFile) { (error) in
                if let error = error {
                    print(error)
                } else {
                    print("Deleted file with path \(photoFile.path)")
                }
            }
        }
        
        if let videoFile = asset.videoFileData {
            deleteFile(file: videoFile) { (error) in
                if let error = error {
                    print(error)
                } else {
                    print("Deleted file with path \(videoFile.path)")
                }
            }
        }
        
        let document = db.collection(Constants.assetsCollectionFirebaseName).document(asset.id)
        document.delete { (error) in
            completion(error)
        }
    }
    
    private func getStorageDownloadURL(path: String, completion: @escaping (URL?, Error?) -> Void) {
        let storageRef = storage.reference()
        let fileRef = storageRef.child(path)
        fileRef.downloadURL { (url, error) in
            completion(url, error)
        }
    }
    
    private func deleteFile(file: SongsCloudFileData, completion: @escaping (Error?) -> Void) {
        let storageRef = self.storage.reference()
        let fileRef = storageRef.child(file.path)
        fileRef.delete { (error) in
            completion(error)
        }
    }
    
    private func uploadFile(fileRef: StorageReference, data: Data, metadata: StorageMetadata, completion: @escaping (SongsCloudFileData?, Error?) -> Void) {
        fileRef.putData(data, metadata: metadata) { (_, error) in
            if let error = error {
                completion(nil, error)
            } else {
                self.getStorageDownloadURL(path: fileRef.fullPath) { (url, error) in
                    if let error = error {
                        completion(nil, error)
                    } else if let url = url {
                        completion(SongsCloudFileData(path: fileRef.fullPath, downloadURL: url.absoluteString), nil)
                    } else {
                        completion(nil, NSError.withLocalizedDescription("Both _ and error in uploadFile are nil"))
                    }
                }
            }
        }
    }
    
    private func uploadImage(_ photoNSURL: NSURL, completion: @escaping (SongsCloudFileData?, Error?) -> Void) {
        do {
            let url = photoNSURL as URL
            let imageData = try Data(contentsOf: url)
            
            if let image = UIImage(data: imageData)?.cropedToSquare()?.resizeImage(128, opaque: true) {
                if let data = image.jpegData(compressionQuality: 1) {
                    let storageRef = storage.reference()
                    let path = "\(Constants.imagesFolderFirebaseName)/\(UUID().uuidString).jpeg"
                    let imageRef = storageRef.child(path)
                    
                    let metadata = StorageMetadata()
                    metadata.contentType = "image/jpeg"
                    
                    uploadFile(fileRef: imageRef, data: data, metadata: metadata) { (fileData, error) in
                        completion(fileData, error)
                    }
                    
                } else {
                    completion(nil, NSError.withLocalizedDescription("Unable to get png data from image"))
                }
            } else {
                completion(nil, NSError.withLocalizedDescription("Unable to optimize image size and form"))
            }
        } catch {
            completion(nil, NSError.withLocalizedDescription("Unable to process image NSURL"))
        }
    }
    
    private func uploadVideo(_ videoNSURL: NSURL, completion: @escaping (SongsCloudFileData?, Error?) -> Void) {
        if let url = videoNSURL.absoluteURL {
            let avAsset = AVURLAsset(url: url)
            avAsset.exportVideo { (url) in
                if let url = url {
                    do {
                        let nsdata = try NSData(contentsOf: url, options: .mappedIfSafe)
                        let data = Data(referencing: nsdata)
                        
                        let storageRef = self.storage.reference()
                        let path = "\(Constants.videosFolderFirebaseName)/\(UUID().uuidString).mp4"
                        let imageRef = storageRef.child(path)
                        
                        let metadata = StorageMetadata()
                        metadata.contentType = "video/mp4"
                        
                        self.uploadFile(fileRef: imageRef, data: data, metadata: metadata) { (fileData, error) in
                            completion(fileData, error)
                        }
                    } catch {
                        completion(nil, NSError.withLocalizedDescription("Unable to convert video URL"))
                    }
                } else {
                    completion(nil, NSError.withLocalizedDescription("Unable to convert video"))
                }
            }
        } else {
            completion(nil, NSError.withLocalizedDescription("Unable to get video URL"))
        }
    }
    
    private func uploadAsset(_ asset: SongsAsset, completion: @escaping (Error?) -> Void) {
        do {
            let data = try encoder.encode(asset)
            if var json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                json.removeValue(forKey: "id")
                
                let document = db.collection(Constants.assetsCollectionFirebaseName).document(asset.id)
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
            let error = NSError.withLocalizedDescription("Unable to encode songs asset")
            completion(error)
        }
    }
    
    private func updateRemoteAssetRec(_ asset: SongsAsset, _ photoNSURL: NSURL?, _ videoNSURL: NSURL?, completion: @escaping (SongsAsset?, Error?) -> Void) {
        
        // Upload files 1 by 1 with every call
        // Priority:
        // 1 - Video
        // 2 - Image
        // 3 - Asset
        
        if asset.videoFileData?.downloadURL != videoNSURL?.absoluteString {
            var updatedAsset = asset
            
            // Delete previous file in background
            if let videoFileData = asset.videoFileData {
                updatedAsset.videoFileData = nil
                deleteFile(file: videoFileData) { (error) in
                    if let error = error {
                        print(error)
                    } else {
                        print("Deleted photo with path \(videoFileData.path)")
                    }
                }
            }
            
            // Upload with recursive call in completion
            if let videoNSURL = videoNSURL {
                uploadVideo(videoNSURL) { (fileData, error) in
                    if let error = error {
                        // Error uploading video so we ignore it
                        print(error)
                        self.updateRemoteAssetRec(updatedAsset, photoNSURL, nil, completion: completion)
                    } else if let fileData = fileData {
                        // Successful video upload
                        updatedAsset.videoFileData = fileData
                        
                        let downloadnsurl = NSURL(string: fileData.downloadURL)
                        self.updateRemoteAssetRec(updatedAsset, photoNSURL, downloadnsurl, completion: completion)
                    }
                }
            } else {
                self.updateRemoteAssetRec(updatedAsset, photoNSURL, videoNSURL, completion: completion)
            }
            
            return
        }
        
        
        if asset.photoFileData?.downloadURL != photoNSURL?.absoluteString {
            var updatedAsset = asset
            
            // Delete previous file in background
            if let photoFileData = asset.photoFileData {
                updatedAsset.photoFileData = nil
                deleteFile(file: photoFileData) { (error) in
                    if let error = error {
                        print(error)
                    } else {
                        print("Deleted photo with path \(photoFileData.path)")
                    }
                }
            }
            
            // Upload with recursive call in completion
            if let photoNSURL = photoNSURL {
                uploadImage(photoNSURL) { (fileData, error) in
                    if let error = error {
                        // Error uploading video so we ignore it
                        print(error)
                        self.updateRemoteAssetRec(updatedAsset, nil, videoNSURL, completion: completion)
                    } else if let fileData = fileData {
                        // Successful video upload
                        updatedAsset.photoFileData = fileData
                        
                        let downloadnsurl = NSURL(string: fileData.downloadURL)
                        self.updateRemoteAssetRec(updatedAsset, downloadnsurl, videoNSURL, completion: completion)
                    }
                }
            } else {
                self.updateRemoteAssetRec(updatedAsset, photoNSURL, videoNSURL, completion: completion)
            }
            
            return
        }
        
        uploadAsset(asset) { (error) in
            if let error = error {
                completion(nil, error)
            } else {
                completion(asset, nil)
            }
        }
        
    }
    
    func updateRemoteAsset(_ asset: SongsAsset, _ photoNSURL: NSURL?, _ videoNSURL: NSURL?, completion: @escaping (SongsAsset?, Error?) -> Void) {
        updateRemoteAssetRec(asset, photoNSURL, videoNSURL) { (updatedAssed, error) in
            completion(updatedAssed, error)
        }
    }
    
    func getRemoteAssets(completion: @escaping ([SongsAsset]?, Error?) -> Void) {
        db.collection(Constants.assetsCollectionFirebaseName).getDocuments { (query, error) in
            if let error = error {
                completion(nil, error)
            } else if let query = query {
                var assets: [SongsAsset] = []
                
                query.documents.forEach { (document) in
                    do {
                        var jsonData = document.data()
                        jsonData.updateValue(document.documentID, forKey: "id")
                        
                        if let data = try? JSONSerialization.data(withJSONObject: jsonData) {
                            var asset = try self.decoder.decode(SongsAsset.self, from: data)
                            asset.id = document.documentID
                            assets.append(asset)
                        } else {
                            print("Can't create json data from firebase document data")
                        }
                    } catch {
                        print(error)
                    }
                }
                
                completion(assets, nil)
            } else {
                completion(nil, NSError.withLocalizedDescription("Both query and error in getRemoteAssets are nil"))
            }
        }
    }
}
