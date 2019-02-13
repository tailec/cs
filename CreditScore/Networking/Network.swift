//
//  Network.swift
//  CreditScore
//
//  Created by krawiecp-home on 11/02/2019.
//  Copyright © 2019 pawel. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

enum NetworkError: Swift.Error {
    case generic
}

final class Network<T: Decodable> {
    private let rootEndPoint: String
    private let session: URLSession
    private let scheduler: SchedulerType
    
    init(_ rootEndPoint: String = Environment.Prod.rootEndPoint,
         session: URLSession = URLSession.shared,
         scheduler: SchedulerType = ConcurrentDispatchQueueScheduler(qos: .background)) {
        self.rootEndPoint = rootEndPoint
        self.session = session
        self.scheduler = scheduler
    }
    
    // generic method for GET requests
    // I'm using Result type here so I can wrap `complete` and `error` events
    // in `next` events and prevent disposal of this observable
    func get(_ path: String) -> Observable<Result<T, NetworkError>> {
        let request = URLRequest(url: URL(string: "\(rootEndPoint)\(path)")!) // TODO: fix !
        return session.rx.data(request: request)
            .observeOn(scheduler)
            .retry(3) // retry 3 times immediately when URLSession returns an error
            .map(T.parse)
            .retryWhen { trigger in // another retry but with timer
                return trigger.enumerated()
                    .flatMap { (attempt, error) -> Observable<Int> in
                        if attempt >= 3 {
                            return Observable.error(error)
                        }
                        return Observable<Int>
                            .timer(Double(attempt + 1), scheduler: MainScheduler.instance)
                            .take(1)
                }
            }
            .map { value in Result.success(value) }
            .catchErrorJustReturn(Result.failure(NetworkError.generic))
    }
}

fileprivate extension Decodable {
    static func parse(data: Data) throws -> Self { // some syntax sugar
        return try JSONDecoder().decode(Self.self, from: data)
    }
}

fileprivate enum Environment {
    enum Prod {
        static let rootEndPoint = "https://5lfoiyb0b3.execute-api.us-west-2.amazonaws.com/prod/"
    }
}
