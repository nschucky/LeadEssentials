//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Antonio Alves on 12/29/20.
//

import XCTest
import EssentialFeed

class FeedStore {
    
    typealias DeletionCompletion = (Error?) -> Void
    
    var deletedCachedFeedCallCount = 0
    var insertCallCount = 0
    
    private var deletionCompletions = [DeletionCompletion]()
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        deletedCachedFeedCallCount += 1
        self.deletionCompletions.append(completion)
    }
    
    func completeDeletion(with error: NSError, at index: Int = 0) {
        deletionCompletions[index](error)
    }
    
    func completeSuccessfully(at index: Int = 0) {
        deletionCompletions[index](nil)
    }
    
    func insert(_ items: [FeedItem]) {
        insertCallCount += 1
    }
}

class LocalFeedLoader {
    let store: FeedStore
    
    init(store: FeedStore) {
        self.store = store
    }
    
    func save(_ items: [FeedItem]) {
        store.deleteCachedFeed { [unowned self] error in
            if error == nil {
                self.store.insert(items)
            }
        }
    }
}

class CacheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotDeleteCacheUponCreation() {
        XCTAssertEqual(makeSUT().store.deletedCachedFeedCallCount, 0)
    }
    
    func test_save_requestCacheDeletion() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        
        sut.save(items)
        
        XCTAssertEqual(store.deletedCachedFeedCallCount, 1)
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletingError() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        let deletionError = anyNSError()
        
        sut.save(items)
        store.completeDeletion(with: deletionError)
        
        XCTAssertEqual(store.insertCallCount, 0)
    }
    
    func test_save_requestNewCacheInsertionOnSuccessfulDeletion() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        
        sut.save(items)
        store.completeSuccessfully()
        
        XCTAssertEqual(store.insertCallCount, 1)
    }
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStore) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        
        return (sut, store)
    }
    
    private func uniqueItem() -> FeedItem {
        return FeedItem(feedItemId: UUID(), description: "any description", location: "any location", imageURL: anyURL())
    }
    
    private func anyURL() -> URL {
        return URL(string: "https://www.google.com")!
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 0)
    }
    
}
