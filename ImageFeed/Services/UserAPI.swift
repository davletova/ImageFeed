//
//  UserAPI.swift
//  ImageFeed
//
//  Created by Алия Давлетова on 05.06.2023.
//

import Foundation

struct UserAPI {
    let getUserPath = "/me"
    
    var apiRequester: APIRequester
    
    init(apiRequester: APIRequester) {
        self.apiRequester = apiRequester
    }
    
    func getUser(handler: @escaping(Result<User, Error>) -> Void) {
        guard let baseURL = URL(string: DefaultBaseURL) else {
            fatalError("failed to create url from \(DefaultBaseURL)")
        }
        
        guard let request = URLRequest.makeHTTPRequest(
            baseUrl: baseURL,
            path: getUserPath,
            method: HTTPMehtod.get,
            body: nil
        ) else {
            fatalError("failed to create get user URL")
        }
        
        apiRequester.doRequest(request: request) { result in
            switch result {
            case .failure(let error):
                handler(.failure(error))
            case .success(let data):
                do {
                    let user = try JSONDecoder().decode(User.self, from: data)
                    handler(.success(user))
                } catch {
                    handler(.failure(error))
                }
            }
        }
    }
}
