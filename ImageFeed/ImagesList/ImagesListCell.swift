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
        delegate?.imageListCellTapLike(self)
    }
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    static let reuseIdentifier = "ImageListCell"
    
    override func prepareForReuse() {
        super.prepareForReuse()
     
        likeButton.accessibilityIdentifier = "LikeButton"
        cellImageView.kf.cancelDownloadTask()
    }
}

extension ImageListCell {
    public func configCell(cellImage: UIImage, photoDate: Date?, isImageLike: Bool) {
        cellImageView.image = cellImage
        date.text = ""
        if let photoDate = photoDate {
            date.text = dateFormatter.string(from: photoDate)
        }
        
        guard let buttonImage = isImageLike ? UIImage(named: "Active") : UIImage(named: "No Active") else {
            assertionFailure("configCell: failed to get likeButton image")
            return
        }
        likeButton.setImage(buttonImage, for: .normal)
        likeButton.accessibilityIdentifier = isImageLike ? "LikeButton" : "UnlikeButton"
    }
    
    public func setIsLike(isImageLike: Bool) {
        guard let buttonImage = isImageLike ? UIImage(named: "Active") : UIImage(named: "No Active") else {
            assertionFailure("configCell: failed to get likeButton image")
            return
        }
        likeButton.setImage(buttonImage, for: .normal)
        likeButton.accessibilityIdentifier = isImageLike ? "LikeButton" : "UnlikeButton"
    }
}
