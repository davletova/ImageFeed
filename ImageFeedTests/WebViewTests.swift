//
//  ImageFeedTest.swift
//  ImageFeedTest
//
//  Created by Алия Давлетова on 10.07.2023.
//
//
//  ImageFeedTests.swift
//  ImageFeedTests
//
//  Created by Алия Давлетова on 10.07.2023.
//

import XCTest
@testable import ImageFeed

final class WebViewTests: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        //given
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "WebViewViewController") as! WebViewViewController
        
        let presenter = WebViewPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        _ = viewController.view
        
        //then
        XCTAssertTrue(presenter.viewDidLoadCalled) //behaviour verification
    }
    
    func testPresenterCallsLoadRequest() {
        //given
        let authHelper = AuthHelper()
        let webViewPresenter = WebViewPresenter(authHelper: authHelper)
        let viewController = WebViewControllerSpy()
        viewController.presenter = webViewPresenter
        webViewPresenter.view = viewController
        
        //when
        webViewPresenter.viewDidLoad()
        
        //then
        XCTAssertTrue(viewController.viewLoadRequestCalled)
    }
    
    func testProgressVisibleWhenLessThenOne() {
        //given
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        let progress: Float = 0.6
        
        //when
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)
        
        //then
        XCTAssertFalse(shouldHideProgress)
    }
    
    func testProgressHiddenWhenOne() {
        //given
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        let progress: Float = 1
        
        //when
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)
        
        //then
        XCTAssertTrue(shouldHideProgress)
    }
    
    func testAuthHelperAuthURL() {
        //given
        let configuration = AuthConfiguration.standard
        let authHelper = AuthHelper(configuration: configuration)
        
        //when
        let url = authHelper.authURL()
        XCTAssertNotNil(url)
        
        let urlString = url!.absoluteString
        
        //then
        XCTAssertTrue(urlString.contains(configuration.authURLString))
        XCTAssertTrue(urlString.contains(configuration.accessKey))
        XCTAssertTrue(urlString.contains(configuration.redirectURI))
        XCTAssertTrue(urlString.contains("code"))
        XCTAssertTrue(urlString.contains(configuration.accessScope))
    }
    
    func testCodeFromURL() {
        // given
        let configuration = AuthConfiguration.standard
        let authHelper = AuthHelper(configuration: configuration)
        
        var urlComponents = URLComponents(string: "https://unsplash.com/oauth/authorize/native")
        
        XCTAssertNotNil(urlComponents)
        
        let wantTestCode = "test code"
        urlComponents!.queryItems = [
            URLQueryItem(name: "code", value: wantTestCode),
        ]
        
        XCTAssertNotNil(urlComponents!.url)
        
        // when
        let getTestCode = authHelper.code(from: urlComponents!.url!)
        
        // then
        XCTAssertEqual(wantTestCode, getTestCode)
    }
}

final class WebViewPresenterSpy: WebViewPresenterProtocol {
    var viewDidLoadCalled: Bool = false
    var view: WebViewViewControllerProtocol?
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func didUpdateProgressValue(_ newValue: Double) { }
    
    func code(from url: URL) -> String? { return nil }
}

final class WebViewControllerSpy: WebViewViewControllerProtocol {
    var viewLoadRequestCalled: Bool = false
    var presenter: WebViewPresenterProtocol?
    
    func load(_ request: URLRequest) {
        viewLoadRequestCalled = true
    }
    
    func setProgressValue(_ newValue: Float) { }
    
    func setProgressHidden(_ isHidden: Bool) { }
}
