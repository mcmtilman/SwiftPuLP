# Using solvers

The ``Solver`` uses PuLP to find a solution for a model.

## Overview

### Solver

The solver converts a model into a PuLP *LpProblem*, requests PuLP to solve the problem, and returns a ``Solver/Result`` based on information extracted from the PuLP problem.

The solver uses the default PuLP solver.

### Creating a solver

To create a solver use the default (public) initializer.

```swift
func init()
```

### Solving a model

To solve a model use the following method.

```swift
func solve(_ model: Model, logging: Bool = false) -> Result?
```

This method returns a result when it can convert the status and variable bindings in the LpProblem. Otherwise nil is returned.

By default, PuLP message logging is disabled.

#### Result

The solver result contains a ``Solver/Status`` and a dictionary of values keyed by variable name.

The following describes the result when solving the basic model in <doc:UsingModels>.

```swift
let model = ...
let result = Solver().solve(model)

// result.status == .optimal
// result.variables == ["x": 7, "y": 4.4]
```

### Integration with PuLP

The solver converts the Swift model into PuLP objects using *PythonKit*, according to the following mapping.

```swift
Variable               -> LpVariable

Variable.Domain        -> LpContinuous | LpInteger | LpBinary

LinearFunction         -> LpAffineExpression

LinearConstraint       -> LpConstraint

Model                  -> LpProblem

Objective.Optimization -> LpMinimize | LpMaximize
```

The mapping back from a (solved) LpProblem to a result is as follows.

```swift
LpProblem status    -> Solver.Status

LpProblem variables -> Dictionary with key = variable name, value = variable value
```

#### Generating a single LpVariable instance for each different Swift variable

The Python counterparts of the Swift model elements are generated when the solver tries to solve the model.

Since a given variable may occur multiple times in the objective function and / or one or more constraints, this may result in multiple LpVariable instances being generated for each distinct Swift variable. Converting variables into Python uses a variable cache to keep track of the Python object generated for each new (Swift) variable encountered.

### Example: Solving a sudoku

Based on the [The Sudoku Problem Formulation for the PuLP Modeller](https://coin-or.github.io/pulp/CaseStudies/a_sudoku_problem.html).

    Authors: Antony Phillips, Dr Stuart Mitchell
    edited by Nathan Sudermann-Merx

The Swift model can be found in *SudokuTests*. It closely mirrors the PuLP model. It has no objective function, and uses only binary variables and constraints.

#### Sudoku input

```
+-------+-------+-------+
| 8 . . | . . . | . . . |
| . . 3 | 6 . . | . . . |
| . 7 . | . 9 . | 2 . . |
+-------+-------+-------+
| . 5 . | . . 7 | . . . |
| . . . | . 4 5 | 7 . . |
| . . . | 1 . . | . 3 . |
+-------+-------+-------+
| . . 1 | . . . | . 6 8 |
| . . 8 | 5 . . | . 1 . |
| . 9 . | . . . | 4 . . |
+-------+-------+-------+
```

#### Sudoku output

```
+-------+-------+-------+
| 8 1 2 | 7 5 3 | 6 4 9 |
| 9 4 3 | 6 8 2 | 1 7 5 |
| 6 7 5 | 4 9 1 | 2 8 3 |
+-------+-------+-------+
| 1 5 4 | 2 3 7 | 8 9 6 |
| 3 6 9 | 8 4 5 | 7 2 1 |
| 2 8 7 | 1 6 9 | 5 3 4 |
+-------+-------+-------+
| 5 2 1 | 9 7 4 | 3 6 8 |
| 4 3 8 | 5 2 6 | 9 1 7 |
| 7 9 6 | 3 1 8 | 4 5 2 |
+-------+-------+-------+
```

## Topics

### <!--@START_MENU_TOKEN@-->Group<!--@END_MENU_TOKEN@-->

- <!--@START_MENU_TOKEN@-->``Symbol``<!--@END_MENU_TOKEN@-->
