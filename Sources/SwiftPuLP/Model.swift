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
 */
public struct Model {
    
    // MARK: -
    
    /// Specifies if the objective function must be maximized or minimized.
    public enum Optimization {
        
        case minimize, maximize
        
    }
    
    // MARK: -

    /// Represent the objective of a linear programming problem: maximize or minimize a linear expression.
    public struct Objective {
        
        // MARK: -
        
        /// The linear function to be optimized.
        let function: LinearFunction
            
        /// The optimization to be performed.
        /// Default = minimize.
        let optimization: Optimization
            
        // MARK: -
        
        /// Creates an objective to optimize given linear function.
        ///
        /// - Parameters:
        ///   - function: Linear function to be optimized.
        ///   - optimization: Type of optimization: .minimize or .maximize (default = .minimize).
        public init(_ function: LinearFunction, optimization: Optimization = .minimize) {
            self.function = function
            self.optimization = optimization
        }
        
        /// Creates an objective to optimize given linear variable.
        ///
        /// - Parameters:
        ///   - variable: Variable to be optimized.
        ///   - optimization: Type of optimization: .minimize or .maximize (default = .minimize).
        public init(_ variable: Variable, optimization: Optimization = .minimize) {
            self.function = LinearFunction(variable: variable)
            self.optimization = optimization
        }
        
    }

    // MARK: -
    
    /// The name of the model. Should not contain spaces.
    let name: String
    
    /// The optional objective of the model.
    let objective: Objective?
    
    /// Labeled linear constraints. The labels may be empty.
    let constraints: [(constraint: LinearConstraint, name: String)]
    
    // MARK: -
    
    /// Creates a model with given name, optional objective and constraints.
    ///
    /// - Parameters:
    ///   - name: Name of the model. May be empty but should not contains spaces.
    ///   - objective: Optional objective (default = nil).
    ///   - constraints: Possibly empty list of labeled constraints. The labels may be empty.
    public init(_ name: String, objective: Objective? = nil, constraints: [(constraint: LinearConstraint, name: String)] = []) {
        self.name = name
        self.objective = objective
        self.constraints = constraints
    }
    
}


// MARK: - PythonConvertible -

/**
 Objective optimization adopts PythonConvertible.
 */
extension Model.Optimization: PythonConvertible {

    // MARK: -
    
    /// Converts the optimization into a PuLP 'sense'.
    public var pythonObject: PythonObject {
        switch self {
        case .maximize:
            return PuLP.LpMaximize
        case .minimize:
            return PuLP.LpMinimize
        }
    }

}


// MARK: -

/**
 Model adopts PythonConvertible.
 */
extension Model: PythonConvertible {
    
    // MARK: -
    
    /// Converts the model into a PuLP problem.
    ///
    /// Caches and reuses the generated PuLP variable for each SwiftPuLP variable.
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


// MARK: - Equatable -

/**
 Model adopts Equatable.
 */
extension Model.Objective: Equatable {}

// MARK: -

extension Model: Equatable {
    
    /// Answers if the lhs and rhs models are equal.
    ///
    /// - Returns: True if name, objective and (ordered) list of constraints are equal, false otherwise.
    public static func == (lhs: Model, rhs: Model) -> Bool {
        lhs.name == rhs.name
            && lhs.objective == rhs.objective
            && lhs.constraints.elementsEqual(lhs.constraints, by: ==)
    }
    
}
