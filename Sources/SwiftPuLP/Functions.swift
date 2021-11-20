//
//  Functions.swift
//  
//  Created by Michel Tilman on 03/11/2021.
//  Copyright © 2021 Dotted.Pair.
//  Licensed under Apache License v2.0.
//

import Darwin

/**
 Helper functions to simplify elaboration of a model.
 
 Use enum as a namespace.
 */
public enum Function {
    
    // MARK: -
    
    /// Answers a linear function representing the sum of given sequence of variables.
    ///
    /// > Note: Does not normalize the resulting function.
    ///
    /// - Parameter variables: Sequence of Variable.
    /// - Returns: Linear function consisting of a term for each variable with factor 1.
    public static func sum<T>(_ variables: T) -> LinearFunction where T: Sequence, T.Element == Variable {
        LinearFunction(terms: variables.map { LinearFunction.Term(variable: $0, factor: 1) })
    }

    /// Answers a linear function representing the sum of given sequence of linear functions.
    ///
    /// > Note: Does not normalize the resulting function.
    ///
    /// - Parameter functions: Sequence of LinearFunction.
    /// - Returns: Linear function consisting of the concatenation of the terms and the sum of the constants.
    public static func sum<T>(_ functions: T) -> LinearFunction where T: Sequence, T.Element == LinearFunction {
        let (terms, constant) = functions.reduce(into: ([LinearFunction.Term](), 0.0)) { accumulator, function in
            accumulator.0 += function.terms
            accumulator.1 += function.constant
        }
        
        return LinearFunction(terms: terms, constant: constant)
    }

}


 // MARK: -

/**
 Sequence consisting of all pairwise combinations of elements in two sequences.
 
 Iterating respects the order of the sequences. Major order is imposed by the first sequence.
 
 Example
 ```swift
 print(Array(Pairs(["a", "b", "c"], [1, 2])))
 // outputs [("a", 1), ("a", 2), ("b", 1), ("b", 2), ("c", 1), ("c", 2)]
 ```
 */
public struct Pairs<S1, S2>: Sequence where S1: Sequence, S2: Sequence {
    
    // MARK: -
    
    public struct Iterator: IteratorProtocol {
        
        // MARK: -
        
        // Remembers the second sequence since we may recreate the iterator.
        private let seq2: S2

        // Iterator for the first sequence.
        private var it1: S1.Iterator

        // Iterator for the second sequence.
        private var it2: S2.Iterator

        // Current element in the first sequence.
        //
        // If nil, we are at the end.
        private var el1: S1.Element?

        // Current element in the second sequence.
        //
        // If nil, we are at the end if the first iterator is.
        private var el2: S2.Element?

        // MARK: -

        // Creates an iterator for given sequences.
        fileprivate init(_ seq1: S1, _ seq2: S2) {
            self.seq2 = seq2
            self.it1 = seq1.makeIterator()
            self.it2 = self.seq2.makeIterator()
            self.el1 = self.it1.next()
            self.el2 = self.it2.next()
        }
        
        // MARK: -

        /// Answers the next pair of elements from both sequences, or nil if at the end.
        ///
        /// - Returns: Next pair of elements or nil if at end.
        public mutating func next() -> (S1.Element, S2.Element)? {
            guard let x = el1, let y = el2 else { return nil }
            
            el2 = it2.next()
            if el2 == nil {
                el1 = it1.next()
                if el1 != nil {
                    it2 = seq2.makeIterator()
                    el2 = it2.next()
                }
            }

            return (x, y)
        }
        
    }

    // MARK: -

    // First sequence.
    private let seq1: S1
    
    // Second sequence.
    private let seq2: S2
    
    // MARK: -

    /// Creates a sequence representing all pairs of elements from both sequences.
    ///
    /// - Parameters:
    ///   - seq1: First sequence.
    ///   - seq2: Second sequence.
    public init(_ seq1: S1, _ seq2: S2) {
        self.seq1 = seq1
        self.seq2 = seq2
    }

    // MARK: -

    /// Answers an iterator.
    ///
    /// - Returns: The iterator.
    public func makeIterator() -> Iterator {
        Iterator(seq1, seq2)
    }
    
}
