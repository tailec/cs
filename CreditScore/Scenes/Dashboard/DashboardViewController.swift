//
//  DashboardViewController.swift
//  CreditScore
//
//  Created by krawiecp-home on 11/02/2019.
//  Copyright © 2019 pawel. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class DashboardViewController: UIViewController {
    private let viewModel: DashboardViewModel
    private let disposeBag = DisposeBag()
    
    private let circleView = CircleView()
    
    init(viewModel: DashboardViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }
    
    private func bindViewModel() {
        let input = DashboardViewModel.Input(ready: rx.viewWillAppear.asDriver())
        
        let output = viewModel.transform(input: input)
        
        output.title
            .drive(rx.title)
            .disposed(by: disposeBag)
        
        // this little piggy shows tiny spinner in status bar
        output.loading
            .drive(UIApplication.shared.rx.isNetworkActivityIndicatorVisible)
            .disposed(by: disposeBag)
        
        output.loading
            .drive(circleView.rx.isAnimating)
            .disposed(by: disposeBag)

        output.score
            .filter { $0 != nil }
            .map { $0! } // it's safe to unwrap because filter rejects non-optional values
            .drive(circleView.rx.value)
            .disposed(by: disposeBag)
        
        // I should've exposed some error output for user friendly error messages (like no network  connection or other generic messages) but I think it should be fine for assesment purposes
        output.score
            .filter { $0 == nil }
            .drive(onNext: { [weak self] _ in
                guard let strongSelf = self else { return }
                // these strings should come from view model but I think it's ok for exercise purposes
                let alertController = UIAlertController(title: "Snap!", message: "Something went wrong", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                strongSelf.present(alertController, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        circleView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(circleView)
        
        circleView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        circleView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        circleView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8).isActive = true
        circleView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8).isActive = true
    }
}
