# Using linear functions

A ``LinearFunction`` represents a linear combination of zero or more variables.

## Overview

If x, y, z represent different variables, then a linear combination of these variables has the canonical form.

```swift
a * x + b * y + c * z + d
```

The weight factors a, b and c are the *coefficients*, and d is the *constant*.

An expression like *a ∗ x* is a *term* of the linear function. 

### Creating linear functions

To create a linear function use one of the following public initializers.

```swift
init(terms: [Term], constant: Double = 0)

init(variable: Variable)
```

Create a term as follows.

```swift
LinearFunction.Term(variable: Variable, factor: Double = 1)
```

### Using arithmethic operators to build a linear function

Arithmetic operators may be used to build linear functions. Parentheses can be used to alter precedence.

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

> Note: Expressions consisting of a single variable or a single constant are not recognized as linear functions by the compiler. To use a variable x as a linear function, either one of functions 1 through 3 will do.

### Normalizing a linear function

When creating linear functions, the same variable may appear multiple times, and a term may have a zero factor. When using operators to build functions, some additional processing is required: constants are combined into a single value, while parentheses are removed and factors are propagated if needed.

*Normalizing* a function is the process of reducing the function into its canonical form, whereby each variable appears only once, and whereby terms with 0 factor are removed.

For instance, the following function contains 2 terms with variables x and y each.

```swift
2 * x + 3 * y - 5 * z + x - 4 * y + y + 10
```

Normalizing this function results in the following expression.

```swift
3 * x - 5 * z + 10
```

If z is an alias for x, then the normalized function becomes even simpler.

```swift
-2 * x + 10
```

### Applying a linear function

Given a linear function f with variables x, y and z, then we can apply f on values for these variables. To do so, provide the parameters to f as a dictionary mapping variable names to values, as illustrated in the following example.

```swift
let (x, y, z) = (Variable("x"), Variable("y"), Variable("z"))
let f = 2 * x + 3 * y - z
let parameters = ["x": 5, "y": 1, "z": 2]

print(f(parameters))
// prints 11
```

> Note: If a variable is missing from the parameters, its value is assumed to be 0.

> Warning: This function application is not optimized for handling large amounts of variables.

## Topics

### <!--@START_MENU_TOKEN@-->Group<!--@END_MENU_TOKEN@-->

- <!--@START_MENU_TOKEN@-->``Symbol``<!--@END_MENU_TOKEN@-->
