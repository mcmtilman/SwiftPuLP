//
//  Python.swift
//
//  Created by Michel Tilman on 28/10/2021.
//  Copyright © 2021 Dotted.Pair.
//  Licensed under Apache License v2.0.
//

import PythonKit

/**
 Utility functions.
 */
public extension PythonObject {
    
    // MARK: Computed properties
    
    /// Answers true of the object is None.
    /// Testing for equality in Python may cause strange side effects, e.g. testing the presence of an object.
    /// For instance, LpAffineExpression.__eq__ returns an LpConstraint, which may cause simple equality
    /// testing between a PuLP model objective and None to fail.
    var isNone: Bool {
        self.isInstance(of: Python.type(Python.None))
    }
    
    // MARK: Testing
    
    /// Answers true if the object is an instance of given type.
    func isInstance(of type: PythonObject) -> Bool {
        Python.isinstance(self, type) == true
    }
    
}
