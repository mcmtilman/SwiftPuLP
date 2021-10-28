//
//  Model.swift
//
//  Created by Michel Tilman on 22/10/2021.
//  Copyright © 2021 Dotted.Pair.
//  Licensed under Apache License v2.0.
//

import PythonKit
import Foundation

// Answers true if the name is not empty and does not contain special characters (cf. PuLP).
fileprivate func isValidName(_ name: String, invalidCharacters: String) -> Bool {
    guard !name.isEmpty else { return false }
    let nameChars = CharacterSet(charactersIn: name)
    let specialChars = CharacterSet(charactersIn: invalidCharacters)
    
    return nameChars.isDisjoint(with: specialChars)
}


/*
 Represents an LP problem consisting of an objective and a list of contraints.
 A model has a non-empty name containing no spaces.
 */
public struct Model {
    
    // MARK: Stored properties
    
    /// The name of the model. May not be empty and may not contain spaces.
    public let name: String
    
    /// The optional objective of the model.
    /// Default = nil.
    public let objective: Objective?
    
    // MARK: Initializing
    
    /**
     Creates a model with given name and objective.
     Fails if the name is empty or contains special characters.
     */
    public init?(_ name: String, objective: Objective? = nil) {
        guard isValidName(name, invalidCharacters: " ") else { return nil }

        self.name = name
        self.objective = objective
    }
    
}


/**
 Represents an objective function.
 */
public protocol ObjectiveFunction {
    
    /// An objective function can be converted into a PuLP LpAffineExpression.
    var pythonLinearFunction: PythonObject { get }
    
}


/**
 Represent the objective of a linear programming problem: maximize or minimize a linear expression.
 */
public struct Objective {
    
    /**
     Specifies if the objective function must be maximized or minimized.
     */
    public enum Optimization {
        
        case minimize, maximize
        
    }
    
    // MARK: Stored properties
    
    /// The linear function to be optimized.
    public let function: ObjectiveFunction
        
    /// The optimization to be performed.
    /// Default = minimize.
    public let optimization: Optimization
        
    // MARK: Initializing
    
    /// Creates an objective to optimize given linear expression.
    public init(_ function: ObjectiveFunction, optimization: Optimization = .minimize) {
        self.function = function
        self.optimization = optimization
    }
    
}


/**
 A variable has a name and a domain.
 The domain may be further restricted to optional lower and upper bounds.
 */
public struct Variable {
    
    /**
     A domain identifies the range of values of a variable:
     - binary (values 0 and 1).
     - real (real numbers)
     - integer (integer values)
     */
    public enum Domain {

        case binary, real, integer

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
        guard isValidName(name, invalidCharacters: "-+[] ->/") else { return nil }
        if let min = minimum, let max = maximum, min > max { return nil }
        if domain == .binary, minimum != nil && minimum != 0 || maximum != nil && maximum != 1 { return nil }
        
        self.name = name
        self.minimum = domain == .binary && minimum == nil ? 0 : minimum
        self.maximum = domain == .binary && maximum == nil ? 1 : maximum
        self.domain = domain
    }
    
}


/**
 Variable domain adopts PythonConvertible.
 */
extension Variable.Domain: PythonConvertible {

    // MARK: Computed properties
    
    /**
     Converts the domain into a PuLP category.
     */
    public var pythonObject: PythonObject {
        switch self {
        case .binary: return PuLP.LpBinary
        case .real: return PuLP.LpContinuous
        case .integer: return PuLP.LpInteger
        }
    }
    
}


/**
 Variable adopts PythonConvertible.
 */
extension Variable: PythonConvertible {
    
    // MARK: Computed properties
    
    /**
     Converts the variable into a PuLP variable.
     */
    public var pythonObject: PythonObject {
        PuLP.LpVariable(name: name, lowBound: minimum, upBound: maximum, cat: domain.pythonObject)
    }

}


/**
 Variable adopts ObjectiveFunction.
 */
extension Variable: ObjectiveFunction {
    
    // MARK: Computed properties

    /// Answers the variable as a PuLP LpAffineExpression.
    public var pythonLinearFunction: PythonObject {
        PuLP.LpAffineExpression([PythonObject(tupleOf: self, 1.0)])
    }
    
}


/**
 Variable adopts Equatable extensions with default behaviour.
 */
extension Variable: Equatable {}


/**
 Objective optimization adopts PythonConvertible.
 */
extension Objective.Optimization: PythonConvertible {

    // MARK: Computed properties
    
    /**
     Converts the optimization into a PuLP sense.
     */
    public var pythonObject: PythonObject {
        switch self {
        case .maximize: return PuLP.LpMaximize
        case .minimize: return PuLP.LpMinimize
        }
    }

}


/**
 Model adopts PythonConvertible.
 */
extension Model: PythonConvertible {
    
    // MARK: Computed properties
    
    /**
     Converts the model into a PuLP problem.
     */
    public var pythonObject: PythonObject {
        var problem = PuLP.LpProblem(name: name, sense: objective?.optimization ?? .minimize) // set sense, even without an objective.
        if let objective = objective {
            problem += objective.function.pythonLinearFunction
        }
        
        return problem
    }
        
}
