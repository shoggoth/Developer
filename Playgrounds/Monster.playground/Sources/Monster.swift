import Foundation

// Just testing out access from the other files here.
public struct MonsterStruct {
    
    let name: String
    
    public init() {
        
        // 'tarded.
        // Both the struct and the init have to be public or nothing works in a playground.
        // https://stackoverflow.com/questions/29637444
        self.init(name: "Nogger")
    }
    
    public init(name: String) {
        
        self.name = name
    }
}
