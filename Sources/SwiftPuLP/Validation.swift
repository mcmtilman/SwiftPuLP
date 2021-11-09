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
 An error identifies the model element in error, and, if necessary, more details.
 */
public enum ValidationError {
    
    case duplicateConstraintName(LinearConstraint, String)
    case invalidModelName(Model)
    case duplicateVariableName(Variable)
    case emptyVariableName(Variable)
    case invalidVariableBounds(Variable)
    case invalidVariableName(Variable)

}


// MARK: - Validating -

/**
 Variable supports validation.
 */
extension Variable {
    
    // MARK: -
    
    // Characters in this set may not be used in variable names.
    static let specialChars = CharacterSet(charactersIn: "-+[] ->/")
    
    /// Returns validation errors.
    /// If not empty, the PuLP solver may fail.
    ///
    /// Does not return validation errors related to other variables, such as duplicate name errors.
    public var validationErrors: [ValidationError] {
        var errors = [ValidationError]()
        
        collectErrors(into: &errors)
        
        return errors
    }
    
    // MARK: -

    // Generates errors for:
    // - Empty names or names containing one or more special characters.
    // - Invalid bounds / domain combinations.
    func collectErrors(into errors: inout [ValidationError]) {
        if name.isEmpty {
            errors.append(.emptyVariableName(self))
        }
        else if !CharacterSet(charactersIn: name).isDisjoint(with: Self.specialChars) {
            errors.append(.invalidVariableName(self))
        }
        if let min = minimum, let max = maximum, min > max {
            errors.append(.invalidVariableBounds(self))
        }
        else if domain == .binary, minimum ?? 0 != 0 || maximum ?? 1 != 1 {
            errors.append(.invalidVariableBounds(self))
        }
    }
    
}


// MARK: -

/**
 LinearFunction supports validation.
 */
extension LinearFunction {
    
    // MARK: -
    
    // Collects the term variables.
    func collectVariables(into variables: inout [Variable.Id: Variable]) {
        for term in terms {
            variables[term.variable.id] = term.variable
        }
    }
    
}


// MARK: -

/**
 LinearConstraint supports validation,
 */
extension LinearConstraint {
    
    // MARK: -
    
    // Delegates collection of variables to the linear function.
    func collectVariables(into variables: inout [Variable.Id: Variable]) {
        function.collectVariables(into: &variables)
    }

}


// MARK: -

/**
 Model supports validation, delegating variable validation to its objective function and constraints.
 Additionally the model is responsible for detecting name conflicts in the variables and in the constraints.
 */
extension Model {
    
    // MARK: -

    /// Returns validation errors.
    /// If not empty, the PuLP solver may fail.
    public var validationErrors: [ValidationError] {
        var errors = [ValidationError]()
        
        collectErrors(into: &errors)
        
        return errors
    }
    
    // MARK: -
    
    // Collects all errors from its nested elements and verifies that variable / constraint names are unique.
    func collectErrors(into errors: inout [ValidationError]) {
        if name.contains(" ") {
            errors.append(.invalidModelName(self))
        }
        collectVariableErrors(into: &errors)
        collectConstraintErrors(into: &errors)
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
        var variables = [Variable.Id: Variable]()
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
    func collectVariables(into variables: inout [Variable.Id: Variable]) {
        objective?.function.collectVariables(into: &variables)
        for (constraint, _) in constraints {
            constraint.collectVariables(into: &variables)
        }
    }

}


// MARK: - Equatable -

/**
 ValidationError adopts Equatable.
 */
extension ValidationError: Equatable {}
