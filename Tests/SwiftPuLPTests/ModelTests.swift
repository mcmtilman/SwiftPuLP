import XCTest
import PythonKit
import SwiftPuLP

final class ModelTests: XCTestCase {
    
    func testCreateModel() throws {
        let model = Model(name: "Model", sense: .minimize)
        
        XCTAssertEqual(model.name, "Model")
        XCTAssertEqual(model.sense, .minimize)
    }

    func testCreateDefaultModel() throws {
        let model = Model(name: "Model")
        
        XCTAssertEqual(model.sense, .maximize)
    }

    func testModelAsPythonObject() throws {
        let pulp = Python.import("pulp")
        let problem = Model(name: "Model", sense: .minimize).pythonObject
        
        XCTAssertEqual(problem.name, "Model")
        XCTAssertEqual(problem.sense, pulp.LpMinimize)
    }

}
