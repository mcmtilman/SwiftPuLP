//
//  FunctionTests.swift
//  
//  Created by Michel Tilman on 03/11/2021.
//  Copyright © 2021 Dotted.Pair.
//  Licensed under Apache License v2.0.
//

import XCTest
import SwiftPuLP

/**
 Tests common functions.
 */
final class FunctionTests: XCTestCase {
    
    // MARK: Linear functions tests
    
    func testSumOfVariables() {
        let x = (0..<5).map { i in Variable("x_\(i)") }
        let sum = Function.sum(x)

        XCTAssertEqual(sum, x[0] + x[1] + x[2] + x[3] + x[4])
    }
    
    func testSumOfFunctions() {
        let x = (0..<5).map { i in Variable("x_\(i)") }
        let functions = (0..<x.count).map { i in Double(i) * x[i] }
        let sum = Function.sum(functions)

        XCTAssertEqual(sum, 0 * x[0] + 1 * x[1] + 2 * x[2] + 3 * x[3] + 4 * x[4])
    }
    
    // MARK: Pairs tests
    
    func testMixedArrayPairs() {
        let pairs = Array(Pairs(["a", "b", "c"], [1, 2]))
        let expected = [("a", 1), ("a", 2), ("b", 1), ("b", 2), ("c", 1), ("c", 2)]

        XCTAssertTrue(pairs.elementsEqual(expected, by: ==))
    }

    func testMixedRangePairs() {
        let pairs = Array(Pairs(0...3, 4..<6))
        let expected = [(0, 4), (0, 5), (1, 4), (1, 5), (2, 4), (2, 5), (3, 4), (3, 5)]

        XCTAssertTrue(pairs.elementsEqual(expected, by: ==))
    }
    
    func testEmptyRangePairs() {
        let pairs = Array(Pairs(0...3, 4..<4))
        let expected = [(Int, Int)]()
        XCTAssertTrue(pairs.elementsEqual(expected, by: ==))
    }

    func testSingletonRangePairs() {
         let pairs = Array(Pairs(0...0, 4..<5))
         let expected = [(0, 4)]

         XCTAssertTrue(pairs.elementsEqual(expected, by: ==))
    }

    func testLeftNestedPairs() {
        let pairs = Pairs(Pairs(0...1, 2...3), 0...1)
        let expected = [((0, 2), 0), ((0, 2), 1), ((0, 3), 0), ((0, 3), 1), ((1, 2), 0), ((1, 2), 1), ((1, 3), 0), ((1, 3), 1)]

        XCTAssertTrue(pairs.map(\.0).elementsEqual(expected.map(\.0), by: ==))
        XCTAssertTrue(pairs.map(\.1).elementsEqual(expected.map(\.1), by: ==))
   }

    func testRightNestedPairs() {
        let pairs = Pairs(0...1, Pairs(2...3, 0...1))
        let expected = [(0, (2, 0)), (0, (2, 1)), (0, (3, 0)), (0, (3, 1)), (1, (2, 0)), (1, (2, 1)), (1, (3, 0)), (1, (3, 1))]

        XCTAssertTrue(pairs.map(\.0).elementsEqual(expected.map(\.0), by: ==))
        XCTAssertTrue(pairs.map(\.1).elementsEqual(expected.map(\.1), by: ==))
    }

    func testDoubleNestedPairs() {
        let pairs = Pairs(Pairs(0...1, 4...5), Pairs(2...3, 0...1))
        let expected = [((0, 4), (2, 0)), ((0, 4), (2, 1)), ((0, 4), (3, 0)), ((0, 4), (3, 1)), ((0, 5), (2, 0)), ((0, 5), (2, 1)), ((0, 5), (3, 0)), ((0, 5), (3, 1)), ((1, 4), (2, 0)), ((1, 4), (2, 1)), ((1, 4), (3, 0)), ((1, 4), (3, 1)), ((1, 5), (2, 0)), ((1, 5), (2, 1)), ((1, 5), (3, 0)), ((1, 5), (3, 1))]

        XCTAssertTrue(pairs.map(\.0).elementsEqual(expected.map(\.0), by: ==))
        XCTAssertTrue(pairs.map(\.1).elementsEqual(expected.map(\.1), by: ==))
    }

}
