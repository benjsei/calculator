//
//  OddViewModelInitializer.swift
//  Odd
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
public class OddViewModelInitializer: NSObject {
    @objc public class func cucumberishSwiftInit() {
        
        let disposeBag = DisposeBag()
        
        var input: OddViewModel.Input!
        var output: OddViewModel.Output!
        var integerEvaluated : String?
        
        before { (scenario) -> Void in
            
            if scenario?.tags?.contains("OddViewModel") ?? false {
                
               
            }
        }
        
        Given("I am filling (.*) in the field to evalute") { (args, _) -> Void in
            
            guard let args = args else  {
                XCTAssert(false)
                return
            }
           
            integerEvaluated = args.first
        }
    
        When("I am tapping in the evaluate button") { (_, _) -> Void in
            
            let oddViewModel = OddViewModel()
            
            input = createInput(integerEvaluated: Observable.just(integerEvaluated),
                                evaluateButtonTap: Observable.just(()))
            
            output = oddViewModel.transform(input: input)
            output.evaluateColor.drive().disposed(by: disposeBag)
        }
        
        Then("I see the evaluate button red") { (_, _) -> Void in
         
            let resultExcepted = UIColor.red
            
            let result = try! output.evaluateColor.toBlocking().first()!
            
            XCTAssertEqual(resultExcepted, result)
        }
        
        Then("I see the evaluate button green") { (_, _) -> Void in
            
            let resultExcepted = UIColor.green
            
            let result = try! output.evaluateColor.toBlocking().first()!
            
            XCTAssertEqual(resultExcepted, result)
        }
        
        let bundle = Bundle(for: OddViewModelInitializer.self)
        Cucumberish.executeFeatures(inDirectory: "features/presenter/odd", from: bundle, includeTags: nil, excludeTags: nil)
    }
    
    public class func createInput(integerEvaluated: Observable<String?> = Observable.never(),
                                  evaluateButtonTap: Observable<Void> = Observable.never()) -> OddViewModel.Input {
        
        return OddViewModel.Input(integerEvaluated: integerEvaluated,
                                  evaluateButtonTap: evaluateButtonTap)
    }
    
    
}

