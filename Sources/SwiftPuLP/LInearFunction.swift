//
//  LinearFunction.swift
//  
//  Created by Michel Tilman on 26/10/2021.
//  Copyright © 2021 Dotted.Pair.
//  Licensed under Apache License v2.0.
//

import Collections

/**
 Linear functions are linear combinations of variables and (double) factors and constants.
 They have the canonical format: a * x + b * y + ... + c, where:
    * factors a, b, ... represent double coefficients which may be omitted when 1;
    * the trailing double constant c may be omitted when 0.
    * x, y, ... represent variables.
 */
public struct LinearFunction {
    
    // Merge terms with same variable, keeping the order of terms.
    static private func mergeTerms(_ terms: [Term]) -> [Term] {
        let groupedTerms = OrderedDictionary<Variable, [Term]>(grouping: terms, by: (\.variable))
        guard groupedTerms.count < terms.count else { return terms }

        return groupedTerms.values.map { terms in
            let factor = terms.reduce(0.0) { factor, term in factor + term.factor }
            
            return terms.first!.variable.withFactor(factor)
        }
    }
    
    /// A term is a variable multiplied by a factor (i.e. its coefficient).
    public struct Term {
        
        // MARK: Stored properties
        
        // The factor.
        // Default = 1.
        let factor: Double
        
        // The variable of a term.
        // When creating a linear function, terms with same variable are merged,
        // with the combined factor.
       let variable: Variable

        // MARK: Initializing
        
        /// Creates a term consisting of a variable with optional factor.
        public init(variable: Variable, factor: Double = 1) {
            self.factor = factor
            self.variable = variable
        }
        
    }
    
    // MARK: Stored properties
    
    // Terms of the linear function.
    // May be empty.
    let terms: [Term]
    
    // Minimal element of a linear function.
    let constant: Double
    
    // MARK: Initializing
    
    /// Creates linear function with given terms and constant.
    /// Terms with the same variable are merged into one term.
    public init(terms: [Term], constant: Double = 0) {
        self.terms = terms.count > 1 ? Self.mergeTerms(terms) : terms
        self.constant = constant
    }
    
}


/**
 Covenience functions to compose linear functions using basic arithmetic operators.
 */
public extension Double {
    
    // MARK: Building linear functions
    
    static func * (lhs: Double, rhs: Variable) -> LinearFunction {
        LinearFunction(terms: [rhs.withFactor(lhs)])
    }
     
    static func * (lhs: Double, rhs: LinearFunction) -> LinearFunction {
        func applyFactor(_ term: LinearFunction.Term) -> LinearFunction.Term {
            LinearFunction.Term(variable: term.variable, factor: lhs * term.factor)
        }
        
        return LinearFunction(terms: rhs.terms.map(applyFactor), constant: lhs * rhs.constant)
    }
     
}


/**
 Covenience functions to compose linear functions using basic arithmetic operators.
 */
public extension Variable {
    
    // MARK: Building linear functions
    
    static func + (lhs: Variable, rhs: Double) -> LinearFunction {
        LinearFunction(terms: [lhs.withFactor(1)], constant: rhs)
    }
     
    static func + (lhs: Variable, rhs: Variable) -> LinearFunction {
        LinearFunction(terms: [lhs.withFactor(1), rhs.withFactor(1)])
    }
     
    static func + (lhs: Variable, rhs: LinearFunction) -> LinearFunction {
        LinearFunction(terms: [lhs.withFactor(1)] + rhs.terms, constant: rhs.constant)
    }
    
    static func - (lhs: Variable, rhs: Double) -> LinearFunction {
        LinearFunction(terms: [lhs.withFactor(1)], constant: -rhs)
    }
     
    static func - (lhs: Variable, rhs: Variable) -> LinearFunction {
        LinearFunction(terms: [lhs.withFactor(1), rhs.withFactor(-1)])
    }
     
    static func - (lhs: Variable, rhs: LinearFunction) -> LinearFunction {
        LinearFunction(terms: [lhs.withFactor(1)] + rhs.terms.map(\.negated), constant: -rhs.constant)
    }
    
    // MARK: Private building linear functions
    
    fileprivate func withFactor(_ factor: Double = 1) -> LinearFunction.Term {
        LinearFunction.Term(variable: self, factor: factor)
    }

}


/**
 Covenience functions to compose linear functions using basic arithmetic operators.
 */
public extension LinearFunction {
    
    // MARK: Building linear functions
    
    static func + (lhs: Self, rhs: Double) -> Self {
        LinearFunction(terms: lhs.terms, constant: lhs.constant + rhs)
    }
    
    static func + (lhs: Self, rhs: Variable) -> Self {
        LinearFunction(terms: lhs.terms + [rhs.withFactor(1)], constant: lhs.constant)
    }
    
    static func + (lhs: Self, rhs: Self) -> Self {
        LinearFunction(terms: lhs.terms + rhs.terms, constant: lhs.constant + rhs.constant)
    }
    
    static func - (lhs: Self, rhs: Double) -> Self {
        LinearFunction(terms: lhs.terms, constant: lhs.constant - rhs)
    }
    
    static func - (lhs: Self, rhs: Variable) -> Self {
        LinearFunction(terms: lhs.terms + [rhs.withFactor(-1)], constant: lhs.constant)
    }
    
    static func - (lhs: Self, rhs: Self) -> Self {
        LinearFunction(terms: lhs.terms + rhs.terms.map(\.negated), constant: lhs.constant - rhs.constant)
    }
    
}


/**
 Covenience functions to compose linear functions using basic arithmetic operators.
 */
public extension LinearFunction.Term {
    
    // MARK: Private computed properties
    
    // Answers the term with negated factor.
    fileprivate var negated: Self {
        Self(variable: variable, factor: -factor)
    }
    
}


/**
 Equatable extensions for variables and linear functions.
 */
extension LinearFunction.Term: Equatable {}

extension LinearFunction: Equatable {}
