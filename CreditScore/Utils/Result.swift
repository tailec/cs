//
//  Result.swift
//  CreditScore
//
//  Created by krawiecp-home on 12/02/2019.
//  Copyright © 2019 pawel. All rights reserved.
//

import Foundation

enum Result<Value, Error: Swift.Error> {
    case success(Value)
    case failure(Error)
}
