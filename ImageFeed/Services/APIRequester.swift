//
//  APIRequester.swift
//  ImageFeed
//
//  Created by Алия Давлетова on 05.06.2023.
//

import Foundation

let tokenHTTPHeaderField = "Authorization"

final class APIRequester: NetworkRequester {
    private var accessToken: String
    
    init(accessToken: String) {
        self.accessToken = accessToken
    }
    
    override func doRequest<T: Decodable>(request: URLRequest, handler: @escaping (Result<T, Error>) -> Void) -> URLSessionTask {
        var request = request
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: tokenHTTPHeaderField)
        
        return super.doRequest(request: request, handler: handler)
    }
    
    func setToken(_ token: String) {
        accessToken = token
    }
}
