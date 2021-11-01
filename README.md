# SwiftPuLP

SwiftPuLP wraps the Python Linear Programming PuLP module, using a similar style to create and solve models.

## Core model

The building blocks are:

* **Variable**, having a unique name, a domain, and optional minimum and maximum bounds.

* **LinearFunction**, summing zero or more variables, each weighted with a factor (aka coefficient), and a constant.

* **LinearConstraint**, comparing a linear function with a constant (less than or equal to, equal to or greather than or equal to).

* The **Model**, consisting of an optional **Objective** (a linear function and an optimization goal: minimize or maximize) and zero or more linear constraints.

* The **Solver**, using the default solver from PuLP to optimize the model's objective and return an optional **Result** with a status and a dictionary of variable - value pairs.

### Variable

To create a variable use the following public initializer.

    init(_ name: String, minimum: Double? = nil, maximum: Double? = nil, domain: Domain = .real)

Here **Variable.Domain** is defined as:

    public enum Domain {

        case binary, real, integer

    }

#### Invalid variables

The variable is not valid if:

* the variable's name is empty or contains any of the following characters: *-+[] ->/*;
* a non-nil minimum value exceeds a non-nil maximum value;
* in case of a binary domain, the mimimum value is not nil or 0, and the maximum value is not nil or 1.

#### Examples

1. Create a continuous variable named *x* without lower or upper bounds.

        let x = Variable("x")

2. Create a list of 100 binary variables named *x_0* through *x_99*.

        let x = (0..<100).map { Variable("x_\($0)", domain: .binary) }

### LinearFunction

A LinearFunction is a linear combination of zero or more weighted variables and an optional constant. The most basic cases consist of:

* a single variable without coefficient
* a single constant.

#### Examples of linear functions

1. A variable x

    x

2. A constant c

    10

3. A variable x with coefficient + a constant

    2 * x + 10

4. Multiple coefficient - variables pairs + a constant

    2 * x + 3 * y + 10

Internally a linear function consists of zero or more coefficient - variable pairs (aka *terms*) and a constant.

To create a linear function use one of the following public initializers.

    init(terms: [LinearFunction.Term], constant: Double = 0)
    
    init(variable: Variable)

Create a term as follows.

    LinearFunction.Term(variable: Variable, factor: Double = 1)

#### Use arithmethic operators to build a linear function

Arithmetic operators may be used in a more intuitive way to build linear functions, and parentheses may be used to alter precedence. In the following examples x, y, z represent variables.

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

### LinearConstraint

A **LinearConstraint** imposes a restriction by comparing a linear function with a constant, where comparison can be:

* less than or equal to
* equal to
* greater than or equal to.

To create a constraint use on of the following public initializers.

    init(function: LinearFunction, comparison: Comparison = .eq, constant: Double = 0)
    
    init(variable: Variable, comparison: Comparison = .eq, constant: Double = 0)
    
Here **LinearConstraint.Comparison** is defined as:

    public enum Comparison {
        
        case lte, eq, gte
        
    }

#### Use arithmethic and comparison operators to build a linear constraint

Arithmetic and comparison operators may be used in a more intuitive way to build linear constraints, as illustrated in the following examples.

    x <= 20
    
    4 * x - 5 * y >= -10
    
### Model

A model represents an LP problem to be solved by one of the solvers supported by PuLP.
The model has an optional objective, consisting of a linear function and an optimization goal, where the optimization is one of:

    .minimize
    
    .maximize

In addition, the model takes 0 or more labeled constraints.

To create a model use the following public initializer.

    init(_ name: String, objective: Objective? = nil, constraints: [(constraint: LinearConstraint, name: String)]

Each constraint is associated here with a label, which may be empty.

#### Objective

To create an objective use one of the following public initializers.

    init(_ function: LinearFunction, optimization: Optimization = .minimize)
    
    init(_ variable: Variable, optimization: Optimization = .minimize)
    

#### Invalid models

A model is not valid if:

* the variable's name contains spaces;
* its objective function and constraints use invalid variables or distinct variables with the same name
* it uses multiple constraints with the same name.

#### Example

The following example shows how to create a simple valid model.

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

The **Solver** takes no parameters and uses the default PuLP solver, while disabling logging of messages to standard output.

The solve a model use the following method.

    func solve(_ model: Model) -> Result?

This method returns a **Solver.Result** when it can convert the relevant data in an LpProblem. Otherwise nil is returned.

#### Result

A solver result contains a **Solver.Status** and a list of values for each resolved variable.

The status cases mirror the status values in PuLP and is one of the following:

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

This property returns a list of all validation errors. Currently SwiftPuLP supports the following validation errors.

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

## Conversion to / from PuLP

The Swift data structures are converted into PuLP objects using PythonKit (cf. the *PythonConvertible* protocol), according to the following mapping.

* Variable -> LpVariable
* Variable.Domain -> LpContinuous | LpInteger | LpBinary
* LinearFunction -> LpAffineExpression
* LinearConstraint -> LpConstraint
* Model -> LpProblem
* Objective.Optimization -> LpMinimize | LpMaximize

The solver requests PuLP to solve the constructed LpProblem and builds a result from data extracted from the updated problem (cf. the *ConvertibleFromPython* protocol).

* LpStatusNotSolved | LpStatusOptimal | LpStatusInfeasible | LpStatusUnbounded | LpStatusUndefined -> Solver.Status
* LpProblem variables -> Dictionary with key = variable name, value = variable value

### Generating a unique LpVariable instance for each variable

The Python counterparts of the Swift model elements are generated when the solver tries to solve the model. Since a given variable may occur multiple times in the objective function and / or one or more constraints, this may result in multiple LpVariable instances being generated for each Swift distinct variable. Converting variables into Python relies on a variable cache to keep track of the Python object generated for each new variable encountered.

In the following scenario only one LpVariable instance will be generated, which is OK.

    let x = Variable("x")

    let y = x

In the following case, however, PuLP may still run into problems.

    let (x, y) = (Variable("x"), Variable("x", domain: .integer))

Each variable is mapped onto a different Python LpVariable with the same name. Validation of the model returns errors whenever a variable name is reused for different variable instances.

## Examples

## Dependencies

SwiftPulp depends on the *Collections* and *PythonKit* packages.

## Requirements

SwiftPulp needs PuLP to be installed and may require the PYTHON_LIBRARY environment variable to be set.

## Compatibility

SwiftPulp was tested on macOS Big Sur 11.6 with XCode 13.1, Python 3.9.7 and PuLP 2.5.1.

## Status

Work in progress, but able to run some simple optimization problems.
