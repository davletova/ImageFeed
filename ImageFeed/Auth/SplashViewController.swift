//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Алия Давлетова on 03.06.2023.
//

import UIKit
import ProgressHUD

let showAuthView = "ShowAuthView"
let showImageListView = "ShowImageListView"
let tabBarViewController = "TabBarViewController"

let networkErrorAlertTitle = "Что-то пошло не так"
let networkErrorAlertMessage = "Не удалось войти в систему"
let networkErrorAlertButtonText = "OK"

class SplashViewController: UIViewController {

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if OAuth2TokenStorage.shared.accessToken != nil {
            UIBlockingProgressHUD.show()
            
            getUser()
        } else {
            self.performSegue(withIdentifier: showAuthView, sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showAuthView {
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers[0] as? AuthViewController
            else {
                assertionFailure("Failed to prepare for \(showAuthView)")
                return
            }
            viewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    private func getUser() {
        ProfileService.shared.getUser() { result in
            DispatchQueue.main.async {
                print("inside getUser, DispatchQueue.main.sync")
                switch result {
                case (.failure(let error)):
                    if let err = error as? NetworkError,
                       err == NetworkError.AccessDenied {
                        self.performSegue(withIdentifier: showAuthView, sender: nil)
                    } else {
                        
                        
                        let alert = UIAlertController(title: networkErrorAlertTitle, message: networkErrorAlertMessage, preferredStyle: .alert)
                        let action = UIAlertAction(title: networkErrorAlertButtonText, style: .default) {_ in
                            print("failed")
                        }
                        
                        alert.addAction(action)
                        
                        self.present(alert, animated: true)
                        
                        
                        print("get user failed with error: \(error)")
                        break
                    }
                case (.success(let getUserResponse)):
                    self.getProfileImageURL(username: getUserResponse.username)
                }
            }
        }
    }
    
    private func getProfileImageURL(username: String) {
        ProfileImageService.shared.getUserImage(username: username) { result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    self.showAlert()
                    print("get profile image's URL failed with error: \(error.localizedDescription)")
                    return
                case .success(let profileImageURL):
                    NotificationCenter.default
                        .post(
                            name: ProfileImageService.DidChangeNotification,
                            object: self,
                            userInfo: ["URL": profileImageURL]
                        )
                }
                
                UIBlockingProgressHUD.dismiss()
                self.switchToTabBarController()
            }
        }
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid configuration")
            return
        }
        
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: tabBarViewController)
        
        window.rootViewController = tabBarController
    }
}

extension SplashViewController {
    private func showAlert() {
        let alert = UIAlertController(title: networkErrorAlertTitle, message: networkErrorAlertMessage, preferredStyle: .alert)
        let action = UIAlertAction(title: networkErrorAlertButtonText, style: .default) { _ in
            print("OK tab")
        }
        
        alert.addAction(action)
        
        self.present(alert, animated: true)
    }
}
