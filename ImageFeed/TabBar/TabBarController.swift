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
        
        let imageListViewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController")
        
        let profileViewController = ProfileViewController()
        let profilePresenter = ProfileViewPresenter(
            cookieCleaner: CookieCleaner(),
            oauth2TokenStorage: OAuth2TokenStorage(),
            avatarURLProvider: ProfileImageService.getProfileImageService())
        profileViewController.profileViewPresenter = profilePresenter
        profilePresenter.viewController = profileViewController
        
        profileViewController.tabBarItem = UITabBarItem(
            title: nil,
            image: UIImage(named: "tab_profile_no_active"),
            selectedImage: nil
        )
        
        self.viewControllers = [imageListViewController, profileViewController]
    }
}
