//
//  SolverTests.swift
//  
//  Created by Michel Tilman on 27/10/2021.
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

    let PuLP = Python.import("pulp")
    
    // MARK: Status conversion from PuLP tests
    
    func testStatusFromPuLP() {
        let data: [(object: PythonObject, status: Solver.Status)] = [
            (PuLP.LpStatusNotSolved, .unsolved),
            (PuLP.LpStatusOptimal, .optimal),
            (PuLP.LpStatusInfeasible, .infeasible),
            (PuLP.LpStatusUnbounded, .unbounded),
            (PuLP.LpStatusUndefined, .undefined)
        ]

        for (object, status) in data {
            XCTAssertEqual(Solver.Status(object), status)
        }
    }
    
    func testInvalidStatusObjectFromPuLP() {
        let object: PythonObject = "A string"
        
        XCTAssertNil(Solver.Status(object))
    }
    
    func testUnknownStatusValueFromPuLP() {
        let value: PythonObject = 10
        
        XCTAssertNil(Solver.Status(value))
    }
    
    // MARK: Solver tests
    
    func testSolveOptimalModel() {
        guard let model = Model("Optimal", objective: Objective(LinearFunction(terms: []))) else { return XCTFail("Nil model") }
        guard let result = Solver().solve(model) else { return XCTFail("Nil result") }
        
        XCTAssertEqual(result.status, .optimal)
        XCTAssertEqual(result.variables.count, 0)
    }

    func testSolveUnboundedModel() {
        guard let x = Variable("x") else { return XCTFail("Nil variable") }
        guard let model = Model("Unbounded", objective: Objective(x)) else { return XCTFail("Nil model") }
        guard let result = Solver().solve(model) else { return XCTFail("Nil result") }
        
        XCTAssertEqual(result.status, .unbounded)
        XCTAssertEqual(result.variables.count, 1)
        XCTAssertEqual(result.variables[0].name, "x")
        XCTAssertEqual(result.variables[0].value, 0)
    }

}
