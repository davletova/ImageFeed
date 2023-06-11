//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Алия Давлетова on 01.06.2023.
//

import Foundation

private let accessTokenKey = "accessToken"

protocol OAuth2TokenStorageProtocol {
    var accessToken: String? {get set}
}

class OAuth2TokenStorage: OAuth2TokenStorageProtocol {
    private let userDefaults = UserDefaults.standard
    
    var accessToken: String? {
        get {
            return userDefaults.string(forKey: accessTokenKey)
        }
        
        set {
            userDefaults.set(newValue, forKey: accessTokenKey)
        }
    }
}
