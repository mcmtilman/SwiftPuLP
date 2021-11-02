////
//  ValidationTests.swift
//  
//  Created by Michel Tilman on 31/10/2021.
//  Copyright © 2021 Dotted.Pair.
//  Licensed under Apache License v2.0.
//

import XCTest
import SwiftPuLP

/**
 Tests validating model elements.
 */
final class ValidationTests: XCTestCase {

    // MARK: Validating valid variables
    
    func testValidVariable() {
        let variable = Variable("x", minimum: 1, maximum: 10, domain: .integer)
        
        XCTAssertTrue(variable.validationErrors.isEmpty)
    }

    func testDefaultVariable() {
        let variable = Variable("x")
        
        XCTAssertTrue(variable.validationErrors.isEmpty)
    }
    
    func testFixedVariable() {
        let variable = Variable("x", minimum: 1, maximum: 1, domain: .integer)
        
        XCTAssertTrue(variable.validationErrors.isEmpty)
    }

    func testBinaryVariable() {
        let variable = Variable("x", minimum: 0, maximum: 1, domain: .binary)

        XCTAssertTrue(variable.validationErrors.isEmpty)
    }
    
    // MARK: Validating invalid variables
    
    func testEmptyNameVariable() {
        let variable = Variable("")
        let errors = variable.validationErrors
        
        XCTAssertEqual(errors.count, 1)
        XCTAssertEqual(errors[0], .emptyVariableName(variable))
    }

    func testInvalidNameVariable() {
        for name in ("-+[] ->/".map { "x\($0)y" }) {
            let variable = Variable(name)
            let errors = variable.validationErrors
            
            XCTAssertEqual(errors.count, 1)
            XCTAssertEqual(errors[0], .invalidVariableName(variable))
        }
    }

    func testInvalidRangeVariable() {
        let variable = Variable("x", minimum: 3, maximum: 2, domain: .integer)
        let errors = variable.validationErrors
        
        XCTAssertEqual(errors.count, 1)
        XCTAssertEqual(errors[0], .invalidVariableBounds(variable))
    }

    func testInvalidMinimumBinaryVariable() {
        let variable = Variable("x", minimum: -1, domain: .binary)
        let errors = variable.validationErrors
        
        XCTAssertEqual(errors.count, 1)
        XCTAssertEqual(errors[0], .invalidVariableBounds(variable))
    }

    func testInvalidMaximumBinaryVariable() {
        let variable = Variable("x", maximum: 2, domain: .binary)
        let errors = variable.validationErrors
        
        XCTAssertEqual(errors.count, 1)
        XCTAssertEqual(errors[0], .invalidVariableBounds(variable))
    }

    func testMultipleVariableErrors() {
        let variable = Variable("", minimum: 3, maximum: 2, domain: .binary)
        let errors = variable.validationErrors
        
        XCTAssertEqual(errors.count, 2)
        XCTAssertEqual(errors[0], .emptyVariableName(variable))
        XCTAssertEqual(errors[1], .invalidVariableBounds(variable))
    }

    // MARK: Validating valid models
    
    func testValidModel() {
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

        XCTAssertTrue(model.validationErrors.isEmpty)
    }

    func testEmptyConstraintsModel() {
        let (x, y) = (Variable("x", domain: .integer), Variable("y"))
        let function = x + 2 * y
        let objective = Objective(function, optimization: .maximize)
        let model = Model("Basic", objective: objective)

        XCTAssertTrue(model.validationErrors.isEmpty)
    }

    func testEmptyNameModel() {
        let x = Variable("x")
        let model = Model("", objective: Objective(x))

        XCTAssertTrue(model.validationErrors.isEmpty)
    }

    func testDuplicateVariablesModel() {
        let x = Variable("x")
        let y = x
        let function = x + 2 * y
        let objective = Objective(function, optimization: .maximize)
        let constraints = [
            (2 * x + y <= 20, "red"),
            (4 * x - 5 * y >= -10, "blue"),
            (-x + 2 * y >= -2, "yellow"),
            (-x + 5 * y == 15, "green")
        ]
        let model = Model("Basic", objective: objective, constraints: constraints)

        XCTAssertTrue(model.validationErrors.isEmpty)
    }
    
    func testEmptyConstraintNameModel() {
        let (x, y) = (Variable("x", domain: .integer), Variable("y"))
        let function = x + 2 * y
        let objective = Objective(function, optimization: .maximize)
        let constraints = [
            (2 * x + y <= 20, ""),
            (4 * x - 5 * y >= -10, "blue"),
            (-x + 2 * y >= -2, "yellow"),
            (-x + 5 * y == 15, "green")
        ]
        let model = Model("Basic", objective: objective, constraints: constraints)

        XCTAssertTrue(model.validationErrors.isEmpty)
    }
    
    // MARK: Validating invalid models
    
    func testInvalidNameModel() {
        let x = Variable("x")
        let model = Model("X Y", objective: Objective(x))
        let errors = model.validationErrors
        
        XCTAssertEqual(errors.count, 1)
        XCTAssertEqual(errors[0], .invalidModelName(model))
    }

    func testDuplicateVariableNamesModel() {
        let (x, y) = (Variable("x"), Variable("x"))
        let function = x + 2 * y
        let objective = Objective(function, optimization: .maximize)
        let constraints = [
            (2 * x + y <= 20, "red"),
            (4 * x - 5 * y >= -10, "blue"),
            (-x + 2 * y >= -2, "yellow"),
            (-x + 5 * y == 15, "green")
        ]
        let model = Model("Basic", objective: objective, constraints: constraints)
        let errors = model.validationErrors
        
        XCTAssertEqual(errors.count, 1)
        XCTAssertEqual(errors[0], .duplicateVariableName(y))
    }
    
    func testDuplicateConstraintNamesModel() {
        let (x, y) = (Variable("x"), Variable("y"))
        let function = x + 2 * y
        let objective = Objective(function, optimization: .maximize)
        let constraints = [
            (2 * x + y <= 20, "red"),
            (4 * x - 5 * y >= -10, "red"),
            (-x + 2 * y >= -2, "yellow"),
            (-x + 5 * y == 15, "green")
        ]
        let model = Model("Basic", objective: objective, constraints: constraints)
        let errors = model.validationErrors
        
        XCTAssertEqual(errors.count, 1)
        XCTAssertEqual(errors[0], .duplicateConstraintName(constraints[1].0, "red"))
    }

    // Variable errors are listed before constraint errors.
    func testMultipleErrorsModel() {
        let (x, y) = (Variable("x"), Variable("x"))
        let function = x + 2 * y
        let objective = Objective(function, optimization: .maximize)
        let constraints = [
            (2 * x + y <= 20, "red"),
            (4 * x - 5 * y >= -10, "red"),
            (-x + 2 * y >= -2, "yellow"),
            (-x + 5 * y == 15, "green")
        ]
        let model = Model("Basic", objective: objective, constraints: constraints)
        let errors = model.validationErrors
        
        XCTAssertEqual(errors.count, 2)
        XCTAssertEqual(errors[0], .duplicateVariableName(y))
        XCTAssertEqual(errors[1], .duplicateConstraintName(constraints[1].0, "red"))
    }

}


/**
 Utility types.
 */
fileprivate typealias Objective = Model.Objective
