import Foundation

class TupleElements {
    
    var num: Int = 3
    
    var tup: (num: Int, name: String?) {
        
        get { return (num, "Bona Fide") }
        
        set { num = newValue.num }
    }
    
    deinit { print("Going away") }
}

public func classExperiments() {
    
    let elem = TupleElements()
    
    elem.tup = (27, nil)
    
    print(elem.tup)
}
