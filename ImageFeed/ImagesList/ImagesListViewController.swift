//
//  ViewController.swift
//  ImageFeed
//
//  Created by Алия Давлетова on 04.05.2023.
//

import UIKit

class ImagesListViewController: UIViewController {
    @IBOutlet weak private var tableView: UITableView!
    
    private let photosName: [String] = Array(0..<20).map{"\($0)"}
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
        
        guard let accessToken = OAuth2TokenStorage.shared.accessToken else {
            assertionFailure("ImagesListViewController: access token not found")
            return
        }
        imageListService = ImagesListService(apiRequester: APIRequester(accessToken: accessToken))
        
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
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
            let image = UIImage(named: photosName[indexPath.row])
            viewController.image = image
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photosName.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        imageListService?.getPhotosNextPage() { response in
            
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
        guard let image = UIImage(named: photosName[indexPath.row]) else { return }
        guard let buttonImage = indexPath.row % 2 == 0 ? UIImage(named: "No Active") : UIImage(named: "Active") else { return }
        
        cell.configCell(cellImage: image, dataLabel: dateFormatter.string(from: Date()), buttonImage: buttonImage)
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let image = UIImage(named: photosName[indexPath.row]) else {
            return 0
        }
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = image.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = image.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: ShowSingleImageSegueIdentifier, sender: indexPath)
    }
}

