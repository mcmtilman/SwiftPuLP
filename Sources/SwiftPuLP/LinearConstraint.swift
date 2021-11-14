//
//  LinearConstraint.swift
//  
//  Created by Michel Tilman on 28/10/2021.
//  Copyright © 2021 Dotted.Pair.
//  Licensed under Apache License v2.0.
//

/**
 A linear constraint compares a linear function with a constant.
 
 For instance, given variables x and y, the following expressions represent linear constraints.

 ```swift
 a * x + b * y + c <= d

 a * x + b * y == d

 a * x + b * y - d >= 0
 ```

 Like the function constant *c*, constraint constant *d* is a Double value.
 
 Comparison operators allows us to construct linear constraints as in the following example.
 
 ```swift
let (x, y) = (Variable("x"), Variable("y"))
let constraint = 2 * x + 3 * y <= 10
```
 
 See also: <doc:UsingLinearConstraints>.
 */
public struct LinearConstraint {
    
    // MARK: -
    
    /**
     The comparison operator used in the definition of a ``LinearConstraint``.
    
     A comparison can be one of:
     - less than or equal to (<=)
     - equal to (==)
     - greater than or equal to (>=).
     */
    public enum Comparison {
        
        /// Less than or equal to.
        case lte
        
        /// Equal to.
        case eq
        
        /// Greater than or equal to.
        case gte
        
    }
    
    // MARK: -
    
    /// Linear function to be constrained.
    let function: LinearFunction
    
    /// Comparison.
    let comparison: Comparison
    
    /// Right-hand side of the comparison.
    let constant: Double
    
    // MARK: -
    
    /// Creates a linear constraint by comparing a linear function with a constant.
    ///
    /// > Note: A constraint has no name, but may be labeled when added to a model.
    ///
    /// - Parameters:
    ///   - function: Linear function to be compared.
    ///   - comparison: less than or equal | equal to | greater than or equal (default = .eq).
    ///   - constant: Default = 0.
    public init(function: LinearFunction, comparison: Comparison = .eq, constant: Double = 0) {
        self.function = function
        self.comparison = comparison
        self.constant = constant
    }

    /// Creates a linear constraint by comparing a a variable with a constant.
    ///
    /// > Note: A constraint has no name, but may be labeled when added to a model.
    ///
    /// - Parameters:
    ///   - variable: Variable to be compared.
    ///   - comparison: less than or equal | equal to | greater than or equal (default = equal to).
    ///   - constant: Default = 0.
    public init(variable: Variable, comparison: Comparison = .eq, constant: Double = 0) {
        self.init(function: LinearFunction(variable: variable), comparison: comparison, constant: constant)
    }

    // MARK: -
    
    /// Answers the result of applying the function to given parameters and comparing the result with the constant.
    ///
    /// - Parameter parameters: Parameter values keyed by variable names. If a variable name is not found in the dictionary, a value of 0 is assumed.
    /// - Returns: Result of comparison.
    public func callAsFunction(_ parameters: [String: Double]) -> Bool {
        switch comparison {
        case .lte:
            return function(parameters) <= constant
        case .eq:
            return function(parameters) == constant
        case .gte:
            return function(parameters) >= constant
        }
    }

}

// MARK: - Comparison operators -

/**
 Covenience functions to compose linear constraints using basic comparison operators on variables.
 */
public extension Variable {
    
    // MARK: -
    
    /// Converts lhs variable x and rhs constant c into constraint 1 * x <= c.
    static func <= (lhs: Variable, rhs: Double) -> LinearConstraint {
        LinearConstraint(variable: lhs, comparison: .lte, constant: rhs)
    }
    
    /// Converts lhs variable x and rhs constant c into constraint 1 * x == c.
    static func == (lhs: Variable, rhs: Double) -> LinearConstraint {
        LinearConstraint(variable: lhs, comparison: .eq, constant: rhs)
    }
    
    /// Converts lhs variable x and rhs constant c into constraint 1 * x >= c.
    static func >= (lhs: Variable, rhs: Double) -> LinearConstraint {
        LinearConstraint(variable: lhs, comparison: .gte, constant: rhs)
    }
    
}


// MARK: -

/**
 Covenience functions to compose linear constraints using basic comparison operators on linear functions.
 */
public extension LinearFunction {
    
    // MARK: -
    
    /// Converts lhs function Σ aᵢ ∗ xᵢ + c and rhs constant d into constraint Σ aᵢ ∗ xᵢ + c <= d.
    static func <= (lhs: LinearFunction, rhs: Double) -> LinearConstraint {
        LinearConstraint(function: lhs, comparison: .lte, constant: rhs)
    }
    
    /// Converts lhs function Σ aᵢ ∗ xᵢ + c and rhs constant d into constraint Σ aᵢ ∗ xᵢ + c == d.
    static func == (lhs: LinearFunction, rhs: Double) -> LinearConstraint {
        LinearConstraint(function: lhs, comparison: .eq, constant: rhs)
    }
    
    /// Converts lhs function Σ aᵢ ∗ xᵢ + c and rhs constant d into constraint Σ aᵢ ∗ xᵢ + c >= d.
    static func >= (lhs: LinearFunction, rhs: Double) -> LinearConstraint {
        LinearConstraint(function: lhs, comparison: .gte, constant: rhs)
    }
    
}


// MARK: - Equatable -

/**
 LinearConstraint adopts Equatable with default behaviour.
 */
extension LinearConstraint: Equatable {}


// MARK: -

/**
 LinearConstraint.Comparison adopts Equatable with default behaviour.
 */
extension LinearConstraint.Comparison: Equatable {}
