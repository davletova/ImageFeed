//
//  ViewController.swift
//  ImageFeed
//
//  Created by Алия Давлетова on 04.05.2023.
//

import UIKit
import Kingfisher

protocol ImageListPresenterProtocol {
    func getPhotosNextPage()
    func checkIfNeedGetPhotosNextPage(indexPath: IndexPath)
    func changeLike(photo: Photo, handler: @escaping(Photo) -> Void)
    func updateTableViewAnimated()
    func calculateCellHeight(indexPath: IndexPath, tableViewBoundsWidth: CGFloat) -> CGFloat
}

class ImagesListViewController: UIViewController , ImagesListViewControllerProtocol{
    @IBOutlet weak private var tableView: UITableView!
    
    var photos: [Photo] = []
    
    static let DidChangeNotification = Notification.Name(rawValue: "ImageForSingleImageViewLoad")
    
    private let ShowSingleImageSegueIdentifier = "ShowSingleImage"
    
    var presenter: ImageListPresenterProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.accessibilityIdentifier = "ImageFeedTable"
        
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)

        guard let presenter = presenter else {
            assertionFailure("imageListViewController: imageListService is empty")
            return
        }
        
        presenter.getPhotosNextPage()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ShowSingleImageSegueIdentifier {
            guard let viewController = segue.destination as? SingleImageViewController else {
                assertionFailure("segue prepare: segue.destination has an unexpected type")
                return
            }
            guard let indexPath = sender as? IndexPath else {
                assertionFailure("segue prepare: sender has an unexpected type")
                return
            }
            
            if indexPath.row >= photos.count {
                assertionFailure("segue prepare: indexPath.row >= photos.count")
                return
            }
            
            guard let url = URL(string: photos[indexPath.row].largeImageURL) else {
                assertionFailure("failed to create url from: \(photos[indexPath.row].largeImageURL)")
                return
            }
            
            viewController.imageURL = url
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let imageListPresenter = presenter else {
            assertionFailure("presenter is nil")
            return
        }
        imageListPresenter.checkIfNeedGetPhotosNextPage(indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImageListCell.reuseIdentifier, for: indexPath)
        guard let imagListCell = cell as? ImageListCell else {
            return UITableViewCell()
        }
        
        imagListCell.delegate = self
        
        configCell(for: imagListCell, with: indexPath)
        return imagListCell
    }
    
    func configCell(for cell: ImageListCell, with indexPath: IndexPath) {
        if indexPath.row >= photos.count {
            assertionFailure("configCell: indexPath.row >= photos.count")
            return
        }

        let imageView = UIImageView()
        
        do {
            try loadImage(
                to: imageView,
                url: photos[indexPath.row].thumbImageURL
            ) { result in
                switch result {
                case .success(_):
                    self.tableView.reloadRows(at: [indexPath], with: .automatic)
                case .failure(let error):
                    print("load image failed with error: \(error)")
                    return
                }
            }
        }
        catch {
            print("load image failed with error: \(error)")
            return
        }
        
        cell.configCell(cellImage: imageView.image!, photoDate: self.photos[indexPath.row].createdAt, isImageLike: self.photos[indexPath.row].isLiked)
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let presenter = presenter else {
            assertionFailure("")
            return 0
        }
        return presenter.calculateCellHeight(indexPath: indexPath, tableViewBoundsWidth: tableView.bounds.width)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: ShowSingleImageSegueIdentifier, sender: indexPath)
    }
}

extension ImagesListViewController: ImageListCellDelegate {
    func imageListCellTapLike(_ cell: ImageListCell) {
        UIBlockingProgressHUD.show()
        
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        
        presenter?.changeLike(photo: photo) { newPhoto in
            self.photos[indexPath.row] = newPhoto
            
            cell.setIsLike(isImageLike: self.photos[indexPath.row].isLiked)
        }
    }
}

extension ImagesListViewController {
    func performBatchUpdates(indexPaths: [IndexPath]) {
        self.tableView.performBatchUpdates {
            self.tableView.insertRows(at: indexPaths, with: .automatic)
        } completion: { _ in }
    }
    
    func appendPhotos(photos: [Photo]) {
        self.photos.append(contentsOf: photos)
    }
}

enum LoadImageError: Error {
    case badUrl
}

extension ImagesListViewController {
    private func loadImage(
        to imageView: UIImageView,
        url: String,
        handler: @escaping(Result<RetrieveImageResult, KingfisherError>) -> Void
    ) throws {
        guard let photoURL = URL(string: url) else {
            throw LoadImageError.badUrl
        }
        
        let processor = RoundCornerImageProcessor(cornerRadius: 16)
        
        UIBlockingProgressHUD.show()
        
        imageView.kf.setImage(
            with: photoURL,
            placeholder: UIImage(named: "Stub"),
            options: [.processor(processor)],
            completionHandler: {result in
                UIBlockingProgressHUD.dismiss()
                handler(result)
            }
        )
    }
}

