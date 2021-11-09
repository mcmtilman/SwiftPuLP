# ``SwiftPuLP``

SwiftPuLP wraps the Python Linear Programming PuLP module, using a similar style to create and solve models.

## Overview

Solving a Linear Programming consists of creating a model of the problem using variables, linear functions and constraints, solving this model and returning a result.

The building blocks of the core model are:

* ``Variable``, having a unique name, a domain, and optional minimum and maximum bounds. A domain specifies a range of values, subject to optional lower and upper bounds restrictions.

* ``LinearFunction``, summing zero or more variables, each weighted with a factor (aka coefficient), and a constant.

* ``LinearConstraint``, comparing a linear function with a constant (less than or equal to, equal to, greather than or equal to).

* The ``Model``, consisting of an optional *Objective* (a linear function and an optimization goal: minimize or maximize) and zero or more linear constraints.

* The ``Solver``, using the default solver from PuLP, realizes the model's objective and return an optional result with a status a dictionary of variable name - value pairs.

### Variable

To create a variable use the following public initializer.

    init(_ name: String, minimum: Double? = nil, maximum: Double? = nil, domain: Domain = .real)

#### Examples

1. Create a continuous variable named *x* without lower and upper bounds.

        let x = Variable("x")

2. Create a list of 100 binary variables named *x_0* through *x_99*.

        let x = (0..<100).map { Variable("x_\($0)", domain: .binary) }

### LinearFunction

To create a linear function use one of the following public initializers.

    init(terms: [Term], constant: Double = 0)
    
    init(variable: Variable)

Create a term as follows.

    Term(variable: Variable, factor: Double = 1)

#### Use arithmethic operators to build a linear function

Arithmetic operators may be used in a more intuitive way to build linear functions, and parentheses may be used to alter precedence. In the following examples x, y, z represent variables.

    +x

    1 * x
    
    x + 0
    
    0 * x + 10
    
    -x + 10
    
    2 * x + 3 * y + z - 10
    
    2 * x - 3 * (y + z - x - 10)

*Normalizing* the last function results in the following expression.

    5 * x - 3 * y - 3 * z + 30

### LinearConstraint

A Linear Constraint imposes a restriction by comparing a linear function with a constant, where the comparison can be:

* less than or equal to
* equal to
* greater than or equal to.

To create a constraint use on of the following public initializers.

    init(function: LinearFunction, comparison: Comparison = .eq, constant: Double = 0)
    
    init(variable: Variable, comparison: Comparison = .eq, constant: Double = 0)
    
#### Use arithmethic and comparison operators to build a linear constraint

Arithmetic and comparison operators may be used in a more intuitive way to build linear constraints, as illustrated by the following examples.

    x <= 20
    
    4 * x - 5 * y >= -10
    
### Model

A model represents an LP problem to be solved by one of the solvers supported by PuLP.
The model has an optional *Objective*, consisting of a linear function and an optimization goal.

In addition, the model takes 0 or more labeled constraints.

To create a model use the following public initializer.

    init(_ name: String, objective: Objective? = nil, constraints: [(constraint: LinearConstraint, name: String)]

Each constraint is associated with a label, which may be empty.

#### Objective

To create an objective use one of the following public initializers.

    init(_ function: LinearFunction, optimization: Optimization = .minimize)
    
    init(_ variable: Variable, optimization: Optimization = .minimize)
    
#### Invalid models

A variable is not valid if:

* the variable's name is empty or contains any of the following characters: *-+[] ->/*;
* a non-nil minimum value exceeds a non-nil maximum value;
* in case of a binary domain, the mimimum value is not nil or 0, or the maximum value is not nil or 1.

A model is not valid if:

* the model's name contains spaces;
* its objective function and constraints use invalid variables or distinct variables with the same name
* it uses multiple constraints with the same label.

#### Validating a model

To validate a model use the following.

    let model = ...    
    let errors = model.validationErrors    

This property returns a list of ``ValidationError``.

#### Example of a valid model

The following example creates a simple valid model.

    let (x, y) = (Variable("x"), Variable("y"))    
    let function = x + 2 * y    
    let objective = Objective(function, optimization: .maximize)    
    let constraints = [    
        (2 * x + y <= 20, "red"),        
        (4 * x - 5 * y >= -10, "blue"),        
        (-x + 2 * y >= -2, "yellow"),        
        (-x + 5 * y == 15, "green")        
    ]    
    let model = Model("Basic", objective: objective, constraints: constraints)

### Solver

The Solver uses the default PuLP solver, disabling logging of messages to standard output by default.

The solve a model use the following method.

    func solve(_ model: Model) -> Result?

This method returns a result when it can convert the status and variable bindings in the LpProblem. Otherwise nil is returned.

#### Result

A solver result contains a *Status* and a list of values for each resolved variable name.

## Helper functions

The **Function** enum contains helper functions.

* The *sum* function converts a sequence of variables into a linear function summing the variables.
    
## Topics

### <!--@START_MENU_TOKEN@-->Group<!--@END_MENU_TOKEN@-->

- <!--@START_MENU_TOKEN@-->``Symbol``<!--@END_MENU_TOKEN@-->
