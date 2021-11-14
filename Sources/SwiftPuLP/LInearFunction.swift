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

 Linear functions have the form *a ∗ x + b ∗ y + ... + c*, where:
 * x, y, ... denote variables;
 * a, b, ... are coefficients;
 * c is the constant of the function.
 Coefficients and constant are Double numbers.
 
 Arithmetic operators allows us to construct linear functions as in the following example.
 
 ```swift
 let (x, y) = (Variable("x"), Variable("y"))
 let function = 2 * x + 3 * y + 10
 ```
 
 See also: <doc:UsingLinearFunctions>.
  */
public struct LinearFunction {
    
    // MARK: -
    
    /// A term is a variable with its factor.
    ///
    /// A linear function may contain terms with factor 0. These terms are removed when *normalizing* the function.
    public struct Term {
        
        // MARK: -
        
        /// The variable of the term.
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
        /// - Parameter parameters: Parameter values keyed by variable names. If the term's variable name is not found in the dictionary, a value of 0 is assumed.
        /// - Returns: Parameter value ∗ factor.
        func callAsFunction(_ parameters: [String: Double]) -> Double {
            (parameters[variable.name] ?? 0) * factor
        }
        
    }
    
    // MARK: -
    
    /// Terms of the linear function.
    /// May be empty.
    let terms: [Term]
    
    /// Constant of the linear function.
    let constant: Double
    
    // MARK: -
    
    /// Creates a linear function summing given terms and constant, i.e. Σ ai ∗ xi + c.
    /// 
    /// - Parameters:
    ///   - terms: List of terms (default = []).
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
    
    /// Answers the result of applying the function to given parameters.
    ///
    /// - Parameter parameters: Parameter values keyed by variable names. If a variable name is not found in the dictionary, a value of 0 is assumed
    /// - Returns: Total sum of the terms applied to the parameters + constant.
    public func callAsFunction(_ parameters: [String: Double]) -> Double {
        terms.reduce(constant) { total, term in total + term(parameters) }
    }
    
    /// Answers the result of merging terms with same variables, ignoring merged terms with factor 0.
    /// The result is a linear function in canonical form.
    ///
    /// Keeps original order of first occurrence of each variable.
    ///
    /// - Returns: A linear function representing the same mathematical function as the receiver, with every variable instance occuring at most once.
    public func normalized() -> Self {
        guard terms.count > 0 else { return self }
        
        let tuples = terms.map { ($0.variable, $0) }
        let mergedTerms = OrderedDictionary(tuples) { t1, t2 in
            Term(variable: t1.variable, factor: t1.factor + t2.factor)
        }.values.filter { $0.factor != 0 }

        return Self(terms: mergedTerms, constant: constant)
    }
    
}

// MARK: - LinearExpression -

/**
 LinearExpression represents linear functions and variables.
 
 This protocol was mainly introduced to address some compiler issues. Without Variable and LinearFunction adopting this protocol, the compiler gets confused when summing 3 or more variables without an explicit coefficient.

 ```swift
 let (x, y, z) = (Variable("x"), Variable("y"), Variable("z"))
 let function1 = x + y // did compile
 let function2 = x + y + z // did not compile
 ```
 
 Type-annotating the function or adding parentheses did not help, while the following did work.
 
 ```swift
 let (x, y, z) = (Variable("x"), Variable("y"), Variable("z"))
 var function = x + y
 
 function = x + y + z // did compile
 ```
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
 Operator for summing the lhs and rhs linear expressions

 Handles a case where the compiler gets confused (summing three variables or more in a function initializer).
 
 Switches over the possible combinations to improve performance and keep requirements of adopting types simple.
 
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
    default: // Should not happen unless a new type adopts the protocol.
        return LinearFunction(terms: [])
    }
}


// MARK: - Arithmetic operators

/**
 Covenience functions to multiply a linear function with a factor.
 */
public extension Double {
    
    // MARK: -
    
    /// Converts lhs factor a and rhs variable x into linear function a ∗ x + 0.
    static func * (lhs: Double, rhs: Variable) -> LinearFunction {
        LinearFunction(terms: [rhs.term(factor: lhs)])
    }
     
    /// Converts lhs factor f and rhs function Σ aᵢ ∗ xᵢ + c into linear function Σ f ∗ aᵢ ∗ xᵢ + f ∗ c.
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
 
 Constants are combined when needed, but otherwise the resulting function is not normalized: if a variable appears multiple times in the result, its occurences are not merged. Use ``LinearFunction/normalized()`` to merge terms and remove terms with factor 0.
 
 Function results are documented as sums of terms and a constant.
 */
public extension Variable {
    
    // MARK: -
    
    /// Converts variable x into linear function 1 ∗ x + 0
    static prefix func + (variable: Variable) -> LinearFunction {
        LinearFunction(terms: [variable.term()])
    }
     
    /// Converts lhs variable x into linear function -1 ∗ x + 0.
    static prefix func - (variable: Variable) -> LinearFunction {
        LinearFunction(terms: [variable.term(factor: -1)])
    }
     
    /// Combines  lhs variable x and rhs constant c into linear function 1 ∗ x + c.
    static func + (lhs: Variable, rhs: Double) -> LinearFunction {
        LinearFunction(terms: [lhs.term()], constant: rhs)
    }
     
    /// Combines  lhs variable x and rhs variable y into linear function 1 ∗ x + 1 ∗ y + 0.
    static func + (lhs: Variable, rhs: Variable) -> LinearFunction {
        LinearFunction(terms: [lhs.term(), rhs.term()])
    }
     
    /// Combines  lhs variable x and rhs function Σ aᵢ ∗ xᵢ + c into 1 ∗ x + Σ aᵢ ∗ xᵢ + c.
    static func + (lhs: Variable, rhs: LinearFunction) -> LinearFunction {
        LinearFunction(terms: [lhs.term()] + rhs.terms, constant: rhs.constant)
    }

    /// Combines  lhs variable x and rhs constant c into linear function 1 ∗ x + -c.
    static func - (lhs: Variable, rhs: Double) -> LinearFunction {
        LinearFunction(terms: [lhs.term()], constant: -rhs)
    }
     
    /// Combines  lhs variable x and rhs variable y into linear function 1 ∗ x  + -1 ∗ y + 0.
    static func - (lhs: Variable, rhs: Variable) -> LinearFunction {
        LinearFunction(terms: [lhs.term(), rhs.term(factor: -1)])
    }
     
    /// Combines  lhs variable x and rhs function Σ aᵢ ∗ xᵢ + c into 1 ∗ x + Σ -aᵢ ∗ xᵢ + -c.
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
 
 Constants are combined when needed, but otherwise the resulting function is not normalized: if a variable appears multiple times in the result, its occurences are not merged. Use ``LinearFunction/normalized()`` to merge terms and remove terms with factor 0.
 
 Function results are documented as sums of terms and a constant.
 */
public extension LinearFunction {
    
    // MARK: -
    
    /// Returns the function as is.
    static prefix func + (function: LinearFunction) -> LinearFunction {
        function
    }
     
    /// Converts function Σ aᵢ ∗ xᵢ + c into Σ -aᵢ ∗ xᵢ + -c.
    static prefix func - (function: LinearFunction) -> LinearFunction {
        LinearFunction(terms: function.terms.map(\.negated), constant: -function.constant)
    }
     
    /// Combines lhs function Σ aᵢ ∗ xᵢ + c and rhs constant d into Σ aᵢ ∗ xᵢ + (c + d).
    static func + (lhs: LinearFunction, rhs: Double) -> LinearFunction {
        LinearFunction(terms: lhs.terms, constant: lhs.constant + rhs)
    }
    
    /// Combines lhs function Σ aᵢ ∗ xᵢ + c and rhs variable x into Σ aᵢ ∗ xᵢ + 1 ∗ x + c.
    static func + (lhs: LinearFunction, rhs: Variable) -> LinearFunction {
        LinearFunction(terms: lhs.terms + [rhs.term()], constant: lhs.constant)
    }
    
    /// Combines lhs function Σ aᵢ ∗ xᵢ + c and rhs function Σ bᵢ ∗ yᵢ + d into Σ aᵢ ∗ xᵢ + Σ bᵢ ∗ yᵢ + (c + d).
    static func + (lhs: LinearFunction, rhs: LinearFunction) -> LinearFunction {
        LinearFunction(terms: lhs.terms + rhs.terms, constant: lhs.constant + rhs.constant)
    }
    
    /// Combines lhs function Σ aᵢ ∗ xᵢ + c and rhs constant d into Σ aᵢ ∗ xᵢ + (c - d).
    static func - (lhs: LinearFunction, rhs: Double) -> LinearFunction {
        LinearFunction(terms: lhs.terms, constant: lhs.constant - rhs)
    }
    
    /// Combines lhs function Σ aᵢ ∗ xᵢ + c and rhs variable x into Σ aᵢ ∗ xᵢ + -1 ∗ x + c.
    static func - (lhs: LinearFunction, rhs: Variable) -> LinearFunction {
        LinearFunction(terms: lhs.terms + [rhs.term(factor: -1)], constant: lhs.constant)
    }
    
    /// Combines lhs function Σ aᵢ ∗ xᵢ + c and rhs function Σ bᵢ ∗ yᵢ + d into Σ aᵢ ∗ xᵢ + Σ -bᵢ ∗ yᵢ + (c - d).
    static func - (lhs: LinearFunction, rhs: LinearFunction) -> LinearFunction {
        LinearFunction(terms: lhs.terms + rhs.terms.map(\.negated), constant: lhs.constant - rhs.constant)
    }
    
}

// MARK: -

/**
 Helper functions to compose linear functions.
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
 Converting a LinearFunction into a Python (PuLP) object.
 */
extension LinearFunction: PythonConvertible {

    // MARK: -
    
    /// Converts the linear function into a LpAffineExpression PythonObject.
    public var pythonObject: PythonObject {
        pythonObject(withCache: nil)
    }

    // MARK: -
    
    /// Converts the function into a LpAffineExpression PythonObject, optionally caching variables.
    ///
    /// - Parameter cache: If present, caches the first generated LpVariable PythonObject per Variable.
    /// - Returns: LpAffineExpression PythonObject.
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
