//
//  Python.swift
//
//  Created by Michel Tilman on 28/10/2021.
//  Copyright © 2021 Dotted.Pair.
//  Licensed under Apache License v2.0.
//

import PythonKit

// The Python PuLP module.
let PuLP = Python.import("pulp")


/**
 Utility functions.
 */
public extension PythonObject {
    
    // MARK: -
    
    /// Answers the id of the object.
    var id: Double? {
        Double(Python.id(self))
    }
    
    /// Answers true if the object is None.
    /// 
    /// Testing for equality in Python may cause strange side effects, e.g. testing the presence of an object.
    /// For instance, LpAffineExpression.__eq__ returns an LpConstraint, which may cause simple equality
    /// testing between a PuLP model objective and None to fail.
    var isNone: Bool {
        self.isInstance(of: Python.type(Python.None))
    }
    
    // MARK: -
    
    /// Answers true if the object is an instance of given type.
    ///
    /// - Parameter type: Python type object.
    /// - Returns: True if the object is an instance of type.
    func isInstance(of type: PythonObject) -> Bool {
        Python.isinstance(self, type) == true
    }
    
}
