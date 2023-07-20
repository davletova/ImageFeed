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

final class AuthViewController: UIViewController {
    static let ReuseIdentifier: String = "ShowWebView"
    
    var tokenProvider: TokenProviderProtocol = BearerTokenProvider()
    var oauth2TokenStorage: OAuth2TokenStorageProtocol = OAuth2TokenStorage()
    var delegate: AuthViewControllerDelegate?
    
    @IBOutlet private weak var login: UIButton!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        login.accessibilityIdentifier = "Authenticate"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == AuthViewController.ReuseIdentifier {
            guard let webView = segue.destination as? WebViewViewController else {
                assertionFailure("failed to customize seque.destination to WebViewViewController")
                return
            }
            let authHelper = AuthHelper()
            let webViewPresenter = WebViewPresenter(authHelper: authHelper)
            webViewPresenter.view = webView
            webView.presenter = webViewPresenter
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
                        assertionFailure("AuthViewControllerDelegate not found")
                        return
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
