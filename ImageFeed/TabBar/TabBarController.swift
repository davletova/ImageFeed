//
//  TabBarController.swift
//  ImageFeed
//
//  Created by Алия Давлетова on 19.06.2023.
//

import UIKit

final class TabBarController: UITabBarController {
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        
        guard let imagesListViewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as? ImagesListViewController else {
            assertionFailure("failed to convert controller with identifier ImagesListViewController to ImagesListViewController")
            return
        }
        
        guard let accessToken = OAuth2TokenStorage.shared.accessToken else {
            print("ImagesListViewController: access token not found")
            return
        }
        let imagesListService = ImagesListService(apiRequester: APIRequester(accessToken: accessToken))
        
        let imagesListPresenter = ImageListPresenter(service: imagesListService, view: imagesListViewController)
        imagesListViewController.presenter = imagesListPresenter
        
        let profileViewController = ProfileViewController()
        let profilePresenter = ProfileViewPresenter(
            cookieCleaner: CookieCleaner(),
            oauth2TokenStorage: OAuth2TokenStorage(),
            avatarURLProvider: ProfileImageService.shared)
        profileViewController.profileViewPresenter = profilePresenter
        profilePresenter.viewController = profileViewController
        
        profileViewController.tabBarItem = UITabBarItem(
            title: nil,
            image: UIImage(named: "tab_profile_no_active"),
            selectedImage: nil
        )
        
        self.viewControllers = [imagesListViewController, profileViewController]
    }
}
