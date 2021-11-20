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
    let guests = ["Athena", "Brienna", "Cordelia", "Darla", "Eliza", "Freya", "Gemma", "Inara", "Jasika", "Kara", "Leia", "Melissa", "Naya", "Olivia", "Paula", "Qira", "Reina"]
    
    // The binary variables, each one representing a possible table assignment.
    // Use tuples to keep track of the guests for each table.
    lazy var x = guests.combinations(ofCount: 1...maxTableSize).map { table in
        (table: table, variable: Variable("table_\(table.joined(separator: "_")))", domain: .binary))
    }
    
    func testSolveHappinessModel() {
        let model = Model("Happiness", objective: objective(happiness), constraints: constraints())
        guard let result = Solver().solve(model) else { return XCTFail("Nil result") }
        let tables = x.filter { (_, variable) in result.variables[variable.name] == 1 }.map(\.table)
        let expected = [["Athena", "Melissa", "Qira"], ["Brienna", "Freya", "Paula"], ["Cordelia", "Leia", "Reina"], ["Darla", "Gemma", "Jasika", "Naya"], ["Eliza", "Inara", "Kara", "Olivia"]]

        XCTAssertEqual(result.status, .optimal)
        XCTAssertTrue(tables.elementsEqual(expected, by: ==))
    }

    func testSolveLikesModel() {
        let model = Model("Likes", objective: objective(likes), constraints: constraints())
        guard let result = Solver().solve(model) else { return XCTFail("Nil result") }
        let tables = x.filter { (_, variable) in result.variables[variable.name] == 1 }.map(\.table)
        let expected = [["Athena", "Kara", "Melissa"], ["Cordelia", "Darla", "Eliza"], ["Paula", "Qira", "Reina"], ["Brienna", "Inara", "Leia", "Naya"], ["Freya", "Gemma", "Jasika", "Olivia"]]

        XCTAssertEqual(result.status, .optimal)
        XCTAssertTrue(tables.elementsEqual(expected, by: ==))
    }

    // MARK: Utility functions
    
    // Maximizes total score across all table assignments.
    private func objective(_ score: ([String]) -> Double) -> Model.Objective {
        Model.Objective(Function.sum(x.map { (table, variable) in score(table) * variable }), optimization: .maximize)
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
    
    // Dummy 'happiness' calculation from PuLP example.
    // Answers the happiness of the table guests by calculating the maximum distance between the initial letters of each guest.
    // Guests are sorted by name.
    private func happiness(_ table: [String]) -> Double {
        abs(Double(table[0].first?.asciiValue ?? UInt8.min) - Double(table[table.count - 1].first?.asciiValue ?? UInt8.max))
    }

    // Counts the number of likes in a table assignment.
    private func likes(_ table: [String]) -> Double {
        let likes = [
            "Athena": ["Kara"],
            "Eliza": ["Cordelia", "Darla"],
            "Freya": ["Gemma", "Jasika"],
            "Inara": ["Leia"],
            "Kara": ["Athena"],
            "Olivia": ["Jasika"],
            "Qira": ["Paula"]
        ]

        return Double(table.reduce(into: 0) { total, guest in
            if let friends = likes[guest] { total += Set(table).subtracting([guest]).intersection(friends).count }
        })
    }
    
}
