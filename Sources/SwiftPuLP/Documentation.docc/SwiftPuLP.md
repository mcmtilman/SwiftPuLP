# ``SwiftPuLP``

SwiftPuLP wraps the Python Linear Programming PuLP module, using a similar style to create and solve models.

## Overview

Solving a Linear Programming consists of creating a model of the problem using variables, linear functions and constraints, solving this model and returning a result.

### Core model

The building blocks of the core model are:

- term **Variable**:
    A ``Variable`` has a unique name, a domain, and optional minimum and maximum bounds.
    
    A ``Variable/Domain`` specifies a range of values (real, integer or binary), subject to optional lower and upper bounds restrictions.

    See <doc:UsingVariables>.

- term **Linear function**:
    A ``LinearFunction`` represents a linear combination of zero or more variables, i.e. it has a canonical form like *a \* x + b \* y + c*, where x and y represent variables, a and b are the coefficients and c is the constant.

    A ``LinearFunction/Term`` refers to a variable with its factor.

    See <doc:UsingLinearFunctions>.

- term **Constraint**:
    A ``LinearConstraint`` compares a linear function with a constant.

    The ``LinearConstraint/Comparison`` operators include: less than or equal to, equal to, greater than or equal to.

    See <doc:UsingLinearConstraints>.

- term **Model**:
    A ``Model`` has an optional ``Model/Objective``, which specifies a linear function and an optimization goal. A model may also specify zero or more linear constraints.

    The ``Model/Optimization`` goals include: minimize and maximize.

    See <doc:UsingModels>.

- term **Solver**:
    A ``Solver`` computes the best values for the decision variables based on the model's objective and constraints.

    The solver returns an optional ``Solver/Result`` with a ``Solver/Status`` and a dictionary of variable name - value pairs.

    See <doc:UsingSolvers>.

## Helper functions

The ``Function`` enum provdes helper functions.

### Creating linear functions

* The ``Function/sum(_:)`` function converts a sequence of variables into a linear function summing the variables.

## Topics

### <!--@START_MENU_TOKEN@-->Group<!--@END_MENU_TOKEN@-->

- <!--@START_MENU_TOKEN@-->``Symbol``<!--@END_MENU_TOKEN@-->
