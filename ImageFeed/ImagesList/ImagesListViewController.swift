//
//  ViewController.swift
//  ImageFeed
//
//  Created by Алия Давлетова on 04.05.2023.
//

import UIKit
import Kingfisher

protocol ImageListPresenterProtocol {
    var photos: [Photo] { get set }
    
    func getPhotosNextPage()
    func checkIfNeedGetPhotosNextPage(indexPath: IndexPath)
    func changeLike(photo: Photo, handler: @escaping(Photo) -> Void)
    func updateTableViewAnimated()
    func calculateCellHeight(indexPath: IndexPath, tableViewBoundsWidth: CGFloat) -> CGFloat
}

final class ImagesListViewController: UIViewController , ImagesListViewControllerProtocol{
    @IBOutlet weak private var tableView: UITableView!
    
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
            
            guard let presenter = presenter else {
                assertionFailure("prepare: presenter is empty")
                return
            }
            
            if indexPath.row >= presenter.photos.count {
                assertionFailure("segue prepare: indexPath.row >= photos.count")
                return
            }
            
            guard let url = URL(string: presenter.photos[indexPath.row].largeImageURL) else {
                assertionFailure("failed to create url from: \(presenter.photos[indexPath.row].largeImageURL)")
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
        guard let presenter = presenter else {
            assertionFailure("calculate numberOfRowsInSection: presenter is empty")
            return 0
        }
        return presenter.photos.count
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
        guard let presenter = presenter else {
            assertionFailure("config cell: imageListService is empty")
            return
        }
        if indexPath.row >= presenter.photos.count {
            assertionFailure("configCell: indexPath.row >= photos.count")
            return
        }

        let imageView = UIImageView()
        
        do {
            try loadImage(
                to: imageView,
                url: presenter.photos[indexPath.row].thumbImageURL
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
        
        cell.configCell(cellImage: imageView.image!, photoDate: presenter.photos[indexPath.row].createdAt, isImageLike: presenter.photos[indexPath.row].isLiked)
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let presenter = presenter else {
            assertionFailure("calculate heightForRowAt: presenter is empty")
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
        
        guard var presenter = presenter else {
            assertionFailure("imageListCellTapLike: presenter is empty")
            return
        }
        
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = presenter.photos[indexPath.row]
        
        presenter.changeLike(photo: photo) { newPhoto in
            presenter.photos[indexPath.row] = newPhoto
            
            cell.setIsLike(isImageLike: presenter.photos[indexPath.row].isLiked)
        }
    }
}

extension ImagesListViewController {
    func performBatchUpdates(indexPaths: [IndexPath]) {
        self.tableView.performBatchUpdates {
            self.tableView.insertRows(at: indexPaths, with: .automatic)
        } completion: { _ in }
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

