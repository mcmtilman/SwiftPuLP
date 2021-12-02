//
//  ProductionPlanningTests.swift
//  
//  Created by Michel Tilman on 01/12/2021.
//  Copyright © 2021 Dotted.Pair.
//  Licensed under Apache License v2.0.
//

import XCTest
import SwiftPuLP

/**
 Tests result of a production planning solver.
 */
final class ProductionPlanningTests: XCTestCase {
    
    // MARK: Properties
    
    // Types of products.
    let products = ["wrenches", "pliers"]
    
    // Amount of steel needed to produce each type of product.
    let steel = [1.5, 1]
    
    // Hours per molding.
    let molding = [1.0, 1]

    // Maximum hours of molding.
    let maxMolding = 21.0
    
    // Hours per assembly.
    let assembly = [0.3, 0.5]

    // Maximum required product capacity based on demand.
    let maxCapacity = [15.0, 16]

    // Purchase price per steel unit.
    let steelPrice = 58.0
    
    // Number of scenarios.
    let scenarios = 0 ... 3
    
    // Probability of each scenario.
    let probabilities = [0.25, 0.25, 0.25, 0.25]
    
    // Earnings for wrench per scenario.
    let wrenchEarnings = [160.0, 160, 90, 90]
    
    // Earnings for plier per scenario.
    let plierEarnings = [100.0, 100, 100, 100]
    
    // Maximum hours of assembly per scenario.
    let maxAssembly = [8.0, 10, 8, 10]
    
    // MARK: - Derived properties
    
    // Easier to work with product indices than with dictionaries as in PuLP example.
    lazy var productIds = 0 ..< products.count
    
    // Prices per scenario and product.
    lazy var prices = scenarios.map { s in [wrenchEarnings[s], plierEarnings[s]] }

    // MARK: Variables
    
    // Product variables per scenario.
    lazy var productVars = scenarios.map { scenario in
        products.map { product in
            Variable("Production_\(scenario)_\(product)", minimum: 0)
        }
    }
    
    // Purchase-related variable.
    lazy var purchaseVar = Variable("Purchase", minimum: 0)
    
    // MARK: - Solver tests
    
    func testSolveProductionPlanningModel() {
        let objective = objective()
        let model = Model("ProductionPlanning", objective: objective, optimization: .maximize, constraints: constraints())
        guard let result = Solver().solve(model) else { return XCTFail("Nil result") }
        let expected = [[15, 4.75], [15, 4.75], [12.5, 8.5], [5, 16]]

        XCTAssertEqual(result.status, .optimal)
        XCTAssertEqual(result.variables["Purchase"], 27.25)
        for s in scenarios {
            for p in productIds {
                XCTAssertEqual(result.variables["Production_\(s)_\(products[p])"], expected[s][p])
            }
        }
        XCTAssertEqual(objective(result.variables), 863.25)
    }
    
    func testSolveCBCProductionPlanningModel() {
        guard let path = ProcessInfo.processInfo.environment["CBC_PATH"] else { return }

        let solver = CBCSolver(commandPath: path)
        let objective = objective()
        let model = Model("ProductionPlanning", objective: objective, optimization: .maximize, constraints: constraints())
        guard let result = solver.solve(model) else { return XCTFail("Nil result") }
        let expected = [[15, 4.75], [15, 4.75], [12.5, 8.5], [5, 16]]

        XCTAssertEqual(result.status, .optimal)
        XCTAssertEqual(result.variables["Purchase"], 27.25)
        for s in scenarios {
            for p in productIds {
                XCTAssertEqual(result.variables["Production_\(s)_\(products[p])"], expected[s][p])
            }
        }
        XCTAssertEqual(objective(result.variables), 863.25)
    }
    
    // MARK: Utility functions
    
    // Optimizes production based on scenario probabilities and earnings / purchase price.
    private func objective() -> LinearFunction {
        Function.sum(Pairs(scenarios, productIds).map { (s, p) in
            probabilities[s] * (prices[s][p] * productVars[s][p])
        }) - steelPrice * purchaseVar
    }
        
    // Constraints making sure not to exceed available capacities and demand.
    private func constraints() -> [(LinearConstraint, String)] {
        var constraints = [(LinearConstraint, String)]()
        
        for s in scenarios {
            func sum(_ weights: [Double]) -> LinearFunction {
                Function.sum(productIds.map { p in weights[p] * productVars[s][p] })
            }
            
            constraints.append((sum(steel) - purchaseVar <= 0, "Steel_\(s)"))
            constraints.append((sum(molding) <= maxMolding, "Molding_\(s)"))
            constraints.append((sum(assembly) <= maxAssembly[s], "Assembly_\(s)"))
            for p in productIds {
                constraints.append((productVars[s][p] <= maxCapacity[p], "Capacity_\(s)_\(p)"))
            }
        }
        
        return constraints
    }
    
}
