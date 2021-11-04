////
//  SudokuTests.swift
//  
//  Created by Michel Tilman on 02/11/2021.
//  Copyright © 2021 Dotted.Pair.
//  Licensed under Apache License v2.0.
//

import XCTest
import SwiftPuLP

/**
 Tests result of a sudoku solver.
 */
final class SudokuTests: XCTestCase {

    // MARK: Stored properties, common for all 9 by 9 sudokus
    
    // Zero-based ranges and values.
    let (values, rows, columns) = (0...8, 0...8, 0...8)
    
    // Each box lists the row / column indices of its cells.
    lazy var boxes = rows.map { r in
        columns.map { c in
            (r / 3 * 3 + c / 3, r % 3 * 3 + c % 3)
        }
    }
    
    // The variables.
    lazy var choices = values.map { v in
        rows.map { r in
            columns.map { c in
                Variable("Choice_\(v)_\(r)_\(c)", domain: .binary)
            }
        }
    }
    
    // MARK: Sudoku tests
    
    func testGridGeneration() {
        XCTAssertEqual(dataToGrid(sudokuData), sudokuGrid)
    }
    
    func testSolveEvilSudokuModel() {
        let model = Model("Sudoku", constraints: constraints(sudokuData))
        guard let result = Solver().solve(model) else { return XCTFail("Nil result") }

        XCTAssertEqual(result.status, .optimal)
        XCTAssertEqual(dataToGrid(solutionData(result)), solutionGrid)
    }
    
    // MARK: Utility functions
    
    // Lists all constraints for given sudoku data. Only the last part depends on the input.
    private func constraints(_ sudokuData: [(Int, Int, Int)]) -> [(LinearConstraint, String)] {
        var constraints = [(LinearConstraint, String)]()

        // Adds constraint that exactly one variable in the list should have value 1.
        func addSumIsOneConstraint(_ variables: [Variable]) {
            constraints.append((Function.sum(variables) == 1, ""))
        }
        
        for r in rows {
            for c in columns {
                addSumIsOneConstraint(values.map { v in choices[v][r][c] })
            }
        }
        
        for v in values {
            for r in rows {
                addSumIsOneConstraint(columns.map { c in choices[v][r][c] })
            }
            for c in columns {
                addSumIsOneConstraint(rows.map { r in choices[v][r][c] })
            }
            for b in boxes {
                addSumIsOneConstraint(b.map { (r, c) in choices[v][r][c] })
            }
        }
        
        // Fix the givens for cells in the input data,
        for (v, r, c) in sudokuData {
           constraints.append((choices[v - 1][r - 1][c - 1] == 1, ""))
        }
        
        return constraints
    }
    
    // Converts the result variables into the sudoku data format.
    private func solutionData(_ result: Solver.Result) -> [(Int, Int, Int)] {
        var data = [(Int, Int, Int)]()
        
        for r in rows {
            for c in columns {
                for v in values {
                    if result.variables[choices[v][r][c].name] == 1 {
                        data.append((v + 1, r + 1, c + 1))
                    }
                }
            }
        }
        
        return data
    }
    
    // Converts the data into a grid-like string, making to easy to test and compare.
    private func dataToGrid(_ data: [(Int, Int, Int)]) -> String {
        var grid = [[Int]](repeating: [Int](repeating: 0, count: 9), count: 9)
        var result = ""
        
        for (value, row, column) in data {
            grid[row - 1][column - 1] = value
        }
        for r in rows {
            if r % 3 == 0 {
                result += "+-------+-------+-------+\n"
            }
            for c in columns {
                let v = grid[r][c]
                
                if c % 3 == 0 {
                    result += "| "
                }
                result += v == 0 ? ". " : "\(v) "
            }
            result += ("|\n")
        }
        result += "+-------+-------+-------+"
        
        return result
    }
    
}


/**
 Test data.
 */
extension SudokuTests {
    
    // Input sudoku data.
    // Values and row / column indices start at 1.
    var sudokuData : [(value: Int, row: Int, column: Int)] {
        [
            (8, 1, 1),
            (3, 2, 3),
            (6, 2, 4),
            (7, 3, 2),
            (9, 3, 5),
            (2, 3, 7),
            (5, 4, 2),
            (7, 4, 6),
            (4, 5, 5),
            (5, 5, 6),
            (7, 5, 7),
            (1, 6, 4),
            (3, 6, 8),
            (1, 7, 3),
            (6, 7, 8),
            (8, 7, 9),
            (8, 8, 3),
            (5, 8, 4),
            (1, 8, 8),
            (9, 9, 2),
            (4, 9, 7),
        ]
    }

    // Mainly a visual aid, but can be tested as well.
    var sudokuGrid: String {
        """
        +-------+-------+-------+
        | 8 . . | . . . | . . . |
        | . . 3 | 6 . . | . . . |
        | . 7 . | . 9 . | 2 . . |
        +-------+-------+-------+
        | . 5 . | . . 7 | . . . |
        | . . . | . 4 5 | 7 . . |
        | . . . | 1 . . | . 3 . |
        +-------+-------+-------+
        | . . 1 | . . . | . 6 8 |
        | . . 8 | 5 . . | . 1 . |
        | . 9 . | . . . | 4 . . |
        +-------+-------+-------+
        """
    }

    // Mainly a visual aid, but can be tested as well.
    var solutionGrid: String {
        """
        +-------+-------+-------+
        | 8 1 2 | 7 5 3 | 6 4 9 |
        | 9 4 3 | 6 8 2 | 1 7 5 |
        | 6 7 5 | 4 9 1 | 2 8 3 |
        +-------+-------+-------+
        | 1 5 4 | 2 3 7 | 8 9 6 |
        | 3 6 9 | 8 4 5 | 7 2 1 |
        | 2 8 7 | 1 6 9 | 5 3 4 |
        +-------+-------+-------+
        | 5 2 1 | 9 7 4 | 3 6 8 |
        | 4 3 8 | 5 2 6 | 9 1 7 |
        | 7 9 6 | 3 1 8 | 4 5 2 |
        +-------+-------+-------+
        """
    }
    
}
