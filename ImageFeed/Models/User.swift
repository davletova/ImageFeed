//
//  User.swift
//  ImageFeed
//
//  Created by Алия Давлетова on 04.06.2023.
//

import Foundation

struct User: Codable {
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
