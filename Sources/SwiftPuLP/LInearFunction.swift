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
    * factors a, b, ... represent non-zero double coefficients which may be omitted in most cases when 1;
    * the trailing double constant c may be omitted when 0.
    * x, y, ... represent different variables.
 
 Note. Expressions consisting of a single variable or a single constant are not recognized as linear functions by the compiler.
 To use variable x as a function, the + prefix operator serves as a shortcut for 1 * x.
 
        let x = Variable("x")
 
        let function = +x
 
 */
public struct LinearFunction {
    
    /// A term is a variable multiplied by a factor (its coefficient).
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
    
    /// Creates a linear function with given terms and constant of the form Σ ai * xi + c.
    /// - Parameters:
    ///   - terms: List of variable - factor terms. May be empty (default).
    ///   - constant: constant c (default = 0).
    public init(terms: [Term] = [], constant: Double = 0) {
        self.terms = terms
        self.constant = constant
    }
    
    /// Creates a linear function consisting of a single term with given variable and factor 1.
    /// - Parameter variable: The variable,
    public init(variable: Variable) {
        self.init(terms: [variable.term()])
    }
    
    // MARK: Evaluating
    
    /// Answers the result of applying the function to given parameters.
    ///
    /// If a variable is not present in the parameter dictionary, value 0 is assumed.
    public func callAsFunction(_ values: [String: Double]) -> Double {
        terms.reduce(constant) { total, term in total + term(values) }
    }
    
    // MARK: Normalizing
    
    /// Answers the result of merging terms with same variables, ignoring merged terms with factor 0.
    /// Keeps original order of first occurrence of variables.
    ///
    /// EXample: 2 * x + 3 * y - 5 * z + x - 4 * y + y + 10 becomes 3 * x - 5 * z + 10 after normalization,
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
 Simplifies the definition of some operations for building linear functions.
 
 Without ``Variable`` and ``LinearFunction`` adopting this protocol, the compiler runs into problems when adding 3 or more variables:

        let (x, y, z) = (Variable("x"), Variable("y"), Variable("z"))
        let function = x + y + z
 
 Type-annotating the function or adding parentheses does not help, while the following does work:
 
        let (x, y, z) = (Variable("x"), Variable("y"), Variable("z"))
        var function = x + y
 
        function = x + y + z
 
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
 Operator for adding lhs (variable | linear function) and rhs (variable | linear function).
 Combines constants, but does not otherwise normalize the resulting function.
 For instance: adding function 2 * x + 5 and function 3 * x + 10 yields 2 * x + 3 * x + 15. Use ``LinearFunction/normalized()`` to merge the x variables into 5 * x.
 Handles case where compiler get confused (sddition of three variables or more in initializer).
 
 Switches over the four possible combinations to improve performance and make requirements of adopting types simpler.
 
 Intentionally not modelled as a static function on a LinearExpression extension.
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
 Covenience functions to multiply linear functions with a factor.
 */
public extension Double {
    
    // MARK: Building linear functions
    
    /// Converts lhs factor a and rhs variable x into linear function a * x + 0.
    static func * (lhs: Double, rhs: Variable) -> LinearFunction {
        LinearFunction(terms: [rhs.term(factor: lhs)])
    }
     
    /// Converts lhs factor a and rhs function Σ bi * xi + c into linear function Σ a * bi * xi + a * c.
    static func * (lhs: Double, rhs: LinearFunction) -> LinearFunction {
        func applyFactor(_ term: LinearFunction.Term) -> LinearFunction.Term {
            LinearFunction.Term(variable: term.variable, factor: lhs * term.factor)
        }
        
        return LinearFunction(terms: rhs.terms.map(applyFactor), constant: lhs * rhs.constant)
    }
     
}


/**
 Covenience functions to compose linear functions using basic arithmetic operators.
 The resulting functions are not normalized: if a variable appears multiple times in the result, its occurences are not merged. For instance:
 */
public extension Variable {
    
    // MARK: Arithmetic operators building linear functions
    
    /// Converts lhs variable x into linear function 1 * x + 0
    static prefix func + (variable: Variable) -> LinearFunction {
        LinearFunction(terms: [variable.term()])
    }
     
    /// Converts lhs variable x into linear function -1 * x + 0
    static prefix func - (variable: Variable) -> LinearFunction {
        LinearFunction(terms: [variable.term(factor: -1)])
    }
     
    /// Converts  lhs variable x and rhs constant c into linear function 1 * x + c.
    static func + (lhs: Variable, rhs: Double) -> LinearFunction {
        LinearFunction(terms: [lhs.term()], constant: rhs)
    }
     
    /// Converts  lhs variable x and rhs variable y into linear function 1 * x + 1 * y + 0.
    static func + (lhs: Variable, rhs: Variable) -> LinearFunction {
        LinearFunction(terms: [lhs.term(), rhs.term()])
    }
     
    /// Converts  lhs variable x and rhs function Σ ai * xi + c into 1 * x + Σ ai * xi + c.
    static func + (lhs: Variable, rhs: LinearFunction) -> LinearFunction {
        LinearFunction(terms: [lhs.term()] + rhs.terms, constant: rhs.constant)
    }

    /// Converts  lhs variable x and rhs constant c into linear function 1 * x - c.
    static func - (lhs: Variable, rhs: Double) -> LinearFunction {
        LinearFunction(terms: [lhs.term()], constant: -rhs)
    }
     
    /// Converts  lhs variable x and rhs variable y into linear function 1 * x - 1 * y + 0.
    static func - (lhs: Variable, rhs: Variable) -> LinearFunction {
        LinearFunction(terms: [lhs.term(), rhs.term(factor: -1)])
    }
     
    /// Converts  lhs variable x and rhs function Σ ai * xi + c into 1 * x + Σ -ai * xi - c.
    static func - (lhs: Variable, rhs: LinearFunction) -> LinearFunction {
        LinearFunction(terms: [lhs.term()] + rhs.terms.map(\.negated), constant: -rhs.constant)
    }
    
    // MARK: Private building linear functions
    
    // Answers a Term with the variable and given factor.
    fileprivate func term(factor: Double = 1) -> LinearFunction.Term {
        LinearFunction.Term(variable: self, factor: factor)
    }

}


/**
 Covenience functions to compose linear functions using basic arithmetic operators.
 The resulting functions are not ``LinearFunction.normalized()``: if a variable appears multiple times in the result, its occurences are not merged.
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
    fileprivate var negated: Self {
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
