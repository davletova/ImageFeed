//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Алия Давлетова on 18.05.2023.
//

import UIKit
import Kingfisher

let loadSingleImageErrorAlertTitle = "Что-то пошло не так."
let loadSingleImageErrorAlertMessage = "Попробовать ещё раз?"
let loadSingleImageErrorAlertActionRetry = "Повторить"
let loadSingleImageErrorAlertActionExit = "Не надо"

final class SingleImageViewController: UIViewController {
    var imageURL: URL?
    
    @IBOutlet private var sharingButton: UIButton!
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var backButton: UIButton!
    @IBOutlet private var imageView: UIImageView!
    
    @IBAction private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapShareButton() {
        let item = [imageView.image]
        let activityController = UIActivityViewController(activityItems: item as [Any], applicationActivities: nil)
        
        self.present(activityController, animated: true)
    }
    
    override func viewDidLoad() {
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        
        super.viewDidLoad()
        
        scrollView.accessibilityIdentifier = "ScrollImageView"
        backButton.accessibilityIdentifier = "BackButton"
        
        loadImage()
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        rescaleAndCenterImageInScrollView(image: imageView.image!)
    }
}

extension SingleImageViewController {
    private func loadImage() {
        guard let url = imageURL else {
            assertionFailure("SingleImageViewController: imageURL is empty")
            return
        }
        
        let processor = RoundCornerImageProcessor(cornerRadius: 16)
        
        UIBlockingProgressHUD.show()
        
        imageView.kf.setImage(
            with: url,
            placeholder: UIImage(named: "Stub"),
            options: [.processor(processor)]
        ) { result in
            UIBlockingProgressHUD.dismiss()
            
            switch result {
            case .success(_):
                self.rescaleAndCenterImageInScrollView(image: self.imageView.image!)
            case .failure(let error):
                print(error)
                self.showAlert()
                return
            }
        }
        
        guard let image = imageView.image else { return }
        self.rescaleAndCenterImageInScrollView(image: image)
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        
        view.layoutIfNeeded()
        
        let visibleRectSize = scrollView.bounds.size
        
        let imageSize = image.size
        
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        
        let scale = min(maxZoomScale, max(minZoomScale, max(hScale, vScale)))
        
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
    
    private func showAlert() {
        let alert = UIAlertController(title: loadSingleImageErrorAlertTitle, message: loadSingleImageErrorAlertMessage, preferredStyle: .alert)
        let actionRetry = UIAlertAction(title: loadSingleImageErrorAlertActionRetry, style: .default) {_ in
            self.loadImage()
        }
        let actionExit = UIAlertAction(title: loadSingleImageErrorAlertActionExit, style: .default) { _ in }
        
        alert.addAction(actionRetry)
        alert.addAction(actionExit)
        
        self.present(alert, animated: true)
    }
}
