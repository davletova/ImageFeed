//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Алия Давлетова on 15.06.2023.
//

import Foundation

enum ImageSize: String {
    case small = "small"
    case medium = "medium"
    case large = "large"
}

struct GetPublicUserResponse: Decodable {
    let images: [String: String]
    
    private enum CodingKeys: String, CodingKey {
        case images = "profile_image"
    }
}

final class ProfileImageService {
    var apiRequester: APIRequester
    private (set) var avatarURL: String = ""
    
    static let DidChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    static let shared = getProfileImageService()
    static func getProfileImageService() -> ProfileImageService {
        let accessToken = OAuth2TokenStorage.shared.accessToken ?? ""
        return ProfileImageService(apiRequester: APIRequester(accessToken: accessToken))
    }
    
    init(apiRequester: APIRequester) {
        self.apiRequester = apiRequester
    }
    
    func getUserImage(username: String, handler: @escaping(Result<String, Error>) -> Void) {
        guard let baseUrl = URL(string: DefaultBaseURL) else {
            assertionFailure("failed to create url from \(DefaultBaseURL)")
            return
        }
        
        guard let request = URLRequest.makeHTTPRequest(
            baseUrl: baseUrl,
            path: "/users/\(username)",
            method: HTTPMehtod.get,
            body: nil) else {
                assertionFailure("faield to create getPublicUser request")
                return
            }
        
        _ = apiRequester.doRequest(request: request) { (result: Result<GetPublicUserResponse, Error>) in
            switch result {
            case .failure(let error):
                handler(.failure(error))
            case .success(let response):
               
                self.avatarURL = self.getImageURL(response: response) ?? ""
                
                handler(.success(self.avatarURL))
            }
        }
    }
    
    private func getImageURL(response: GetPublicUserResponse) -> String? {
        if let imageURL = response.images[ImageSize.small.rawValue]  {
            return imageURL
        }
        
        print("profile image's URL not found")
        return nil
    }
    
}
