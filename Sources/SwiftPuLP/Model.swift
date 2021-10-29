//
//  Model.swift
//
//  Created by Michel Tilman on 22/10/2021.
//  Copyright © 2021 Dotted.Pair.
//  Licensed under Apache License v2.0.
//

import PythonKit

/*
 Represents an LP problem consisting of an objective and a list of contraints.
 A model has a non-empty name containing no spaces.
 */
public struct Model {
    
    // MARK: Testing
    
    // Answers false if the name is empty or contains spaces (cf. PuLP).
    private static func isValidName(_ name: String) -> Bool {
        !name.isEmpty && !name.contains(" ")
    }

    // MARK: Stored properties
    
    /// The name of the model. May not be empty and may not contain spaces.
    public let name: String
    
    /// The optional objective of the model.
    /// Default = nil.
    public let objective: Objective?
    
    /// The linear constraints.
    public let constraints: [(constraint: LinearConstraint, name: String)]
    
   // MARK: Initializing
    
    /**
     Creates a model with given name, optional objective and constraints.
     Fails if the name is empty or contains spaces.
     */
    public init?(_ name: String, objective: Objective? = nil, constraints: [(constraint: LinearConstraint, name: String)] = []) {
        guard Self.isValidName(name) else { return nil }

        self.name = name
        self.objective = objective
        self.constraints = constraints
    }
    
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
    public let function: LinearFunction
        
    /// The optimization to be performed.
    /// Default = minimize.
    public let optimization: Optimization
        
    // MARK: Initializing
    
    /// Creates an objective to optimize given linear expression.
    public init(_ function: LinearFunction, optimization: Optimization = .minimize) {
        self.function = function
        self.optimization = optimization
    }
    
    /// Creates an objective to optimize given linear variable.
    public init(_ variable: Variable, optimization: Optimization = .minimize) {
        self.function = LinearFunction(variable: variable)
        self.optimization = optimization
    }
    
}


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
        case .maximize:
            return PuLP.LpMaximize
        case .minimize:
            return PuLP.LpMinimize
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
            problem += objective.function.pythonObject
        }
        for (constraint, name) in constraints {
            problem += PythonObject(tupleOf: constraint, name)
        }
        
        return problem
    }
        
}
