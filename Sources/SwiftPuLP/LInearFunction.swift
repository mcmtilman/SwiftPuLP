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
    
    /// A term is a variable multiplied by a factor (i.e. its coefficient).
    public struct Term {
        
        // MARK: Stored properties
        
        // The factor.
        // Default = 1.
        public let factor: Double
        
        // The variable of a term.
        // When creating a linear function, terms with same variable are merged,
        // with the combined factor.
        public let variable: Variable

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
    public init(terms: [Term] = [], constant: Double = 0) {
        self.terms = terms
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
    
    // MARK: Normalizing
    
    /// Answers the result of merging terms with same variables, ignoring merged terms with factor 0.
    /// Keeps original order of first occurrence of variables.
    public func normalized() -> Self {
        guard terms.count > 0 else { return self }
        guard terms.count > 1 else { return terms[0].factor == 0 ? Self() : self }
        var groups = OrderedDictionary<ObjectIdentifier, [Term]>()
        
        for term in terms where term.factor != 0 {
            groups[ObjectIdentifier(term.variable), default: []].append(term)
        }

        guard groups.count < terms.count else { return self }
        let mergedTerms: [Term] = groups.values.compactMap { terms in
            let term = terms[0]
            guard terms.count > 1 else { return term }
            let factor = terms.reduce(0) { total, term in total + term.factor }
            
            return factor == 0 ? nil : Term(variable: term.variable, factor: factor)
        }
        
        return Self(terms: mergedTerms, constant: constant)
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
 These operators combine factors and constants, but do not otherwise normalize the resulting function.
 */
public prefix func + (expression: LinearExpression) -> LinearFunction {
    switch expression {
    case let function as LinearFunction:
        return function
    default:
        return LinearFunction(terms: expression.terms, constant: expression.constant)
    }
    
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
