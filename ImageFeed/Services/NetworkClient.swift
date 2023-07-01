//
//  NetworkClient.swift
//  ImageFeed
//
//  Created by Алия Давлетова on 31.05.2023.
//

import Foundation

enum HTTPMehtod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

protocol NetworkRequesterProtocol {
    func doRequest<T: Decodable>(request: URLRequest, handler: @escaping (Result<T, Error>) -> Void) -> URLSessionTask
}

enum NetworkError: Error {
   case CodeError
   case AccessDenied
}

class NetworkRequester: NetworkRequesterProtocol {
    func doRequest<T: Decodable>(
        request: URLRequest,
        handler: @escaping(Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                handler(.failure(error))
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                print("failed to convert response")
                return
            }

            if response.statusCode == 401 {
                handler(.failure(NetworkError.AccessDenied))
                return
            }
            
            if response.statusCode < 200 || response.statusCode >= 300 {
                handler(.failure(NetworkError.CodeError))
                return
            }
            
            guard let data = data else { return }
            
            do {
                let result = try JSONDecoder().decode(T.self, from: data)
                handler(.success(result))
            }
            catch {
                print("decode error")
                handler(.failure(error))
            }
        }
        
        task.resume()
        return task
    }
}

