//
//  CalculatorViewController.swift
//  Calculator
//
//  Created by Benjamin Seillier on 02/07/2018.
//  Copyright © 2018 Benjamin Seillier. All rights reserved.
//

import UIKit
import RxSwift

class CalculatorViewController: UIViewController {

    // MARK: - IBOutlet
    
    @IBOutlet weak var field1Textfield: UITextField!
    @IBOutlet weak var field2Textfield: UITextField!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet var calculatorViewModel: CalculatorViewModel!
    
    // MARK: - Private Property
    
    private let disposeBag = DisposeBag()
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        bindViewModel()
    }

    // MARK: - Private Function
    
    private func bindViewModel() {
        
        let input = CalculatorViewModel.Input(field1: field1Textfield.rx.text.asObservable(),
                                              field2: field2Textfield.rx.text.asObservable())
        
        let output = calculatorViewModel.transform(input: input)
        
        driveOutput(output: output)
    }

    private func driveOutput(output: CalculatorViewModel.Output) {
        
        output.result
            .drive(resultLabel.rx.text)
            .disposed(by: disposeBag)
    }
    

}

