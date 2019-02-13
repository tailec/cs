//
//  UIViewController+Rx.swift
//  CreditScore
//
//  Created by krawiecp-home on 12/02/2019.
//  Copyright © 2019 pawel. All rights reserved.
//

import RxSwift
import RxCocoa

extension Reactive where Base: UIViewController {
    // rx extension of `UIViewController` `viewWillAppear` lifecycle method
    var viewWillAppear: ControlEvent<Void> {
        let source = self.methodInvoked(#selector(Base.viewWillAppear(_:))).map { _ in }
        return ControlEvent(events: source)
    }
}
