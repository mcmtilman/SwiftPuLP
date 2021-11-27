//
//  Model.swift
//
//  Created by Michel Tilman on 22/10/2021.
//  Copyright © 2021 Dotted.Pair.
//  Licensed under Apache License v2.0.
//

import Collections

/**
 Represents a linear programming optimization problem consisting of an objective and a list of contraints.
 
 See also: <doc:UsingModels>.
 */
public struct Model {
    
    // MARK: -
    
    /// Specifies if the (optional) objective function must be maximized or minimized.
    public enum Optimization {
        
        case minimize, maximize
        
    }
    
    // MARK: -
    
    /// The name of the model. Should not contain spaces.
    let name: String
    
    /// The optional objective of the model.
    let objective: LinearFunction?
    
    /// The optimization to be performed.
   let optimization: Optimization

    /// Labeled linear constraints. The labels may be empty.
    let constraints: [(constraint: LinearConstraint, name: String)]
        
    // MARK: -
    
    /// Creates a model with given name, optional objective and constraints.
    ///
    /// - Parameters:
    ///   - name: Name of the model. May be empty but should not contains spaces.
    ///   - objective: Optional objective function (default = nil).
    ///   - optimization: Optimization goal (default = .minimize).
    ///   - constraints: Possibly empty list of labeled constraints. The labels may be empty.
    public init(_ name: String, objective: LinearFunction? = nil, optimization: Optimization = .minimize, constraints: [(constraint: LinearConstraint, name: String)] = []) {
        self.name = name
        self.objective = objective
        self.optimization = optimization
        self.constraints = constraints
    }
    
    /// Creates a model with given name, variable and constraints.
    ///
    /// - Parameters:
    ///   - name: Name of the model. May be empty but should not contains spaces.
    ///   - objective: Variable.
    ///   - optimization: Optimization goal (default = minimize).
    ///   - constraints: Possibly empty list of labeled constraints. The labels may be empty.
    public init(_ name: String, objective: Variable, optimization: Optimization = .minimize, constraints: [(constraint: LinearConstraint, name: String)] = []) {
        self.init(name, objective: LinearFunction(variable: objective), optimization: optimization, constraints: constraints)
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
        objective?.collectVariables(into: &variables)
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
