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
        
        // The variable of a term.
        // When creating a linear function, terms with same variable are merged,
        // with the combined factor.
        let variable: Variable

        // The factor.
        // Default = 1.
        let factor: Double
        
        // MARK: Initializing
        
        /// Creates a term consisting of a variable with optional factor.
        public init(variable: Variable, factor: Double = 1) {
            self.factor = factor
            self.variable = variable
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
    let terms: [Term]
    
    // Minimal element of a linear function.
    let constant: Double
    
    // MARK: Initializing
    
    /// Creates a linear function with given terms and constant.
    public init(terms: [Term] = [], constant: Double = 0) {
        self.terms = terms
        self.constant = constant
    }
    
    /// Creates a linear function with given variable.
    public init(variable: Variable) {
        self.init(terms: [variable.term()])
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
        var groups = OrderedDictionary<Variable.Id, [Term]>()
        
        for term in terms where term.factor != 0 {
            groups[term.variable.id, default: []].append(term)
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
 Simplifies definition of some operations for building linear functions.
 */
public protocol LinearExpression {}

/**
 Variable adopts LinearExpression.
 */
extension Variable: LinearExpression {}

/**
 LinearFunction adopts LinearExpression.
 */
extension LinearFunction: LinearExpression {}

/**
 Operator for building linear functions.
 Handles case where compiler get confused (sddition of three variables or more in initializer).
 Intentionally not modelled as static function on LinearExpression extension.
 These operators combine factors and constants, but do not otherwise normalize the resulting function.
 */
public func + (lhs: LinearExpression, rhs: LinearExpression) -> LinearFunction {
    switch (lhs, rhs) {
    case (let l as Variable, let r as Variable):
        return LinearFunction(terms: [l.term(), r.term()])
    case (let l as Variable, let r as LinearFunction):
        return LinearFunction(terms: [l.term()] + r.terms, constant: r.constant)
    case (let l as LinearFunction, let r as Variable):
        return LinearFunction(terms: l.terms + [r.term()], constant: l.constant)
    case (let l as LinearFunction, let r as LinearFunction):
        return LinearFunction(terms: l.terms + r.terms, constant: l.constant + r.constant)
    default:
        return LinearFunction(terms: [])
    }
}
    

/**
 Covenience functions to compose linear functions using basic arithmetic operators.
 */
public extension Double {
    
    // MARK: Building linear functions
    
    static func * (lhs: Double, rhs: Variable) -> LinearFunction {
        LinearFunction(terms: [rhs.term(factor: lhs)])
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
    
    // MARK: Arithmetic operators building linear functions
    
    static prefix func + (variable: Variable) -> LinearFunction {
        LinearFunction(terms: [variable.term()])
    }
     
    static prefix func - (variable: Variable) -> LinearFunction {
        LinearFunction(terms: [variable.term(factor: -1)])
    }
     
    static func + (lhs: Variable, rhs: Double) -> LinearFunction {
        LinearFunction(terms: [lhs.term()], constant: rhs)
    }
     
    static func + (lhs: Variable, rhs: Variable) -> LinearFunction {
        LinearFunction(terms: [lhs.term(), rhs.term()])
    }
     
    static func + (lhs: Variable, rhs: LinearFunction) -> LinearFunction {
        LinearFunction(terms: [lhs.term()] + rhs.terms, constant: rhs.constant)
    }

    static func - (lhs: Variable, rhs: Double) -> LinearFunction {
        LinearFunction(terms: [lhs.term()], constant: -rhs)
    }
     
    static func - (lhs: Variable, rhs: Variable) -> LinearFunction {
        LinearFunction(terms: [lhs.term(), rhs.term(factor: -1)])
    }
     
    static func - (lhs: Variable, rhs: LinearFunction) -> LinearFunction {
        LinearFunction(terms: [lhs.term()] + rhs.terms.map(\.negated), constant: -rhs.constant)
    }
    
    // MARK: Building linear functions
    
    // Answesr a Term with the variable and given factor.
    internal func term(factor: Double = 1) -> LinearFunction.Term {
        LinearFunction.Term(variable: self, factor: factor)
    }

}


/**
 Covenience functions to compose linear functions using basic arithmetic operators.
 */
public extension LinearFunction {
    
    // MARK: Building linear functions
    
    static prefix func + (function: LinearFunction) -> LinearFunction {
        function
    }
     
    static prefix func - (function: LinearFunction) -> LinearFunction {
        LinearFunction(terms: function.terms.map(\.negated), constant: -function.constant)
    }
     
    static func + (lhs: LinearFunction, rhs: Double) -> LinearFunction {
        LinearFunction(terms: lhs.terms, constant: lhs.constant + rhs)
    }
    
    static func + (lhs: LinearFunction, rhs: Variable) -> LinearFunction {
        LinearFunction(terms: lhs.terms + [rhs.term()], constant: lhs.constant)
    }
    
    static func + (lhs: LinearFunction, rhs: LinearFunction) -> LinearFunction {
        LinearFunction(terms: lhs.terms + rhs.terms, constant: lhs.constant + rhs.constant)
    }
    
    static func - (lhs: LinearFunction, rhs: Double) -> LinearFunction {
        LinearFunction(terms: lhs.terms, constant: lhs.constant - rhs)
    }
    
    static func - (lhs: LinearFunction, rhs: Variable) -> LinearFunction {
        LinearFunction(terms: lhs.terms + [rhs.term(factor: -1)], constant: lhs.constant)
    }
    
    static func - (lhs: LinearFunction, rhs: LinearFunction) -> LinearFunction {
        LinearFunction(terms: lhs.terms + rhs.terms.map(\.negated), constant: lhs.constant - rhs.constant)
    }
    
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
