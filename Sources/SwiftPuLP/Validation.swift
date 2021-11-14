//
//  Validation.swift
//  
//  Created by Michel Tilman on 31/10/2021.
//  Copyright © 2021 Dotted.Pair.
//  Licensed under Apache License v2.0.
//

import Foundation
import Collections

/**
 Single validation error, such as an invalid variable name or a duplicate constraint name.
 An error specifies the model element in error, and, if necessary, includes extra details.
 
 Validation of a ``Variable`` or ``Model``is not performed automatically upon creation time.
 To check if a variable or a model has validation errors use property **validationErrors**.
 */
public enum ValidationError {
    
    /// The model has multiple constraints with the same non-empty label.
    /// The additional associated value identifies the offending constraint label.
    case duplicateConstraintName(LinearConstraint, String)
    
    /// The model has multiple variables with the same name.
    case duplicateVariableName(Variable)

    /// The model name contains spaces.
    case invalidModelName(Model)

    /// The variable has invalid bounds / domain combinations.
    case invalidVariableBounds(Variable)
 
    /// The variable name is empty or contains invalid characters.
    case invalidVariableName(Variable)

}


// MARK: - Validating -

/**
 Validating a single variable.
 */
extension Variable {
    
    // MARK: -
    
    /// Characters in this set may not be used in variable names.
    static let specialChars = CharacterSet(charactersIn: "-+[] ->/")
    
    /// Returns validation errors.
    /// 
    /// If not empty, the PuLP solver may fail.
    public var validationErrors: [ValidationError] {
        var errors = [ValidationError]()
        
        collectErrors(into: &errors)
        
        return errors
    }
    
    // MARK: -

    // Collects errors for this variable.
    //
    // Generates errors for:
    // - Empty names or names containing one or more special characters.
    // - Invalid bounds / domain combinations.
    fileprivate func collectErrors(into errors: inout [ValidationError]) {
        if name.isEmpty {
            errors.append(.invalidVariableName(self))
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
 Validating a linear function.
 */
extension LinearFunction {
    
    // MARK: -
    
    // Collects the different variables used in the function.
    fileprivate func collectVariables(into variables: inout OrderedSet<Variable>) {
        for term in terms {
            variables.append(term.variable)
        }
    }
    
}


// MARK: -

/**
 Validating a linear constraint.
 */
extension LinearConstraint {
    
    // MARK: -
    
    // Delegates collection of variables to the linear function.
    fileprivate func collectVariables(into variables: inout OrderedSet<Variable>) {
        function.collectVariables(into: &variables)
    }

}


// MARK: -

/**
 Model supports validation. Delegates variable validation to its objective function and constraints.
 Additionally the model detects name conflicts in variables and in constraints.
 */
extension Model {
    
    // MARK: -

    /// Returns validation errors.
    ///
    /// If not empty, the PuLP solver may fail.
    public var validationErrors: [ValidationError] {
        var errors = [ValidationError]()
        
        collectErrors(into: &errors)
        
        return errors
    }
    
    // MARK: -
    
    // Validates name correctnes, collects errors from nested elements and verifies that variable names respectively constraint labels are unique in this model.
    fileprivate func collectErrors(into errors: inout [ValidationError]) {
        if name.contains(" ") {
            errors.append(.invalidModelName(self))
        }
        collectVariableErrors(into: &errors)
        collectConstraintErrors(into: &errors)
    }
    
    // Verifies that distinct constraints have empty or different labels.
    fileprivate func collectConstraintErrors(into errors: inout [ValidationError]) {
        var names = Set<String>()
        
        for (constraint, name) in constraints {
            if !name.isEmpty, !names.insert(name).inserted {
                errors.append(.duplicateConstraintName(constraint, name))
            }
        }
    }
    
    // Verifies that variables are valid and that distinct variables have different names.
    fileprivate func collectVariableErrors(into errors: inout [ValidationError]) {
        var variables = OrderedSet<Variable>()
        var names = Set<String>()

        collectVariables(into: &variables)
        for variable in variables {
            variable.collectErrors(into: &errors)
            if !name.isEmpty, !names.insert(variable.name).inserted {
                errors.append(.duplicateVariableName(variable))
            }
        }
    }
    
    // Collects all unique variables from nested elements.
    fileprivate func collectVariables(into variables: inout OrderedSet<Variable>) {
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
