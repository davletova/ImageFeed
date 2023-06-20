//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Алия Давлетова on 03.06.2023.
//

import UIKit
import ProgressHUD

let showImageListView = "ShowImageListView"
let tabBarViewController = "TabBarViewController"

let networkErrorAlertTitle = "Что-то пошло не так"
let networkErrorAlertMessage = "Не удалось войти в систему"
let networkErrorAlertButtonText = "OK"

class SplashViewController: UIViewController {

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        view.backgroundColor = UIColor(named: "YP Black")
        
        createLogo()
        
        if OAuth2TokenStorage.shared.accessToken != nil {
            UIBlockingProgressHUD.show()
            
            getUser()
        } else {
            goToAuth()
        }
    }
    
    private func getUser() {
        ProfileService.shared.getUser() { result in
            DispatchQueue.main.async {
                switch result {
                case (.failure(let error)):
                    if let err = error as? NetworkError,
                       err == NetworkError.AccessDenied {
                        self.goToAuth()
                    } else {
                        UIBlockingProgressHUD.dismiss()
                        self.showAlert()
                        
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
    
    private func goToAuth() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        guard let authViewController = storyboard.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController
        else {
            assertionFailure("Что-то пошло не так")
            return
        }
        authViewController.delegate = self
        authViewController.modalPresentationStyle = .fullScreen
        self.present(authViewController, animated: true)
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
        let action = UIAlertAction(title: networkErrorAlertButtonText, style: .default) {_ in }
        
        alert.addAction(action)
        
        self.present(alert, animated: true)
    }
}

extension SplashViewController {
    private func createLogo() {
        let imageView = UIImageView(image: UIImage(named: "Vector"))
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(imageView)
        
        imageView.heightAnchor.constraint(equalToConstant: 76).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 73).isActive = true
        
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
}
