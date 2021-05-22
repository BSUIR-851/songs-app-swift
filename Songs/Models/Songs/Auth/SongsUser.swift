//
//  SongsUser.swift
//  Songs
//
//  Created by Yura Morozov on 16.05.21.
//

import Foundation

struct SongsUser: Codable {
    var id: String
    var email: String
    var isAdmin: Bool = false
    var isBlocked: Bool = false
}
