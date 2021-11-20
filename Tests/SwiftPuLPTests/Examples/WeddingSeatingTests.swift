//
//  WeddingSeatingTests.swift.swift
//  
//  Created by Michel Tilman on 19/11/2021.
//  Copyright © 2021 Dotted.Pair.
//  Licensed under Apache License v2.0.
//

import XCTest
import SwiftPuLP
import Algorithms

/**
 Tests result of a wedding seating application of set partitioning.
 */
final class WeddingSeatingTests: XCTestCase {

    // Maximum number of tables
    let maxTables = 5

    // Maximum number of guests per table
    let maxTableSize = 4
    
    // The guests.
    let guests = ["Athena", "Brienna", "Cordelia", "Darla", "Eliza", "Freya", "Gemma", "Inara", "Jemma", "Kara", "Leia", "Melissa", "Naya", "Olivia", "Paula", "Qira", "Reina"]
    
    // All possible table assignments.
    lazy var possibleTables = (1...maxTableSize).flatMap { i in guests.combinations(ofCount: i) }
    
    // The binary variables.
    lazy var x = possibleTables.map { a in
        (table: a, variable: Variable("table_\(a.joined(separator: "_")))", domain: .binary))
    }
    
    func testSolveWeddingSeatingModel() {
        let model = Model("Seating_Model", objective: objective(), constraints: constraints())
        guard let result = Solver().solve(model) else { return XCTFail("Nil result") }
        let tables = x.filter { (_, variable) in result.variables[variable.name] == 1 }.map(\.table)
        let expected = [["Athena", "Melissa", "Qira"], ["Brienna", "Freya", "Paula"], ["Cordelia", "Leia", "Reina"], ["Darla", "Gemma", "Jemma", "Naya"], ["Eliza", "Inara", "Kara", "Olivia"]]

        XCTAssertEqual(result.status, .optimal)
        XCTAssertTrue(tables.elementsEqual(expected, by: ==))
    }

    // MARK: Utility functions
    
    // Maximizes total happiness across all table assignments.
    private func objective() -> Model.Objective {
        Model.Objective(Function.sum(x.map { (table, variable) in happiness(table) * variable }), optimization: .maximize)
    }
                        
    // Limits the maximum number of tables.
    // Assigns each guest to one table.
    private func constraints() -> [(LinearConstraint, String)] {
        var constraints = [(LinearConstraint, String)]()
        
        constraints.append((Function.sum(x.map(\.variable)) <= Double(maxTables), "Maximum_tables_\(maxTables)"))
        for guest in guests {
            constraints.append((Function.sum(x.filter { $0.table.contains(guest) }.map(\.variable)) == 1, "Must_seat_\(guest)"))
        }

        return constraints
    }
    
    // Dummy 'happiness' calculation.
    // Answers the happiness of the table guests by calculating the maximum distance between the initial letters of each guest.
    // Guests are sorted by name.
    private func happiness(_ table: [String]) -> Double {
        abs(Double(table[0].first?.asciiValue ?? UInt8.min) - Double(table[table.count - 1].first?.asciiValue ?? UInt8.max))
    }

}
