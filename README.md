# SwiftPuLP

SwiftPuLP wraps the Python Linear Programming PuLP module, using a similar style to create and solve models.

## Core model

The building blocks are:

* **Variable**, having a unique name, a domain, and optional minimum and maximum bounds.

* **LinearFunction**, summing zero or more variables, each weighted with a factor (aka coefficient), and a constant.

* **LinearConstraint**, comparing a linear function with a constant (less than or equal to, equal to or greather than or equal to).

* The **Model**, consisting of an optional *Objective* (a linear function and an optimization goal: minimize or maximize) and zero or more linear constraints.

* The **Solver**, using the default solver from PuLP to realize the model's objective and return an optional *Result* with a status and a dictionary of variable - value pairs.

### Variable

To create a variable use the following public initializer.

    init(_ name: String, minimum: Double? = nil, maximum: Double? = nil, domain: Domain = .real)

*Domain* is defined as follows.

    public enum Domain {

        case binary, real, integer

    }

The real domain corresponds *continuous* variables in PuLP.

#### Invalid variables

The variable is not valid if:

* the variable's name is empty or contains any of the following characters: *-+[] ->/*;
* a non-nil minimum value exceeds a non-nil maximum value;
* in case of a binary domain, the mimimum value is not nil or 0, or the maximum value is not nil or 1.

#### Examples

1. Create a continuous variable named *x* without lower and upper bounds.

        let x = Variable("x")

2. Create a list of 100 binary variables named *x_0* through *x_99*.

        let x = (0..<100).map { Variable("x_\($0)", domain: .binary) }

### LinearFunction

A linear function is a linear combination of zero or more weighted variables (aka *terms*))and an optional constant. The most basic cases consist of:

* a single variable without coefficient
* a single constant.

#### Examples of linear functions

1. A variable x.

    x

2. A constant c.

    10

3. A variable x with coefficient and a constant.

    2 * x + 10

4. Multiple weighted variables and a constant.

    2 * x + 3 * y + 10

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
    
    2 * x - 3 * (y + z - 10)

The LinearFunction initializer normalizes the last function as follows.

    2 * x - 3 * y - 3 * z + 30

Note that coefficients must be placed to the left of variables and nested linear functions.

Also note that the compiler does not recognize the following constructs as linear functions.

    x
    
    10

The compiler may also get confused when using sums of multiple variables.

    x + y + z
    
This does not work, so a little help is needed.

    x + y + z + 0
    
    1 * x + y + z
    
    +x + y + z

### LinearConstraint

A Linear Constraint imposes a restriction by comparing a linear function with a constant, where the comparison can be:

* less than or equal to
* equal to
* greater than or equal to.

To create a constraint use on of the following public initializers.

    init(function: LinearFunction, comparison: Comparison = .eq, constant: Double = 0)
    
    init(variable: Variable, comparison: Comparison = .eq, constant: Double = 0)
    
*Comparison* is defined as follows.

    public enum Comparison {
        
        case lte, eq, gte
        
    }

#### Use arithmethic and comparison operators to build a linear constraint

Arithmetic and comparison operators may be used in a more intuitive way to build linear constraints, as illustrated in the following examples.

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
    
*Optimization* is defined as follows.

    public enum Optimization {
        
        case minimize, maximize
        
    }

#### Invalid models

A model is not valid if:

* the variable's name contains spaces;
* its objective function and constraints use invalid variables or distinct variables with the same name
* it uses multiple constraints with the same label.

#### Example

The following example illustrates how to create a simple valid model.

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

The Solver takes no parameters and uses the default PuLP solver, disabling logging of messages to standard output.

The solve a model use the following method.

    func solve(_ model: Model) -> Result?

This method returns a result when it can convert the status and variable bindings in the LpProblem. Otherwise nil is returned.

#### Result

A solver result contains a *Status* and a list of values for each resolved variable name.

The status cases mirror the status values in PuLP and are defined as follows.

    public enum Status: Double {
        
        case unsolved = 0
        case optimal = 1
        case infeasible = -1
        case unbounded = -2
        case undefined = -3

    }

## Validating a model

### Validating the complete model

To validate a model use the following.

    let model = ...    
    let errors = model.validationErrors    
    ...

This property returns a list of all *validation errors*. Currently SwiftPuLP supports the following validation errors.

    public enum ValidationError {   
     
        case duplicateConstraintName(LinearConstraint, String)
        case invalidModelName(Model)
        case duplicateVariableName(Variable)
        case emptyVariableName(Variable)
        case invalidVariableBounds(Variable)
        case invalidVariableName(Variable)
        
    }

### Validating a single variable

To validate an individual variable use a similar approach.

    let variable = ...    
    let errors = variable.validationErrors    
    ...

## Type overview

    Variable
    
    Variable.Domain
    
    LinearFunction
    
    LinearFunction.Term
        
    LinearConstraint
    
    LinearConstraint.Comparison
    
    Model
    
    Model.Objective
    
    Model.Optimization
    
    Solver
    
    Solver.Status
    
    Solver.Result
    
## Helper functions

The **Function** enum contains helper functions.

* The *sum* function converts a sequence of variables into a linear function summing the variables.
    
## Conversion to / from PuLP

The Swift data structures are converted into PuLP objects using PythonKit (cf. the *PythonConvertible* protocol), according to the following mapping.

    Variable -> LpVariable
    
    Variable.Domain -> LpContinuous | LpInteger | LpBinary
    
    LinearFunction -> LpAffineExpression
    
    LinearConstraint -> LpConstraint
    
    Model -> LpProblem
    
    Objective.Optimization -> LpMinimize | LpMaximize

The solver requests PuLP to solve the constructed LpProblem and builds a result from data extracted from the updated problem (cf. the *ConvertibleFromPython* protocol).

    LpStatusNotSolved | LpStatusOptimal | LpStatusInfeasible | LpStatusUnbounded | LpStatusUndefined -> Solver.Status
    
    LpProblem variables -> Dictionary with key = variable name, value = variable value

### Generating a unique LpVariable instance for each variable

The Python counterparts of the Swift model elements are generated when the solver tries to solve the model. Since a given variable may occur multiple times in the objective function and / or one or more constraints, this may result in multiple LpVariable instances being generated for each distinct Swift variable. Converting variables into Python relies on a variable cache to keep track of the Python object generated for each new variable encountered.

#### Examples

In the following scenario only one LpVariable instance will be generated, since y is an alias for x.

    let x = Variable("x")
    let y = x

In the following case, however, PuLP may still run into problems.

    let (x, y) = (Variable("x"), Variable("x", domain: .integer))

Each variable here is mapped onto a different Python LpVariable with the same name. Validation of this model returns a duplicate variable name error.

## Examples

### Example 1: Solving a sudoku

Based on the [The Sudoku Problem Formulation for the PuLP Modeller](https://coin-or.github.io/pulp/CaseStudies/a_sudoku_problem.html).

    Authors: Antony Phillips, Dr Stuart Mitchell
    edited by Nathan Sudermann-Merx

The Swift model can be found in *SudokuTests*. It closely mirrors the PuLP model. It has no objective function, and only binary constraints.

#### Analysis

Much of the code is similar (apart from some refactoring to make it more testable), except for a few points.

1. In the Python example the 'boxes' variable is created by list comprehension with 4 'for' variables.

        Boxes = [    
            [(3 * i + k + 1, 3 * j + l + 1) for k in range(3) for l in range(3)]
            for i in range(3)
            for j in range(3)
        ]

    This is both concise and readable: variables 'i' and 'j' identify a box in the sudoku grid, while variables 'k' and 'l' identify cells within the boxes.
    
    Attempting to mirror this declaratively in Swift yields something like this (using zero-based coordinates).
    
        (0...2).flatMap { i in (0...2).map { j in (i, j) }}.map { (i, j) in
            (0...2).flatMap { k in (0...2).map { l in (3 * i + k, 3 * j + l) }}
        }
    
    A simpler variant is the one used in SudokuTests.    
    
        (0...8).map { r in
            (0...8).map { c in
                (r / 3 * 3 + c / 3, r % 3 * 3 + c % 3) 
            } 
        }
    
    Support in Swift for iterating over multi-dimensional ranges might be another option.
    
        let ranges = (0...2) * (0...2)  
        let boxes = ranges.map { i, j in ranges.map { k, l in (3 * i + k, 3 * j + l) }}


2. The 'choices' variable in Python is created using a utility class method on LpVariable.

        choices = LpVariable.dicts("Choice", (VALS, ROWS, COLS), cat="Binary")
 
## Dependencies

SwiftPulp depends on the *Collections* and *PythonKit* packages.

## Requirements

SwiftPulp needs PuLP to be installed and may require the PYTHON_LIBRARY environment variable to be set.

## Compatibility

SwiftPulp was tested on macOS Big Sur 11.6 with XCode 13.1, Python 3.9.7 and PuLP 2.5.1.

## Status

Work in progress, but able to run some simple optimization problems.
