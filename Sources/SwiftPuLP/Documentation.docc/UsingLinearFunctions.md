# Using linear functions

A ``LinearFunction`` represents a linear combination of zero or more variables.

## Overview

If x, y, z represent variables, then a linear combination of these variables has the canonical form.

```swift
a * x + b * y + c * z + d
```

The weight factors a, b and c are the *coefficients*, and d is the *constant*.

An expression like *a * x* is a term of the linear function. 

### Creating linear functions

To create a linear function use one of the following public initializers.

```swift
init(terms: [LinearFunction.Term], constant: Double = 0)

init(variable: Variable)
```

Create a term as follows.

```swift
LinearFunction.Term(variable: Variable, factor: Double = 1)
```

### Using arithmethic operators to build a linear function

Arithmetic operators may be used in a more intuitive way to build linear functions, and parentheses may be used to alter precedence.

In the following examples x, y, z represent variables.

```swift
let function1 = +x

let function2 = 1 * x

let function3 = x + 0

let function4 = 0 * x + 10

let function5 = -x + 10

let function6 = x + y + z

let function7 = 2 * x + 3 * y + z - 10

let function8 = 2 * x - 3 * (y + z - x - 10)
```

### Normalizing a linear function

When creating linear functions, the same variable may appear multiple times in the result. Only constants are combined into one value.

For instance, function8 is represented as follows.

```swift
2 * x - 3 * y - 3 * z + 3 * x + 30
```

*Normalizing* a function is the process of reducing the function into its canonical form, where each variable appears only once.

For instance, normalizing function8 results in the following expression.

```swift
5 * x - 3 * y - 3 * z + 30
```

## Topics

### <!--@START_MENU_TOKEN@-->Group<!--@END_MENU_TOKEN@-->

- <!--@START_MENU_TOKEN@-->``Symbol``<!--@END_MENU_TOKEN@-->
