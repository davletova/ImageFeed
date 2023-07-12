//
//  ImageListPresenter.swift
//  ImageFeed
//
//  Created by Алия Давлетова on 12.07.2023.
//

import Foundation

protocol ImageListServiceProtocol {
    func changeLike(photo: Photo, _ completion: @escaping(Result<ChangeLikeResponse, Error>) -> Void)
}

protocol ImageListViewControllerProtocol {
    var photos: [Photo] { get set }
    func performBatchUpdates()
}

final class ImageListPresenter {
    var imageListService: ImageListServiceProtocol
    var view: ImageListViewControllerProtocol?
    
    init(imageListService: ImageListServiceProtocol) {
        self.imageListService = imageListService
    }
    
    func changeLike(photo: Photo, _ handler: @escaping(Photo) -> Void) {
        imageListService.changeLike(photo: photo) { result in
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
            self.tableView.performBatchUpdates {
                self.tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in }
            
            oldPhotosCount = photos.count
        }
    }
}
