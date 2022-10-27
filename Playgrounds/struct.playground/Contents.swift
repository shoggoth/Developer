import Foundation

struct Struct {
    
    var name: String = "Struct"
    let iden: String = UUID().uuidString
}

class Class {
    
    var name: String = "Class"
    let iden: String = UUID().uuidString
}

var s1 = Struct()
var s2 = s1
s1.name = "Nogger"
s2.name = "Jogger"

var c1 = Class()
var c2 = c1
c1.name = "Nogger"
c2.name = "Jogger"

print(s1)
print(s2)
print("\(c1) \(c1.name) \(c1.iden)")
print("\(c2) \(c2.name) \(c2.iden)")
