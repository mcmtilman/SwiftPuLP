# SwiftPuLP

SwiftPuLP wraps the Python Linear Programming PuLP module, using a similar style to create and solve models.

## Overview

Solving a Linear Programming consists of creating a model of the problem using variables, linear functions and constraints, solving this model and returning a result.

The building blocks of the core model are:

* A **Variable** has a unique name, a domain, and optional minimum and maximum bounds.
    
    A **Domain** specifies a range of values (real, integer or binary), subject to optional bounds restrictions.

    See: [Using Variables](Sources/SwiftPuLP/Documentation.docc/UsingVariables.md)

* A **LinearFunction** represents a linear combination of zero or more variables, i.e. it has a form like *a ∗ x + b ∗ y + c*, where *x* and *y* denote variables, *a* and *b* are the coefficients (aka factors) and *c* is the constant.

    A **Term** refers to a variable with its factor.
    
    See: [Using linear functions](Sources/SwiftPuLP/Documentation.docc/UsingLinearFunctions.md)

* A **LinearConstraint**  compares a linear function with a constant.

    The **Comparison** operators include: less than or equal to, equal to, greater than or equal to.
    
    See: [Using linear constraints](Sources/SwiftPuLP/Documentation.docc/UsingLinearConstraints.md)

* A **Model** has an optional **Objective**, which is a linear function, and an **Optimization** goal. A model may also specify zero or more linear constraints.

    The optimization goals include: minimize and maximize.

    See: [Using models](Sources/SwiftPuLP/Documentation.docc/UsingModels.md)

* A **Solver** computes the best values for the decision variables based on the model's objective, optimization goal and constraints.

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

struct Solver {}

struct Solver.Result {}

struct CBCSolver {}

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

The Swift model can be found in [SudokuTests](Tests/SwiftPuLPTests/Examples/SudokuTests.swift). It closely mirrors the PuLP model. It has no objective function, and only binary constraints.

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
    
    Mirroring this declaratively in Swift results in the following (using zero-based coordinates).
    
    ```swift
    let ranges = Pairs(0...2, 0...2)
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

3. Performance compared to native Python PuLP is heavily impacted by the conversion between Swift and Python data structures. The CBCSolver negates this overhead by directly using PuLP's default CBC solver.

### Example 2: Wedding seating planning illustrating set partitioning optimization

Based on [A set partitioning model of a wedding seating problem](https://coin-or.github.io/pulp/CaseStudies/a_set_partitioning_problem.html).

    Authors: Stuart Mitchell 2009

The Swift model can be found in [WeddingSeatingTests](Tests/SwiftPuLPTests/Examples/WeddingSeatingTests.swift). It mirrors the PuLP model. It has an objective function, and only binary variables.

This model is also used to test a preliminary version of the CBCSolver.

## Dependencies

SwiftPuLP depends on the *Collections* and *PythonKit* packages. It also uses *CharacterSet* from *Foundation*.

The test target depends on the *Algorithms* package.

## Requirements

SwiftPuLP needs PuLP to be installed and may require the PYTHON_LIBRARY environment variable to be set.

To use the CBCSolver the CBC_PATH environment variable must be set to the CBC executable.

## Compatibility

SwiftPuLP was tested on macOS Big Sur 11.6 with XCode 13.1, Python 3.9.7 and PuLP 2.5.1.

## Status

Work in progress, but able to run some simple optimization problems.
