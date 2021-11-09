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
 A linear function is the sum of zero or more terms and a constant, where each term is the product of a variable with a coefficient (aka factor).

 Linear functions have the canonical form a * x + b * y + ... + c, where:
    * x, y, ... represent different variables;
    * factors a, b, ... represent non-zero double coefficients (which may be omitted in most cases when 1);
    * the trailing double constant c may typically be omitted when 0.
 
 Overloading the arithmetic operators allows us to construct linear functions as in the following example.
 
        let (x, y) = (Variable("x"), Variable("y"))
        let function = 2 * x + 3 * y + 10

 Note that expressions consisting of a single variable or a single constant are not recognized as linear functions by the compiler. To use a variable x as a linear function, apply the + prefix operator (as a shortcut for 1 * x).
 
        let x = Variable("x")
        let function = +x
 
 */
public struct LinearFunction {
    
    // MARK: -
    
    ////// A term is a variable multiplied by a factor.
    public struct Term {
        
        // MARK: -
        
        /// The variable of a term.
        let variable: Variable

        /// The factor.
        let factor: Double
        
        // MARK: -
        
        /// Creates a term consisting of a variable with optional factor.
        ///
        /// - Parameters:
        ///   - variable: Variable of the term.
        ///   - factor: Coefficient of the variable (default = 1).
        public init(variable: Variable, factor: Double = 1) {
            self.factor = factor
            self.variable = variable
        }
        
        // MARK: -
        
        /// Answers the result of applying the term to given parameters.
        ///
        /// - Parameter parameters: Parameter values keyed by variable names. If the variable name is not found in the dictionary, a value of 0 is assumed.
        /// - Returns: Parameter value * factor.
        func callAsFunction(_ parameters: [String: Double]) -> Double {
            (parameters[variable.name] ?? 0) * factor
        }
        
    }
    
    // MARK: -
    
    /// Terms of the linear function.
    /// May be empty.
    let terms: [Term]
    
    /// Constant of a linear function.
    let constant: Double
    
    // MARK: -
    
    /// Creates a linear function with given terms and constant of the form Σ ai * xi + c.
    /// 
    /// - Parameters:
    ///   - terms: List of variable - factor terms. May be empty (default).
    ///   - constant: Constant c (default = 0).
    public init(terms: [Term] = [], constant: Double = 0) {
        self.terms = terms
        self.constant = constant
    }
    
    /// Creates a linear function consisting of a single term with given variable and factor 1.
    ///
    /// - Parameter variable: The variable (implicit factor 1).
    public init(variable: Variable) {
        self.init(terms: [variable.term()])
    }
    
    // MARK: -
    
    /// Answers the result of applying the function to given parameters. Allows client code to calculate the objective function applied to the variables computed by the solver.
    ///
    /// - Parameter parameters: Parameter values keyed by variable names. If a variable name is not found in the dictionary, a value of 0 is assumed
    /// - Returns: Total sum of the terms applied to the parameters + constant.
    public func callAsFunction(_ parameters: [String: Double]) -> Double {
        terms.reduce(constant) { total, term in total + term(parameters) }
    }
    
    /// Answers the result of merging terms with same variables, ignoring merged terms with factor 0.
    /// Keeps original order of first occurrence of variables. The result is a linear function in canonical form.
    ///
    /// Before normalization.
    ///
    ///     2 * x + 3 * y - 5 * z + x - 4 * y + y + 10
    ///
    /// After normalization.
    ///
    ///     3 * x - 5 * z + 10
    ///
    /// - Returns: A linear function calculating the same result as the receiver. Every variable occurs only once in the terms.
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

// MARK: - LinearExpression -

/**
 LinearExpression represents linear functions and variables.
 Simplifies the definition of some operations for building linear functions.
 
 Without ``Variable`` and ``LinearFunction`` adopting this protocol, the compiler runs into problems when adding 3 or more variables:

        let (x, y, z) = (Variable("x"), Variable("y"), Variable("z"))
        let function = x + y + z // does not compile
 
 Type-annotating the function or adding parentheses does not help, while the following does work:
 
        let (x, y, z) = (Variable("x"), Variable("y"), Variable("z"))
        var function = x + y
 
        function = x + y + z // compiles
 */
public protocol LinearExpression {}


// MARK: -

/**
 Variable adopts LinearExpression.
 */
extension Variable: LinearExpression {}


// MARK: -

/**
 LinearFunction adopts LinearExpression.
 */
extension LinearFunction: LinearExpression {}

// MARK: -

/**
 Operator for adding the lhs and rhs expressions
 Combines constants, but does not otherwise normalize the resulting function.
 For instance: adding function 2 * x + 5 and function 3 * x + 10 yields 2 * x + 3 * x + 15. Use ``LinearFunction/normalized()`` to merge the x variables into 5 * x.
 Handles case where compiler get confused (addition of three variables or more in initializer).
 
 Switches over the four possible combinations to improve performance and make requirements of adopting types simpler.
 
 Intentionally not modelled as a static function on a LinearExpression extension.
 
 - Parameters:
    - lhs: Variable or LinearFunction.
    - rhs: Variable or LinearFunction.
 - Returns: Non-normalized linear function representng the sum of lhs and rhs.
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


// MARK: - Arithmetic operators

/**
 Covenience functions to multiply linear functions with a factor.
 */
public extension Double {
    
    // MARK: -
    
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


// MARK: -

/**
 Covenience functions to compose linear functions using basic arithmetic operators.
 The resulting functions are not normalized: if a variable appears multiple times in the result, its occurences are not merged. For instance:
 */
public extension Variable {
    
    // MARK: -
    
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
    
    // MARK: -
    
    // Answers a Term with the variable and given factor.
    fileprivate func term(factor: Double = 1) -> LinearFunction.Term {
        LinearFunction.Term(variable: self, factor: factor)
    }

}


// MARK: -

/**
 Covenience functions to compose linear functions using basic arithmetic operators.
 The resulting functions are not ``LinearFunction.normalized()``: if a variable appears multiple times in the result, its occurences are not merged.
 */
public extension LinearFunction {
    
    // MARK: -
    
    /// Returns the function as is.
    static prefix func + (function: LinearFunction) -> LinearFunction {
        function
    }
     
    /// Converts function Σ ai * xi + c into Σ -ai * xi - c.
    static prefix func - (function: LinearFunction) -> LinearFunction {
        LinearFunction(terms: function.terms.map(\.negated), constant: -function.constant)
    }
     
    /// Converts lhs function Σ ai * xi + c and rhs constant d into Σ ai * xi + (c + d).
    static func + (lhs: LinearFunction, rhs: Double) -> LinearFunction {
        LinearFunction(terms: lhs.terms, constant: lhs.constant + rhs)
    }
    
    /// Converts lhs function Σ ai * xi + c and rhs variable x into Σ ai * xi + 1 * x + c.
    static func + (lhs: LinearFunction, rhs: Variable) -> LinearFunction {
        LinearFunction(terms: lhs.terms + [rhs.term()], constant: lhs.constant)
    }
    
    /// Converts lhs function Σ ai * xi + c and rhs function Σ bi * yi + d into Σ ai * xi + Σ bi * yi + (c + d).
    static func + (lhs: LinearFunction, rhs: LinearFunction) -> LinearFunction {
        LinearFunction(terms: lhs.terms + rhs.terms, constant: lhs.constant + rhs.constant)
    }
    
    /// Converts lhs function Σ ai * xi + c and rhs constant d into Σ ai * xi + (c - d).
    static func - (lhs: LinearFunction, rhs: Double) -> LinearFunction {
        LinearFunction(terms: lhs.terms, constant: lhs.constant - rhs)
    }
    
    /// Converts lhs function Σ ai * xi + c and rhs variable x into Σ ai * xi - 1 * x + c.
    static func - (lhs: LinearFunction, rhs: Variable) -> LinearFunction {
        LinearFunction(terms: lhs.terms + [rhs.term(factor: -1)], constant: lhs.constant)
    }
    
    /// Converts lhs function Σ ai * xi + c and rhs function Σ bi * yi + d into Σ ai * xi + Σ -bi * yi + (c - d).
    static func - (lhs: LinearFunction, rhs: LinearFunction) -> LinearFunction {
        LinearFunction(terms: lhs.terms + rhs.terms.map(\.negated), constant: lhs.constant - rhs.constant)
    }
    
}

// MARK: -

/**
 Covenience functions to compose linear functions.
 */
extension LinearFunction.Term {
    
    // MARK: -
    
    // Answers the term with negated factor.
    fileprivate var negated: Self {
        Self(variable: variable, factor: -factor)
    }
    
}


// MARK: - PythonConvertible -

/**
 Linear function adopts PythonConvertible.
 */
extension LinearFunction: PythonConvertible {

    // MARK: -
    
    /// Converts the linear function into a PuLP LpAffineExpression.
    public var pythonObject: PythonObject {
        pythonObject(withCache: nil)
    }

    // MARK: -
    
    // Converts the function into a LpAffineExpression, optionally caching PuLP variables.
    //
    // - Parameter cache: Cache of generated Python LpVariable instances for each SwithPuLP variable.
    // - Returns: Python LpAffineExpression.
    func pythonObject(withCache cache: VariableCache?) -> PythonObject {
        func pythonTuple(_ term: Term) -> PythonObject {
            PythonObject(tupleOf: term.variable.pythonObject(withCache: cache), term.factor)
        }
        
        return PuLP.LpAffineExpression(terms.map(pythonTuple), constant: constant)
    }
    
}


// MARK: - Equatable -

/**
 LinearFunction adopts Equatable with default behaviour.
 */
extension LinearFunction.Term: Equatable {}

// MARK: -

extension LinearFunction: Equatable {}
