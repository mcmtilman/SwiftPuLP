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
    public init(commandPath: String) {
        self.commandPath = commandPath
    }
    
    // MARK: -

    /// Solves the model by directly accssing the CBC executable and returns the result.
    ///
    /// Returns nil in case of failure.
    public func solve(_ model: Model) -> Solver.Result? {
        guard let tempFolder = try? FileManager.default.url(for: .itemReplacementDirectory, in: .userDomainMask, appropriateFor: URL(fileURLWithPath: NSHomeDirectory()), create: true) else { return nil }
        let modelPath = tempFolder.appendingPathComponent("model.mps").path
        let solutionPath = tempFolder.appendingPathComponent("model.sol").path
        defer { removeFolder(tempFolder) }
        
        guard MPSWriter().writeModel(model, toFile: modelPath),
              executeCommand(modelPath, solutionPath, model.optimization == .maximize) else { return nil }
        
        return SolutionReader().readResultFromFile(atPath: solutionPath, for: model)
    }
    
    // Executes the CBC command.
    //
    // Returns true if successful.
    private func executeCommand(_ modelPath: String, _ solutionPath: String, _ maximize: Bool = false) -> Bool {
        #if os(macOS)
            let process = Process()
        
            process.launchPath = commandPath
            process.arguments = [modelPath, maximize ? "max" : "min", "timeMode", "elapsed", "branch", "printingOptions", "normal", "solution", solutionPath] // branch when mip
            process.launch()
            process.waitUntilExit()
            
            if process.terminationStatus == 0 { return true }

            print("CBC exited with status: \(process.terminationStatus)")
        #endif
        
        return false
    }
    
    // Removes the temporary folder.
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
 Writes the model to given file in MPS format.
 */
fileprivate struct MPSWriter {
    
    // MARK: -
    
    // Writes the model to given file in MPS format. Answers if successful.
    
    // String(format:) is slow, so cache logical variable and constraint names.
    func writeModel(_ model: Model, toFile path: String) -> Bool {
        guard FileManager.default.createFile(atPath: path, contents: nil, attributes: nil),
              let fileHandle = FileHandle(forWritingAtPath: path) else { return false }
        var writer = FileWriter(fileHandle: fileHandle)

        let variables = model.variables
        let variableNames = (0 ..< variables.count).map { i in String(format: "X%07d", i) }
        let constraintNames = (0 ..< model.constraints.count).map { i in String(format: "C%07d", i) }
        let one = String(format: "%.12e", 1.0) // Factor 1 is often used in several unit test models.

        // MARK: -
        
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
                    if variable.domain != .real {
                        writer.append("    MARK      'MARKER'                 'INTORG'\n")
                    }
                    for (i, factor) in factors {
                        let name = i >= 0 ? constraintNames[i] : "OBJ     "
                        
                        writer.append("    \(variableNames[v])  \(name)   \(toMPS(factor))\n")
                    }
                    if variable.domain != .real {
                        writer.append("    MARK      'MARKER'                 'INTEND'\n")
                    }
                    
               }
            }
        }
        
        // Writes the constants of the various constraints.
        // Each constant is the constraint's constant - its function constant.
        func writeRHSLines() {
            writer.append("RHS\n")
            for (i, (constraint, _)) in model.constraints.enumerated() {
                let constant = constraint.constant - constraint.function.constant
                
                writer.append("    RHS       \(constraintNames[i])   \(toMPS(constant))\n")
            }
        }
        
        // Writes the (implicitly) binary variables, i.e. integer variables with (min, max) == (0, 1) are also considered to be binary.
        func writeBoundsLines() {
            writer.append("BOUNDS\n")
            for (v, variable) in variables.enumerated() where isBinary(variable) {
                writer.append(" BV BND       \(variableNames[v])\n")
            }
        }

        // Writes closing line.
        func writeEndOfDataLine() {
            writer.append("ENDATA\n")
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
            double == 1 ? one : String(format: "%.12e", double)
        }
        
        // Converts the optimization to MPS format.
        func toMPS(_ optimization: Model.Optimization) -> String {
            switch optimization {
            case .minimize:
                return "Minimized"
            case .maximize:
                return "Maximized"
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
        
        // Answers if the variable behaves like a binary.
        func isBinary(_ variable: Variable) -> Bool {
            variable.domain != .real && (variable.minimum, variable.maximum) == (0, 1)
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
    
}


// MARK: -

/**
 Buffers lines of strings before writing to file.
 */
fileprivate struct FileWriter {
    
    // MARK: -

    // Valid file handle.
    let fileHandle: FileHandle
    
    // Maximum number of lines to buffer.
    let capacity = 500
    
    // Actual buffer.
    var lines = [String]()
    
    // MARK: -

    // If the buffer is full flush lines to file before buffering a new line.
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
    
    // FLush the strings currently in the buffer.
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
fileprivate struct SolutionReader {
    
    // MARK: -

    // Returns a result constructed from the CBC output file, or nil in case of failure.
    func readResultFromFile(atPath path: String, for model: Model) -> Solver.Result? {
        do {
            return try readFromFile(path, model)
        } catch {
            print("Error reading solution file: \(error)")
            return nil
        }
    }

    // MARK: -

    // eads the status and variable bindings from the CBC output file.
    private func readFromFile(_ path: String, _ model: Model) throws -> Solver.Result? {
        let data = try String(contentsOfFile: path, encoding: .utf8)
        let lines = data.components(separatedBy: .newlines)
        
        guard let line = lines.first else { return nil }
        let status = readStatus(fromString: line)
        let variables = model.variables
        let bindings = lines.dropFirst().dropLast().compactMap { (line) -> (String, Double)? in
            let tokens = line.split(separator: " ")
            
            switch (Int(tokens[0]), tokens[1], Double(tokens[2])) {
            case (let id?, let name, let value?) where name.starts(with: "X"):
                return (variables[id].name, value)
            default:
                return nil
            }
        }
        
        return Solver.Result(status: status, variables: Dictionary(uniqueKeysWithValues: bindings))
    }
    
    // Reads the CBC status. Undefined if not recognized.
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
