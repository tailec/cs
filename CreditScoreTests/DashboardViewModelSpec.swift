//
//  DashboardViewModelSpec.swift
//  CreditScoreTests
//
//  Created by krawiecp-home on 12/02/2019.
//  Copyright © 2019 pawel. All rights reserved.
//

import XCTest
@testable import CreditScore
import Quick
import Nimble
import RxSwift
import RxCocoa
import RxBlocking

// I haven't added many tests because of time constraints
// but this spec should showcase testability of this view model

// I tried to make everything in this project to be easy to test by using DI, protocol etc.
class DashboardViewModelSpec: QuickSpec {
    override func spec() {
        describe("DashboardViewModel") {
            var scoreRepositoryMock: ScoreRepositoryMock!
            var viewModel: DashboardViewModel!
            var disposeBag: DisposeBag!
            
            beforeEach {
                scoreRepositoryMock = ScoreRepositoryMock()
                viewModel = DashboardViewModel(dependencies: DashboardViewModel.Dependencies(repository: scoreRepositoryMock))
                disposeBag = DisposeBag()
            }
            
            it("becomes ready") {
                let ready = PublishSubject<Void>()
                let input = DashboardViewModel.Input(ready: ready.asDriver(onErrorJustReturn: ()))
                let output = viewModel.transform(input: input)
                
                output.score.drive().disposed(by: disposeBag)
                ready.onNext(())
                
                expect(scoreRepositoryMock.fetchScoreCalled) == true
            }
            
            it("tracks loading score request") {
                let ready = PublishSubject<Void>()
                let input = DashboardViewModel.Input(ready: ready.asDriver(onErrorJustReturn: ()))
                let output = viewModel.transform(input: input)
                
                let expected = [true, false]
                var actual = [Bool]()
                
                output.loading
                    .do(onNext: { actual.append($0) },
                        onSubscribe: { actual.append(true) })
                    .drive()
                    .disposed(by: disposeBag)
                ready.onNext(())
                
                expect(actual).to(equal(expected))
            }
            
            it("receives correct data") {
                let ready = PublishSubject<Void>()
                let input = DashboardViewModel.Input(ready: ready.asDriver(onErrorJustReturn: ()))
                let output = viewModel.transform(input: input)
                
                scoreRepositoryMock.fetchScoreReturn = Observable.just(Score(score: 42))
                
                output.score.drive().disposed(by: disposeBag)
                ready.onNext(())
                let data = try! output.score.toBlocking().first()!
                
                expect(data) == 42
            }
        }
    }
}

class ScoreRepositoryMock: ScoreRepositorable {
    var fetchScoreCalled = false
    var fetchScoreReturn = Observable.just(Score(score: 1))
    
    func fetchScore() -> Observable<Score> {
        fetchScoreCalled = true
        return fetchScoreReturn
    }
}
