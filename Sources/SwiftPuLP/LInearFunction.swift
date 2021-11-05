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
    
    // Merges terms with same variable, respecting the original order of terms.
    static private func mergeTerms(_ terms: [Term]) -> [Term] {
        guard terms.count > 1 else { return terms }
        let groups = OrderedDictionary<ObjectIdentifier, [Term]>(grouping: terms) {
            ObjectIdentifier($0.variable)
        }
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
        
        func withFactor(_ factor: Double) -> Term {
            Term(variable: variable, factor: factor * self.factor)
        }
        
        // MARK: Evaluating
        
        // Answers the result of applying the term to given values dictionary.
        // Ignores variables with name not listed in the dictionary.
        func callAsFunction(_ values: [String: Double]) -> Double {
            (values[variable.name] ?? 0) * factor
        }
        
    }
    
    // MARK: Stored properties
    
    // Terms of the linear function.
    // May be empty.
    public let terms: [Term]
    
    // Minimal element of a linear function.
    public let constant: Double
    
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
        self.terms = variable.terms
        self.constant = 0
    }
    
    // MARK: Evaluating
    
    /// Answers the result of applying the function to given values.
    public func callAsFunction(_ values: [String: Double]) -> Double {
        terms.reduce(constant) { total, term in total + term(values) }
    }
    
}


/**
 Represents linear functions and variables.
 Simplifies definition of shared operators for building linear functions.
 */
public protocol LinearExpression {
    
    var terms: [LinearFunction.Term] { get }
    
    var constant: Double { get }
    
}


/**
 Variable adopts LinearExpression.
 */
extension Variable: LinearExpression {
    
    // MARK: Computed properties
    
    /// Answers the constant of the variable viewed as a linear function.
   public var constant: Double {
        0
    }
    
    /// Answers the terms of the variable viewed as a linear function.
    public var terms: [LinearFunction.Term] {
        [LinearFunction.Term(variable: self, factor: 1)]
    }
    
}


/**
 LinearFunction adopts LinearExpression.
 */
extension LinearFunction: LinearExpression {}


/**
 Operators for building linear functions.
 Intentionally not modelled as static functions (e.g. on LinearExpression extension).
 */
public prefix func + (expression: LinearExpression) -> LinearFunction {
    LinearFunction(terms: expression.terms, constant: expression.constant)
}

public prefix func - (expression: LinearExpression) -> LinearFunction {
    LinearFunction(terms: expression.terms.map(\.negated), constant: -expression.constant)
}

public func + (lhs: LinearExpression, rhs: LinearExpression) -> LinearFunction {
    LinearFunction(terms: lhs.terms + rhs.terms, constant: lhs.constant + rhs.constant)
}

public func - (lhs: LinearExpression, rhs: LinearExpression) -> LinearFunction {
    LinearFunction(terms: lhs.terms + rhs.terms.map(\.negated), constant: lhs.constant - rhs.constant)
}

public func + (lhs: LinearExpression, rhs: Double) -> LinearFunction {
    LinearFunction(terms: lhs.terms, constant: lhs.constant + rhs)
}

public func - (lhs: LinearExpression, rhs: Double) -> LinearFunction {
    LinearFunction(terms: lhs.terms, constant: lhs.constant - rhs)
}

public func * (lhs: Double, rhs: LinearExpression) -> LinearFunction {
    LinearFunction(terms: rhs.terms.map { $0.withFactor(lhs) }, constant: lhs * rhs.constant )
}
    

/**
 Covenience functions to compose linear functions.
 */
extension LinearFunction.Term {
    
    // MARK: Private computed properties
    
    // Answers the term with negated factor.
    var negated: Self {
        Self(variable: variable, factor: -factor)
    }
    
}


/**
 Linear function adopts PythonConvertible.
 */
extension LinearFunction: PythonConvertible {

    // MARK: Computed properties
    
    /// Converts the linear function into a PuLP LpAffineExpression.
    public var pythonObject: PythonObject {
        pythonObject(withCache: nil)
    }

    // MARK: Converting to Python
    
    // Converts the function into an LpAffineExpression, optionally caching PuLP variables.
    func pythonObject(withCache cache: VariableCache?) -> PythonObject {
        func pythonTuple(_ term: Term) -> PythonObject {
            PythonObject(tupleOf: term.variable.pythonObject(withCache: cache), term.factor)
        }
        
        return PuLP.LpAffineExpression(terms.map(pythonTuple), constant: constant)
    }
    
}


/**
 LinearFunction adopts Equatable with default behaviour.
 */
extension LinearFunction.Term: Equatable {}
extension LinearFunction: Equatable {}
