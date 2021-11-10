# Using linear constraints

A ``LinearConstraint`` imposes a restriction by comparing a linear function with a constant.


## Overview

The ``LinearConstraint/Comparison`` operators are:
* less than or equal to
* equal to
* greater than or equal to.

### Creating linear constraints

To create a constraint use on of the following public initializers.

```swift
init(function: LinearFunction, comparison: Comparison = .eq, constant: Double = 0)
    
init(variable: Variable, comparison: Comparison = .eq, constant: Double = 0)
```

### Using arithmethic and comparison operators to build a linear constraint

Arithmetic and comparison operators may be used in a more intuitive way to build linear constraints, as illustrated by the following examples.

```swift
let constraint1 = x <= 20
    
let constraint2 = 4 * x - 5 * y >= -10
```

## Topics

### <!--@START_MENU_TOKEN@-->Group<!--@END_MENU_TOKEN@-->

- <!--@START_MENU_TOKEN@-->``Symbol``<!--@END_MENU_TOKEN@-->
