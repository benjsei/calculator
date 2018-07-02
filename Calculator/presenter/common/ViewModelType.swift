//
//  ViewModelType.swift
//  Calculator
//
//  Created by Benjamin Seillier on 02/07/2018.
//  Copyright © 2018 Benjamin Seillier. All rights reserved.
//

import Foundation

/// protocol to specify viewModel architecture
protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    
    // MARK: - Public Function
    
    /// transform input to ouput
    ///
    /// - Parameter input: input driver
    /// - Returns: output driver
    func transform(input: Input) -> Output
}
