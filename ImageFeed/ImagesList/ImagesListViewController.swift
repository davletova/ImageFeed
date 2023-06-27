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
    private var oldPhotosCount = 0
    
    static let DidChangeNotification = Notification.Name(rawValue: "ImageForSingleImageViewLoad")
    
    private let ShowSingleImageSegueIdentifier = "ShowSingleImage"
    
    private var imageListService: ImagesListService?
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        
        guard let accessToken = OAuth2TokenStorage.shared.accessToken else {
            assertionFailure("ImagesListViewController: access token not found")
            return
        }
        imageListService = ImagesListService(apiRequester: APIRequester(accessToken: accessToken))
        imageListService?.getPhotosNextPage() { response in
            DispatchQueue.main.async {
                switch response {
                case .failure(let error):
                    assertionFailure("failed to getPhotosNextPage with error: \(error)")
                    break
                case .success(let photos):
                    
                    self.photos.append(contentsOf: photos)
                    
                    self.updateTableViewAnimated()
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ShowSingleImageSegueIdentifier {
            print("ShowSingleImageSegueIdentifier start")
            
            guard let viewController = segue.destination as? SingleImageViewController else {
                print("segue prepare: segue.destination has an unexpected type")
                return
            }
            guard let indexPath = sender as? IndexPath else {
                print("segue prepare: sender has an unexpected type")
                return
            }
            
            if indexPath.row >= photos.count {
                print("indexPath.row >= photos.count")
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
        if indexPath.row == photos.count - 1 {
            
            print("indexPath.row == photos.count - 1")
            
            imageListService?.getPhotosNextPage() { response in
                print("start getPhotosNextPage closure ")
                
                DispatchQueue.main.async {
                    switch response {
                    case .failure(let error):
                        assertionFailure("failed to getPhotosNextPage with error: \(error)")
                        break
                    case .success(let photos):
                        self.photos.append(contentsOf: photos)
                        self.updateTableViewAnimated()
                    }
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
        imageView.kf.indicator?.view.backgroundColor = .white
        imageView.kf.setImage(
            with: photoURL,
            placeholder: UIImage(named: "Stub"),
            options: [.processor(processor)],
            completionHandler: handler
        )
    }
}
