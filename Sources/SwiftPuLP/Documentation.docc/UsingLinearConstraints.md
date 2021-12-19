# Using linear constraints

A ``LinearConstraint`` imposes a restriction on decision variables by comparing a linear function with a constant.


## Overview

A linear constraint is a comparison operation where the left-hand side is a linear function, and the right-hand side is a constant.

The ``LinearConstraint/Comparison`` enum lists the available comparison operators:
* lte (<=)
* eq (==)
* gte (>=)

### Examples

Given variables x and y, the following expressions represent linear constraints.

```swift
a * x + b * y + c <= d

a * x + b * y == d

a * x + b * y - d >= 0
```

The weight factors a and b are the *coefficients*, and c and d represent constants. The left-hand side may contain a constant, while the right-hand side must be a (single) constant.

### Creating linear constraints

To create a constraint use one of the following public initializers.

```swift
init(function: LinearFunction, comparison: Comparison = .eq, constant: Double = 0)
    
init(variable: Variable, comparison: Comparison = .eq, constant: Double = 0)
```

### Using arithmethic and comparison operators to build a linear constraint

Arithmetic and comparison operators may be used to build linear constraints, as illustrated by the previous examples.

Note that we can directly use a variable on the left-hand side, as illustrated in the following example.

```swift
let constraint = x <= 20
```

### Applying a linear constraint

Given a linear constraint g with variables x, y and z, then we can apply g on values for these variables. To do so, provide the parameters to g as a dictionary mapping variable names to values, as illustrated in the following example.

```swift
let (x, y, z) = (Variable("x"), Variable("y"), Variable("z"))
let g = 2 * x + 3 * y - z <= 20
let parameters = ["x": 5, "y": 1, "z": 2]

print(g(parameters))
// prints true
```

> Note: If a variable is missing from the parameters, its value is assumed to be 0.

> Warning: This function application is not optimized for handling large amounts of variables.

## Topics

### <!--@START_MENU_TOKEN@-->Group<!--@END_MENU_TOKEN@-->

- <!--@START_MENU_TOKEN@-->``Symbol``<!--@END_MENU_TOKEN@-->
