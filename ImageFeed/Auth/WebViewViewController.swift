//
//  WebViewViewController.swift
//  ImageFeed
//
//  Created by Алия Давлетова on 29.05.2023.
//

import UIKit
import WebKit

final class WebViewViewController: UIViewController {
    private let UnsplashAuthorizeURL = "https://unsplash.com/oauth/authorize"
    private let getCodeURLPath = "/oauth/authorize/native"
    private let responseType = "code"
    
    private var estimatedProgressObservation: NSKeyValueObservation?
    
    var delegate: WebViewViewControllerDelegate?
    
    @IBOutlet private weak var webView: WKWebView!
    @IBOutlet private weak var progressView: UIProgressView!
    
    @IBAction private func didTapBackButton(_ sender: Any?) {
        delegate?.webViewViewControllerDidCancel(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        estimatedProgressObservation = webView.observe(
            \.estimatedProgress,
             options: [],
             changeHandler: { [weak self] _, _ in
                 guard let self = self else { return }
                 self.updateProgress()
             })
        
        webView.navigationDelegate = self

        guard let baseURL = URL(string: UnsplashAuthorizeURL) else {
            assertionFailure("failed to create URL from string \(UnsplashAuthorizeURL)")
            return
        }
        
        let queryItems = [
            URLQueryItem(name: "client_id", value: AccessKey),
            URLQueryItem(name: "redirect_uri", value: RedirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: AccessScope)
        ]

        
        guard let request = URLRequest.makeHTTPRequest(
            baseUrl: baseURL,
            path: nil,
            method: HTTPMehtod.get,
            queryItems: queryItems,
            body: nil) else {
            assertionFailure("failed to create UnsplashAuthorizeURL with query items")
            return
        }
        
        webView.load(request)

        updateProgress()
    }
    
    private func updateProgress() {
        progressView.progress = Float(webView.estimatedProgress)
        progressView.isHidden = fabs(webView.estimatedProgress - 1) <= 0.0001
    }
}

extension WebViewViewController: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if let code = code(from: navigationAction) {
            UIBlockingProgressHUD.show()
            
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
            
            UIBlockingProgressHUD.dismiss()
            
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
    
    private func code(from navigationAction: WKNavigationAction) -> String? {
        if let url = navigationAction.request.url,
           let urlComponents = URLComponents(string: url.absoluteString),
           urlComponents.path == getCodeURLPath,
           let items = urlComponents.queryItems,
           let codeItems = items.first(where: { $0.name == responseType })
        {
            return codeItems.value
        } else {
            return nil
        }
    }
}
