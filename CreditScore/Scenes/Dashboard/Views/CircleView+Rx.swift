//
//  CircleView+Rx.swift
//  CreditScore
//
//  Created by krawiecp-home on 12/02/2019.
//  Copyright © 2019 pawel. All rights reserved.
//

import RxSwift
import RxCocoa

// Useful rx extensions for view
extension Reactive where Base: CircleView {
    // Bindable sink for for `startAnimating` and `stopAnimating` methods
    var isAnimating: Binder<Bool> {
        return Binder(self.base) { circle, active in
            if active {
                circle.startAnimating()
            } else {
                circle.stopAnimating()
            }
        }
    }
    
    // Bindable sink for `setValue` method
    var value: Binder<Int> {
        return Binder(self.base) { circle, val in
            circle.setValue(val)
        }
    }
}
