import Foundation

public func shapeExperiments() {
    
    let shape = Shape()
    
    shape.numberOfSides = 7
    
    print("shape = \(shape.simpleDescription())")
    
    let namedShape = NamedShape(name: "Octagon")
    
    namedShape.numberOfSides = 8
    print("shape = \(namedShape.simpleDescription())")}

class Shape {
    
    var numberOfSides = 0
    
    func simpleDescription() -> String { return "A \(numberOfSides) sided shape" }
}

class NamedShape {
    
    var numberOfSides = 0
    var name: String
    
    init(name: String) {
        
        self.name = name
    }
    
    func simpleDescription() -> String { return "A \(numberOfSides) sided shape named \(name)" }
}
