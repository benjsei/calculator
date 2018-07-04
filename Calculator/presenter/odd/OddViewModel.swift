//
//  OddViewModel.swift
//  Calculator
//
//  Created by Benjamin Seillier on 03/07/2018.
//  Copyright © 2018 Benjamin Seillier. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class OddViewModel: NSObject, ViewModelType {
    
    // MARK: - Public Property
    
    struct Input {
        
        let integerEvaluated: Observable<String?>
        
        let evaluateButtonTap: Observable<Void>
    }
    
    struct Output {
        
        let evaluateColor: Driver<UIColor>
    }
    
    func transform(input: Input) -> Output {
        
        let evaluateColor = getEvaluateColorDriver(input: input)
        
        return Output( evaluateColor: evaluateColor)
    }
    
    // MARK: - Private Property
    
    private var disposeBag = DisposeBag()
    private let errorMessage = "Error"
    private let zeroInt = 0
    
    // MARK: - Private Function
    
    private func getEvaluateColorDriver(input: Input) -> Driver<UIColor> {
        
        let integerEvaluatedObservable = getIntObservable(stringObservable: input.integerEvaluated)
        
        return input
            .evaluateButtonTap
            .withLatestFrom(integerEvaluatedObservable)
            .map({ (integerEvaluated) -> UIColor in
                
                if self.isOdd(integerEvaluated: integerEvaluated) {
                    return .red
                }
                
                return .green
            })
            .asDriver(onErrorJustReturn: .red)
    }
    
    private func isOdd(integerEvaluated : Int) -> Bool {
        
        return integerEvaluated % 2 == 0
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
