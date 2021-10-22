import PythonKit

fileprivate var pulpModule = Python.import("pulp")

public struct Model: PythonConvertible {
    
    public enum Sense: PythonConvertible {

        case maximize
        case minimize

        public var pythonObject: PythonObject {
            switch self {
            case .maximize: return pulpModule.LpMaximize
            case .minimize: return pulpModule.LpMinimize
            }
        }
        
    }

    public let name: String
    
    public let sense: Sense
    
    public var pythonObject: PythonObject {
        pulpModule.LpProblem(name: name, sense: sense)
    }
        
    public init(name: String, sense: Sense = .maximize) {
        self.name = name
        self.sense = sense
    }

}

public struct Variable: PythonConvertible {
    
    public enum Category: PythonConvertible {

        case binary
        case continuous
        case integer

        public var pythonObject: PythonObject {
            switch self {
            case .binary: return pulpModule.LpBinary
            case .continuous: return pulpModule.LpContinuous
            case .integer: return pulpModule.LpInteger
            }
        }
        
    }

    let name: String
    
    let lowerBound: Double?
    
    let upperBound: Double?
    
    let category: Category
    
    public var pythonObject: PythonObject {
        pulpModule.LpVariable(name: name, lowerBound: lowerBound ?? Python.None, upperBound: upperBound ?? Python.None, category: category.pythonObject)
    }

    public init(name: String, lowerBound: Double? = nil, upperBound: Double? = nil, category: Category = .continuous) {
        self.name = name
        self.lowerBound = lowerBound
        self.upperBound = upperBound
        self.category = category
    }
    
}
