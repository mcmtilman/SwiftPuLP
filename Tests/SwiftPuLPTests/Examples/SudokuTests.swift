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

    // MARK: Input / output data
    
    // Compact way to input sudoku data.
    // Values and row / column indices start at 1.
    static let sudokuData : [(value: Int, row: Int, column: Int)] = [
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

    // Mainly a visual aid, but can be tested as well.
    static let sudokuGrid =
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

    // Mainly a visual aid, but can be tested as well.
    static let solutionGrid =
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

    // MARK: Computed properties.
    
    // Lists all constraints. Only the last part depends on the input.
    var constraints: [(LinearConstraint, String)] {
        var constraints = [(LinearConstraint, String)]()

        // Exactly one variable in the list should have value 1.
        // The rest must have value 0.
        func addExactlyOneConstraint(for variables: [Variable]) {
            constraints.append((VarSum(variables) == 1, ""))
        }
        
        for r in rows {
            for c in columns {
                addExactlyOneConstraint(for: values.map { v in choices[v][r][c] })
            }
        }
        
        for v in values {
            for r in rows {
                addExactlyOneConstraint(for: columns.map { c in choices[v][r][c] })
            }
            for c in columns {
                addExactlyOneConstraint(for: rows.map { r in choices[v][r][c] })
            }
            for b in boxes {
                addExactlyOneConstraint(for: b.map { (r, c) in choices[v][r][c] })
            }
        }
        
        // Fix the givens for cells in the input data,
        for (v, r, c) in Self.sudokuData {
           constraints.append((choices[v - 1][r - 1][c - 1] == 1, ""))
        }
        
        return constraints
    }
    
    // MARK: Sudoku tests
    
    func testGridGeneration() {
        XCTAssertEqual(dataToGrid(Self.sudokuData), Self.sudokuGrid)
    }
    
    func testSolveEvilSudokuModel() {
        let model = Model("Sudoku", constraints: constraints)
        guard let result = Solver().solve(model) else { return XCTFail("Nil result") }

        XCTAssertEqual(result.status, .optimal)
        XCTAssertEqual(dataToGrid(solutionData(result)), Self.solutionGrid)
    }
    
    // MARK: Utility functions
    
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
            if [0, 3, 6].contains(r) {
                result += "+-------+-------+-------+\n"
            }
            for c in columns {
                let v = grid[r][c]
                
                if [0, 3, 6].contains(c) {
                    result += "| "
                }
                result += v == 0 ? ". " : "\(v) "
                if c == 8 {
                    result += ("|\n")
                }
            }
        }
        result += "+-------+-------+-------+"
        
        return result
    }
    
    func testRange() {
        let ranges = (0...2) * (0...2)
        let boxes = ranges.map { i, j in ranges.map { k, l in (3 * i + k, 3 * j + l) } }
        
        print(boxes)
    }

}

extension ClosedRange where Bound: Strideable, Bound.Stride: SignedInteger {

    static func * (lhs: ClosedRange, rhs: ClosedRange) -> RangePair<Bound, Bound> {
        RangePair(lhs, rhs)
    }

}

struct RangePair<U, V> where U: Strideable, U.Stride: SignedInteger, V: Strideable, V.Stride: SignedInteger {
    
    let u: ClosedRange<U>
    
    let v: ClosedRange<V>
    
    init(_ u: ClosedRange<U>, _ v: ClosedRange<V>) {
        self.u = u
        self.v = v
    }
    
    func map<T>(_ transform: (U, V) -> T) -> [T] {
        var result = [T]()
        
        for x in u {
            for y in v {
                result.append(transform(x, y))
            }
        }
        
        return result
    }
    
}
