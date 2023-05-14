//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Алия Давлетова on 10.05.2023.
//

import Foundation
import UIKit

final class ImageListCell: UITableViewCell {
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var date: UILabel!
    
    static let reuseIdentifier = "ImageListCell"
}
