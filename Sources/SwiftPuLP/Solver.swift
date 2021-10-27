//
//  Solver.swift
//  
//  Created by Michel Tilman on 27/10/2021.
//  Copyright © 2021 Dotted.Pair.
//  Licensed under Apache License v2.0.
//

import PythonKit

/**
 Result of the solver.
 Contains status of solver result, values for the variables and value of the objective function in case of a solution.
 */
 public struct SolverResult {
    
    /// Status of the solver result..
    public enum Status: Double {
        
        case notSolved = 0
        case optimal = 1
        case infeasible = -1
        case unbounded = -2
        case undefined = -3

    }
    
}


/**
 Result status adopts ConvertibleFromPython.
 */
extension SolverResult.Status: ConvertibleFromPython {

    /// Creates a status case from given python object.
    /// Fails if object is not a float or does not correspond to a raw case value.
    public init?(_ object: PythonObject) {
        guard let value = Double(object), let status = Self(rawValue: value) else { return nil }

        self = status
    }
    
}
