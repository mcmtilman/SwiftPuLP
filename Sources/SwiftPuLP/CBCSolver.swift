//
// CBCSolver.swift
//  
//  Created by Michel Tilman on 21/11/2021.
//  Copyright © 2021 Dotted.Pair.
//  Licensed under Apache License v2.0.
//

import Foundation

/**
 Solver direct;y using CBC CLI  (which is the default solver in PuLP) without intervening Python code.
 
  CBCSolver goes through the following steps.
 - Convert a model into a MPS file.
 - Execute the CBC command with the MPS file as input. The output is a solution file.
 - Extract the result from the solution file.
 */
public struct CBCSolver {
    
    // MARK: -
    
    // Path of the CBC exectuable.
    private let commandPath: String
    
    // MARK: -
    
    /// Create a solver with the path of the executable
    ///
    /// - Parameter commandPath: Path to CBC executable.
    public init(commandPath: String) {
        self.commandPath = commandPath
    }
    
    // MARK: -

    /// Solves the model by directly accssing the CBC executable and returns the result.
    ///
    /// Returns nil in case of failure.
    ///
    /// - Parameter model: Model to solve.
    /// - Returns: Result or nil in case of failure.
    public func solve(_ model: Model) -> Solver.Result? {
        guard let folder = createTemporaryFolder() else { return nil }
        let modelPath = folder.appendingPathComponent("model.mps").path
        let solutionPath = folder.appendingPathComponent("model.sol").path
        defer { removeFolder(folder) }
        
        guard MPSWriter().writeModel(model, toFile: modelPath),
              executeCommand(modelPath, solutionPath, model.optimization) else { return nil }
        
        return SolutionReader().readResultFromFile(atPath: solutionPath, model: model)
    }
    
    // MARK: -

    // Returns a URL to a new temporary folder.
    // 'Logs' an error when the operation fails.
    private func createTemporaryFolder() -> URL? {
        do {
            return try FileManager.default.url(for: .itemReplacementDirectory, in: .userDomainMask, appropriateFor: URL(fileURLWithPath: NSHomeDirectory()), create: true)
        } catch {
            print("Could not create temporary folder: \(error)")
            
            return nil
        }
    }
    
    // Executes the CBC command.
    // Returns true if successful.
    private func executeCommand(_ modelPath: String, _ solutionPath: String, _ optimization: Model.Optimization) -> Bool {
        #if os(macOS)
            let process = Process()

            process.launchPath = commandPath
            process.arguments = [modelPath, "\(optimization)", "timeMode", "elapsed", "branch", "printingOptions", "normal", "solution", solutionPath] // branch when mip
            process.standardOutput = nil
            process.launch()
            process.waitUntilExit()
            
            if process.terminationStatus == 0 { return true }

            print("CBC exited with status: \(process.terminationStatus)")
        #endif
        
        return false
    }
    
    // Removes given folder.
    // 'Logs' a warning when the operation fails.
    private func removeFolder(_ folder: URL) {
        do {
            try FileManager.default.removeItem(at: folder)
        } catch {
            print("Could not remove temporary folder: \(error)")
        }
    }
    
}
        

// MARK: -

/**
 Writes the model to a file in MPS format.
 */
struct MPSWriter {
    
    // MARK: -
    
    /// Writes the model to given file in MPS format. Answers if successful.
    ///
    /// String(format:) is a bit slow, so cache logical variable and constraint names.
    ///
    /// - Parameters:
    ///   - model: Valid model.
    ///   - path: Path of MPS file to be created.
    /// - Returns: True if successful.
    func writeModel(_ model: Model, toFile path: String) -> Bool {
        guard var writer = createFile(atPath: path).map(BufferedWriter.init) else { return false }

        let variables = model.variables
        let variableNames = (0 ..< variables.count).map { i in String(format: "X%07d", i) }
        let constraintNames = (0 ..< model.constraints.count).map { i in String(format: "C%07d", i) }
        let one = String(format: "% .12e", 1.0) // Factor 1 is often used in several unit test models.

        // Writes the model's optimization.  This is not suffient for CBC.
        // The CBC executable requires an explicit argument reflecting the model's optimization.
        func writeOptimizationLine() {
            writer.append("*SENSE:\(toMPS(model.optimization))\n")
        }
    
        // Writes an anomymous model name for now.
        func writeNameLine() {
            writer.append("NAME          MODEL\n")
        }

        // Writes optional objective and constraints (with comparisons).
        func writeRowLines() {
            writer.append("ROWS\n")
            if model.objective != nil {
                writer.append(" N  OBJ\n")
            }
            for (i, (constraint, _)) in model.constraints.enumerated() {
                writer.append(" \(toMPS(constraint.comparison))  \(constraintNames[i])\n")
            }
        }

        // Writes the factors, one per line, for each variable - objective / constraint combination in use.
        func writeColumnLines() {
            let factors = collectFactors()
            
            writer.append("COLUMNS\n")
            for (v, variable) in variables.enumerated() {
                if let factors = factors[variable] {
                    if variable.domain != .continuous {
                        writer.append("    MARK      'MARKER'                 'INTORG'\n")
                    }
                    for (i, factor) in factors {
                        let name = i >= 0 ? constraintNames[i] : "OBJ     "
                        
                        writer.append("    \(variableNames[v])  \(name)  \(toMPS(factor))\n")
                    }
                    if variable.domain != .continuous {
                        writer.append("    MARK      'MARKER'                 'INTEND'\n")
                    }
                    
               }
            }
        }
        
        // Writes the constants of the various constraints.
        // Each constant is the constraint's constant minus its function constant.
        func writeRHSLines() {
            writer.append("RHS\n")
            for (i, (constraint, _)) in model.constraints.enumerated() {
                let constant = constraint.constant - constraint.function.constant
                
                writer.append("    RHS       \(constraintNames[i])  \(toMPS(constant))\n")
            }
        }
        
        // Writes the variable bounds.
        func writeBoundsLines() {
            writer.append("BOUNDS\n")
            for (v, variable) in variables.enumerated() {
                writeVariableBoundsLines(variable, variableNames[v])
            }
        }

        // Integer variables with (min, max) == (0, 1) are implicitly considered to be binary.
        func writeVariableBoundsLines(_ variable: Variable, _ name: String) {
            let (domain, minimum, maximum) = (variable.domain, variable.minimum, variable.maximum)
            
            if let minimum = minimum, minimum == maximum {
                return writer.append(" FX BND       \(name)  \(toMPS(minimum))\n")
            } else if domain != .continuous, minimum == 0, maximum == 1 {
                return writer.append(" BV BND       \(name)\n")
            }
            if let minimum = minimum {
                if minimum != 0 || domain == .integer && maximum == nil {
                    writer.append(" LO BND       \(name)  \(toMPS(minimum))\n")
                }
            } else if maximum != nil {
                writer.append(" MI BND       \(name)\n")
            } else {
                writer.append(" FR BND       \(name)\n")
            }
            if let maximum = maximum {
                writer.append(" UP BND       \(name)  \(toMPS(maximum))\n")
            }
        }

        // Writes closing line.
        func writeEndOfDataLine() {
            writer.append("ENDATA")
            writer.flush()
        }
        
        // Returns a dictionary mapping variables onto tuples with non-zero factor for each variable's occurrence in linear functions.
        // The functions are identified by number, using -1 for the objective function and the constraint order for each constraint.
        func collectFactors() -> [Variable: [(Int, Double)]] {
            var factors = [Variable: [(Int, Double)]]()
            
            for (i, (constraint, _)) in model.constraints.enumerated() {
                for term in constraint.function.terms where term.factor != 0 {
                    factors[term.variable, default: []].append((i, term.factor))
                }
            }
            if let function = model.objective {
                for term in function.terms where term.factor != 0 {
                    factors[term.variable, default: []].append((-1, term.factor))
                }
            }

            return factors
        }
        
        // Converts the double to MPS format.
       func toMPS(_ double: Double) -> String {
            double == 1 ? one : String(format: "% .12e", double)
        }
        
        // Converts the optimization to MPS format.
        func toMPS(_ optimization: Model.Optimization) -> String {
            switch optimization {
            case .minimize:
                return "Minimize"
            case .maximize:
                return "Maximize"
            }
        }

        // Converts the comparison to MPS format.
        func toMPS(_ comparison: LinearConstraint.Comparison) -> String {
            switch comparison {
            case .lte:
                return "L"
            case .eq:
                return "E"
            case .gte:
                return "G"
            }
        }
        
        writeOptimizationLine()
        writeNameLine()
        writeRowLines()
        writeColumnLines()
        writeRHSLines()
        writeBoundsLines()
        writeEndOfDataLine()
        
        return true
    }
    
    // MARK: -
    
    // Creates a file at given path and returns a filehandle, or nil in case of failure.
    private func createFile(atPath path: String) -> FileHandle? {
        return FileManager.default.createFile(atPath: path, contents: nil, attributes: nil) ? FileHandle(forWritingAtPath: path) : nil
    }
    
}


// MARK: -

/**
 Buffers lines of strings before writing to file.
 */
struct BufferedWriter {
    
    // MARK: -

    // Valid file handle.
    private let fileHandle: FileHandle
    
    // Maximum number of lines to buffer.
    private let capacity = 500
    
    // Actual buffer.
    private var lines = [String]()
            
    // MARK: -
            
    /// Creates a writer for given filehandle. (Not really that necessary.)
    ///
    /// - Parameter fileHandle: Handle to MPS file.
    init(fileHandle: FileHandle) {
        self.fileHandle = fileHandle
    }
    
    // MARK: -

    /// If the buffer is full flush lines to file before buffering a new line.
    ///
    /// - Parameter line: String to be written.
    mutating func append(_ line: String) {
        if lines.isEmpty {
            lines.reserveCapacity(capacity)
        }
        lines.append(line)
        if lines.count == capacity {
            flush()
            lines = []
        }
    }
    
    /// FLush the strings currently in the buffer.
    func flush() {
        if !lines.isEmpty, let data = lines.joined().data(using: .utf8) {
            fileHandle.write(data)
        }
    }
                 
}


// MARK: -

/**
 Reads the solution generated by CBC.
 */
struct SolutionReader {
    
    // MARK: -

    /// Returns a result constructed from the CBC output file, or nil in case of failure.
    ///
    /// - Parameters:
    ///   - path: Path to solution file produced by CBC.
    ///   - model: Solved model.
    /// - Returns: Result of nil in case of failure.
    func readResultFromFile(atPath path: String, model: Model) -> Solver.Result? {
        do {
            return try readFromFile(path, model)
        } catch {
            print("Error reading solution file: \(error)")
            return nil
        }
    }

    // MARK: -

    // Reads the status and variable bindings from the CBC output file.
    private func readFromFile(_ path: String, _ model: Model) throws -> Solver.Result? {
        let data = try String(contentsOfFile: path, encoding: .utf8)
        let lines = data.components(separatedBy: .newlines)
        
        guard let line = lines.first else { return nil }
        let status = readStatus(fromString: line)
        let variables = model.variables
        let bindings = lines.dropFirst().dropLast().compactMap { (line) -> (String, Double)? in
            let tokens = line.split(separator: " ")
            guard tokens.count > 2 else { return nil }
            let i = tokens[0] == "**" ? 1 : 0
            
            switch (Int(tokens[i]), tokens[i + 1], Double(tokens[i + 2])) {
            case (let id?, let name, let value?) where name.starts(with: "X"):
                return (variables[id].name, value)
            default:
                return nil
            }
        }
        
        return Solver.Result(status: status, variables: Dictionary(uniqueKeysWithValues: bindings))
    }
    
    // Returns the CBC status. Undefined status if not recognized.
    private func readStatus(fromString line: String) -> Solver.Status {
        let tokens = line.split(separator: " ")
        guard let status = tokens.first else { return .undefined }
        
        switch status {
        case "Optimal":
            return .optimal
        case "Infeasible":
            return .infeasible
        case "Integer":
            return .infeasible
        case "Unbounded":
            return .unbounded
        case "Stopped":
            return .unsolved
        default:
            return .undefined
        }
    }
    
}
