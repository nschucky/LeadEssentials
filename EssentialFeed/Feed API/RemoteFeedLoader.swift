//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Antonio Alves on 12/15/20.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
    
    private let client: HTTPClient
    private let url: URL
    
    public enum RemoteFeedLoaderError: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public typealias LoadResult = FeedLoader.Result
    
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (LoadResult) -> Void) {
        client.get(from: url) { [weak self] httpClientResult in
            guard self != nil else { return }
            switch httpClientResult {
            case let .success(data, response):
                completion(RemoteFeedLoader.map(data, from: response))
            case .failure:
                completion(.failure(RemoteFeedLoaderError.connectivity))
            }
        }
    }
    
    private static func map(_ data: Data, from response: HTTPURLResponse) -> Result<[FeedImage], Error> {
        do {
            let items = try FeedItemsMapper.map(data, from: response)
            return Result.success(items.toModels())
        } catch {
            return Result.failure(error)
        }
    }
}

private extension Array where Element == RemoteFeedItem {
    func toModels() -> [FeedImage] {
        return map { FeedImage(feedId: $0.id, description: $0.description, location: $0.location, url: $0.image)}
    }
}
