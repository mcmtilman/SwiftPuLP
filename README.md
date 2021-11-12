# SwiftPuLP

SwiftPuLP wraps the Python Linear Programming PuLP module, using a similar style to create and solve models.

## Overview

Solving a Linear Programming consists of creating a model of the problem using variables, linear functions and constraints, solving this model and returning a result.

The building blocks of the core model are:

* A **Variable** has a unique name, a domain, and optional minimum and maximum bounds.
    
    A **Domain** specifies a range of values (real, integer or binary), subject to optional bounds restrictions.

    See: [Using Variables](Sources/SwiftPuLP/Documentation.docc/UsingVariables.md)

* A **LinearFunction** represents a linear combination of zero or more variables, i.e. it has a form like *a \* x + b \* y + c*, where *x* and *y* denote variables, *a* and *b* are the coefficients (aka factors) and *c* is the constant.

    A **Term** refers to a variable with its factor.
    
    See: [Using linear functions](Sources/SwiftPuLP/Documentation.docc/UsingLinearFunctions.md)

* A **LinearConstraint**  compares a linear function with a constant.

    The **Comparison** operators include: less than or equal to, equal to, greater than or equal to.
    
    See: [Using linear constraints](Sources/SwiftPuLP/Documentation.docc/UsingLinearConstraints.md)

* A **Model** has an optional **Objective**, which specifies a linear function and an optimization goal. A model may also specify zero or more linear constraints.

    The **Optimization** goals include: minimize and maximize.

    See: [Using models](Sources/SwiftPuLP/Documentation.docc/UsingModels.md)

* A **Solver** computes the best values for the decision variables based on the model's objective and constraints.

    The solver returns an optional **Result** with a **Status** and a dictionary of variable name - value pairs.

    See: [Using solvers](Sources/SwiftPuLP/Documentation.docc/UsingSolvers.md)

### Type overview

```swift
protocol LinearExpression {}

class Variable {}

struct LinearFunction {}

struct LinearFunction.Term {}
    
struct LinearConstraint {}

struct Model {}

struct Model.Objective {}

struct Solver {}

struct Solver.Result {}

enum Variable.Domain {}
    
enum LinearConstraint.Comparison {}
    
enum Model.Optimization {}

enum Solver.Status {}

enum ValidationError {}

```

## Helper functions

The **Function** enum contains helper functions.

See: [Helper functions](Sources/SwiftPuLP/Documentation.docc/HelperFunctions.md)
    
## Examples

### Example 1: Solving a sudoku

Based on the [The Sudoku Problem Formulation for the PuLP Modeller](https://coin-or.github.io/pulp/CaseStudies/a_sudoku_problem.html).

    Authors: Antony Phillips, Dr Stuart Mitchell
    edited by Nathan Sudermann-Merx

The Swift model can be found in *SudokuTests*. It closely mirrors the PuLP model. It has no objective function, and only binary constraints.

#### Analysis

Much of the code is similar (apart from some refactoring to make it more testable), except for a few points.

1. In the Python example the 'boxes' variable is created by list comprehension with 4 'for' variables.

    ```python
    Boxes = [    
        [(3 * i + k + 1, 3 * j + l + 1) for k in range(3) for l in range(3)]
        for i in range(3)
        for j in range(3)
    ]
    ```

    This is both concise and readable: variables *i* and *j* identify a box in the Sudoku grid, while variables *k* and *l* identify cells within the boxes.
    
    Attempting to mirror this declaratively in Swift yields something like this (using zero-based coordinates).
    
    ```swift
    (0...2).flatMap { i in (0...2).map { j in (i, j) }}.map { (i, j) in
        (0...2).flatMap { k in (0...2).map { l in (3 * i + k, 3 * j + l) }}
    }
    ```
    
    A simpler variant is this one used in SudokuTests.    
    
    ```swift
    (0...8).map { r in
        (0...8).map { c in
            (r / 3 * 3 + c / 3, r % 3 * 3 + c % 3) 
        } 
    }
    ```
    
    Support in Swift for iterating over multi-dimensional ranges might be another option.
    
    ```swift
    let ranges = (0...2) * (0...2)  
    let boxes = ranges.map { i, j in ranges.map { k, l in (3 * i + k, 3 * j + l) }}
    ```

2. The 'choices' variable in Python is created using a utility class method on LpVariable.

    ```python
    choices = LpVariable.dicts("Choice", (VALS, ROWS, COLS), cat="Binary")
    ```
    
    The following variant with nested arrays is used in SudokuTests.
    
    ```swift
    choices = values.map { v in
        rows.map { r in
            columns.map { c in
                Variable("Choice_\(v)_\(r)_\(c)", domain: .binary)
            }
        }
    }
    ```

## Dependencies

SwiftPulp depends on the *Collections* and *PythonKit* packages.

## Requirements

SwiftPulp needs PuLP to be installed and may require the PYTHON_LIBRARY environment variable to be set.

## Compatibility

SwiftPulp was tested on macOS Big Sur 11.6 with XCode 13.1, Python 3.9.7 and PuLP 2.5.1.

## Status

Work in progress, but able to run some simple optimization problems.
