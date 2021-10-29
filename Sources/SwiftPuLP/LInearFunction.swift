//
//  LinearFunction.swift
//  
//  Created by Michel Tilman on 26/10/2021.
//  Copyright © 2021 Dotted.Pair.
//  Licensed under Apache License v2.0.
//

import Collections
import PythonKit

/**
 Linear functions are linear combinations of variables and (double) factors and constants.
 They have the canonical format: a * x + b * y + ... + c, where:
    * factors a, b, ... represent non-zero double coefficients which may be omitted when 1;
    * the trailing double constant c may be omitted when 0.
    * x, y, ... represent different variables.
 Note. Expressions consisting of a single variable or a single constant are not recognized as linear functions (cf. arithmetic operator building blocks).
 */
public struct LinearFunction {
    
    // Merges terms with same variable name, respecting the original order of terms.
    static private func mergeTerms(_ terms: [Term]) -> [Term] {
        guard terms.count > 1 else { return terms }
        let groups = OrderedDictionary<String, [Term]>(grouping: terms, by: (\.variable.name))
        guard groups.count < terms.count else { return terms }

        return groups.values.map { terms in
            let term = terms[0]
            guard terms.count > 1 else { return term }

            return Term(variable: term.variable, factor: terms.map(\.factor).reduce(0, +))
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
        
        // MARK: Evaluating
        
        // Answers the result of evaluating the term with given variable values.
        func eval(with values: [String: Double]) -> Double {
            (values[variable.name] ?? 0) * factor
        }
        
    }
    
    // MARK: Stored properties
    
    // Terms of the linear function.
    // May be empty.
    let terms: [Term]
    
    // Minimal element of a linear function.
    let constant: Double
    
    // MARK: Initializing
    
    /// Creates a linear function with given terms and constant.
    /// Merges terms with the same variable name into one, using the first encountered variable's properties.
    /// Ignores merged terms with factor 0.
    public init(terms: [Term], constant: Double = 0) {
        self.terms = Self.mergeTerms(terms).filter { $0.factor != 0 }
        self.constant = constant
    }
    
    /// Creates a linear function with given variable.
    public init(variable: Variable) {
        self.terms = [variable.withFactor(1)]
        self.constant = 0
    }
    
    // MARK: Evaluating
    
    // Answers the result of evaluating the function with given variable values.
    public func eval(with values: [String: Double]) -> Double {
        terms.reduce(constant) { total, term in total + term.eval(with: values) }
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
    
    static prefix func - (value: Variable) -> LinearFunction {
        LinearFunction(terms: [value.withFactor(-1)])
    }
     
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
    
    static prefix func - (value: LinearFunction) -> LinearFunction {
        LinearFunction(terms: value.terms.map(\.negated), constant: -value.constant)
    }
     
    static func + (lhs: Self, rhs: Double) -> Self {
        Self(terms: lhs.terms, constant: lhs.constant + rhs)
    }
    
    static func + (lhs: Self, rhs: Variable) -> Self {
        Self(terms: lhs.terms + [rhs.withFactor(1)], constant: lhs.constant)
    }
    
    static func + (lhs: Self, rhs: Self) -> Self {
        Self(terms: lhs.terms + rhs.terms, constant: lhs.constant + rhs.constant)
    }
    
    static func - (lhs: Self, rhs: Double) -> Self {
        Self(terms: lhs.terms, constant: lhs.constant - rhs)
    }
    
    static func - (lhs: Self, rhs: Variable) -> Self {
        Self(terms: lhs.terms + [rhs.withFactor(-1)], constant: lhs.constant)
    }
    
    static func - (lhs: Self, rhs: Self) -> Self {
        Self(terms: lhs.terms + rhs.terms.map(\.negated), constant: lhs.constant - rhs.constant)
    }
    
}


/**
 Covenience functions to compose linear functions.
 */
extension LinearFunction.Term {
    
    // MARK: Private computed properties
    
    // Answers the term with negated factor.
    fileprivate var negated: Self {
        Self(variable: variable, factor: -factor)
    }
    
}


/**
 Linear function adopts PythonConvertible.
 */
extension LinearFunction: PythonConvertible {

    // MARK: Computed properties
    
    /**
     Converts the linear function into a PuLP LpAffineExpression.
     */
    public var pythonObject: PythonObject {
        func pythonTuple(_ term: Term) -> PythonObject {
            PythonObject(tupleOf: term.variable, term.factor)
        }
        
        return PuLP.LpAffineExpression(terms.map(pythonTuple), constant: constant)
    }

}


/**
 LinearFunction adopts Equatable with default behaviour.
 */
extension LinearFunction.Term: Equatable {}
extension LinearFunction: Equatable {}
