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
    
    // MARK: - Private Property
    
    private var disposeBag = DisposeBag()
    private let errorMessage = "Error"
    private let zeroInt = 0
    
    // MARK: - Private Function
    
    private func getResultDriver(input: Input) -> Driver<String> {
        
        let field1IntObservable = getIntObservable(stringObservable: input.field1)
        
        let field2IntObservable = getIntObservable(stringObservable: input.field2)
        
        return Observable
            .combineLatest(field1IntObservable, field2IntObservable)
            .map { (field1,  field2) -> String in
                
                let result = field1 + field2
                
                return String(result)
            }
            .asDriver(onErrorJustReturn: errorMessage)
    }
    
    private func getIntObservable(stringObservable: Observable<String?>) -> Observable<Int> {
        
        return stringObservable
            .map { (string) -> Int in
            
            return self.getInt(valueString: string)
        }
    }
    
    private func getInt(valueString: String?) -> Int {
        
        guard let valueString = valueString,
            let valueInt = Int(valueString) else {
                return zeroInt
        }
        
        return valueInt
    }
}
