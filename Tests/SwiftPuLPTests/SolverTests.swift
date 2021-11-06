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
        let model = Model("Optimal", objective: Objective(LinearFunction()))
        guard let result = Solver().solve(model) else { return XCTFail("Nil result") }
        
        XCTAssertEqual(result.status, .optimal)
        XCTAssertEqual(result.variables.count, 0)
    }

    func testSolveUnboundedModel() {
        let x = Variable("x")
        let model = Model("Unbounded", objective: Objective(x))
        guard let result = Solver().solve(model) else { return XCTFail("Nil result") }
        
        XCTAssertEqual(result.status, .unbounded)
        XCTAssertEqual(result.variables.count, 1)
        XCTAssertEqual(result.variables["x"], 0)
    }

    func testSolveBasicModel() {
        let (x, y) = (Variable("x", domain: .integer), Variable("y"))
        let function = x + 2 * y
        let objective = Objective(function, optimization: .maximize)
        let constraints = [
            (2 * x + y <= 20, "red"),
            (4 * x - 5 * y >= -10, "blue"),
            (-x + 2 * y >= -2, "yellow"),
            (-x + 5 * y == 15, "green")
        ]
        let model = Model("Basic", objective: objective, constraints: constraints)
        guard let result = Solver().solve(model) else { return XCTFail("Nil result") }
        
        XCTAssertEqual(result.status, .optimal)
        XCTAssertEqual(result.variables.count, 2)
        XCTAssertEqual(result.variables["x"], 7)
        XCTAssertEqual(result.variables["y"], 4.4)
        XCTAssertEqual(function(result.variables), 15.8)
    }

    // Temporary.
    func testSolveResourceAllocationModel() {
        let x = (0 ... 4).map { i in Variable("x\(i)", minimum: 0) }
        let y = (0 ... 2).map { i in Variable("y\(i)", domain: .binary) }
        guard x.count == 5, y.count == 3 else { return XCTFail("Nil variable") }
        
        let function = (20 * x[1] + 12 * x[2]) + (40 * x[3] + 25 * x[4])
        let objective = Objective(function, optimization: .maximize)
        let constraints = [
            (Function.sum(x[1...]) <= 50, "manpower"),
            (3 * x[1] + 2 * x[2] + x[3] <= 100, "a"),
            (x[2] + 2 * x[3] + 3 * x[4] <= 90, "b"),
            (x[1] - 100 * y[1] <= 0, "x1"),
            (x[3] - 100 * y[2] <= 0, "x3"),
            (y[1] + y[2] <= 1, "y")
        ]
        let model = Model("Resource-allocation", objective: objective, constraints: constraints)
        guard let result = Solver().solve(model) else { return XCTFail("Nil result") }
        let variables = result.variables
        
        XCTAssertEqual(result.status, .optimal)
        XCTAssertEqual(variables.count, 6)
        XCTAssertEqual(variables, ["x1": 0, "x2": 0, "x3": 45, "x4": 0, "y1": 0, "y2": 1])
        XCTAssertEqual(variables["x4"], 0)
        XCTAssertEqual(variables["y1"], 0)
        XCTAssertEqual(variables["y2"], 1)
        XCTAssertEqual(function(result.variables), 1800)
    }

}


/**
 Utility types.
 */
fileprivate typealias Objective = Model.Objective
