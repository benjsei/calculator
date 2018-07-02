//
//  CalculatorViewModel.swift
//  Calculator
//
//  Created by Benjamin Seillier on 02/07/2018.
//  Copyright © 2018 Benjamin Seillier. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class CalculatorViewModel: NSObject, ViewModelType {
    
    // MARK: - Public Property
    
    struct Input {
        
        let field1 :Observable<String?>
        
        let field2: Observable<String?>
    }
    
    struct Output {
        
        let result: Driver<String>
    }
    
    func transform(input: Input) -> Output {
        
        let resultDriver = getResultDriver(input: input)
        
        return Output( result: resultDriver)
    }
    
    // MARK: Private Property
    
    private var disposeBag = DisposeBag()
    private let errorMessage = "Error"
    private let formatDoubleString = "%.00f"
    private let defaultDouble = 0.00
    
    // MARK: - Private Function
    
    private func getResultDriver(input: Input) -> Driver<String> {
        
        let field1DoubleObservable = input
            .field1
            .map { (field1) -> Double in
                
                return self.toDouble(valueString: field1)
        }
        
        let field2DoubleObservable = input
            .field2
            .map { (field2) -> Double in
                
                return self.toDouble(valueString: field2)
        }
        
        return Observable
            .combineLatest(field1DoubleObservable, field2DoubleObservable)
            .map { (field1,  field2) -> String in
                
                let result = field1 + field2
                let resultString = String(format: self.formatDoubleString, result)
                
                return resultString
            }
            .asDriver(onErrorJustReturn: errorMessage)
    }
    
    private func toDouble(valueString: String?) -> Double {
        
        guard let valueString = valueString,
            let valueDouble = Double(valueString) else {
                return defaultDouble
        }
        
        return valueDouble
    }
}
