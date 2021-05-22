//
//  LocaleSettings.swift
//  Songs
//
//  Created by Yura Morozov on 15.05.21.
//

import Foundation

enum LocaleSettings: String, Identifiable, Codable {
    var id: String {
        return self.rawValue
    }
    
    var languageCode: String {
        switch self {
            case .system:
                if let systemLanguageCode: String = Locale.current.languageCode {
                    return systemLanguageCode
                } else {
                    return "en"
                }
            case .en:
                return "en"
            case .ru:
                return "ru"
        }
    }
    
    case system = "sys_lang_e"
    case en = "en_lang_e"
    case ru = "ru_lang_e"
}
