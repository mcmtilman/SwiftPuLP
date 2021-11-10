# Using a solver

<!--@START_MENU_TOKEN@-->Summary<!--@END_MENU_TOKEN@-->

## Overview

### Solver

The Solver uses the default PuLP solver, disabling logging of messages to standard output by default.

The solve a model use the following method.

    func solve(_ model: Model) -> Result?

This method returns a result when it can convert the status and variable bindings in the LpProblem. Otherwise nil is returned.

#### Result

A solver result contains a *Status* and a list of values for each resolved variable name.

## Integration with PuLP

The solver converts the Swift model into PuLP objects using *PythonKit*, according to the following mapping.

    Variable -> LpVariable
    
    Variable.Domain -> LpContinuous | LpInteger | LpBinary
    
    LinearFunction -> LpAffineExpression
    
    LinearConstraint -> LpConstraint
    
    Model -> LpProblem
    
    Objective.Optimization -> LpMinimize | LpMaximize

The solver requests PuLP to solve the constructed LpProblem and builds a result from data extracted from the updated problem.

    LpStatusNotSolved | LpStatusOptimal | LpStatusInfeasible | LpStatusUnbounded | LpStatusUndefined -> Solver.Status
    
    LpProblem variables -> Dictionary with key = variable name, value = variable value



## Topics

### <!--@START_MENU_TOKEN@-->Group<!--@END_MENU_TOKEN@-->

- <!--@START_MENU_TOKEN@-->``Symbol``<!--@END_MENU_TOKEN@-->
