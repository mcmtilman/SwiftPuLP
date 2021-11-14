//
//  ModelTests.swift
//
//  Created by Michel Tilman on 22/10/2021.
//  Copyright © 2021 Dotted.Pair.
//  Licensed under Apache License v2.0.
//

import XCTest

#if DEBUG
    @testable import SwiftPuLP
#else
    import SwiftPuLP
#endif

/**
 Tests creating a model.
 */
final class ModelTests: XCTestCase {
    
#if DEBUG

    // MARK: Objective tests
    
    func testVariableObjective() {
        let x = Variable("x")
        let objective = Objective(x, optimization: .maximize)

        XCTAssertEqual(objective.function, x + 0)
        XCTAssertEqual(objective.optimization, .maximize)
    }
    
    func testFunctionObjective() {
        let x = Variable("x")
        let function = 2 * x + 1
        let objective = Objective(function, optimization: .maximize)

        XCTAssertEqual(objective.function, function)
        XCTAssertEqual(objective.optimization, .maximize)
    }
    
    func testDefaultObjective() {
        let x = Variable("x")
        let objective = Objective(x)

        XCTAssertEqual(objective.optimization, .minimize)
    }
    
    // MARK: Model tests

    func testDefaultModel() {
        let model = Model("XYZ")
        
        XCTAssertNil(model.objective)
    }

#endif

}


/**
 Utility types.
 */
fileprivate typealias Objective = Model.Objective
