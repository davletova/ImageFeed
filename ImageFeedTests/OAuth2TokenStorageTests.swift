//
//  OAuth2TokenStorage.swift
//  ImageFeedTests
//
//  Created by Алия Давлетова on 12.07.2023.
//

import XCTest
@testable import ImageFeed

final class OAuth2TokenStorageTest: XCTestCase {
    func testSetNewValue() {
        // given
        let token = "access token test"
        let storage = OAuth2TokenStorage()
        
        // when
        storage.accessToken = token
        
        // then
        XCTAssertEqual(storage.accessToken, token)
    }
    
    func testRemoveAccessToke() {
        // given
        let storage = OAuth2TokenStorage()
        storage.accessToken = "token"
        
        // when
        storage.removeAccessToken()
        
        // then
        XCTAssertNil(storage.accessToken)
    }
}
