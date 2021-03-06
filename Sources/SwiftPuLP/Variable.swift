//
//  Variable.swift
//  
//  Created by Michel Tilman on 29/10/2021.
//  Copyright © 2021 Dotted.Pair.
//  Licensed under Apache License v2.0.
//

/**
 A variable represents a linear programming decision variable and may appear in the objective function and / or in linear constraints of a linear programming model.
 
 The range of values for a variable is defined in the first place by its ``Domain``. A domain represents a subset of Double, such as continuous (real) numbers, or the binary numbers 0 and 1.
 
 In addition, a variable may specify lower and / or upper bounds, for instance to limit the domain values to the integer numbers less than 10.
 
 See also: <doc:UsingVariables>.
 */
public class Variable {
    
    // MARK: -
    
    /// Type of a variable id.
    /// Different variables have different ids.
    typealias Id = ObjectIdentifier
    
    // MARK: -

    /**
     A domain specifies the  values a variable can take.
     
     Domains identify subsets of Double and correspond to PuLP categories.
     */
    public enum Domain {

        /// Allowed values are 0 and 1.
        case binary
        
        /// Allowed values are the integer numbers.
        case integer

        /// Allowed values are all Double numbers.
        case continuous
        
    }

    // MARK: -
    
    /// The name of the variable.
    ///
    /// Should not be empty and should not contain special characters.
    ///
    /// Should be unique in a single model.
    public let name: String
    
    /// Optional lower bound for the values (inclusive).
    ///
    /// If present should not exceed a non-nil maximum.
    /// If present should be 0 for binary variables.
    let minimum: Double?
    
    /// Optional upper bound for the values (inclusive).
    ///
    /// If present should be 1 for binary variables.
    let maximum: Double?
    
    /// Domain of this variable.
    let domain: Domain
    
    /// Answers a unique id for the variable.
    var id: Id {
        ObjectIdentifier(self)
    }
    
    // MARK: -
    
    /// Creates a variable with given name and domain.
    /// The variable may optionally specify a lower and / or upper bound for its values.
    ///
    /// > Note: The initializer does not fail if parameters are not correct. To check if the definition is valid use ``validationErrors``.
    ///
    /// - Parameters:
    ///   - name: Name of the variable. Should not be empty and should not contain any of the characters "-+[] ->/". Should be unique in a single model.
    ///   - domain: Specifies the subset of Double values the variable may assume (default = .continuous).
    ///   - minimum: Specifies a lower bound for the variable if present (default = nil). If not nil should not exceed a non-nil maximum. Should be nil or 0 for binary variables. 
    ///   - maximum: Specifies an upper bound for the variable if present (default = nil). Should be nil or 1 for binary variables.
    public init(_ name: String, domain: Domain = .continuous, minimum: Double? = nil, maximum: Double? = nil) {
        self.name = name
        self.minimum = domain == .binary && minimum == nil ? 0 : minimum
        self.maximum = domain == .binary && maximum == nil ? 1 : maximum
        self.domain = domain
    }

}


// MARK: - Equatable -

/**
 Variable adopts Equatable.
 */
extension Variable: Equatable {

    // MARK: -

    /// Returns true if the lhs and rhs variables are the same objects, false otherwise.
    ///
    /// - Returns: lhs === rhs.
    public static func == (lhs: Variable, rhs: Variable) -> Bool {
        lhs === rhs
    }

}


// MARK: - Hashable -

/**
 Variable adopts Hashable.
 */
extension Variable: Hashable {
    
    /// Hashes the object id.
    ///
    /// - Parameter hasher: See ``Hashable``
    public func hash(into hasher: inout Hasher) {
        id.hash(into: &hasher)
    }
    
}
