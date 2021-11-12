////
//  Functions.swift
//  
//  Created by Michel Tilman on 03/11/2021.
//  Copyright © 2021 Dotted.Pair.
//  Licensed under Apache License v2.0.
//

/**
 Helper functions to simplify elaboration of a model.
 
 Use enum as a namespace.
 */
public enum Function {
    
    // MARK: Linear functions
    
    /// Answers a linear function representing the sum of given sequence of variables.
    ///
    /// > Note: Does not normalize the resulting function.
    ///
    /// - Parameter variables: Sequence of Variable.
    /// - Returns: Linear function consisting of a term for each variable with factor 1.
    public static func sum<T>(_ variables: T) -> LinearFunction where T: Sequence, T.Element == Variable {
        LinearFunction(terms: variables.map { LinearFunction.Term(variable: $0, factor: 1) })
    }

}
