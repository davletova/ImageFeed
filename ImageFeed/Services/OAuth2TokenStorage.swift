//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Алия Давлетова on 01.06.2023.
//

import Foundation
import SwiftKeychainWrapper

private let accessTokenKeychainKey = "accessToken"

protocol OAuth2TokenStorageProtocol {
    var accessToken: String? {get set}
}

final class OAuth2TokenStorage: OAuth2TokenStorageProtocol {
    static let shared: OAuth2TokenStorageProtocol = OAuth2TokenStorage()
    
    var accessToken: String? {
        get {
            return KeychainWrapper.standard.string(forKey: accessTokenKeychainKey)
        }
        
        set {
            guard let newValue = newValue else {
                assertionFailure("write accessToken: newValue is empty")
                return
            }
            let isSuccess = KeychainWrapper.standard.set(newValue, forKey: accessTokenKeychainKey)
            
            guard isSuccess else {
                assertionFailure("failed to write access token in Keychain")
                return
            }
        }
    }
}

extension OAuth2TokenStorage: AccessTokenCleanerProtocol {
    func removeAccessToken() {
        KeychainWrapper.standard.remove(forKey: KeychainWrapper.Key(rawValue: accessTokenKeychainKey))
    }
}
