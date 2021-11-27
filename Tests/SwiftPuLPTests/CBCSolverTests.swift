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

    func testBasicNormalSolution() {
        guard let url = Bundle.module.url(forResource: "BasicNormalSolution", withExtension: "sol", subdirectory: "Resources")  else { return XCTFail("Nil resource file") }
        
        let (x, y) = (Variable("x", minimum: 0, domain: .integer), Variable("y", minimum: 0))
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
        XCTAssertEqual(objective(result.variables), 15.8)
    }
    
    func testBasicAllSolution() {
        guard let url = Bundle.module.url(forResource: "BasicAllSolution", withExtension: "sol", subdirectory: "Resources")  else { return XCTFail("Nil resource file") }
        
        let (x, y) = (Variable("x", minimum: 0, domain: .integer), Variable("y", minimum: 0))
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
        XCTAssertEqual(objective(result.variables), 15.8)
    }
#endif

}
