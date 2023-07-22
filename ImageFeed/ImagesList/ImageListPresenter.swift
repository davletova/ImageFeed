//
//  ImageListPresenter.swift
//  ImageFeed
//
//  Created by Алия Давлетова on 12.07.2023.
//

import Foundation
import UIKit

protocol ImagesListServiceProtocol {
    func changeLike(photo: Photo, _ completion: @escaping(Result<ChangeLikeResponse, Error>) -> Void)
    func getPhotosNextPage(handler: @escaping(Result<[Photo], Error>) -> Void)
}

protocol ImagesListViewControllerProtocol {
    func performBatchUpdates(indexPaths: [IndexPath])
}

final class ImageListPresenter: ImageListPresenterProtocol {
    var service: ImagesListServiceProtocol
    var view: ImagesListViewControllerProtocol
    
    var photos: [Photo] = []
    
    internal var oldPhotosCount = 0
    
    init(service: ImagesListServiceProtocol, view: ImagesListViewControllerProtocol) {
        self.service = service
        self.view = view
    }
    
    func getPhotosNextPage() {
        service.getPhotosNextPage() { response in
            DispatchQueue.main.async {
                switch response {
                case .failure(let error):
                    print("failed to getPhotosNextPage with error: \(error)")
                    break
                case .success(let photos):
                    self.photos.append(contentsOf: photos)
                    
                    self.updateTableViewAnimated()
                }
            }
        }
    }
    
    func checkIfNeedGetPhotosNextPage(indexPath: IndexPath) {
        if indexPath.row == photos.count - 1 {
            getPhotosNextPage()
        }
    }
    
    func changeLike(photo: Photo, handler: @escaping(Photo) -> Void) {
        service.changeLike(photo: photo) { result in
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()
                
                switch result {
                case .failure(let error):
                    print("request to change like failed with error: \(error)")
                    return
                case .success(_):
                    let newPhoto = Photo(
                        id: photo.id,
                        size: photo.size,
                        createdAt: photo.createdAt,
                        welcomeDescription: photo.welcomeDescription,
                        thumbImageURL: photo.thumbImageURL,
                        largeImageURL: photo.largeImageURL,
                        isLiked: !photo.isLiked
                    )
                    
                    handler(newPhoto)
                }
            }
        }
    }
    
    func updateTableViewAnimated() {
        if oldPhotosCount != photos.count {
            let indexPaths = (oldPhotosCount..<photos.count).map{ i in
                IndexPath(row: i, section: 0)
            }
            
            view.performBatchUpdates(indexPaths: indexPaths)
            
            oldPhotosCount = photos.count
        }
    }
    
    func calculateCellHeight(indexPath: IndexPath, tableViewBoundsWidth: CGFloat) -> CGFloat {
        if photos.count <= indexPath.row {
            return 0
        }
        
        let photo = photos[indexPath.row]
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableViewBoundsWidth - imageInsets.left - imageInsets.right
        let imageWidth = photo.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = photo.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
}
