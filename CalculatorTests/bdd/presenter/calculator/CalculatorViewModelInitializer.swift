//
//  CalculatorViewModelInitializer.swift
//  Calculator
//
//  Created by Benjamin Seillier on 20/02/2017.
//  Copyright © 2018 Benjamin Seillier. All rights reserved.
//

import Foundation
import Cucumberish
import RxSwift
import RxTest
import OHHTTPStubs
import RxCocoa
import RxBlocking

@testable import Calculator

@objc
public class CalculatorViewModelInitializer: NSObject {
    @objc public class func cucumberishSwiftInit() {
        
        let disposeBag = DisposeBag()
        
        var input: CalculatorViewModel.Input!
        var output: CalculatorViewModel.Output!
        var field1Value : String?
        
        before { (scenario) -> Void in
            
            if scenario?.tags?.contains("calculatorViewModel") ?? false {
                
               
            }
        }
        
        Given("I am filling (.*) in the first field") { (args, _) -> Void in
            
            guard let args = args else  {
                XCTAssert(false)
                return
            }
           
            field1Value = args[0]
        }
    
        When("I am filling (.*) in the second field") { (args, _) -> Void in
            
            guard let args = args else  {
                XCTAssert(false)
                return
            }
            
            let calculatorViewModel = CalculatorViewModel()
            
            input = createInput(field1: Observable.just(field1Value),
                                field2: Observable.just(args[0]))
            
            output = calculatorViewModel.transform(input: input)
            output.result.drive().disposed(by: disposeBag)
        }
        
        Then("I see (.*) in the result label") { (args, _) -> Void in
         
            guard let args = args else  {
                XCTAssert(false)
                return
            }
            
            let resultExcepted = args[0]
            
            let result = try! output.result.toBlocking().first()!
            
            XCTAssertEqual(resultExcepted, result)
        }
        
        let bundle = Bundle(for: CalculatorViewModelInitializer.self)
        Cucumberish.executeFeatures(inDirectory: "features/presenter/calculator", from: bundle, includeTags: nil, excludeTags: nil)
    }
    
    public class func createInput(field1: Observable<String?> = Observable.never(),
                                  field2: Observable<String?> = Observable.never()) -> CalculatorViewModel.Input {
        
        return CalculatorViewModel.Input(field1: field1,
                                         field2: field2)
    }
    
    
}

