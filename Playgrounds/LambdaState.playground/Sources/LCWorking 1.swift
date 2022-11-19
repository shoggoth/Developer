import Foundation

class GKState {
    
    func didEnter(from previousState: GKState?) {}
    func willExit(to nextState: GKState) {}
    func update(deltaTime: TimeInterval) {}
}

protocol LambdaCallable {
    
    associatedtype U
    
    var enterFunc: ((GKState?, U?) -> ())? { get }
    var leaveFunc: ((GKState, U?) -> ())? { get }
    var deltaFunc: ((TimeInterval, U?) -> ())? { get }
}

class LambdaState<T: LambdaCallable>: GKState {
    
    var lambdas: T
    
    public init(l: T) { lambdas = l }
        
    open override func didEnter(from previousState: GKState?) { lambdas.enterFunc?(previousState, lambdas as? T.U) }
    
    open override func willExit(to nextState: GKState) { lambdas.leaveFunc?(nextState, lambdas as? T.U) }
    
    open override func update(deltaTime: TimeInterval) {
        
        super.update(deltaTime: deltaTime)
        
        lambdas.deltaFunc?(deltaTime, lambdas as? T.U)
    }
}

struct PlayState: LambdaCallable {
    
    let enterFunc: ((GKState?, PlayState?) -> ())?
    let leaveFunc: ((GKState, PlayState?) -> ())?
    let deltaFunc: ((TimeInterval, PlayState?) -> ())?
    
    func enter() { print("success enter") }
    func leave() { print("success leave") }
    func delta() { print("success delta") }
}

class NoPlayState: LambdaCallable {

    typealias U = NoPlayState
    
    var enterFunc: ((GKState?, U?) -> ())? = { _, t in print("Not entering \(String(describing: t))") }
    var leaveFunc: ((GKState, U?) -> ())? = { _, t in print("Not entering \(String(describing: t))") }
    var deltaFunc: ((TimeInterval, U?) -> ())? = { _, t in print("Not entering \(String(describing: t))") }
}

struct VoidPlayState: LambdaCallable {

    typealias U = Void
    
    var enterFunc: ((GKState?, U?) -> ())? = nil
    var leaveFunc: ((GKState, U?) -> ())? = nil
    var deltaFunc: ((TimeInterval, U?) -> ())? = nil
}

let foo = LambdaState(l: PlayState(
    enterFunc: { state, str in str?.enter() },
    leaveFunc: { state, str in str?.leave() },
    deltaFunc:  { state, str in str?.delta() }
))

foo.didEnter(from: nil)
foo.willExit(to: GKState())
foo.update(deltaTime: 0.23)

let bar = LambdaState(l: NoPlayState())

bar.didEnter(from: nil)
bar.willExit(to: GKState())
bar.update(deltaTime: 0.23)

let baz = LambdaState(l: VoidPlayState())

baz.didEnter(from: nil)
baz.willExit(to: GKState())
baz.update(deltaTime: 0.23)

let fop = LambdaState(l: PlayState(
    enterFunc: { state, str in print(foo) },
    leaveFunc: { state, str in print(bar) },
    deltaFunc:  { state, str in print(baz) }
))

fop.didEnter(from: nil)
fop.willExit(to: GKState())
fop.update(deltaTime: 0.23)


