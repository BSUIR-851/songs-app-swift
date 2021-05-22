//
//  NSError.swift
//  Songs
//
//  Created by Yura Morozov on 15.05.21.
//

import Foundation

extension NSError {
    static func withLocalizedDescription(_ s: String) -> NSError {
        return NSError(
            domain: "",
            code: 0,
            userInfo: [
                NSLocalizedDescriptionKey : s
            ])
    }
}
