//
//  AdditionViewModelInitializer.swift
//  Addition
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
public class AdditionViewModelInitializer: NSObject {
    @objc public class func cucumberishSwiftInit() {
        
        let disposeBag = DisposeBag()
        
        var input: AdditionViewModel.Input!
        var output: AdditionViewModel.Output!
        var field1Value : String?
        
        before { (scenario) -> Void in
            
            if scenario?.tags?.contains("AdditionViewModel") ?? false {
                
               
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
            
            let additionViewModel = AdditionViewModel()
            
            input = createInput(field1: Observable.just(field1Value),
                                field2: Observable.just(args.first))
            
            output = additionViewModel.transform(input: input)
            output.result.drive().disposed(by: disposeBag)
        }
        
        Then("I see (.*) in the result label") { (args, _) -> Void in
         
            guard let args = args else  {
                XCTAssert(false)
                return
            }
            
            let resultExcepted = args.first
            
            let result = try! output.result.toBlocking().first()!
            
            XCTAssertEqual(resultExcepted, result)
        }
        
        let bundle = Bundle(for: AdditionViewModelInitializer.self)
        Cucumberish.executeFeatures(inDirectory: "features/presenter/addition", from: bundle, includeTags: nil, excludeTags: nil)
    }
    
    public class func createInput(field1: Observable<String?> = Observable.never(),
                                  field2: Observable<String?> = Observable.never()) -> AdditionViewModel.Input {
        
        return AdditionViewModel.Input(field1: field1,
                                         field2: field2)
    }
    
    
}

