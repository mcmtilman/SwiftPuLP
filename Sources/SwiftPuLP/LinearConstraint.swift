//
//  LinearConstraint.swift
//  
//  Created by Michel Tilman on 28/10/2021.
//  Copyright © 2021 Dotted.Pair.
//  Licensed under Apache License v2.0.
//

import PythonKit

/**
 A linear constraint compares a linear function with a constant.
 
 Linear constraints have one of the following canonical forms.
 
        a * x + b * y + ... + c <= d
 
        a * x + b * y + ... + c == d
 
        a * x + b * y + ... + c >= d
 
 Like the function constant c, constant d represents a double value.
 
 Overloading the comparison operators allows us to construct linear constraints as in the following example.
 
        let (x, y) = (Variable("x"), Variable("y"))
        let constraint = 2 * x + 3 * y <= 10

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
        
        case lte, eq, gte
        
    }
    
    // MARK: -
    
    /// Linear function to be constrained.
    let function: LinearFunction
    
    /// Comparison.
    let comparison: Comparison
    
    /// Right-hand side of the comparison.
    let constant: Double
    
    // MARK: -
    
    /// Creates a linear constraint.
    ///
    /// A constraint has no name, but may be labeled when added to a model.
    ///
    /// - Parameters:
    ///   - function: Linear function to be compared with a constant.
    ///   - comparison: less than or equal | equal to | greater than or equal. Default = equal to.
    ///   - constant: Default = 0.
    public init(function: LinearFunction, comparison: Comparison = .eq, constant: Double = 0) {
        self.function = function
        self.comparison = comparison
        self.constant = constant
    }

    /// Creates a linear constraint.
    ///
    /// A constraint has no name, but may be labeled when added to a model.
    ///
    /// - Parameters:
    ///   - variable: Variable to be compared with a constant.
    ///   - comparison: less than or equal | equal to | greater than or equal. Default = equal to.
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
    
    /// Converts lhs variable x and rhs constant c into constraint 1 * x = c.
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
    
    /// Converts lhs function Σ ai * xi + c and rhs constant d into constraint Σ ai * xi + c <= d.
    static func <= (lhs: LinearFunction, rhs: Double) -> LinearConstraint {
        LinearConstraint(function: lhs, comparison: .lte, constant: rhs)
    }
    
    /// Converts lhs function Σ ai * xi + c and rhs constant d into constraint Σ ai * xi + c == d.
    static func == (lhs: LinearFunction, rhs: Double) -> LinearConstraint {
        LinearConstraint(function: lhs, comparison: .eq, constant: rhs)
    }
    
    /// Converts lhs function Σ ai * xi + c and rhs constant d into constraint Σ ai * xi + c >= d.
    static func >= (lhs: LinearFunction, rhs: Double) -> LinearConstraint {
        LinearConstraint(function: lhs, comparison: .gte, constant: rhs)
    }
    
}


// MARK: - PythonConvertible -

/**
 Constraint comparison adopts PythonConvertible.
 */
extension LinearConstraint.Comparison: PythonConvertible {

    // MARK: -
    
    /// Converts the comparison into a PuLP comparison.
    public var pythonObject: PythonObject {
        switch self {
        case .lte:
            return PuLP.LpConstraintLE
        case .eq:
            return PuLP.LpConstraintEQ
        case .gte:
            return PuLP.LpConstraintGE
        }
    }
    
}


// MARK: -

/**
 LinearConstraint adopts PythonConvertible.
 */
extension LinearConstraint: PythonConvertible {
    
    // MARK: -
    
    /// Converts the linear constraint into a PuLP constraint.
    public var pythonObject: PythonObject {
        pythonObject(withCache: nil)
    }
    
    // MARK: -
    
    /// Converts the constraint into a LpConstraint, optionally caching PuLP variables.
    ///
    /// - Parameter cache: Cache of generated Python LpVariable instances for each SwithPuLP variable.
    /// - Returns: Python LpConstraint.
    func pythonObject(withCache cache: VariableCache?) -> PythonObject {
        PuLP.LpConstraint(function.pythonObject(withCache: cache), sense: comparison, rhs: constant)
    }
        
}


// MARK: - Equatable -

/**
 LinearConstraint adopts Equatable with default behaviour.
 */
extension LinearConstraint.Comparison: Equatable {}

// MARK: -

extension LinearConstraint: Equatable {}
