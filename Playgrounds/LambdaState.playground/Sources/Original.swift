/*
import Foundation

class GKState {
    
    func didEnter(from previousState: GKState?) {}
    func willExit(to nextState: GKState) {}
    func update(deltaTime: TimeInterval) {}
}

class LambdaState<T>: GKState {
    
    var summat: T?
    
    private var enterFunc: ((GKState?, LambdaState?) -> ())?
    private var leaveFunc: ((GKState, LambdaState<T>?) -> ())?
    private var deltaFunc: ((TimeInterval, LambdaState?) -> ())?

    public init(enter: ((GKState?, LambdaState?) -> ())? = nil, leave: ((GKState, LambdaState<T>?) -> ())? = nil, delta: ((TimeInterval, LambdaState?) -> ())? = nil) {
        
        enterFunc = enter
        leaveFunc = leave
        deltaFunc = delta
    }
    
    open override func didEnter(from previousState: GKState?) { enterFunc?(previousState, self) }
    
    open override func willExit(to nextState: GKState) { leaveFunc?(nextState, self) }
    
    open override func update(deltaTime: TimeInterval) {
        
        super.update(deltaTime: deltaTime)
        
        deltaFunc?(deltaTime, self)
    }
}

class PlayState: LambdaState<String> {
    
    func setup() { summat = "Hello" }
    func print() { Swift.print("summat = \(summat)") }
}

let foo = PlayState(
    enter: { _, playState in
        
        //scene.interstitial.setLevelName(name: "Refactoring + Lambda")
        //scene.interstitial.flashupNode(named: "GetReady")
        (playState as? PlayState)?.setup()
        //(playState as? PlayState)?.mobSpawner = scene.mobSpawner
        //(playState as? PlayState)?.pickupSpawner = scene.pickupSpawner
    },
    leave: { _, playState in
        
        (playState as? PlayState)?.print()
    })

//foo.didEnter(from: nil)
//foo.willExit(to: GKState())
 */
