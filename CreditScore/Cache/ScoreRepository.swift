//
//  ScoreRepository.swift
//  CreditScore
//
//  Created by krawiecp-home on 12/02/2019.
//  Copyright © 2019 pawel. All rights reserved.
//

import RxSwift
import RxCocoa

// not a great name :)
protocol ScoreRepositorable {
    func fetchScore() -> Observable<Score>
}

final class ScoreRepository<Cache>: ScoreRepositorable where Cache: AbstractCache, Cache.CachableObjectType == Score {
    
    private enum RepositoryError: Error {
        case dataNotFetchedNotStoredError
    }
    
    private let network: ScoreNetworkable
    private let cache: Cache
    
    init(network: ScoreNetworkable = ScoreNetwork(),
         cache: Cache) {
        self.network = network
        self.cache = cache
    }
    
    func fetchScore() -> Observable<Score> {
        let uid = Score.sharedUID
        let storedSource = cache.fetch(withId: uid)
        
        let networkSource = network.fetchScore()
            .flatMap { result -> Observable<Score> in
                // complete observable when there's no data
                guard case let Result.success(value) = result else { return .empty() }
                return .just(value)
            }
            .flatMap { score in
                return self.cache.save(object: score)
                    .asObservable()
                    .flatMap { _ in Observable.error(CompletableError()) }
                    .concat(Observable.just(score))
                // ^ this is nice rxswift trick for transforming Completable to Observable
            }
        // try to fetch latest data from network and if it fails then get data from store
        // if data is not in the store, return an error
        return networkSource
            .ifEmpty(switchTo: storedSource.asObservable())
            .ifEmpty(switchTo: Observable.error(RepositoryError.dataNotFetchedNotStoredError))
    }
}

fileprivate struct CompletableError: Error { }
