//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Алия Давлетова on 03.06.2023.
//

import UIKit

let showAuthView = "ShowAuthView"
let showImageListView = "ShowImageListView"
let tabBarViewController = "TabBarViewController"

class SplashViewController: UIViewController {
    var user: User?
    
    let auth2TokenStorage: OAuth2TokenStorageProtocol = OAuth2TokenStorage()
    var apiRequester: APIRequester?
    var userAPI: UserAPI?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let token = auth2TokenStorage.accessToken {
            self.apiRequester = APIRequester(accessToken: token)
            self.userAPI = UserAPI(apiRequester: self.apiRequester!)
            
            self.userAPI?.getUser() { result in
                DispatchQueue.main.async {
                    switch result {
                    case (.failure(let error)):
                        if let err = error as? NetworkError,
                           err == NetworkError.AccessDenied {
                            self.performSegue(withIdentifier: showAuthView, sender: nil)
                        } else {
                            fatalError("get user failed with error: \(error)")
                        }
                    case (.success(let user)):
                        self.user = user
                        self.switchToTabBarController()
                    }
                }
            }
        } else {
            self.performSegue(withIdentifier: showAuthView, sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showAuthView {
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers[0] as? AuthViewController
            else { fatalError("Failed to prepare for \(showAuthView)") }
            viewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            fatalError("Invalid configuration")
        }
        
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: tabBarViewController)
        
        if let profileView = tabBarController.children[1] as? ProfileViewController {
            profileView.user = self.user
        }
        
        window.rootViewController = tabBarController
    }
}
