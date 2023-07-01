//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Алия Давлетова on 10.05.2023.
//

import Foundation
import UIKit

protocol ImageListCellDelegate: AnyObject {
    func imageListCellTapLike(_ cell: ImageListCell)
}

final class ImageListCell: UITableViewCell {
    weak var delegate: ImageListCellDelegate?
    
    @IBOutlet private var cellImageView: UIImageView!
    @IBOutlet private var likeButton: UIButton!
    @IBOutlet private var date: UILabel!
    
    @IBAction func likeButtonClicked(_ sender: Any) {
        print("LIKE!!!")
        delegate?.imageListCellTapLike(self)
    }
    
    static let reuseIdentifier = "ImageListCell"
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        cellImageView.kf.cancelDownloadTask()
    }
}

extension ImageListCell {
    public func configCell(cellImage: UIImage, dataLabel: String, buttonImage: UIImage) {
        cellImageView.image = cellImage
        date.text = dataLabel
        likeButton.setImage(buttonImage, for: .normal)
    }
    
    public func setIsLike(buttonImage: UIImage) {
        likeButton.setImage(buttonImage, for: .normal)
    }
}
