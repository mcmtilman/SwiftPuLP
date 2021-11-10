# Using variables

A ``Variable`` represents a decision variable in a linear programming problem.

## Overview

A variable has a name, a domain specifiying its possible values, and optional minimum and maximum bounds.

The ``Variable/Domain`` specifies the values that are allowed:
* real (aka continuous)
* integer
* binary.

Values in these domains are represented as Double numbers.

### Creating variables

To create a variable use the following public initializer.

```swift
init(_ name: String, minimum: Double? = nil, maximum: Double? = nil, domain: Domain = .real)
```

### Examples

1. Create a continuous variable named *x* without lower and upper bounds.

    ```swift
    let x = Variable("x")
    ```

2. Create a list of 100 binary variables named *x_0* through *x_99*.

    ```swift
    let x = (0..<100).map { Variable("x_\($0)", domain: .binary) }
    ```

### Validating a variable

A variable is not valid if:
* the variable's name is empty or contains any of the following characters: *-+[] ->/*;
* a non-nil minimum value exceeds a non-nil maximum value;
* in case of a binary domain, the mimimum value is not nil or 0, or the maximum value is not nil or 1.

To verify that an individual variable is valid check if the ``Variable/validationErrors`` property returns an empty list.

```swift
let x = Variable("x")  
let errors = x.validationErrors  

guard errors.isEmpty else { ... }
```

> Note: Duplicate variable names are only detected when validating a model.

## Topics

### <!--@START_MENU_TOKEN@-->Group<!--@END_MENU_TOKEN@-->

- <!--@START_MENU_TOKEN@-->``Symbol``<!--@END_MENU_TOKEN@-->
