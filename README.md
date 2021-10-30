# SwiftPuLP

SwiftPuLP wraps the Python Linear Programming PuLP module, using a similar style to create and solve models.

## Core model

The building blocks are:

* **Variable**, having a unique name, a domain, and optional minimum and maximum bounds.

* **LinearFunction**, summing zero or more variables, each weighted with a factor (aka coefficient), and a constant.

* **LinearConstraint**, comparing a linear function with a constant (less than or equal to, equal to or greather than or equal to).

* The **Model**, consisting of an optional **Objective** (a linear function and an optimization goal: minimize or maximize) and zero or more linear constraints.

* The **Solver**, using the default solver from PuLP to optimize the model's objective and return a **Result** with a status and a dictionary of variable - value pairs.

### Variable

To create a variable use the following initializer

    public init?(_ name: String, minimum: Double? = nil, maximum: Double? = nil, domain: Domain = .real)

where domain is one of:

* .real (aka continuous)
* .integer
* .binary (0 or 1)

The initializer fails if:

* the variable's name is empty or contains any of the following characters: *-+[] ->/*;
* a non-nil minimum value exceeds a non-nil maximum value;
* in case of a binary domain, the mimimum value is not nil or 0, and the maximum value is not nil or 1.

#### Examples

1. Create a continuous variable named *x* without lower or upper bounds.

        let x = Variable("x")

2. Create a list of 100 binary variables named *x_0* through *x_99*.

        let x = (0..<100).compactMap { Variable("x_\($0)", domain: .binary) }

### LinearFunction

### LinearConstraint

### Model

### Solver

## Examples

## Conversion to / from PuLP

The Swift data structures are converted into PuLP objects using PythonKit, according to the following mapping.

    Variable -> LpVariable
    Variable.Domain -> LpContinuous | LpInteger | LpBinary
    LinearFunction -> LpAffineExpression
    LinearConstraint -> LpConstraint
    Model -> LpProblem
    Objective.Optimization -> LpMinimize | LpMaximize

The solver requests PuLP to solve the constructed LpProblem and builds a result from data extracted from the updated problem.

    LpStatusNotSolved | LpStatusOptimal | LpStatusInfeasible | LpStatusUnbounded ? LpStatusUndefined -> Solver.Status
    LpProblem variables -> Dictionary with key = variable name, value = variable value

### Generating a unique LpVariable instance for each variable *name*

The Python counterparts of the Swift model elements are generated when the solver tries to solve the model. Since a given variable may occur multiple times in the objective function and / or one or more constraints, this may result in multiple LpVariables being generated for each Swift variable.

PuLP can run into problems when this happens. Hence converting variables into Python relies on a *VariableRegistry* to keep track of the first Python object generated for each variable name. The following example illustrates the impact.

    guard let x = Variable("x"), let z = Variable("x", domain: .integer) else {...}

Both these variables will be mapped onto the same Python LpVariable (whichever variable comes first wins). Currently no error is generated when such a conflict arises.

## Requirements

Needs PuLP and may require the PYTHON_LIBRARY environment variable to be set.

## Compatibility

Tested on macOS Big Sur 11.6 with XCode 13.0, Python 3.9.7 and PuLP 2.5.1.

## Status

Work in progress , but able to run some simple optimization problems.
