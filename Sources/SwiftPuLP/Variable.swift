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
 A variable has a name and a domain.
 The domain may be further restricted to optional lower and upper bounds.
 */
public class Variable {
    
    /// Type of a variable id.
    public typealias Id = ObjectIdentifier
    
    /**
     A domain identifies the range of values of a variable:
     - binary (values 0 and 1).
     - real (real aka continuous numbers)
     - integer (integer values)
     */
    public enum Domain {

        case binary, real, integer

    }

    // MARK: Stored properties
    
    /// The name of the variable. May not be empty and may not contain spaces.
    public let name: String
    
    /// Optional lower bound for the values (inclusive).
    /// If present must not exceed a non-nil maximum.
    /// If present must be 0 for binary variables.
    public let minimum: Double?
    
    /// Optional upper bound for the values (inclusive).
    /// If present must be 1 for binary variables.
    public let maximum: Double?
    
    /// Domain  of values for this variable.
    /// Default = real.
    public let domain: Domain
    
    // MARK: Computed properties
    
    /// Answers a unique id for the variable.
    var id: Id {
        ObjectIdentifier(self)
    }
    
    // MARK: Initializing
    
    /// Creates a variable with given name and domain.
    /// The variable may optionally specify a lower and / or upper bound for its values.
    /// Variables come in three flavours:
    /// - real domain (supports double values satisfying the optional lower and upper bounds)
    /// - integer domain (supports integer values satisfying the optional lower and upper bounds)
    /// - binary domain (a value is either 0 or 1).
    public init(_ name: String, minimum: Double? = nil, maximum: Double? = nil, domain: Domain = .real) {
        self.name = name
        self.minimum = domain == .binary && minimum == nil ? 0 : minimum
        self.maximum = domain == .binary && maximum == nil ? 1 : maximum
        self.domain = domain
    }

}


/**
 Variable domain adopts PythonConvertible.
 */
extension Variable.Domain: PythonConvertible {

    // MARK: Computed properties
    
    /**
     Converts the domain into a PuLP category.
     */
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


/**
 Variable adopts PythonConvertible.
 */
extension Variable: PythonConvertible {
    
    // MARK: Computed properties
    
    /**
     Converts the variable into a PuLP variable.
     */
    public var pythonObject: PythonObject {
        PuLP.LpVariable(name: name, lowBound: minimum, upBound: maximum, cat: domain.pythonObject)
    }
    
    // MARK: Converting to Python
    
    // Converts the variable into a PuLP LpAffineExpression, optionally caching PuLP variables.
    func pythonObject(withCache cache: VariableCache?) -> PythonObject {
        guard let cache = cache else { return pythonObject }

        return cache[self.id, default: pythonObject]
    }
    
}


/**
 PuLP expects only one object for all similarly-named variables.
 The variable cache allows clients to cache new LpVariables if not already present,
 otherwise the existing one is returned.
 */
public class VariableCache {
    
    // MARK: Stored properties
    
    // Links variable names to generated PuLP variables.
    private var cache = [Variable.Id: PythonObject]()
    
    // MARK: Initializing
    
    // Default initializer made public.
    public init() {}
    
    // MARK: Accessing
    
    /// Answers the cached PuLP variable.
    /// If none found, generates a new one and caches it.
    public subscript(key: Variable.Id, default defaultValue: @autoclosure () -> PythonObject) -> PythonObject {
        get {
            return cache[key] ?? {
                let value = defaultValue()
                cache[key] = value
                return value
            }()
        }
    }
}


/**
 Variable adopts Equatable.
 */
extension Variable: Equatable {
 
    /// Needed since we do not use a struct,
    public static func == (lhs: Variable, rhs: Variable) -> Bool {
        lhs.name == rhs.name
            && lhs.minimum == rhs.minimum
            && lhs.maximum == rhs.maximum
            && lhs.domain == rhs.domain
    }
    
}
