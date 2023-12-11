//
//  Constants.swift
//  ImageFeed
//
//  Created by Алия Давлетова on 28.05.2023.
//

import Foundation

let AccessKey = "<access_key>"

let SecretKey = "<secret_key>"

let RedirectURI = "urn:ietf:wg:oauth:2.0:oob"

let AccessScope = "public+read_user+write_likes"

let DefaultBaseURL = "https://api.unsplash.com"

let GetTokenURL = "https://unsplash.com/oauth/token"

let UnsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"

struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseURL: String
    let getTokenURL: String
    let authURLString: String
    
    init(accessKey: String, secretKey: String, redirectURI: String, accessScope: String, getTokenURL: String, defaultBaseURL: String, authURLString: String) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.defaultBaseURL = defaultBaseURL
        self.getTokenURL = getTokenURL
        self.authURLString = authURLString
    }
    
    static var standard: AuthConfiguration {
        return AuthConfiguration(accessKey: AccessKey,
                                 secretKey: SecretKey,
                                 redirectURI: RedirectURI,
                                 accessScope: AccessScope,
                                 getTokenURL: GetTokenURL,
                                 defaultBaseURL: DefaultBaseURL,
                                 authURLString: UnsplashAuthorizeURLString
        )
    }
}
