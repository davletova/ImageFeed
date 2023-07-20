//
//  WebViewViewControllerDelegate.swift
//  ImageFeed
//
//  Created by Алия Давлетова on 29.05.2023.
//

import Foundation

protocol WebViewViewControllerDelegate {
    // WebViewViewController получил код
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    
    // пользователь нажал кнопку назад и отменил авторизацию.
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}
