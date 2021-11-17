# Helper functions

The ``Function`` enum and ``Pairs`` struct provide access to helper functions and types.

## Overview

The helper functions are available as static methods in the Function enum.

### Creating linear functions

* The ``Function/sum(_:)`` function converts a sequence of variables into a linear function summing the variables.
    
    The following example creates the constraint that one and only one of 100 binary variables should have value 1.

    ```swift
    let x = (0..<100).map { i in Variable("x\(i)", domain: .binary) }
    let constraint = Function.sum(x) == 1
    ```

### Iterating over pairs of sequences

* The ``Pairs`` struct combines two sequences, and implements an iterator that generates all pairwise combinations of elements from each sequence.

    ```swift
    print(Array(Pairs(["a", "b", "c"], [1, 2])))
    // outputs [("a", 1), ("a", 2), ("b", 1), ("b", 2), ("c", 1), ("c", 2)]
    ```
    
    > Note:  As Pairs are sequences themselves, they can be nested.

## Topics

### <!--@START_MENU_TOKEN@-->Group<!--@END_MENU_TOKEN@-->

- <!--@START_MENU_TOKEN@-->``Symbol``<!--@END_MENU_TOKEN@-->
