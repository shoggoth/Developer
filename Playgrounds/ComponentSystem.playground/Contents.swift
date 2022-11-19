import GameplayKit

class MyComponent: GKComponent {
    
    let name: String
    var deinitFunc: (() -> ())? = nil
    
    init(name: String) {
        
        self.name = name
        super.init()
        print("\(name) init")
    }
    
    deinit {
        
        print("\(name) deinit")
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func update(deltaTime seconds: TimeInterval) {
        
        print("\(name) tick \(seconds)")
    }
}

var mc: MyComponent? = MyComponent(name: "Test")
let cs = GKComponentSystem(componentClass: MyComponent.self)

if let mcc = mc {
    
    mcc.deinitFunc = { print("gonna deinit") }
    mc = nil
    cs.addComponent(mcc)

    (0...8).forEach {
        
        //print("time \($0)")
        cs.update(deltaTime: Double($0) * 0.125)
    }
    
    cs.removeComponent(mcc)
}
