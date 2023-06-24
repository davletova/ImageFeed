//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Алия Давлетова on 24.06.2023.
//

import Foundation

let getPhotosPath = "/photos"

final class ImagesListService {

    private (set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    
    func getPhotosNextPage() {
        let nextPage = lastLoadedPage == nil ? 1 : lastLoadedPage! + 1
        
        guard let baseURL = URL(string: DefaultBaseURL) else {
            assertionFailure("failed to create url from \(DefaultBaseURL)")
            return
        }
        
        guard let request = URLRequest.makeHTTPRequest(
            baseUrl: baseURL,
            path: getPhotosPath,
            method: HTTPMehtod.get,
            queryItems: nil,
            body: nil)
        else {
            assertionFailure("failed to create request ")
            return
        }
    }
}

