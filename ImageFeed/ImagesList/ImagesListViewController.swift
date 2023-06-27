//
//  ViewController.swift
//  ImageFeed
//
//  Created by Алия Давлетова on 04.05.2023.
//

import UIKit
import Kingfisher

class ImagesListViewController: UIViewController {
    @IBOutlet weak private var tableView: UITableView!
    
    private var photos: [Photo] = []
    
    private let ShowSingleImageSegueIdentifier = "ShowSingleImage"
    
    private var imageListServiceObserver: NSObjectProtocol?
    private var imageListService: ImagesListService?
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("viewDidLoad")
        
        imageListServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ImagesListService.DidChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else {
                    print("self nil")
                    return
                }
                self.updateTableViewAnimated()
            }
    
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        
        guard let accessToken = OAuth2TokenStorage.shared.accessToken else {
            assertionFailure("ImagesListViewController: access token not found")
            return
        }
        imageListService = ImagesListService(apiRequester: APIRequester(accessToken: accessToken))
        imageListService?.getPhotosNextPage() { response in
            switch response {
            case .failure(let error):
                assertionFailure("failed to getPhotosNextPage with error: \(error)")
                break
            case .success(let photos):
                self.photos.append(contentsOf: photos)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ShowSingleImageSegueIdentifier {
            guard let viewController = segue.destination as? SingleImageViewController else {
                print("segue prepare: segue.destination has an unexpected type")
                return
            }
            guard let indexPath = sender as? IndexPath else {
                print("segue prepare: sender has an unexpected type")
                return
            }
            
            if indexPath.row >= photos.count {
                print("prepare")
                return
            }
            
            let imageView = UIImageView()
            
            do {
                try loadImage(to: imageView, url: photos[indexPath.row].largeImageURL) { result in
                    switch result {
                    case .success(_):
                        DispatchQueue.main.async {
                            viewController.image = imageView.image
                        }
                    case .failure(let error):
                        print(error)
                    }
                }
            } catch {
                print("prepare error: \(error)")
                return
            }
            
//            imageListService?.getPhotosNextPage() { response in
//                switch response {
//                case .failure(let error):
//                    assertionFailure("failed to getPhotosNextPage with error: \(error)")
//                    break
//                case .success(let photos):
//                    self.photos = photos
//                }
//            }
//            guard let photoURL = URL(string: photos[indexPath.row].largeImageURL) else {
//                assertionFailure("failed to create URL from \(photos[indexPath.row].largeImageURL)")
//                return
//            }
//
//            let imageView = UIImageView()
//            let processor = RoundCornerImageProcessor(cornerRadius: 16)
//
//            imageView.kf.setImage(
//                with: photoURL,
//                placeholder: UIImage(named: "scribble.variable"),
//                options: [.processor(processor)]
//            ) { result in
//                imageView.kf.indicatorType = .none
//
//                switch result {
//                case .success(_):
//                    viewController.image = imageView.image
//                case .failure(let error):
//                    print(error)
//                }
//            }
//
//            imageView.kf.indicatorType = .activity
            
            
            
//            let image = UIImage(named: photosName[indexPath.row])
//            viewController.image = image
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("numberOfRowsInSection: \(photos.count)")
       return photos.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
      
        if indexPath.row == tableView.numberOfRows(inSection: 0) - 1 {
            imageListService?.getPhotosNextPage() { response in
                switch response {
                case .failure(let error):
                    assertionFailure("failed to getPhotosNextPage with error: \(error)")
                    break
                case .success(let photos):
//                    self.photos = photos
                    break
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImageListCell.reuseIdentifier, for: indexPath)
        
        guard let imagListCell = cell as? ImageListCell else {
            return UITableViewCell()
        }
        
        configCell(for: imagListCell, with: indexPath)
        return imagListCell
    }
    
    func configCell(for cell: ImageListCell, with indexPath: IndexPath) {
        if indexPath.row >= photos.count {
            print("indexPath.row >= photos.count")
            return
        }
        
        let imageView = UIImageView()
        
        do {
            try loadImage(
                to: imageView,
                url: photos[indexPath.row].thumbImageURL
            ) {
                result in
                    switch result {
                    case .success(_):
                        self.tableView.reloadRows(at: [indexPath], with: .automatic)
                    case .failure(let error):
                        print(error)
                    }
            }
        }
        catch {
            print("configCell failed: \(error)")
            return
        }
        
        guard let buttonImage = indexPath.row % 2 == 0 ? UIImage(named: "No Active") : UIImage(named: "Active") else { return }
        cell.configCell(cellImage: imageView.image!, dataLabel: dateFormatter.string(from: Date()), buttonImage: buttonImage)
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if photos.count <= indexPath.row {
            return 0
        }
        
        let photo = photos[indexPath.row]
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = photo.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = photo.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: ShowSingleImageSegueIdentifier, sender: indexPath)
    }
}

extension ImagesListViewController {
    private func updateTableViewAnimated() {
        let oldCout = photos.count
            
            
            let deleteCount = min(self.tableView.numberOfRows(inSection: 0), self.photos.count)
            self.tableView.performBatchUpdates {
                self.tableView.deleteRows(at: self.getIndexPathes(deleteCount), with: .automatic)
                self.tableView.insertRows(at: self.getIndexPathes(deleteCount), with: .automatic)
            }
        
    }
    
    private func getIndexPathes(_ count: Int) -> [IndexPath] {
        var result: [IndexPath] = []
        
        for i in 0..<count {
            result.append(IndexPath(row: i, section: 0))
        }
        
        return result
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
        
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(
            with: photoURL,
            placeholder: UIImage(named: "Stub"),
            options: [.processor(processor)],
            completionHandler: handler
        )
    }
}
