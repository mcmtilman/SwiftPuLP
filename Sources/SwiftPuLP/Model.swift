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
 A model should have a non-empty name containing no spaces.
 */
public struct Model {
    
    /// Specifies if the objective function must be maximized or minimized.
    public enum Optimization {
        
        case minimize, maximize
        
    }
    
    /// Represent the objective of a linear programming problem: maximize or minimize a linear expression.
    public struct Objective {
        
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
     */
    public init(_ name: String, objective: Objective? = nil, constraints: [(constraint: LinearConstraint, name: String)] = []) {
        self.name = name
        self.objective = objective
        self.constraints = constraints
    }
    
}

/**
 Objective optimization adopts PythonConvertible.
 */
extension Model.Optimization: PythonConvertible {

    // MARK: Computed properties
    
    /// Converts the optimization into a PuLP sense.
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
    
    /// Converts the model into a PuLP problem, caching generated PuLP variables per Variable.
    public var pythonObject: PythonObject {
        var problem = PuLP.LpProblem(name: name, sense: objective?.optimization ?? .minimize) // set sense, even without an objective.
        let cache = VariableCache()
        
        if let objective = objective {
            problem += objective.function.pythonObject(withCache: cache)
        }
        for (constraint, name) in constraints {
            problem += PythonObject(tupleOf: constraint.pythonObject(withCache: cache), name)
        }
        
        return problem
    }
        
}


/**
 Model adopts Equatable.
 */
extension Model.Objective: Equatable {}
extension Model: Equatable {
    
    public static func == (lhs: Model, rhs: Model) -> Bool {
        lhs.name == rhs.name
            && lhs.objective == rhs.objective
            && lhs.constraints.elementsEqual(lhs.constraints, by: ==)
    }
    
}
