# Helper functions

The ``Function`` enum provides access to helper functions.

## Overview

The helper methods are available as static methods in the Function enum.

### Creating linear functions

* The ``Function/sum(_:)`` function converts a sequence of variables into a linear function summing the variables.
    
    The following example creates the constraint that one and only one of 100 binary variables should have value 1.

    ```swift
    let x = (0..<100).map { i in Variable("x\(i)", domain: .binary) }
    let constraint = Function.sum(x) == 1
    ```

## Topics

### <!--@START_MENU_TOKEN@-->Group<!--@END_MENU_TOKEN@-->

- <!--@START_MENU_TOKEN@-->``Symbol``<!--@END_MENU_TOKEN@-->
