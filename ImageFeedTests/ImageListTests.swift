//
//  ImageListTests.swift
//  ImageFeedTests
//
//  Created by Алия Давлетова on 13.07.2023.
//

import XCTest
@testable import ImageFeed

let testPhotos: [Photo] = [
    Photo(id: "1",
          size: CGSize(width: 100, height: 200),
          createdAt: nil,
          welcomeDescription: nil,
          thumbImageURL: "thumbImageURL_1",
          largeImageURL: "largeImageURL_2",
          isLiked: true),
    Photo(id: "2",
          size: CGSize(width: 300, height: 400),
          createdAt: nil,
          welcomeDescription: nil,
          thumbImageURL: "thumbImageURL_2",
          largeImageURL: "largeImageURL_2",
          isLiked: false),
    Photo(id: "3",
          size: CGSize(width: 150, height: 250),
          createdAt: nil,
          welcomeDescription: "",
          thumbImageURL: "thumbImageURL_3",
          largeImageURL: "largeImageURL_3",
          isLiked: false)
]

final class ImageListTests: XCTestCase {
    func testGetPhotosNextPage() {
        // given
        let view = ImageListViewControllerSpy()
        let service = ImageListServiceSpy()
        let presenter = ImageListPresenter(service: service, view: view)
        
        // when
        presenter.getPhotosNextPage()
        
        // then
        XCTAssertTrue(service.getPhotosNextPageCalled)
    }
    
    func testNeedGetPhotosNextPage() {
        // given
        let view = ImageListViewControllerSpy()
        let service = ImageListServiceSpy()
        let presenter = ImageListPresenter(service: service, view: view)
        presenter.photos.append(contentsOf: testPhotos)
        
        // when
        presenter.checkIfNeedGetPhotosNextPage(indexPath: IndexPath(row: 2, section: 0))
        
        // then
        XCTAssertTrue(service.getPhotosNextPageCalled)
    }
    
    func testDontNeedGetPhotosNextPage() {
        // given
        let view = ImageListViewControllerSpy()
        let service = ImageListServiceSpy()
        let presenter = ImageListPresenter(service: service, view: view)
        
        // when
        presenter.checkIfNeedGetPhotosNextPage(indexPath: IndexPath(row: 1, section: 0))
        
        // then
        XCTAssertFalse(service.getPhotosNextPageCalled)
    }
    
    func testChangeLike() {
        // given
        let view = ImageListViewControllerSpy()
        let service = ImageListServiceSpy()
        let presenter = ImageListPresenter(service: service, view: view)
        
        // when
        presenter.changeLike(photo: testPhotos[0]) { _ in }
        
        // then
        XCTAssertTrue(service.changeLikeCalled)
    }
    
    func testUpdateTableViewAnimated() {
        // given
        let view = ImageListViewControllerSpy()
        let service = ImageListServiceSpy()
        let presenter = ImageListPresenter(service: service, view: view)
        presenter.photos.append(contentsOf: testPhotos)
        
        // when
        presenter.updateTableViewAnimated()
        
        // then
        XCTAssertTrue(view.performBatchUpdatesCalled)
    }
    
    func testUpdateTableViewAnimatedDontCalled() {
        // given
        let view = ImageListViewControllerSpy()
        view.photos = []
        
        let service = ImageListServiceSpy()
        let presenter = ImageListPresenter(service: service, view: view)
        
        // when
        presenter.updateTableViewAnimated()
        
        // then
        XCTAssertFalse(view.performBatchUpdatesCalled)
    }
    
    func testUpdateOldPhotosCount() {
        // given
        let view = ImageListViewControllerSpy()
        let service = ImageListServiceSpy()
        let presenter = ImageListPresenter(service: service, view: view)
        presenter.photos.append(contentsOf: testPhotos)
        
        // when
        presenter.updateTableViewAnimated()
        
        // then
        XCTAssertEqual(presenter.oldPhotosCount, view.photos.count)
    }
    
    func testCalculateCellHeight() {
        // given
        let view = ImageListViewControllerSpy()
        let service = ImageListServiceSpy()
        let presenter = ImageListPresenter(service: service, view: view)
        presenter.photos.append(contentsOf: testPhotos)
        // when
        let getCellHeight = presenter.calculateCellHeight(indexPath: IndexPath(row: 0, section: 0), tableViewBoundsWidth: 400)
        
        // then
        
        // Вычислим вручную:
        // imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        // imageViewWidth = tableViewBoundsWidth - imageInsets.left - imageInsets.right
        // 400 - 16 - 16 = 368
        // imageWidth = 100
        // scale = imageViewWidth / imageWidth
        // 368 / 100 = 3,68
        // cellHeight = photo.size.height * scale + imageInsets.top + imageInsets.bottom
        // 200 * 3.68 + 4 + 4 = 744
        
        let wantCellHeight = CGFloat(744)
        XCTAssertEqual(getCellHeight, wantCellHeight)
    }
    
    func testViewControllerCallsViewDidLoad() {
        //given
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as! ImagesListViewController
        let presenter = ImageListPresenterSpy()
        presenter.view = viewController
        viewController.presenter = presenter
        
        //when
        _ = viewController.view
        
        //then
        XCTAssertTrue(presenter.getPhotosNextPageCalled) //behaviour verification
    }
}

final class ImageListServiceSpy: ImagesListServiceProtocol {
    var getPhotosNextPageCalled = false
    var changeLikeCalled = false
    
    func changeLike(photo: ImageFeed.Photo, _ completion: @escaping (Result<ImageFeed.ChangeLikeResponse, Error>) -> Void) {
        changeLikeCalled = true
    }
    
    func getPhotosNextPage(handler: @escaping (Result<[ImageFeed.Photo], Error>) -> Void) {
        getPhotosNextPageCalled = true
    }
}

final class ImageListViewControllerSpy: ImagesListViewControllerProtocol {
    var photos: [ImageFeed.Photo] = testPhotos
    
    var performBatchUpdatesCalled = false
        
    func performBatchUpdates(indexPaths: [IndexPath]) {
        performBatchUpdatesCalled = true
    }
    
    func appendPhotos(photos: [ImageFeed.Photo]) {}
}

final class ImageListPresenterSpy: ImageListPresenterProtocol {
    var photos: [ImageFeed.Photo] = []
    
    var view: ImagesListViewControllerProtocol?
    var getPhotosNextPageCalled = false
    
    func getPhotosNextPage() {
        getPhotosNextPageCalled = true
    }
    
    func checkIfNeedGetPhotosNextPage(indexPath: IndexPath) {}
    
    func changeLike(photo: ImageFeed.Photo, handler: @escaping (ImageFeed.Photo) -> Void) {}
    
    func updateTableViewAnimated() {}
    
    func calculateCellHeight(indexPath: IndexPath, tableViewBoundsWidth: CGFloat) -> CGFloat { return 0 }
    
    func appendPhotos(photos: [ImageFeed.Photo]) {}
}
