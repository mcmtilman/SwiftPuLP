//
//  Variable.swift
//  
//  Created by Michel Tilman on 29/10/2021.
//  Copyright © 2021 Dotted.Pair.
//  Licensed under Apache License v2.0.
//

import Foundation
import PythonKit

/**
 A variable represents a decision variable and may appear in the linear objective function and / or in linear constraints of a LP model.
 
 Each variable should have a unique name.

 The range of values for a variable is defined by its ``Domain``. All domains represent Double numbers, but may further limit the range to integer numbers or binary numbers.
 
 The domain values may be further restricted to optional lower and upper bounds.
 
 It is possible to create variables with invalid names or invalid bounds / domain combinations. Use ``validationErrors`` to detect if a variable is valid.
 */
public class Variable {
    
    // MARK: -
    
    ////// Type of a variable id.
    typealias Id = ObjectIdentifier
    
    // MARK: -

    /**
     A domain specifies the range of (Double) values a variable can take.
     
     Supported domains are:
     - binary (values 0 and 1).
     - real (aka continuous numbers in PuLP)
     - integer (integer values)
     */
    public enum Domain {

        case binary, real, integer

    }

    // MARK: -
    
    /// The unique name of the variable.
    ///
    /// Should not be empty and should not contain special characters.
    public let name: String
    
    /// Optional lower bound for the values (inclusive).
    ///
    /// If present must not exceed a non-nil maximum.
    /// If present must be 0 for binary variables.
    let minimum: Double?
    
    /// Optional upper bound for the values (inclusive).
    ///
    /// If present must be 1 for binary variables.
    let maximum: Double?
    
    /// Domain of values for this variable.
    let domain: Domain
    
    /// Answers a unique id for the variable.
    var id: Id {
        ObjectIdentifier(self)
    }
    
    // MARK: -
    
    /// Creates a variable with given name and ``Domain``.
    /// The variable may optionally specify a lower and / or upper bound for its values.
    /// Invalid names or invalid bounds / domain combinations may result in ``validationErrors``.
    /// 
    /// - Parameters:
    ///   - name: Unique name of the variable. Should not be empty and should not contain any of the characters "-+[] ->/"
    ///   - minimum: Specifies a lower bound for the variable if present. If present should not exceed a non-nil maximum.= and must be 0 for binary variables.
    ///   - maximum: Specifies an upper bound for the variable if present. If present must be 1 for binary variables.
    ///   - domain: Specifies the range of (Double) values the variable may assume. Default = .real.
    public init(_ name: String, minimum: Double? = nil, maximum: Double? = nil, domain: Domain = .real) {
        self.name = name
        self.minimum = domain == .binary && minimum == nil ? 0 : minimum
        self.maximum = domain == .binary && maximum == nil ? 1 : maximum
        self.domain = domain
    }

}

// MARK: -

/**
 PuLP expects only one object for all similarly-named variables.
 The variable cache allows clients to cache new LpVariables if not already present,
 otherwise the existing one is returned.
 */
class VariableCache {
    
    // MARK: -
    
    // Links variable names to generated PuLP variables.
    private var cache = [Variable.Id: PythonObject]()
    
    // MARK: -
    
    // Answers the cached PuLP variable.
    // If none found, generates a new one and caches it.
    fileprivate subscript(key: Variable.Id, default defaultValue: @autoclosure () -> PythonObject) -> PythonObject {
        get {
            return cache[key] ?? {
                let value = defaultValue()
                cache[key] = value
                return value
            }()
        }
    }
}


// MARK: - PythonConvertible -

/**
 Converting Variable into Python.
 */
extension Variable: PythonConvertible {
    
    // MARK: -
    
    /// Converts the variable into a PuLP LpVariable.
    public var pythonObject: PythonObject {
        PuLP.LpVariable(name: name, lowBound: minimum, upBound: maximum, cat: domain.pythonObject)
    }
    
    // MARK: -

    /// Converts the variable into a PuLP LpVariable, optionally caching generated PuLP variables.
    ///
    /// - Parameter cache: If present caches a generated Python LpVariable instance for each SwithPuLP variable.
    /// - Returns: Cached or newly generated Python LpVariable.
    func pythonObject(withCache cache: VariableCache?) -> PythonObject {
        guard let cache = cache else { return pythonObject }

        return cache[self.id, default: pythonObject]
    }
    
}


// MARK: -

/**
 Converting Variable.Domain into Python.
 */
extension Variable.Domain: PythonConvertible {

    // MARK: -

    /// Converts the domain into a PuLP category.
    public var pythonObject: PythonObject {
        switch self {
        case .binary:
            return PuLP.LpBinary
        case .real:
            return PuLP.LpContinuous
        case .integer:
            return PuLP.LpInteger
        }
    }
    
}


// MARK: - Equatable -

/**
 Variable adopts Equatable.
 */
extension Variable: Equatable {
 
    // MARK: -

    /// Returns true if the lhs and rhs variables are the same content-wise, false otherwise.
    /// Mainly used for testing.
    ///
    /// - Returns: True if name, minimum, maximum and domain are equal.
    public static func == (lhs: Variable, rhs: Variable) -> Bool {
        lhs.name == rhs.name
            && lhs.minimum == rhs.minimum
            && lhs.maximum == rhs.maximum
            && lhs.domain == rhs.domain
    }
    
}
