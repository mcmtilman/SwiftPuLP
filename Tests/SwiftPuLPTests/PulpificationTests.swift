//
//  PulpificationTests.swift
//  
//  Created by Michel Tilman on 14/11/2021.
//  Copyright © 2021 Dotted.Pair.
//  Licensed under Apache License v2.0.
//

import XCTest
import PythonKit
import SwiftPuLP

/**
 Tests converting model elements to PuLP.
 */
final class PulpificationTests: XCTestCase {
    
    let PuLP = Python.import("pulp")
    
    // MARK: Variable tests
       
    func testVariableToPuLP() {
        let variable = Variable("x", minimum: 1, maximum: 10, domain: .integer)
        let pythonVariable = variable.pythonObject
        
        XCTAssertTrue(pythonVariable.isInstance(of: PuLP.LpVariable))
        XCTAssertEqual(pythonVariable.name, "x")
        XCTAssertEqual(pythonVariable.lowBound, 1)
        XCTAssertEqual(pythonVariable.upBound, 10)
        XCTAssertEqual(pythonVariable.cat, PuLP.LpInteger)
    }

    func testDefaultVariableToPuLP() {
        let variable = Variable("x")
        let pythonVariable = variable.pythonObject
        
        XCTAssertEqual(pythonVariable.name, "x")
        XCTAssertEqual(pythonVariable.lowBound, Python.None)
        XCTAssertEqual(pythonVariable.upBound, Python.None)
        XCTAssertEqual(pythonVariable.cat, PuLP.LpContinuous)
    }

    func testDomainToPuLP() {
        let domains = [Variable.Domain.binary, .real, .integer]
        let categories = [PuLP.LpBinary, PuLP.LpContinuous, PuLP.LpInteger]

        for (domain, category) in zip(domains, categories) {
            XCTAssertEqual(domain.pythonObject, category)
        }
    }

    // MARK: Linear function tests
    
    func testFunctionToPuLP() {
        let (x, y) = (Variable("x"), Variable("y"))
        let function = 2 * x + 3 * y + 10
        let pythonObject = function.pythonObject

        XCTAssertTrue(pythonObject.isInstance(of: PuLP.LpAffineExpression))
        XCTAssertEqual(pythonObject.toDict(), [["name": "x", "value": 2], ["name": "y", "value": 3]])
        XCTAssertEqual(pythonObject.constant, 10)
    }

    // MARK: Linear constraint tests
    
    func testConstraintToPuLP() {
        let (x, y) = (Variable("x"), Variable("y"))
        let constraint = 2 * x + 3 * y <= 5
        let pythonConstraint = constraint.pythonObject

        XCTAssertTrue(pythonConstraint.isInstance(of: PuLP.LpConstraint))
        XCTAssertEqual(pythonConstraint.toDict()["coefficients"], [["name": "x", "value": 2], ["name": "y", "value": 3]])
        // PuLP internally transforms the constraint into 2 * x + 3 * y - 5 <= 0.
        // The PuLP constant retrieved from LpConstraint is actually the constant of the transformed linear function, hence -5.
        XCTAssertEqual(pythonConstraint.constant, -5)
        XCTAssertEqual(pythonConstraint.sense, PuLP.LpConstraintLE)
    }

    func testComparisonToPuLP() {
        let comparisons = [LinearConstraint.Comparison.lte, .eq, .gte]
        let senses = [PuLP.LpConstraintLE, PuLP.LpConstraintEQ, PuLP.LpConstraintGE]

        for (comparison, sense) in zip(comparisons, senses) {
            XCTAssertEqual(comparison.pythonObject, sense)
        }
    }

    // MARK: Model tests
    
    func testOptimizationToPuLP() {
        let optimizations = [Model.Optimization.maximize, .minimize]
        let senses = [PuLP.LpMaximize, PuLP.LpMinimize]

        for (optimization, sense) in zip(optimizations, senses) {
            XCTAssertEqual(optimization.pythonObject, sense)
        }
    }
    
    func testModelToPuLP() {
       let (x, y) = (Variable("x"), Variable("y"))
        let function = 2 * x + 3 * y + 10
        let model = Model("XYZ", objective: Model.Objective(function, optimization: .maximize))
        let pythonModel = model.pythonObject
        
        XCTAssertTrue(pythonModel.isInstance(of: PuLP.LpProblem))
        XCTAssertEqual(pythonModel.name, "XYZ")
        XCTAssertTrue(pythonModel.objective.isInstance(of: PuLP.LpAffineExpression))
        XCTAssertEqual(pythonModel.objective.toDict(), [["name": "x", "value": 2], ["name": "y", "value": 3]])
        XCTAssertEqual(pythonModel.objective.constant, 10)
        XCTAssertEqual(pythonModel.sense, PuLP.LpMaximize)
    }
    
   func testDefaultModelToPuLP() {
        let model = Model("XYZ")
        let pythonModel = model.pythonObject
        
        XCTAssertTrue(pythonModel.objective.isNone)
        XCTAssertEqual(pythonModel.sense, PuLP.LpMinimize)
    }
    
    func testAliasedVariablesToPuLP() {
        let (x, y) = (Variable("x"), Variable("y"))
        let z = x
        let model = Model("Alias", constraints: [(x + y + z <= 10, "alias")])
        let variables = model.pythonObject.variables()
        let ids = variables.map(\.id)
        
        XCTAssertEqual(variables.count, 2)
        XCTAssertEqual(variables[0].name, "x")
        XCTAssertEqual(variables[1].name, "y")
        XCTAssertEqual(Set(ids).count, 2)
    }

}
