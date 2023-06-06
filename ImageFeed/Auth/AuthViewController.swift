//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Алия Давлетова on 29.05.2023.
//

import UIKit


protocol AuthViewControllerDelegate {
    func switchToTabBarController()
}

class AuthViewController: UIViewController {
    static let ReuseIdentifier: String = "ShowWebView"
    
    var tokenProvider: TokenProviderProtocol = BearerTokenProvider()
    var oauth2TokenStorage: OAuth2TokenStorageProtocol = OAuth2TokenStorage()
    
    var delegate: AuthViewControllerDelegate?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == AuthViewController.ReuseIdentifier {
            guard let webView = segue.destination as? WebViewViewController else {
                fatalError("failed to customize seque.destination to WebViewViewController")
            }
            webView.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        tokenProvider.getToken(code: code) { result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    print("failed to get token with error: \(error)")
                case .success(let accessTokenResponse):
                    self.oauth2TokenStorage.accessToken = accessTokenResponse.accessToken
                    
                    guard let delegate = self.delegate else {
                        fatalError("AuthViewControllerDelegate not found")
                    }
                    
                    delegate.switchToTabBarController()
                }
            }
        }
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }
}
