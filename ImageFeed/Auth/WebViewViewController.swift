//
//  WebViewViewController.swift
//  ImageFeed
//
//  Created by Алия Давлетова on 29.05.2023.
//

import UIKit
import WebKit

protocol WebViewViewControllerProtocol: AnyObject {
    var presenter: WebViewPresenterProtocol? { get set }
    
    func load(_ request: URLRequest)
    func setProgressValue(_ newValue: Float)
    func setProgressHidden(_ isHidden: Bool)
}

final class WebViewViewController: UIViewController & WebViewViewControllerProtocol {
    private let getCodeURLPath = "/oauth/authorize/native"
    private let responseType = "code"
    
    var presenter: WebViewPresenterProtocol?
    
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
                 guard let self = self else {
                     assertionFailure("webView.observe.changeHandler: self is empty")
                     return
                 }
                 guard let presenter = self.presenter else {
                     assertionFailure("webView.observe.changeHandler: presenter is empty")
                     return
                 }
                 presenter.didUpdateProgressValue(self.webView.estimatedProgress)
             })
        
        webView.navigationDelegate = self

        guard let presenter = self.presenter else {
            assertionFailure("webView.observe.changeHandler: presenter is empty")
            return
        }
        
        presenter.viewDidLoad()
    }
    
    func load(_ request: URLRequest) {
        webView.load(request)
    }
    
    func setProgressValue(_ newValue: Float) {
        progressView.progress = newValue
    }

    func setProgressHidden(_ isHidden: Bool) {
        progressView.isHidden = isHidden
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
        if let url = navigationAction.request.url {
            return presenter?.code(from: url)
        }
        return nil
    }
}

