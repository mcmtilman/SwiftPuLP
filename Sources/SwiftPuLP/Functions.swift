////
//  Functions.swift
//  
//  Created by Michel Tilman on 03/11/2021.
//  Copyright © 2021 Dotted.Pair.
//  Licensed under Apache License v2.0.
//

/**
 Common functions.
 */
public enum Function {
    
    // MARK: Linear functions
    
    /// Answers a linear function representing the sum of given sequence of variables.
    public static func sum<T>(_ variables: T) -> LinearFunction where T: Sequence, T.Element == Variable {
        LinearFunction(terms: variables.map { LinearFunction.Term(variable: $0, factor: 1) })
    }

}
