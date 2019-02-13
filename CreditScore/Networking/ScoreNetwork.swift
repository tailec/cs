//
//  ScoreNetwork.swift
//  CreditScore
//
//  Created by krawiecp-home on 12/02/2019.
//  Copyright © 2019 pawel. All rights reserved.
//

import Foundation
import RxSwift

protocol ScoreNetworkable {
    func fetchScore() -> Observable<Result<Score, NetworkError>>
}

final class ScoreNetwork: ScoreNetworkable {
    private let network: Network<Score>
    
    init(network: Network<Score> = Network<Score>()) {
        self.network = network
    }
    
    func fetchScore() -> Observable<Result<Score, NetworkError>> {
        return network.get("mockcredit/values")
    }
}
