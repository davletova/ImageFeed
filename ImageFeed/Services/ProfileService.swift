//
//  UserAPI.swift
//  ImageFeed
//
//  Created by Алия Давлетова on 05.06.2023.
//

import Foundation

let getUserPath = "/me"

struct GetUserResponse: Codable {
    let id: String
    let username: String
    let firstName: String
    let lastName: String?
    let bio: String?
    let links: [String: String]
    
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case username = "username"
        case firstName = "first_name"
        case lastName = "last_name"
        case bio = "bio"
        case links = "links"
    }
}

final class ProfileService {
    var apiRequester: APIRequester
    
    var profile: Profile?
    
    static let shared: ProfileService = getProfileService()
    
    static private func getProfileService() -> ProfileService {
        let accessToken = OAuth2TokenStorage.shared.accessToken ?? ""
        return ProfileService(apiRequester: APIRequester(accessToken: accessToken))
    }
    
    init(apiRequester: APIRequester) {
        self.apiRequester = apiRequester
    }
    
    func getUser(handler: @escaping(Result<GetUserResponse, Error>) -> Void) {
        guard let baseURL = URL(string: DefaultBaseURL) else {
            assertionFailure("failed to create url from \(DefaultBaseURL)")
            return
        }
        
        guard let request = URLRequest.makeHTTPRequest(
            baseUrl: baseURL,
            path: getUserPath,
            method: HTTPMehtod.get,
            queryItems: nil,
            body: nil
        ) else {
            assertionFailure("failed to create get user URL")
            return
        }
        
        _ = apiRequester.doRequest(request: request) { (result: Result<GetUserResponse, Error>) in
            switch result {
            case .failure(let error):
                handler(.failure(error))
            case .success(let response):
                self.updateProfileDetails(user: response)
                
                handler(.success(response))
            }
        }
    }
    
    private func updateProfileDetails(user: GetUserResponse) {
        let name = "\(user.firstName) \(user.lastName ?? "")"
        let login = user.username
        let description = user.bio ?? ""
        
        profile = Profile(name: name, login: login, description: description)
    }
}
