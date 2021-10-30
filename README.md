# SwiftPuLP

SwiftPuLP wraps the Python Linear Programming PuLP module, using a similar style to create and solve models.

## Core model

The building blocks are:

* **Variable** having a unique name, a domain, and optional minimum and maximum bounds.
* **LinearFunction** summing zero or more variables, each weighted with a factor (aka coefficient), and a constant.
* **LinearConstraint** comparing a linear function with a constant (less than or equal to, equal to or greather than or equal to).
* The **Model** consisting of an optional objective (a linear function and an optimizal goal: minimize or maximize) and zero or more linear constraints.
* The **Solver** using the default solver from PuLP to optimize the model's objective and return a status and a dictionary of variable (name) - value pairs.

### Variable

To create a variable use the following initializer

    public init?(_ name: String, minimum: Double? = nil, maximum: Double? = nil, domain: Domain = .real)

where domain is one of:

    .real (aka continuous)
    .integer
    .binary (0 or 1)

The initializer fails if:

* the variable's name is empty or contains any of the following characters: "-+[] ->/";
* a non-nil minimum value exceeds a non-nil maximum value;
* in case of a binary domain, the mimimum value is nil or 0, and the maximum value is either nil or 1.

### LinearFunction

### LinearConstraint

### Model

### Solver

## Examples

## Requirements

Needs PuLP and may require the PYTHON_LIBRARY environment variable to be set.

## Compatibility

Tested on macOS Big Sur 11.6 with XCode 13.0, Python 3.9.7 and PuLP 2.5.1.

## Status

Work in progress , but able to run some simple optimization problems.
