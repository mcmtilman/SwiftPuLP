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

    /// Status of the solver result..
    public enum Status: Double {
        
        case unsolved = 0
        case optimal = 1
        case infeasible = -1
        case unbounded = -2
        case undefined = -3
    }
    
    /// Result of the solver.
    /// Contains status of solver result and values for the variables.
    public struct Result {
        
        // MARK: Stored properties
        
        /// Status of the result.
        public let status: Status
        
        /// Computed values for the decision variables.
        /// The keys are the variable names.
        public let variables:  [String: Double]
        
        // MARK: Initializing
        
        /// Initializes a result with given status and variable bindings.
        public init(status: Status, variables: [String: Double]) {
            self.status = status
            self.variables = variables
        }

    }
    
    // MARK: Initializing
    
    /// Default initializer made public.
    public init() {}
    
    // MARK: Solving
    
    /// Solves given model and returns a result with status and computed variables.
    /// Provide a variable registry in thread-local storage.
    public func solve(_ model: Model) -> Result? {
        guard Thread.current.threadDictionary[ThreadLocalKey] == nil else { return nil }

        Thread.current.threadDictionary[ThreadLocalKey] = VariableRegistry()
        defer { Thread.current.threadDictionary.removeObject(forKey: ThreadLocalKey) }
        
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

    // MARK: Initializing

    /// Creates a status case from given python object.
    /// Fails if object is not a float or does not correspond to a raw case value.
    public init?(_ object: PythonObject) {
        guard let value = Double(object), let status = Self(rawValue: value) else { return nil }

        self = status
    }
    
}


/**
 Result adopts ConvertibleFromPython.
 */
extension Solver.Result: ConvertibleFromPython {
    
    // MARK: Private Initializing

    // Extracts name and value of given LpVariables.
    // Fails if input not of the proper types.
    private static func asTuple(object: PythonObject) -> (name: String, value: Double)? {
        guard object.isInstance(of: PuLP.LpVariable),
                let name = String(object.name),
                let value = Double(object.value()) else { return nil }

        return (name, value)
    }
    
   // MARK: Initializing

    /// Creates a result from given python model.
    public init?(_ object: PythonObject) {
        guard let status = Solver.Status(object.status),
              let values = Array(object.variables())?.compactMap(Self.asTuple) else { return nil }

        self.status = status
        self.variables = Dictionary(uniqueKeysWithValues: values)
    }
    
}
