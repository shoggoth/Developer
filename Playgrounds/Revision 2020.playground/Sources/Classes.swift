import Foundation

public func classExperiments() {
    
    let elem = TupleElements()
    let mung = Mung(value: 23)
    
    elem.tup = (27, nil)
    
    print(elem.tup)
    
    Mung.lloigor = "Ftang"
    
    if let t = Mung.lloigor { print("mung = \(mung.value) Mung.lloigor = \(t)") }
}

class TupleElements {
    
    var num: Int = 3
    
    var tup: (num: Int, name: String?) {
        
        get { return (num, "Bona Fide") }
        
        set { num = newValue.num }
    }
    
    deinit { print("TupleElements Going away") }
}

class Mung {
    
    static var lloigor: String? = nil
    
    var value: Int = 0
    
    init(value: Int) {
        
        self.value = value
    }
    
    deinit { print("Mung \(value) Going away") }
}
