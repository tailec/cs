//
//  DashboardViewModel.swift
//  CreditScore
//
//  Created by krawiecp-home on 11/02/2019.
//  Copyright © 2019 pawel. All rights reserved.
//

import RxSwift
import RxCocoa

// I'm a big fan of pure observable MVVM bindings because view model
// doesn't have any side-effects or/and disposables.
final class DashboardViewModel: ViewModelType {
    struct Input {
        let ready: Driver<Void>
    }
    
    struct Output {
        let score: Driver<Int?> // null means complete lack of data (data not fetched from network or not stored in file system)
        let loading: Driver<Bool>
        let title: Driver<String>
    }
    
    struct Dependencies {
        let repository: ScoreRepositorable
    }
    
    private let dependencies: Dependencies
    
    init(dependencies: Dependencies = Dependencies(repository: ScoreRepository(cache: Cache<Score>()))) {
        self.dependencies = dependencies
    }
    
    func transform(input: DashboardViewModel.Input) -> DashboardViewModel.Output {
        let activityIndicator = ActivityIndicator()
        let loading = activityIndicator.asDriver()
        
        let score = input.ready
            .asObservable()
            .flatMap {
                self.dependencies.repository.fetchScore()
                    .trackActivity(activityIndicator)
            }
            .map { $0.score }
            .asDriver(onErrorJustReturn: nil)
        
        return Output(score: score,
                      loading: loading,
                      title: Driver.just("Dashboard")) // normally I'd use localized strings but I think it's ok to hardcode strings for exercise purposes
    }
}
