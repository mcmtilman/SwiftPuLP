# Using models

A ``Model`` represents an linear programming problem to be solved by one of the solvers supported by PuLP.

## Overview

The model has an optional *objective* representing a ``LinearFunction``, and a ``Model/Optimization`` goal, and zero or more labeled linear constraints.

The optimization goal is one of:
* minimize
* maximize.

### Creating a model

To create a model use one of the following public initializers.

```swift
init(_ name: String, objective: LinearFunction? = nil, optimization: Optimization = .minimize, constraints: [(constraint: LinearConstraint, name: String)]

init(_ name: String, objective: Variable, optimization: Optimization = .minimize, constraints: [(constraint: LinearConstraint, name: String)]
```

Each constraint is associated with a label, which may be empty.
    
### Validating a model

A model is not valid if:
* the model's name contains spaces;
* its objective function or constraints use invalid variables or distinct variables with the same name
* it uses multiple constraints with the same label.

To verify that an individual model is valid check if ``Model/validationErrors()`` returns an empty list.

```swift
let model = Model("x", constraints:[])  
let errors = model.validationErrors()

guard errors.isEmpty else { ... }
```

#### Example of a valid model

The following example illustrates how to create a simple and valid model.

```swift
let (x, y) = (Variable("x", domain: .integer), Variable("y"))    
let objective = x + 2 * y    
let constraints = [    
    (2 * x + y <= 20, "red"),        
    (4 * x - 5 * y >= -10, "blue"),        
    (-x + 2 * y >= -2, "yellow"),        
    (-x + 5 * y == 15, "green")        
]    
let model = Model("Basic", objective: objective, optimization: .maximize, constraints: constraints)
```

## Topics

### <!--@START_MENU_TOKEN@-->Group<!--@END_MENU_TOKEN@-->

- <!--@START_MENU_TOKEN@-->``Symbol``<!--@END_MENU_TOKEN@-->
