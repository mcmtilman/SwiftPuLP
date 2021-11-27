# Using variables

A ``Variable`` represents a decision variable in a linear programming problem.

## Overview

A variable has a name, a domain specifiying its possible values, and optional minimum and maximum bounds.

The ``Variable/Domain`` enum specifies the values that are allowed:
* continuous (i.e. real numbers)
* integer
* binary.

Values in these domains are represented by Double numbers. For the binary domain the values are 0 and 1.

### Creating variables

To create a variable use the following public initializer.

```swift
init(_ name: String, minimum: Double? = nil, maximum: Double? = nil, domain: Domain = .continuous)
```

### Examples

1. Create a continuous variable named *x* without lower and upper bounds.

    ```swift
    let x = Variable("x")
    ```

2. Create a list of 100 binary variables named *x_1* through *x_100*.

    ```swift
    let x = (1...100).map { Variable("x_\($0)", domain: .binary) }
    ```

3. Create variables x and y with the name name.

    ```swift
    let x = Variable("x")
    let y = Variable("x")
    ```

    When converting to PuLP x and y generate different instances of LpVariable with the same name. This can cause problems when solving the generated PuLP problem.

4. Create a variable x and an alias y.

    ```swift
    let x = Variable("x")
    let y = x
    ```

    Since x and y refer to the same variable, this does not give problems (though it may be confusing when x and y are used in the same model).

### Validating a variable

A variable is not valid if:
* the variable's name is empty or contains any of the following characters: *-+[] ->/*
* a non-nil minimum value exceeds a non-nil maximum value
* for a binary domain, the mimimum value is not nil or 0, or the maximum value is not nil or 1.

To verify that an individual variable is valid check if the ``Variable/validationErrors()`` property returns an empty list.

```swift
let x = Variable("x")  
let errors = x.validationErrors()

guard errors.isEmpty else { ... }
```

> Note: Duplicate variable names are only detected when validating a model.

## Topics

### <!--@START_MENU_TOKEN@-->Group<!--@END_MENU_TOKEN@-->

- <!--@START_MENU_TOKEN@-->``Symbol``<!--@END_MENU_TOKEN@-->
