//
//  Cucumberish.m
//  Calculator
//
//  Created by Benjamin Seillier on 02/07/2018.
//  Copyright © 2018 Benjamin Seillier. All rights reserved.
//

#import "CalculatorTests-Swift.h"

__attribute__((constructor))
void CucumberishInit()
{
    [CalculatorViewModelInitializer cucumberishSwiftInit];
}
