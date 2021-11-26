# Using models

A ``Model`` represents an linear programming problem to be solved by one of the solvers supported by PuLP.

## Overview

The model has an optional ``Model/Objective`` consisting of a linear function and a ``Model/Optimization`` goal, and zero or more labeled linear constraints.

The optimization goal is one of:
* minimize
* maximize.

### Creating a model

To create a model use the following public initializer.

```swift
init(_ name: String, objective: Objective? = nil, constraints: [(constraint: LinearConstraint, name: String)]
```

Each constraint is associated with a label, which may be empty.

To create an objective use one of the following public initializers.

```swift
init(_ function: LinearFunction, optimization: Optimization = .minimize)
    
init(_ variable: Variable, optimization: Optimization = .minimize)
```
    
### Validating a model

A model is not valid if:
* the model's name contains spaces;
* its objective function or constraints use invalid variables or distinct variables with the same name
* it uses multiple constraints with the same label.

To verify that an individual model is valid check if the ``Model/validationErrors()`` property returns an empty list.

```swift
let model = Model("x", constraints:[])  
let errors = model.validationErrors()

guard errors.isEmpty else { ... }
```

#### Example of a valid model

The following example illustrates how to create a simple and valid model.

```swift
let (x, y) = (Variable("x", domain: .integer), Variable("y"))    
let function = x + 2 * y    
let objective = Objective(function, optimization: .maximize)    
let constraints = [    
    (2 * x + y <= 20, "red"),        
    (4 * x - 5 * y >= -10, "blue"),        
    (-x + 2 * y >= -2, "yellow"),        
    (-x + 5 * y == 15, "green")        
]    
let model = Model("Basic", objective: objective, constraints: constraints)
```

## Topics

### <!--@START_MENU_TOKEN@-->Group<!--@END_MENU_TOKEN@-->

- <!--@START_MENU_TOKEN@-->``Symbol``<!--@END_MENU_TOKEN@-->
