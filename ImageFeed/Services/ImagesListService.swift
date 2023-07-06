//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Алия Давлетова on 24.06.2023.
//

import Foundation

let getPhotosPath = "/photos"
let perPage = 10
let thumbImageURLKey = "small"
let largeImageURLKey = "full"

struct UnsplashPhoto: Codable {
    var id: String
    var width: Int
    var height: Int
    var createdAt: String
    var description: String?
    var urls: [String: String]
    var likedByUser: Bool
    
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case width = "width"
        case height = "height"
        case createdAt = "created_at"
        case description = "description"
        case urls = "urls"
        case likedByUser = "liked_by_user"
    }
}

final class ImagesListService {
    private let apiRequester: APIRequester
    
    private var lastLoadedPage: Int?
    
    private var dataTask: URLSessionTask?
    
    init(apiRequester: APIRequester) {
        self.apiRequester = apiRequester
    }

    func getPhotosNextPage(handler: @escaping(Result<[Photo], Error>) -> Void) {
        assert(Thread.isMainThread)
        if dataTask != nil {
            return
        }
        
        let nextPage = lastLoadedPage == nil ? 1 : lastLoadedPage! + 1
        
        guard let baseURL = URL(string: DefaultBaseURL) else {
            assertionFailure("failed to create url from \(DefaultBaseURL)")
            return
        }
        
        let queryItems: [URLQueryItem] = [
            URLQueryItem(name: "page", value: nextPage.description),
            URLQueryItem(name: "per_page", value: perPage.description)
        ]
        
        guard let request = URLRequest.makeHTTPRequest(
            baseUrl: baseURL,
            path: getPhotosPath,
            method: HTTPMehtod.get,
            queryItems: queryItems,
            body: nil)
        else {
            assertionFailure("failed to create request ")
            return
        }
        
        dataTask = apiRequester.doRequest(request: request) { (result: Result<[UnsplashPhoto], Error>) in
            self.dataTask = nil
            
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    handler(.failure(error))
                case .success(let response):
                    self.lastLoadedPage = nextPage
                    
                    var photosPerPage: [Photo] = []
                    for unsplashPhoto in response {
                        guard let photo = self.convertUnsplashPhotoToPhoto(unsplashPhoto: unsplashPhoto) else {
                            print("failed to convert unsplashPhoto to Photo")
                            continue
                        }
                        
                        photosPerPage.append(photo)
                    }
                    
                    handler(.success(photosPerPage))
                }
            }
        }
    }
}

extension ImagesListService {
    private func convertUnsplashPhotoToPhoto(unsplashPhoto: UnsplashPhoto) -> Photo? {
        guard let thumbImageURL = unsplashPhoto.urls[thumbImageURLKey] else {
            assertionFailure("small image URL not found")
            return nil
        }
        
        guard let largeImageURL = unsplashPhoto.urls[largeImageURLKey] else {
            assertionFailure("full image URL not found")
            return nil
        }
        
        return Photo(
            id: unsplashPhoto.id,
            size: CGSize(width: unsplashPhoto.width, height: unsplashPhoto.height),
            createdAt: unsplashPhoto.createdAt.stringDateTime,
            welcomeDescription: unsplashPhoto.description,
            thumbImageURL: thumbImageURL,
            largeImageURL: largeImageURL,
            isLiked: unsplashPhoto.likedByUser
        )
    }
}

extension ImagesListService {
    struct ChangeLikeResponse: Decodable {
        let photo: UnsplashPhoto
        
        private enum CodingKeys: String, CodingKey {
            case photo = "photo"
        }
    }
    
    func changeLike(photo: Photo, _ completion: @escaping(Result<ChangeLikeResponse, Error>) -> Void) {
        guard let baseURL = URL(string: DefaultBaseURL) else {
            assertionFailure("failed to create URL from \(DefaultBaseURL)")
            return
        }
        let path = "/photos/\(photo.id)/like"
        let httpMethod: HTTPMehtod
        
        switch photo.isLiked {
        case true:
            httpMethod = HTTPMehtod.delete
        case false:
            httpMethod = HTTPMehtod.post
        }
        
        guard let request = URLRequest.makeHTTPRequest(
            baseUrl: baseURL,
            path: path,
            method: httpMethod,
            queryItems: nil,
            body: nil
        ) else {
            assertionFailure("failed to create like request")
            return
        }
        
        _ = apiRequester.doRequest(request: request, handler: completion)
    }
}
