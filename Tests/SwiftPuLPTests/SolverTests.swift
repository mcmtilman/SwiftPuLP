//
//  SolverTests.swift
//  
//  Created by Michel Tilman on 26/10/2021.
//  Copyright © 2021 Dotted.Pair.
//  Licensed under Apache License v2.0.
//

import XCTest
import PythonKit
import SwiftPuLP

/**
 Tests result of a solver process.
 */
final class SolverTests: XCTestCase {

    let pulp = Python.import("pulp")
    
    // MARK: Status tests
    
    func testStatusFromPuLP() {
        let data: [(object: PythonObject, status: SolverResult.Status)] = [
            (pulp.LpStatusNotSolved, .notSolved),
            (pulp.LpStatusOptimal, .optimal),
            (pulp.LpStatusInfeasible, .infeasible),
            (pulp.LpStatusUnbounded, .unbounded),
            (pulp.LpStatusUndefined, .undefined)
        ]

        for (object, status) in data {
            XCTAssertEqual(SolverResult.Status(object), status)
        }
    }
    
    func testInvalidStatusObjectFromPuLP() {
        let object: PythonObject = "A string"
        
        XCTAssertNil(SolverResult.Status(object))
    }
    
    func testUnknownStatusValueFromPuLP() {
        let value: PythonObject = 10
        
        XCTAssertNil(SolverResult.Status(value))
    }
    
}

