//
//  FeedCacheTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Antonio Alves on 1/3/21.
//

import Foundation
import EssentialFeed

func uniqueImage() -> FeedImage {
    return FeedImage(feedId: UUID(), description: "any description", location: "any location", url: anyURL())
}

func uniqueImageFeed() -> (model: [FeedImage], local: [LocalFeedImage]) {
    let model = [uniqueImage(), uniqueImage()]
    let local = model.map { LocalFeedImage(feedId: $0.feedId, description: $0.description, location: $0.location, url: $0.url)}
    return (model, local)
}

extension Date {
    
    func adding(days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
    
    func adding(seconds: Double) -> Date {
        return self + seconds
    }
}