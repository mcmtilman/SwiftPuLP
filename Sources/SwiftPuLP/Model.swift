//
//  Model.swift
//
//  Created by Michel Tilman on 22/10/2021.
//  Copyright © 2021 Dotted.Pair.
//  Licensed under Apache License v2.0.
//

import Collections

/**
 Represents a linear programming problem consisting of an objective and a list of contraints.
 
 See also: <doc:UsingModels>.
 */
public struct Model {
    
    // MARK: -
    
    /// Specifies if the (optional) objective function must be maximized or minimized.
    public enum Optimization {
        
        case minimize, maximize
        
    }
    
    // MARK: -

    /// Represents the objective of a linear programming problem: maximize or minimize a linear function.
    public struct Objective {
        
        // MARK: -
        
        /// The linear function to be optimized.
        let function: LinearFunction
            
        /// The optimization to be performed.
        let optimization: Optimization
            
        // MARK: -
        
        /// Creates an objective to optimize a linear function.
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
    
    /// Objective optimization of minimize if no objective.
    var optimization: Optimization {
        objective?.optimization ?? .minimize
    }
    
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


// MARK: - Equatable -

/**
 Model adopts Equatable.
 */
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


// MARK: -

/**
 Model.Objective adopts Equatable with default behaviour.
 */
extension Model.Objective: Equatable {}


// MARK: - Collecting variables -

/**
 Collecting variables
 */
extension Model {
    
    // MARK: -

   /// The variables ordered by first occurrence in the objective function followed by the constraints.
    public var variables: [Variable] {
        var variables = OrderedSet<Variable>()

        collectVariables(into: &variables)
        
        return Array(variables)
    }
    
   // MARK: -

    // Collects all unique variables from nested elements.
    fileprivate func collectVariables(into variables: inout OrderedSet<Variable>) {
        objective?.function.collectVariables(into: &variables)
        for (constraint, _) in constraints {
            constraint.collectVariables(into: &variables)
        }
    }
    
}


// MARK: -

/**
 Collecting variables
 */
extension LinearFunction {
    
    // MARK: -
    
    // Collects the different variables used in the function.
    fileprivate func collectVariables(into variables: inout OrderedSet<Variable>) {
        for term in terms {
            variables.append(term.variable)
        }
    }
    
}


// MARK: -

/**
 Collecting variables
 */
extension LinearConstraint {
    
    // MARK: -
    
    // Delegates collection of variables to the linear function.
    fileprivate func collectVariables(into variables: inout OrderedSet<Variable>) {
        function.collectVariables(into: &variables)
    }

}
