//
//  Settings.swift
//  Songs
//
//  Created by Yura Morozov on 15.05.21.
//

import UIKit
import Foundation

struct SettingsData: Codable {
    
    static let localeKey = "email"
    static let fontNameKey = "fontName"
    static let fontSizeKey = "fontSize"
    
    var localization = LocaleSettings.system {
        didSet {
            saveToDefaultUD()
        }
    }
    
    var fontName: String = "Verdana-Italic" {
        didSet {
            saveToDefaultUD()
        }
    }
    
    var fontSize: CGFloat = 16 {
        didSet {
            saveToDefaultUD()
        }
    }
    
    private func saveToDefaultUD() {
        UserDefaults.standard.setValue(localization.rawValue, forKey: SettingsData.localeKey)
        UserDefaults.standard.setValue(fontName, forKey: SettingsData.fontNameKey)
        UserDefaults.standard.setValue(fontSize, forKey: SettingsData.fontSizeKey)
    }
    
    static func restoreFromDefaultUD() -> SettingsData {
        if let code = UserDefaults.standard.string(forKey: SettingsData.localeKey),
           let locale = LocaleSettings.init(rawValue: code),
           let fontName = UserDefaults.standard.string(forKey: SettingsData.fontNameKey),
           let fontSize = UserDefaults.standard.float(forKey: SettingsData.fontSizeKey) as? Float {
            return SettingsData(localization: locale, fontName: fontName, fontSize: CGFloat(fontSize))
        } else {
            return SettingsData()
        }
    }
}
