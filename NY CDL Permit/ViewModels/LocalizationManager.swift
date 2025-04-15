//
//  Untitled 2.swift
//  NY CDL Permit
//
//  Created by PDA-Jacky on 4/12/25.
//

import Foundation

final class LocalizationManager {
    static let shared = LocalizationManager()

    private init() {
        loadSavedLanguage()
    }
    
    private(set) var currentLanguage: String = "en"

    func setLanguage(_ language: String) {
        currentLanguage = language
        UserDefaults.standard.set(language, forKey: "selectedLanguage")
    }
    
    private func loadSavedLanguage() {
        if let savedLanguage = UserDefaults.standard.string(forKey: "selectedLanguage") {
            currentLanguage = savedLanguage
        } else {
            let localeId = Locale.current.identifier
            if localeId.starts(with: "zh-Hant") {
                currentLanguage = "zh-Hant"
            } else if localeId.starts(with: "zh-Hans") {
                currentLanguage = "zh-Hans"
            } else if let langCode = Locale.current.language.languageCode?.identifier {
                currentLanguage = langCode
            } else {
                currentLanguage = "en"
            }
        }
    }

    func localizedString(_ key: String) -> String {
        guard let path = Bundle.main.path(forResource: currentLanguage, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            // Fallback to default localization
            return NSLocalizedString(key, comment: "")
        }
        return NSLocalizedString(key, tableName: nil, bundle: bundle, value: "", comment: "")
    }
}
