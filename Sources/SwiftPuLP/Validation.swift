//
//  Validation.swift
//  
//  Created by Michel Tilman on 31/10/2021.
//  Copyright © 2021 Dotted.Pair.
//  Licensed under Apache License v2.0.
//

import Foundation

/**
 Single validation error, such as an invalid variable name or a duplicate constraint name.
 Each error identifies the model element in error and the reason for the error.
 */
public enum ValidationError {
    
    case duplicateConstraintName(LinearConstraint, String)
    case invalidModelName(Model)
    case duplicateVariableName(Variable)
    case emptyVariableName(Variable)
    case invalidVariableBounds(Variable)
    case invalidVariableName(Variable)

}


/**
 Utility protocol for collecting validation errors, avoids using global function.
 */
protocol Validating {}

extension Validating {
  
    func validate(_ updateErrors: (inout [ValidationError]) -> ()) -> [ValidationError] {
        var errors = [ValidationError]()
        
        updateErrors(&errors)
        
        return errors
    }
    
}


/**
 Variable adopts the validation protocol.
 */
extension Variable: Validating {
    
    // MARK: Constants
    
    // Characters in this set may not be used in variable names.
    static let specialChars = CharacterSet(charactersIn: "-+[] ->/")
    
    // MARK: Computed properties
    
    /// Returns validation errors.
    public var validationErrors: [ValidationError] {
        validate(self.collectErrors)
    }
    
    // MARK: Validating

    // Generates errors for:
    // - Empty names or names containing one or more special characters.
    // - Invalid bounds / domain combinations.
    func collectErrors(into errors: inout [ValidationError]) {
        if name.isEmpty {
            errors.append(.emptyVariableName(self))
        }
        if !CharacterSet(charactersIn: name).isDisjoint(with: Self.specialChars) {     errors.append(.invalidVariableName(self))
        }
        if let min = minimum, let max = maximum, min > max {
            errors.append(.invalidVariableBounds(self))
        }
        else if domain == .binary, minimum ?? 0 != 0 {
            errors.append(.invalidVariableBounds(self))
        }
        else if domain == .binary, maximum ?? 1 != 1 {
            errors.append(.invalidVariableBounds(self))
        }
    }
    
}


/**
 LinearFunction adopts the validation protocol, delegating responsibility to its tem variables.
 */
extension LinearFunction {
    
    // MARK: Validating
    
    // Collects the term variables.
    func collectVariables(into variables: inout [ObjectIdentifier: Variable]) {
        for term in terms {
            variables[ObjectIdentifier(term.variable)] = term.variable
        }
    }
    
}


/**
 LinearConstraint adopts the validation protocol, delegating responsibility to its function,
 */
extension LinearConstraint {
    
    // MARK: Validating
    
    // Delegates collection of variables to the linear function.
    func collectVariables(into variables: inout [ObjectIdentifier: Variable]) {
        function.collectVariables(into: &variables)
    }

}


/**
 Model adopts the validation protocol, delegating some responsibility to its objective function and constraints.
 Additionally the model is responsible for detecting name conflicts in the variables and in the constraints.
 */
extension Model: Validating {
    
    // MARK: Validating
    
    // MARK: Computed properties

    /// Returns validation errors.
    public var validationErrors: [ValidationError] {
        validate(self.collectErrors)
    }
    
    // MARK: Validating
    
    // Collects all errors from its nested elements and verifies that variable / constraint names are unique.
    func collectErrors(into errors: inout [ValidationError]) {
        if name.contains(" ") {
            errors.append(.invalidModelName(self))
        }
        collectConstraintErrors(into: &errors)
        collectVariableErrors(into: &errors)
    }
    
    // Verifies that distinct constraints have different names.
    func collectConstraintErrors(into errors: inout [ValidationError]) {
        var constraintMap = [String: LinearConstraint]()
        
       for (constraint, name) in constraints {
            if !name.isEmpty, constraintMap.updateValue(constraint, forKey: name) != nil {
                errors.append(.duplicateConstraintName(constraint, name))
            }
        }
    }
    
    // Verifies that variables are valid and that distinct variables have different names.
    func collectVariableErrors(into errors: inout [ValidationError]) {
        var variables = [ObjectIdentifier: Variable]()
        var variableMap = [String: Variable]()

        collectVariables(into: &variables)
        for variable in variables.values {
            variable.collectErrors(into: &errors)
            if !name.isEmpty, variableMap.updateValue(variable, forKey: variable.name) != nil {
                errors.append(.duplicateVariableName(variable))
            }
        }
    }
    
    // Collects all unique variables from its nested elements.
    func collectVariables(into variables: inout [ObjectIdentifier: Variable]) {
        objective?.function.collectVariables(into: &variables)
        for (constraint, _) in constraints {
            constraint.collectVariables(into: &variables)
        }
    }

}


/**
 ValidationError adopts Equatable.
 */
extension ValidationError: Equatable {}
