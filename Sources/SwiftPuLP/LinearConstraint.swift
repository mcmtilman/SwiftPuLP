////
//  LinearConstraint.swift
//  
//  Created by Michel Tilman on 28/10/2021.
//  Copyright © 2021 Dotted.Pair.
//  Licensed under Apache License v2.0.
//

import PythonKit

/**
 Linear constraints constrain a linear function by comparing the result to a constant, e.g.
    2 *x + 3 * y <= 20
 */
public struct LinearConstraint {
    
    /**
     A comparison is one of:
     - less than or equal to
     - equal to
     - greater than or equal to.
     */
    public enum Comparison {
        
        case lte, eq, gte
        
    }
    
    /// Linear function to be constrained.
    public let function: LinearFunction
    
    /// Comparison.
    /// Default = .eq.
    public let comparison: Comparison
    
    /// Right-hand side of the comparison.
    /// Default = 0.
    public let constant: Double
    
    // MARK: Initializing
    
    /**
     Initializes a constraint with given name, linear function, comparison and constant.
     Default comparison is equal to.
     Default constant = 0.
     */
    public init(function: LinearFunction, comparison: Comparison = .eq, constant: Double = 0) {
        self.function = function
        self.comparison = comparison
        self.constant = constant
    }

    /**
     Initializes a constraint with given name,variable, comparison and constant.
     Default comparison is equal to.
     Default constant = 0.
     */
    public init(variable: Variable, comparison: Comparison = .eq, constant: Double = 0) {
        self.function = LinearFunction(variable: variable)
        self.comparison = comparison
        self.constant = constant
    }

}


/**
 Constraint comparison adopts PythonConvertible.
 */
extension LinearConstraint.Comparison: PythonConvertible {

    // MARK: Computed properties
    
    /**
     Converts the comparison into a PuLP comparison.
     */
    public var pythonObject: PythonObject {
        switch self {
        case .lte: return PuLP.LpConstraintLE
        case .eq: return PuLP.LpConstraintEQ
        case .gte: return PuLP.LpConstraintGE
        }
    }
    
}


/**
 LinearConstraint adopts PythonConvertible.
 */
extension LinearConstraint: PythonConvertible {
    
    // MARK: Computed properties
    
    /**
     Converts the linear constraint into a PuLP constraint.
     */
    public var pythonObject: PythonObject {
        PuLP.LpConstraint(function.pythonObject, sense: comparison, rhs: constant)
    }
        
}


/**
 Covenience functions to compose linear constraints using basic comparison operators.
 */
public extension Variable {
    
    // MARK: Building linear constraints
    
    static func <= (lhs: Variable, rhs: Double) -> LinearConstraint {
        LinearConstraint(variable: lhs, comparison: .lte, constant: rhs)
    }
    
    static func == (lhs: Variable, rhs: Double) -> LinearConstraint {
        LinearConstraint(variable: lhs, comparison: .eq, constant: rhs)
    }
    
    static func >= (lhs: Variable, rhs: Double) -> LinearConstraint {
        LinearConstraint(variable: lhs, comparison: .gte, constant: rhs)
    }
    
}


/**
 Covenience functions to compose linear constraints using basic comparison operators.
 */
public extension LinearFunction {
    
    // MARK: Building linear constraints
    
    static func <= (lhs: LinearFunction, rhs: Double) -> LinearConstraint {
        LinearConstraint(function: lhs, comparison: .lte, constant: rhs)
    }
    
    static func == (lhs: LinearFunction, rhs: Double) -> LinearConstraint {
        LinearConstraint(function: lhs, comparison: .eq, constant: rhs)
    }
    
    static func >= (lhs: LinearFunction, rhs: Double) -> LinearConstraint {
        LinearConstraint(function: lhs, comparison: .gte, constant: rhs)
    }
    
}


/**
 LinearConstraint adopts Equatable with default behaviour.
 */
extension LinearConstraint.Comparison: Equatable {}
extension LinearConstraint: Equatable {}
