//
//  Model.swift
//
//  Created by Michel Tilman on 22/10/2021.
//  Copyright © 2021 Dotted.Pair.
//  Licensed under Apache License v2.0.
//

import PythonKit
import Collections

// The Python PuLP module loaded lazily.
fileprivate let pulpModule = Python.import("pulp")


/*
 Represents an expression to be used in objective functions and constraints.
 */
public protocol Expression: PythonConvertible {}


/*
 Represents an objective function.
 */
public protocol LinearExpression: Expression {}


/*
 Represents an LP problem consisting of an objective and a list of contraints.
 A model has a non-empty name containing no spaces.
 */
public struct Model: PythonConvertible {
    
    // MARK: Stored properties
    
    /// The name of the model. May not be empty and may not contain spaces.
    public let name: String
    
    /// The optional objective of the model.
    /// Default = nil.
    public let objective: Objective?
    
    // MARK: Computed properties
    
    /**
     Converts the model into a PuLP problem.
     */
    public var pythonObject: PythonObject {
        var problem = pulpModule.LpProblem(name: name, sense: objective?.optimization ?? .minimize)// set sense, even without an objective.
        if let objective = objective {
            problem += objective.function.pythonObject
        }
        
        return problem
    }
        
    // MARK: Initializing
    
    /**
     Creates a model with given name and objective.
     Fails if the name is empty or contains spaces.
     */
    public init?(_ name: String, objective: Objective? = nil) {
        guard !name.isEmpty, !name.contains(" ") else { return nil }

        self.name = name
        self.objective = objective
    }

}


/**
 Represent the objective of a linear programming problem: maximize or minimize a linear expression.
 */
public struct Objective {
    
    /**
     Specifies if the objective function must be maximized or minimized.
     */
    public enum Optimization: PythonConvertible {
        
        case minimize
        case maximize
        
        // MARK: Computed properties
        
        /**
         Converts the optimization into a PuLP sense.
         */
        public var pythonObject: PythonObject {
            switch self {
            case .maximize: return pulpModule.LpMaximize
            case .minimize: return pulpModule.LpMinimize
            }
        }
        
    }
    
    // MARK: Stored properties
    
    /// The linear function to be optimized.
    public let function: LinearExpression
        
    /// The optimization to be performed.
    /// Default = minimize.
    public let optimization: Optimization
        
    // MARK: Initializing
    
    /// Creates an objective to optimize given linear expression.
    public init(_ function: LinearExpression, optimization: Optimization = .minimize) {
        self.function = function
        self.optimization = optimization
    }
    
}


/**
 A variable has a name and a domain.
 The domain may be further restricted to optional lower and upper bounds.
 */
public struct Variable: LinearExpression {
    
    /**
     A domain identifies the range of values of a variable:
     - binary (values 0 and 1).
     - real (real numbers)
     - integer (integer values)
     */
    public enum Domain: PythonConvertible {

        case binary
        case real
        case integer

        // MARK: Computed properties
        
        /**
         Converts the domain into a PuLP category.
         */
        public var pythonObject: PythonObject {
            switch self {
            case .binary: return pulpModule.LpBinary
            case .real: return pulpModule.LpContinuous
            case .integer: return pulpModule.LpInteger
            }
        }
        
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
    
    /**
     Converts the variable into a PuLP variable.
     */
    public var pythonObject: PythonObject {
        pulpModule.LpVariable(name: name, lowBound: minimum, upBound: maximum, cat: domain.pythonObject)
    }

    // MARK: Initializing
    
    /**
     Creates a variable with given name and domain.
     The variable may optionally specify a lower and / or upper bound for its values.
     Variables come in three flavours:
     - real domain (supports double values satisfying the optional lower and upper bounds)
     - integer domain (supports integer values satisfying the optional lower and upper bounds)
     - binary domain (a value is either 0 or 1).
     Creation fails if:
     - the name is empty or contains spaces;
     - a non-nil minimum value is greater than a non-nil maximum value;
     - the variable is binary with minimum != 0 and nil, or maximum != 1 and nil.
     */
    public init?(_ name: String, minimum: Double? = nil, maximum: Double? = nil, domain: Domain = .real) {
        guard !name.isEmpty, !name.contains(" ") else { return nil }
        if let min = minimum, let max = maximum, min > max { return nil }
        if domain == .binary, minimum != nil && minimum != 0 || maximum != nil && maximum != 1 { return nil }
        
        self.name = name
        self.minimum = domain == .binary && minimum == nil ? 0 : minimum
        self.maximum = domain == .binary && maximum == nil ? 1 : maximum
        self.domain = domain
    }
    
}


/**
 Linear functions are linear combinations of variables and Double factors and constants.
 They have the canonical format: a * x + b * y + ... + c, where:
    * a, b, ... represent double coefficients which may be omitted when 1;
    * the trailing double constant c may be omitted when 0.
    * x, y, ... represent variables.
 */
public struct LinearFunction {
    
    // Merge terms with same variable, keeping the order of terms.
    static private func mergeTerms(_ terms: [Term]) -> [Term] {
        guard terms.count > 1 else { return terms }
        let groupedTerms = OrderedDictionary<Variable, [Term]>(grouping: terms, by: (\.variable))
        
        return groupedTerms.values.map { terms in
            let factor = terms.reduce(0.0) { factor, term in factor + term.factor }
            
            return terms.first!.variable.withFactor(factor)
        }
    }
    
    /// A term is a variable multipled by a double factor (i.e. its coefficient).
    public struct Term {
        
        // MARK: Stored properties
        
        // The factor.
        // Default = 1.
        let factor: Double
        
        // The variable of a term.
        // When creating a linear function, terms with same variable are merged,
        // with the combined factor.
       let variable: Variable

        // MARK: Initializing
        
        /// Creates a term consisting of a variable with optional factor.
        public init(variable: Variable, factor: Double = 1) {
            self.factor = factor
            self.variable = variable
        }
        
    }
    
    // MARK: Stored properties
    
    // Terms of the linear function.
    // May be empty.
    let terms: [Term]
    
    // Minimal element of a linear function.
    let constant: Double
    
    // MARK: Initializing
    
    /// Creates linear function with given terms and constant.
    public init(terms: [Term], constant: Double = 0) {
        self.terms = Self.mergeTerms(terms)
        self.constant = constant
    }
    
}


/**
 Covenience functions to compose linear functions using basic arithmetic operators.
 */
public extension LinearFunction {
    
    // MARK: Building linear functions
    
    static func + (lhs: Self, rhs: Double) -> Self {
        LinearFunction(terms: lhs.terms, constant: lhs.constant + rhs)
    }
    
    static func + (lhs: Self, rhs: Term) -> Self {
        LinearFunction(terms: lhs.terms + [rhs], constant: lhs.constant)
    }
    
    static func + (lhs: Self, rhs: Variable) -> Self {
        LinearFunction(terms: lhs.terms + [rhs.withFactor(1)], constant: lhs.constant)
    }
    
    static func - (lhs: Self, rhs: Double) -> Self {
        LinearFunction(terms: lhs.terms, constant: lhs.constant - rhs)
    }
    
    static func - (lhs: Self, rhs: Term) -> Self {
        LinearFunction(terms: lhs.terms + [rhs.negated], constant: lhs.constant)
    }
    
    static func - (lhs: Self, rhs: Variable) -> Self {
        LinearFunction(terms: lhs.terms + [rhs.withFactor(-1)], constant: lhs.constant)
    }
    
}

/**
 Covenience functions to compose linear functions using basic arithmetic operators.
 */
public extension LinearFunction.Term {
    
    // MARK: Building linear functions
    
    static func + (lhs: Self, rhs: Double) -> LinearFunction {
        LinearFunction(terms: [lhs], constant: rhs)
    }
    
    static func + (lhs: Self, rhs: Self) -> LinearFunction {
        LinearFunction(terms: [lhs, rhs])
    }
    
    static func + (lhs: Self, rhs: Variable) -> LinearFunction {
        LinearFunction(terms: [lhs, rhs.withFactor(1)])
    }
    
    static func - (lhs: Self, rhs: Double) -> LinearFunction {
        LinearFunction(terms: [lhs], constant: -rhs)
    }
    
    static func - (lhs: Self, rhs: Self) -> LinearFunction {
        LinearFunction(terms: [lhs, rhs.negated])
    }
    
    static func - (lhs: Self, rhs: Variable) -> LinearFunction {
        LinearFunction(terms: [lhs, rhs.withFactor(-1)])
    }
    
    // MARK: Private building linear functions
    
    // Answers the term with negated factor.
    fileprivate var negated: Self {
        Self(variable: variable, factor: -factor)
    }
    
}


/**
 Covenience functions to compose linear functions using basic arithmetic operators.
 */
public extension Double {
    
    // MARK: Building linear functions
    
    static func * (lhs: Double, rhs: Variable) -> LinearFunction.Term {
        rhs.withFactor(lhs)
    }
     
}


/**
 Covenience functions to compose linear functions using basic arithmetic operators.
 */
public extension Variable {
    
    // MARK: Building linear functions
    
    static func + (lhs: Variable, rhs: Double) -> LinearFunction {
        LinearFunction(terms: [lhs.withFactor(1)], constant: rhs)
    }
     
    static func + (lhs: Variable, rhs: Variable) -> LinearFunction {
        LinearFunction(terms: [lhs.withFactor(1), rhs.withFactor(1)])
    }
     
    static func + (lhs: Variable, rhs: LinearFunction.Term) -> LinearFunction {
        LinearFunction(terms: [lhs.withFactor(1), rhs])
    }
    
    static func - (lhs: Variable, rhs: Double) -> LinearFunction {
        LinearFunction(terms: [lhs.withFactor(1)], constant: -rhs)
    }
     
    static func - (lhs: Variable, rhs: Variable) -> LinearFunction {
        LinearFunction(terms: [lhs.withFactor(1), rhs.withFactor(-1)])
    }
     
    static func - (lhs: Variable, rhs: LinearFunction.Term) -> LinearFunction {
        LinearFunction(terms: [lhs.withFactor(1), rhs.negated])
    }
    
    // MARK: Private building linear functions
    
    fileprivate func withFactor(_ factor: Double = 1) -> LinearFunction.Term {
        LinearFunction.Term(variable: self, factor: factor)
    }

}


/**
 Equatable extensions for variables and linear functions.
 */
extension Variable: Equatable, Hashable {}

extension LinearFunction.Term: Equatable {}

extension LinearFunction: Equatable {}
