//
//  URLRequest.swift
//  ImageFeed
//
//  Created by Алия Давлетова on 01.06.2023.
//

import Foundation

extension URLRequest {
    static func makeHTTPRequest(
        baseUrl: URL,
        path: String?,
        method: HTTPMehtod,
        queryItems: [URLQueryItem]?,
        body: Encodable?
    ) -> URLRequest? {
        var url = baseUrl
        
        if let path = path {
            guard let createURL = URL(string: path, relativeTo: baseUrl) else {
                print("failed to create url from \(baseUrl.absoluteString) and \(path)")
                return nil
            }
            url = createURL
        }
        
        if let qi = queryItems,
           var urlComponents = URLComponents(string: url.absoluteString)
        {
            urlComponents.queryItems = qi
            
            if let urlWithQueryItems = urlComponents.url {
                url = urlWithQueryItems
            } else {
                assertionFailure("failed to create url with query items")
                return nil
            }
        }
 
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
        request.httpMethod = method.rawValue
        if let body = body {
            guard let data = try? JSONEncoder().encode(body) else {
                print("failed to encode request body")
                return nil
            }
            request.httpBody = data
        }
        
        request.timeoutInterval = 10
        
        return request
    }
}
