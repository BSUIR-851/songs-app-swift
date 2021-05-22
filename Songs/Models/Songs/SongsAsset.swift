//
//  SongsRecord.swift
//  Songs
//
//  Created by Yura Morozov on 15.05.21.
//

import Foundation

struct SongsAsset: Codable, Identifiable {
    var id: String
    var name: String
    var author: String
    var description: String
    var year: Int
    
    var photoFileData: SongsCloudFileData?
    var videoFileData: SongsCloudFileData?
    
    var release: SongsMapRelease?
}
