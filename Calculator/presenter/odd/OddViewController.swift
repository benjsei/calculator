//
//  OddViewController.swift
//  Calculator
//
//  Created by Benjamin Seillier on 03/07/2018.
//  Copyright © 2018 Benjamin Seillier. All rights reserved.
//

import UIKit
import RxSwift

class OddViewController: UIViewController {

    // MARK: - IBOutlet
    
    @IBOutlet weak var integerToEvaluateTextfield: UITextField!
    @IBOutlet weak var evaluateButton: UIButton!
    @IBOutlet var oddViewModel: OddViewModel!
    
    // MARK: - Private Property
    
    private let disposeBag = DisposeBag()
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        bindViewModel()
    }

    // MARK: - Private Function
    
    private func bindViewModel() {
        
        let input = OddViewModel.Input(integerEvaluated: integerToEvaluateTextfield.rx.text.asObservable(),
                                       evaluateButtonTap: evaluateButton.rx.tap.asObservable())
        
        let output = oddViewModel.transform(input: input)

        driveOutput(output: output)
    }

    private func driveOutput(output: OddViewModel.Output) {
        
        output.evaluateColor
            .drive(onNext: { (evaluateColor) in
                self.evaluateButton.backgroundColor = evaluateColor
            })
            .disposed(by: disposeBag)
    }
}

