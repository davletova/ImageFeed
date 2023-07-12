//
//  AuthHelper.swift
//  ImageFeed
//
//  Created by Алия Давлетова on 07.07.2023.
//

import Foundation

protocol AuthHelperProtocol {
    func authRequest() -> URLRequest?
    func code(from url: URL) -> String?
}

class AuthHelper: AuthHelperProtocol {
    let configuration: AuthConfiguration
    
    init(configuration: AuthConfiguration = .standard) {
        self.configuration = configuration
    }
    
    func authRequest() -> URLRequest? {
        guard let url = authURL() else {
            return nil
        }
        return URLRequest(url: url)
    }

    func authURL() -> URL? {
        guard let baseURL = URL(string: configuration.authURLString) else {
            assertionFailure("failed to create URL from string \(configuration.authURLString)")
            return nil
        }
        
        let queryItems = [
            URLQueryItem(name: "client_id", value: AuthConfiguration.standard.accessKey),
            URLQueryItem(name: "redirect_uri", value: AuthConfiguration.standard.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: AuthConfiguration.standard.accessScope)
        ]
        
        guard let request = URLRequest.makeHTTPRequest(
            baseUrl: baseURL,
            path: nil,
            method: HTTPMehtod.get,
            queryItems: queryItems,
            body: nil) else {
            assertionFailure("failed to create UnsplashAuthorizeURL with query items")
            return nil
        }
        
        
        var urlComponents = URLComponents(string: configuration.authURLString)!
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: configuration.accessKey),
            URLQueryItem(name: "redirect_uri", value: configuration.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: configuration.accessScope)
        ]
        return urlComponents.url!
    }
    
    func code(from url: URL) -> String? {
        if let urlComponents = URLComponents(string: url.absoluteString),
           urlComponents.path == "/oauth/authorize/native",
           let items = urlComponents.queryItems,
           let codeItem = items.first(where: { $0.name == "code" })
        {
            return codeItem.value
        } else {
            return nil
        }
    }
}
