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
        
        cellImageView.kf.cancelDownloadTask()
    }
}

extension ImageListCell {
    public func configCell(cellImage: UIImage, photoDate: Date?, buttonImage: UIImage) {
        cellImageView.image = cellImage
        date.text = ""
        if let photoDate = photoDate {
            date.text = dateFormatter.string(from: photoDate)
        }
        likeButton.setImage(buttonImage, for: .normal)
    }
    
    public func setIsLike(buttonImage: UIImage) {
        likeButton.setImage(buttonImage, for: .normal)
    }
}
