//
//  Auth.swift
//  ImageFeed
//
//  Created by Алия Давлетова on 31.05.2023.
//

import Foundation

private let authRequestGrantType = "authorization_code"

protocol TokenProviderProtocol {
    func getToken(code: String, handler: @escaping(Result<AccessTokenResponse, Error>) -> Void)
}

struct AccessTokenResponse: Codable {
    let accessToken: String
    let tokenType: String
    let scope: String
    let createdAt: Int64
    
    private enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case scope = "scope"
        case createdAt = "created_at"
    }
}

final class BearerTokenProvider: TokenProviderProtocol {
    private let networkClient: NetworkRequesterProtocol = NetworkRequester()
    
    var task: URLSessionTask?
    var lastCode: String?
    
    func getToken(code: String, handler: @escaping(Result<AccessTokenResponse, Error>) -> Void) {
        assert(Thread.isMainThread)
        if lastCode == code {
            return
        }
        task?.cancel()
        lastCode = code
        
        guard let authURL = authTokenRequestURL(code: code) else {
            return
        }
        
        guard let request = URLRequest.makeHTTPRequest(
            baseUrl: authURL,
            path: nil,
            method: HTTPMehtod.post,
            queryItems: nil,
            body: nil
        ) else {
            assertionFailure("failed to make getToken request")
            return
        }
        
        let urlSessionTask = networkClient.doRequest(request: request) { (result: Result<AccessTokenResponse, Error>) in
            switch result {
            case .failure(let error):
                assertionFailure("getToken doRequest failed with error: \(error)")
            case .success(let response):
                self.task = nil
                
                handler(.success(response))
            }
        }
        
        task = urlSessionTask
    }
    
    func authTokenRequestURL(code: String) -> URL? {
        guard var urlComponents = URLComponents(string: GetTokenURL) else {
            print("failed to create url components for url \(GetTokenURL)")
            return nil
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: AccessKey),
            URLQueryItem(name: "client_secret", value: SecretKey),
            URLQueryItem(name: "redirect_uri", value: RedirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: authRequestGrantType)
        ]
        
        guard let url = urlComponents.url else {
            print("failed to get url from urlComponents")
            return nil
        }

        return url
    }
}

