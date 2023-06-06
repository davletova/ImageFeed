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

struct BearerTokenProvider: TokenProviderProtocol {
    private let networkClient: NetworkRequesterProtocol = NetworkRequester()
    
    func getToken(code: String, handler: @escaping(Result<AccessTokenResponse, Error>) -> Void) {
        guard let authURL = authTokenRequestURL(code: code) else {
            return
        }
        
        guard let request = URLRequest.makeHTTPRequest(
            baseUrl: authURL,
            path: nil,
            method: HTTPMehtod.post,
            body: nil
        ) else {
            fatalError("failed to make getToken request")
        }
        
        networkClient.doRequest(request: request) { result in
            switch result {
            case .failure(let error):
                fatalError("getToken doRequest failed with error: \(error)")
            case .success(let data):
                do {
                    let accessTokenResponse = try JSONDecoder().decode(AccessTokenResponse.self, from: data)
                    handler(.success(accessTokenResponse))
                } catch {
                    print("failed to decode accessTokenResponse")
                    handler(.failure(error))
                }
            }
        }
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

