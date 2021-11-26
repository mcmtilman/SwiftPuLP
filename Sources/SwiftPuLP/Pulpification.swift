//
//  Pulpification .swift
//
//  Created by Michel Tilman on 13/11/2021.
//  Copyright © 2021 Dotted.Pair.
//  Licensed under Apache License v2.0.
//

import PythonKit

/**
 PuLP expects only one Python LpVariable instance for every occurrence of the same Swift variable.
 The variable cache allows clients to create and cache new LpVariables if not yet present, otherwise the cached instance is returned.
 */
fileprivate class VariableCache {
    
    // MARK: -
    
    // Links variable instances to generated PuLP variables.
    private var cache = [Variable: PythonObject]()
    
    // MARK: -
    
    // Answers the cached PuLP LpVariable.
    // If none is found, generates a new one and caches it.
    fileprivate subscript(key: Variable, default defaultValue: @autoclosure () -> PythonObject) -> PythonObject {
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
 Converting a Variable into a Python (PuLP) object.
 */
extension Variable: PythonConvertible {
    
    // MARK: -
    
    /// Converts the variable into a LpVariable PythonObject.
    public var pythonObject: PythonObject {
        PuLP.LpVariable(name: name, lowBound: minimum, upBound: maximum, cat: domain.pythonObject)
    }
    
    // MARK: -

    /// Converts the variable into a LpVariable PythonObject, optionally caching variables.
    fileprivate func pythonObject(withCache cache: VariableCache?) -> PythonObject {
        guard let cache = cache else { return pythonObject }

        return cache[self, default: pythonObject]
    }
    
}


// MARK: -

/**
 Converting a Variable.Domain into a Python (PuLP) object.
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


// MARK: -

/**
 Converting a LinearFunction into a Python (PuLP) object.
 */
extension LinearFunction: PythonConvertible {

    // MARK: -
    
    /// Converts the linear function into a LpAffineExpression PythonObject.
    public var pythonObject: PythonObject {
        pythonObject(withCache: nil)
    }

    // MARK: -
    
    /// Converts the function into a LpAffineExpression PythonObject, optionally caching variables.
    fileprivate func pythonObject(withCache cache: VariableCache?) -> PythonObject {
        func pythonTuple(_ term: Term) -> PythonObject {
            PythonObject(tupleOf: term.variable.pythonObject(withCache: cache), term.factor)
        }
        
        return PuLP.LpAffineExpression(terms.map(pythonTuple), constant: constant)
    }
    
}


// MARK: -

/**
 Converting a LinearConstraint into a Python (PuLP) object.
 */
extension LinearConstraint: PythonConvertible {
    
    // MARK: -
    
    /// Converts the linear constraint into a LpConstraint PythonObject.
    public var pythonObject: PythonObject {
        pythonObject(withCache: nil)
    }
    
    // MARK: -
    
    /// Converts the constraint into a LpConstraint PythonObject, optionally caching variables.
    fileprivate func pythonObject(withCache cache: VariableCache?) -> PythonObject {
        PuLP.LpConstraint(function.pythonObject(withCache: cache), sense: comparison, rhs: constant)
    }
        
}


// MARK: -

/**
 Converting a LinearConstraint.Comparison into a Python (PuLP) object.
 */
extension LinearConstraint.Comparison: PythonConvertible {

    // MARK: -
    
    /// Converts the comparison into a PuLP comparison.
    public var pythonObject: PythonObject {
        switch self {
        case .lte:
            return PuLP.LpConstraintLE
        case .eq:
            return PuLP.LpConstraintEQ
        case .gte:
            return PuLP.LpConstraintGE
        }
    }
    
}


// MARK: -

/**
 Converting a Model into a Python (PuLP) object.
 */
extension Model: PythonConvertible {
    
    // MARK: -
    
    /// Converts the model into a LpProblem PythonObject.
    ///
    /// Caches the first generated LpVariable PythonObject per Variable.
    public var pythonObject: PythonObject {
        var problem = PuLP.LpProblem(name: name, sense: optimization) // set sense, even without an objective.
        let cache = VariableCache()
        
        if let objective = objective {
            problem += objective.pythonObject(withCache: cache)
        }
        for (constraint, name) in constraints {
            problem += PythonObject(tupleOf: constraint.pythonObject(withCache: cache), name)
        }
        
        return problem
    }
        
}


// MARK: -

/**
 Converting a Model.Optimization into a Python (PuLP) object.
 */
extension Model.Optimization: PythonConvertible {

    // MARK: -
    
    /// Converts the optimization into a PuLP 'sense'.
    public var pythonObject: PythonObject {
        switch self {
        case .maximize:
            return PuLP.LpMaximize
        case .minimize:
            return PuLP.LpMinimize
        }
    }

}
