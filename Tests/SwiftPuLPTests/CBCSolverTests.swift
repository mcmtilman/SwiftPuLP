//
//  CBCSolverTests.swift
//  
//  Created by Michel Tilman on 27/11/2021.
//  Copyright © 2021 Dotted.Pair.
//  Licensed under Apache License v2.0.
//

import XCTest

#if DEBUG
    @testable import SwiftPuLP
#else
    import SwiftPuLP
#endif

final class CBCSolverTests: XCTestCase {
    
#if DEBUG

    // MARK: MPS writer tests
    
    func testWriteDefaultModel() {
        guard let url = Bundle.module.url(forResource: "Model", withExtension: "mps", subdirectory: "Resources") else { return XCTFail("Nil resource file") }
        
        let model = Model("Empty")
        guard MPSWriter().writeModel(model, toFile: url.path) else { return XCTFail("Error writing MPS file") }
        guard let contents = try? String(contentsOfFile: url.path, encoding: .utf8)  else { return XCTFail("Error reading MPS file") }
        let expected = """
            *SENSE:Minimize
            NAME          MODEL
            ROWS
            COLUMNS
            RHS
            BOUNDS
            ENDATA
            """

        XCTAssertEqual(contents, expected)
    }

    func testWriteModel() {
        guard let url = Bundle.module.url(forResource: "Model", withExtension: "mps", subdirectory: "Resources") else { return XCTFail("Nil resource file") }
        
        let (x, y) = (Variable("x", domain: .binary), Variable("y", domain: .integer, minimum: 0, maximum: 1))
        let objective = x + y + 2
        let constraints = [
            (x + 2 * y - 2 <= 8, ""),
            (2 * x + y >= 2, "")
        ]
        let model = Model("Empty", objective: objective, optimization: .maximize, constraints: constraints)
        guard MPSWriter().writeModel(model, toFile: url.path) else { return XCTFail("Error writing MPS file") }
        guard let contents = try? String(contentsOfFile: url.path, encoding: .utf8)  else { return XCTFail("Error reading MPS file") }
        let expected = """
            *SENSE:Maximize
            NAME          MODEL
            ROWS
             N  OBJ
             L  C0000000
             G  C0000001
            COLUMNS
                MARK      'MARKER'                 'INTORG'
                X0000000  C0000000   1.000000000000e+00
                X0000000  C0000001   2.000000000000e+00
                X0000000  OBJ        1.000000000000e+00
                MARK      'MARKER'                 'INTEND'
                MARK      'MARKER'                 'INTORG'
                X0000001  C0000000   2.000000000000e+00
                X0000001  C0000001   1.000000000000e+00
                X0000001  OBJ        1.000000000000e+00
                MARK      'MARKER'                 'INTEND'
            RHS
                RHS       C0000000   1.000000000000e+01
                RHS       C0000001   2.000000000000e+00
            BOUNDS
             BV BND       X0000000
             BV BND       X0000001
            ENDATA
            """

        XCTAssertEqual(contents, expected)
    }

    func testWriteVariablesModel() {
        guard let url = Bundle.module.url(forResource: "Model", withExtension: "mps", subdirectory: "Resources") else { return XCTFail("Nil resource file") }
        
        let variables = [
            Variable("x1", minimum: 2, maximum: 2),
            Variable("x2", domain: .binary),
            Variable("x3", domain: .integer, minimum: 0, maximum: 1),
            Variable("x4", minimum: -2),
            Variable("x5", domain: .integer, minimum: 0),
            Variable("x6", maximum: 10),
            Variable("x7"),
            ]
        let objective = Function.sum(variables)
        let model = Model("Variables", objective: objective)
        guard MPSWriter().writeModel(model, toFile: url.path) else { return XCTFail("Error writing MPS file") }
        guard let contents = try? String(contentsOfFile: url.path, encoding: .utf8)  else { return XCTFail("Error reading MPS file") }
        print(contents)
        let expected = """
            *SENSE:Minimize
            NAME          MODEL
            ROWS
             N  OBJ
            COLUMNS
                X0000000  OBJ        1.000000000000e+00
                MARK      'MARKER'                 'INTORG'
                X0000001  OBJ        1.000000000000e+00
                MARK      'MARKER'                 'INTEND'
                MARK      'MARKER'                 'INTORG'
                X0000002  OBJ        1.000000000000e+00
                MARK      'MARKER'                 'INTEND'
                X0000003  OBJ        1.000000000000e+00
                MARK      'MARKER'                 'INTORG'
                X0000004  OBJ        1.000000000000e+00
                MARK      'MARKER'                 'INTEND'
                X0000005  OBJ        1.000000000000e+00
                X0000006  OBJ        1.000000000000e+00
            RHS
            BOUNDS
             FX BND       X0000000  2.000000000000e+00
             BV BND       X0000001
             BV BND       X0000002
             LO BND       X0000003  -2.000000000000e+00
             LO BND       X0000004  0.000000000000e+00
             MI BND       X0000005
             UP BND       X0000005  1.000000000000e+01
             FR BND       X0000006
            ENDATA
            """

        XCTAssertEqual(contents, expected)
    }

    // MARK: Solution reader tests
    
    func testAbsentSolutionFile() {
        let model = Model("Empty")
        let result = SolutionReader().readResultFromFile(atPath: "Zork", model: model)
            
        XCTAssertNil(result)
    }

   func testReadEmptySolution() {
        guard let url = Bundle.module.url(forResource: "EmptySolution", withExtension: "sol", subdirectory: "Resources") else { return XCTFail("Nil resource file") }
        
        let model = Model("Empty")
        guard let result = SolutionReader().readResultFromFile(atPath: url.path, model: model) else { return XCTFail("Nil result") }
            
        XCTAssertEqual(result.status, .undefined)
        XCTAssertTrue(result.variables.isEmpty)
    }

    func testReadNormalSolution() {
        guard let url = Bundle.module.url(forResource: "BasicNormalSolution", withExtension: "sol", subdirectory: "Resources")  else { return XCTFail("Nil resource file") }
        
        let (x, y) = (Variable("x", domain: .integer, minimum: 0), Variable("y", minimum: 0))
        let objective = x + 2 * y
        let constraints = [
            (2 * x + y <= 20, ""),
            (4 * x - 5 * y >= -10, ""),
            (-x + 2 * y >= -2, ""),
            (-x + 5 * y == 15, "")
        ]
        let model = Model("Basic", objective: objective, optimization: .maximize, constraints: constraints)
        guard let result = SolutionReader().readResultFromFile(atPath: url.path, model: model) else { return XCTFail("Nil result") }

        XCTAssertEqual(result.status, .optimal)
        XCTAssertEqual(result.variables.count, 2)
        XCTAssertEqual(result.variables["x"], 7)
        XCTAssertEqual(result.variables["y"], 4.4)
    }
    
    func testReadAllSolution() {
        guard let url = Bundle.module.url(forResource: "BasicAllSolution", withExtension: "sol", subdirectory: "Resources")  else { return XCTFail("Nil resource file") }
        
        let (x, y) = (Variable("x", domain: .integer, minimum: 0), Variable("y", minimum: 0))
        let objective = x + 2 * y
        let constraints = [
            (2 * x + y <= 20, ""),
            (4 * x - 5 * y >= -10, ""),
            (-x + 2 * y >= -2, ""),
            (-x + 5 * y == 15, "")
        ]
        let model = Model("Basic", objective: objective, optimization: .maximize, constraints: constraints)
        guard let result = SolutionReader().readResultFromFile(atPath: url.path, model: model) else { return XCTFail("Nil result") }

        XCTAssertEqual(result.status, .optimal)
        XCTAssertEqual(result.variables.count, 2)
        XCTAssertEqual(result.variables["x"], 7)
        XCTAssertEqual(result.variables["y"], 4.4)
    }

    func testReadInfeasibleSolution() {
        guard let url = Bundle.module.url(forResource: "InfeasibleSolution", withExtension: "sol", subdirectory: "Resources")  else { return XCTFail("Nil resource file") }
        
        let (x, y) = (Variable("x", domain: .integer, minimum: 8), Variable("y"))
        let objective = x + 2 * y
        let constraints = [
            (2 * x + y <= 20, "red"),
            (4 * x - 5 * y >= -10, "blue"),
            (-x + 2 * y >= -2, "yellow"),
            (-x + 5 * y == 15, "green")
        ]
        let model = Model("Basic", objective: objective, optimization: .maximize, constraints: constraints)
        guard let result = SolutionReader().readResultFromFile(atPath: url.path, model: model) else { return XCTFail("Nil result") }

        XCTAssertEqual(result.status, .infeasible)
        XCTAssertEqual(result.variables.count, 2)
        XCTAssertEqual(result.variables["x"], 7.7272727)
        XCTAssertEqual(result.variables["y"], 4.5454545)
    }
    
#endif

    // MARK: CBBSolver tests

    func testSolveBasicModel() {
        guard let path = ProcessInfo.processInfo.environment["CBC_PATH"] else { return }

        let solver = CBCSolver(commandPath: path)
        let (x, y) = (Variable("x", domain: .integer, minimum: 0), Variable("y"))
        let objective = x + 2 * y
        let constraints = [
            (2 * x + y <= 20, "red"),
            (4 * x - 5 * y >= -10, "blue"),
            (-x + 2 * y >= -2, "yellow"),
            (-x + 5 * y == 15, "green")
        ]
        let model = Model("Basic", objective: objective, optimization: .maximize, constraints: constraints)
        guard let result = solver.solve(model) else { return XCTFail("Nil result") }
        
        XCTAssertEqual(result.status, .optimal)
        XCTAssertEqual(result.variables.count, 2)
        XCTAssertEqual(result.variables["x"], 7)
        XCTAssertEqual(result.variables["y"], 4.4)
        XCTAssertEqual(objective(result.variables), 15.8)
    }
    
    func testSolveInfeasibleModel() {
        guard let path = ProcessInfo.processInfo.environment["CBC_PATH"] else { return }

        let solver = CBCSolver(commandPath: path)
        let (x, y) = (Variable("x", domain: .integer, minimum: 8), Variable("y"))
        let objective = x + 2 * y
        let constraints = [
            (2 * x + y <= 20, "red"),
            (4 * x - 5 * y >= -10, "blue"),
            (-x + 2 * y >= -2, "yellow"),
            (-x + 5 * y == 15, "green")
        ]
        let model = Model("Basic", objective: objective, optimization: .maximize, constraints: constraints)
        guard let result = solver.solve(model) else { return XCTFail("Nil result") }
        
        XCTAssertEqual(result.status, .infeasible)
        XCTAssertEqual(result.variables.count, 2)
        XCTAssertEqual(result.variables["x"], 7.7272727)
        XCTAssertEqual(result.variables["y"], 4.5454545)
        XCTAssertEqual(objective(result.variables), 16.8181817)
    }
    
}
