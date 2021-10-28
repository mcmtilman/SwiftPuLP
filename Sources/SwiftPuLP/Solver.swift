//
//  Solver.swift
//  
//  Created by Michel Tilman on 27/10/2021.
//  Copyright © 2021 Dotted.Pair.
//  Licensed under Apache License v2.0.
//

import PythonKit

/**
 Solver for a linear programming model.
*/
public struct Solver {

    /// Status of the solver result..
    public enum Status: Double {
        
        case unsolved = 0
        case optimal = 1
        case infeasible = -1
        case unbounded = -2
        case undefined = -3
    }
    
    /// Variable with computed value.
    public struct Variable  {
        
        // MARK: Stored properties
        
        public let name: String
        
        public let value: Double

    }
    
    /// Result of the solver.
    /// Contains status of solver result and values for the variables.
    public struct Result {
        
        // MARK: Stored properties
        
        /// Status of the result.
        public let status: Status
        
        /// Computed values for the decision variables.
        public let variables: [Variable]
        
        // MARK: Initializing
        
        /// Initializes a result with given status and variable bindings.
        public init(status: Status, variables: [Variable]) {
            self.status = status
            self.variables = variables
        }

    }
    
    // MARK: Initializing
    
    /// Default initializer made public.
    public init() {}
    
    // MARK: Solving
    
    /// Solves given model and returns a result with status and computed variables.
    public func solve(_ model: Model) -> Result? {
        let pythonModel = model.pythonObject
        let solver = PuLP.LpSolverDefault.copy()

        solver.msg = false
        solver.solve(pythonModel)
        
        return Result(pythonModel)
    }

}


/**
 Solver status adopts ConvertibleFromPython.
 */
extension Solver.Status: ConvertibleFromPython {

    /// Creates a status case from given python object.
    /// Fails if object is not a float or does not correspond to a raw case value.
    public init?(_ object: PythonObject) {
        guard let value = Double(object), let status = Self(rawValue: value) else { return nil }

        self = status
    }
    
}


/**
 Result variable adopts ConvertibleFromPython.
 */
extension Solver.Variable: ConvertibleFromPython {

    /// Creates a variable from given python object.
    /// Fails if object is not a PuLP LpVariable.
    public init?(_ object: PythonObject) {
        guard object.isInstance(of: PuLP.LpVariable),
                let name = String(object.name),
                let value = Double(object.value()) else { return nil }

        self.name = name
        self.value = value
    }
    
}


/**
 Result adopts ConvertibleFromPython.
 */
extension Solver.Result: ConvertibleFromPython {
    
    /// Creates a result from given python model.
    public init?(_ object: PythonObject) {
        guard let status = Solver.Status(object.status),
              let variables = Array(object.variables())?.compactMap(Solver.Variable.init) else { return nil }

        self.status = status
        self.variables = variables
    }
    
}
