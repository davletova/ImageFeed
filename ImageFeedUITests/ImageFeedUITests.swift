//
//  ImageFeedUITests.swift
//  ImageFeedUITests
//
//  Created by Алия Давлетова on 14.07.2023.
//

import XCTest

final class ImageFeedUITests: XCTestCase {
    private let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false // настройка выполнения тестов, которая прекратит выполнения тестов, если в тесте что-то пошло не так
        app.launch() // запускаем приложение перед каждым тестом
    }

    func testAuth() throws {
        sleep(3)
        
        app.buttons["Authenticate"].tap()
        
        let webView = app.webViews["UnsplashWebView"]
        
        XCTAssertTrue(webView.waitForExistence(timeout: 5))
        
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 10))
        
        loginTextField.tap()
        loginTextField.typeText("your_email")
        loginTextField.swipeUp()
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        
        passwordTextField.tap()
        passwordTextField.typeText("your_password")
        webView.swipeUp()
        
        webView.buttons["Login"].tap()
        
        print(app.debugDescription)
        
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 10))
    }
    
    func testFeed() throws {
        let imageFeedTable = app.tables["ImageFeedTable"].firstMatch
        XCTAssertTrue(imageFeedTable.waitForExistence(timeout: 5))

        imageFeedTable.swipeUp()
        sleep(2)
        
        let firstCell = imageFeedTable.children(matching: .cell).element(boundBy: 1).firstMatch
        
        firstCell.buttons["UnlikeButton"].tap()
        
        sleep(5)
        XCTAssertTrue(firstCell.buttons["LikeButton"].waitForExistence(timeout: 10))
        firstCell.buttons["LikeButton"].tap()
        
        firstCell.tap()
        
        let singleImageView = app.scrollViews["ScrollImageView"].firstMatch
        XCTAssertTrue(singleImageView.waitForExistence(timeout: 5))
        sleep(5)
        
        singleImageView.pinch(withScale: 3, velocity: 1)
        singleImageView.pinch(withScale: 0.5, velocity: -1)
        
        app.buttons["BackButton"].tap()
        XCTAssertTrue(imageFeedTable.waitForExistence(timeout: 5))
    }
    
    func testProfile() throws {
        let imageFeedTable = app.tables["ImageFeedTable"]
        XCTAssertTrue(imageFeedTable.waitForExistence(timeout: 5))
        
        app.tabBars.buttons.element(boundBy: 1).tap()
        
        XCTAssertTrue(app.staticTexts["Алия Давлетова"].exists)
        XCTAssertTrue(app.staticTexts["aliya_d"].exists)
            
        app.buttons["LogoutButton"].tap()
            
        XCTAssertTrue(app.buttons["Authenticate"].waitForExistence(timeout: 5))
    }
}
