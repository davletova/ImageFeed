//
//  ProfileViewTests.swift
//  ImageFeedTests
//
//  Created by Алия Давлетова on 11.07.2023.
//

import XCTest
@testable import ImageFeed

final class ProfileViewTests: XCTestCase {
    func testCalledPresentWhenGoToSplash() {
        // given
        let presenter = ProfileViewPresenter(
            cookieCleaner: CookieCleanerSpy(),
            oauth2TokenStorage: AccessTokenRemoverSpy(),
            avatarURLProvider: AvatarURLProviderSpy()
        )
        let viewController = ProfileViewControllerSpy()
        presenter.viewController = viewController
        
        // when
        presenter.logout()
        
        // then
        XCTAssertTrue(viewController.presentCalled)
    }
    
    func testCookieCleanCalled() {
        // given
        let cookieCleaner = CookieCleanerSpy()
        let presenter = ProfileViewPresenter(
            cookieCleaner: cookieCleaner,
            oauth2TokenStorage: AccessTokenRemoverSpy(),
            avatarURLProvider: AvatarURLProviderSpy()
        )
        let viewController = ProfileViewControllerSpy()
        presenter.viewController = viewController
        
        // when
        presenter.logout()
        
        // then
        XCTAssertTrue(cookieCleaner.cleanCalled)
    }
    
    func testAccessTokenRemoveCalled() {
        // given
        let accessTokenRemover = AccessTokenRemoverSpy()
        let presenter = ProfileViewPresenter(
            cookieCleaner: CookieCleanerSpy(),
            oauth2TokenStorage: accessTokenRemover,
            avatarURLProvider: AvatarURLProviderSpy()
        )
        let viewController = ProfileViewControllerSpy()
        presenter.viewController = viewController
        
        // when
        presenter.logout()
        
        // then
        XCTAssertTrue(accessTokenRemover.removeAccessTokenCalled)
    }
    
    func testGetAvatarURLCalled() {
        // given
        let avatarURLProvider = AvatarURLProviderSpy()
        let presenter = ProfileViewPresenter(
            cookieCleaner: CookieCleanerSpy(),
            oauth2TokenStorage: AccessTokenRemoverSpy(),
            avatarURLProvider: avatarURLProvider
        )
        let viewController = ProfileViewControllerSpy()
        presenter.viewController = viewController
        
        // when
        presenter.updateAvatar()
        
        // then
        XCTAssertTrue(avatarURLProvider.getAvaterURLCalled)
    }
    
}

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var userAvatar: UIImageView!
    var presentCalled: Bool = false
    var setImageCalled: Bool = false
    
    func present(controller: UIViewController) {
        presentCalled = true
    }
    
    func setImage(url: URL) {
        setImageCalled = true
    }
}

final class CookieCleanerSpy: CookieCleenerProtocol {
    var cleanCalled: Bool = false
    
    func clean() {
        cleanCalled = true
    }
}

final class AccessTokenRemoverSpy: AccessTokenCleanerProtocol {
    var removeAccessTokenCalled: Bool = false
    
    func removeAccessToken() {
        removeAccessTokenCalled = true
    }
}

final class AvatarURLProviderSpy: AvatarURLProviderProtocol {
    var getAvaterURLCalled: Bool = false
    
    func getAvatarURL() -> String {
        getAvaterURLCalled = true
        return "https://images.unsplash.com/face-springmorning.jpg?q=80&fm=jpg&crop=faces&fit=crop&h=32&w=32"
    }
}

//final class WebViewPresenterSpy: WebViewPresenterProtocol {
//    var viewDidLoadCalled: Bool = false
//    var view: WebViewViewControllerProtocol?
//
//    func viewDidLoad() {
//        viewDidLoadCalled = true
//    }
//
//    func didUpdateProgressValue(_ newValue: Double) { }
//
//    func code(from url: URL) -> String? { return nil }
//}
//
//final class WebViewControllerSpy: WebViewViewControllerProtocol {
//    var viewLoadRequestCalled: Bool = false
//    var presenter: WebViewPresenterProtocol?
//
//    func load(_ request: URLRequest) {
//        viewLoadRequestCalled = true
//    }
//
//    func setProgressValue(_ newValue: Float) { }
//
//    func setProgressHidden(_ isHidden: Bool) { }
//}
