//
//  Model.swift
//
//  Created by Michel Tilman on 22/10/2021.
//  Copyright © 2021 Dotted.Pair.
//  Licensed under Apache License v2.0.
//

import PythonKit

// The Python PuLP module loaded lazily.
fileprivate let pulpModule = Python.import("pulp")


/*
 Represents an expression to be used in objective functions and constraints.
 */
public protocol Expression: PythonConvertible {}


/*
 Represents an objective function.
 */
public protocol LinearExpression: Expression {}


/*
 Represents an LP problem consisting of an objective and a list of contraints.
 A model has a non-empty name containing no spaces.
 */
public struct Model: PythonConvertible {
    
    // MARK: Stored properties
    
    /// The name of the model. May not be empty and may not contain spaces.
    public let name: String
    
    /// The objective of the model.
    public let objective: Objective
    
    // MARK: Computed properties
    
    /**
     Converts the model into a PuLP problem.
     */
    public var pythonObject: PythonObject {
        let problem = pulpModule.LpProblem(name: name, sense: objective.optimization)

        problem.setObjective(objective.expression)
        
        return problem
    }
        
    // MARK: Initializing
    
    /**
     Creates a model with given name and objective.
     Fails if the name is empty or contains spaces.
     */
    public init?(_ name: String, objective: Objective) {
        guard !name.isEmpty, !name.contains(" ") else { return nil }

        self.name = name
        self.objective = objective
    }

}


/**
 Represent the objective of a linear programming problem: maximize or minimize a linear expression.
 */
public struct Objective {
    
    /**
     Specifies if the objective function must be maximized or minimized.
     */
    public enum Optimization: PythonConvertible {
        
        case minimize
        case maximize
        
        // MARK: Computed properties
        
        /**
         Converts the optimization into a PuLP sense.
         */
        public var pythonObject: PythonObject {
            switch self {
            case .maximize: return pulpModule.LpMaximize
            case .minimize: return pulpModule.LpMinimize
            }
        }
        
    }
    
    // MARK: Stored properties
    
    /// The linear expression to be optimized.
    public let expression: LinearExpression
        
    /// The optimization to be performed.
    /// Default = maximize.
    public let optimization: Optimization
        
    // MARK: Initializing
    
    /// Creates an objective to optimize given linear expression.
    public init(_ expression: LinearExpression, optimization: Optimization = .maximize) {
        self.expression = expression
        self.optimization = optimization
    }
    
}


/**
 A variable has a name and a domain.
 The domain may be further restricted to optional lower and upper bounds.
 */
public struct Variable: LinearExpression {
    
    /**
     A domain identifies the range of values of a variable:
     - binary (values 0 and 1).
     - real (real numbers)
     - integer (integer values)
     */
    public enum Domain: PythonConvertible {

        case binary
        case real
        case integer

        // MARK: Computed properties
        
        /**
         Converts the domain into a PuLP category.
         */
        public var pythonObject: PythonObject {
            switch self {
            case .binary: return pulpModule.LpBinary
            case .real: return pulpModule.LpContinuous
            case .integer: return pulpModule.LpInteger
            }
        }
        
    }

    // MARK: Stored properties
    
    /// The name of the variable. May not be empty and may not contain spaces.
    public let name: String
    
    /// Optional lower bound for the values (inclusive).
    /// If present must not exceed a non-nil maximum.
    /// If present must be 0 for binary variables.
    public let minimum: Double?
    
    /// Optional upper bound for the values (inclusive).
    /// If present must be 1 for binary variables.
    public let maximum: Double?
    
    /// Domain  of values for this variable.
    /// Default = real.
    public let domain: Domain
    
    // MARK: Computed properties
    
    /**
     Converts the variable into a PuLP variable.
     */
    public var pythonObject: PythonObject {
        pulpModule.LpVariable(name: name, lowBound: minimum, upBound: maximum, cat: domain.pythonObject)
    }

    // MARK: Initializing
    
    /**
     Creates a variable with given name and domain.
     The variable may optionally specify a lower and / or upper bound for its values.
     Variables come in three flavours:
     - real domain (supports double values satisfying the optional lower and upper bounds)
     - integer domain (supports integer values satisfying the optional lower and upper bounds)
     - binary domain (a value is either 0 or 1).
     Creation fails if:
     - the name is empty or contains spaces;
     - a non-nil minimum value is greater than a non-nil maximum value;
     - the variable is binary with minimum != 0 and nil, or maximum != 1 and nil.
     */
    public init?(_ name: String, minimum: Double? = nil, maximum: Double? = nil, domain: Domain = .real) {
        guard !name.isEmpty, !name.contains(" ") else { return nil }
        if let min = minimum, let max = maximum, min > max { return nil }
        if domain == .binary, minimum != nil && minimum != 0 || maximum != nil && maximum != 1 { return nil }
        
        self.name = name
        self.minimum = domain == .binary && minimum == nil ? 0 : minimum
        self.maximum = domain == .binary && maximum == nil ? 1 : maximum
        self.domain = domain
    }
    
}
