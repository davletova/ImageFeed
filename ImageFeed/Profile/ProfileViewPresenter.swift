//
//  ProfileViewPresenter.swift
//  ImageFeed
//
//  Created by Алия Давлетова on 11.07.2023.
//

import Foundation
import UIKit
import Kingfisher

protocol ProfileViewPresenterProtocol {
    func logout()
    func updateAvatar()
}

protocol CookieCleenerProtocol {
    func clean()
}

protocol AccessTokenCleanerProtocol {
    func removeAccessToken()
}

protocol AvatarURLProviderProtocol {
    func getAvatarURL() -> String
}

final class ProfileViewPresenter: ProfileViewPresenterProtocol {
    var viewController: ProfileViewControllerProtocol?
    private var profileImageServiceObserver: NSObjectProtocol?
    
    var cookieCleaner: CookieCleenerProtocol
    var oauth2TokenStorage: AccessTokenCleanerProtocol
    var avatarURLProvider: AvatarURLProviderProtocol
    
    init(cookieCleaner: CookieCleenerProtocol, oauth2TokenStorage: AccessTokenCleanerProtocol, avatarURLProvider: AvatarURLProviderProtocol) {
        self.cookieCleaner = cookieCleaner
        self.oauth2TokenStorage = oauth2TokenStorage
        self.avatarURLProvider = avatarURLProvider
    }
    
    func viewDidLoad() {
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.DidChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.updateAvatar()
            }
    }
    
    func logout() {
        oauth2TokenStorage.removeAccessToken()
        cookieCleaner.clean()
        
        goToSplash()
    }
    
    private func goToSplash() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        guard let splashViewController = storyboard.instantiateInitialViewController() else {
            assertionFailure("ProfileViewController.goToSplash: storyboard.instantiateInitialViewController() not found")
            return
        }
        
        splashViewController.modalPresentationStyle = .fullScreen
        
        guard let viewController = viewController else {
            assertionFailure("ProfileViewPresenter: viewController is empty")
            return
        }
        viewController.present(controller: splashViewController)
    }
    
    func updateAvatar() {
        let profileImageURL = avatarURLProvider.getAvatarURL()
        guard let url = URL(string: profileImageURL) else {
            assertionFailure("updateAvatar: create profileImageURL failed ")
            return }
       
        guard let viewController = viewController else {
            assertionFailure("ProfileViewPresenter: viewController is empty")
            return
        }
        
        viewController.setImage(url: url)
    }
}
