//
//  Solver.swift
//  
//  Created by Michel Tilman on 27/10/2021.
//  Copyright © 2021 Dotted.Pair.
//  Licensed under Apache License v2.0.
//

import Foundation
import PythonKit

/**
 Solver for a linear programming model.
*/
public struct Solver {

    // MARK: -
    
    /// Status of the solver result.
    public enum Status: Double {
        
        case unsolved = 0
        case optimal = 1
        case infeasible = -1
        case unbounded = -2
        case undefined = -3

    }
    
    // MARK: -
    
    /// Result of the solver.
    /// Contains status of solver result and values for the variables.
    public struct Result {
        
        // MARK: -
        
        /// Status of the result.
        public let status: Status
        
        /// Computed values for the decision variables, keyed by the variable names.
        public let variables:  [String: Double]
        
        // MARK: -
        
        /// Initializes a result with given status and variable bindings.
        ///
        /// - Parameters:
        ///   - status: Status of the solver result.
        ///   - variables: Dictionary mapping variable names to the computed values.
        public init(status: Status, variables: [String: Double]) {
            self.status = status
            self.variables = variables
        }

    }
    
    // MARK: -
    
    /// Default initializer made public.
    public init() {}
    
    // MARK: -
    
    /// Solves given model and returns a result with status and computed variables.
    ///
    /// Converts the model into a PuLP LpProblem, solves the problem using PuLP's default solver, and returns relevant information extracted from the solver.
    ///
    /// - Parameters:
    ///   - model: Model being solved.
    ///   - logging: If true log the PuLP solver's messages.
    /// - Returns: Optional ``Result``. Nil if the PuLP solver's state cannot be retrieved.
    public func solve(_ model: Model, logging: Bool = false) -> Result? {
        let pythonModel = model.pythonObject
        let solver = PuLP.LpSolverDefault.copy()
        
        solver.msg = logging.pythonObject
        solver.solve(pythonModel)
        
        return Result(pythonModel)
    }

}


// MARK: - ConvertibleFromPython -

/**
 Creates a Result status from a Python float.
 */
extension Solver.Status: ConvertibleFromPython {

    // MARK: -

    /// Creates a status from given Python object.
    /// 
    /// Fails if the object is not a Python float or does not correspond to a known case value.
    ///
    /// - Parameter object: Python object representing a PuLP status value.
    public init?(_ object: PythonObject) {
        guard let value = Double(object), let status = Self(rawValue: value) else { return nil }

        self = status
    }
    
}


// MARK: -

/**
 Creates a Result from a Python LpProblem.
 */
extension Solver.Result: ConvertibleFromPython {
    
    // MARK: -

    // Returns a name - value tuple for the Python object representing a PuLP variable.
    // Returns nil if the input is not a LpVariable, or if name or value cannot be extracted.
    private static func asTuple(object: PythonObject) -> (name: String, value: Double)? {
        guard object.isInstance(of: PuLP.LpVariable),
                let name = String(object.name),
                let value = Double(object.value()) else { return nil }

        return (name, value)
    }
    
    // MARK: -

    /// Creates a result from the PuLP LpProblem.
    ///
    /// Fails if the Python object is not a LpProblem, the problem status is unknown, or the problem variables cannot be converted into a dictionary of name - value pairs.
    ///
    /// - Parameter object: Python object representing a PuLP problem.
    public init?(_ object: PythonObject) {
        guard object.isInstance(of: PuLP.LpProblem),
              let status = Solver.Status(object.status),
              let values = Array(object.variables())?.compactMap(Self.asTuple) else { return nil }

        self.status = status
        self.variables = Dictionary(uniqueKeysWithValues: values)
    }
    
}
