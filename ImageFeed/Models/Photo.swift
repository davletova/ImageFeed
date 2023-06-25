//
//  Photo.swift
//  ImageFeed
//
//  Created by Алия Давлетова on 24.06.2023.
//

import Foundation

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String //small
    let largeImageURL: String //full
    let isLiked: Bool
} 
