//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Алия Давлетова on 10.05.2023.
//

import Foundation
import UIKit

final class ImageListCell: UITableViewCell {
    @IBOutlet private var cellImageView: UIImageView!
    @IBOutlet private var likeButton: UIButton!
    @IBOutlet private var date: UILabel!
    
    static let reuseIdentifier = "ImageListCell"
}

extension ImageListCell {
    public func configCell(cellImage: UIImage, dataLabel: String, buttonImage: UIImage) {
        cellImageView.image = cellImage
        date.text = dataLabel
        likeButton.setImage(buttonImage, for: .normal)
    }
}
