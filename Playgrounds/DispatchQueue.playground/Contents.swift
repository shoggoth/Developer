//: Playground - noun: a place where people can play

import Cocoa

private func doANumberOfThingsInSerialOnABackgroundThreadAndThenCallSometingOnTheMainThread() {

    let q = DispatchQueue(label: "queuename")

    for i in 0..<10 {

        q.async {

            Thread.sleep(forTimeInterval: 1.0)

            print("Async dispatch \(i) on thread \(Thread.current.isMainThread) \(Thread.current)")
        }
    }

    q.async { DispatchQueue.main.sync { print("MT Finish up \(Thread.current.isMainThread)") }}

    print("Moving on with main thread \(Thread.current.isMainThread)")
}

private func doANumberOfThingsConcurrentlyAndThenCallSometingOnTheMainThreadWhenAllHaveFinished() {

    let group = DispatchGroup()

    for i in 0..<10 {

        group.enter()

        DispatchQueue.global().async {

            Thread.sleep(forTimeInterval: 3.0)

            print("Async dispatch \(i) on thread \(Thread.current.isMainThread) \(Thread.current)")

            group.leave()
        }
    }

    group.notify(queue: DispatchQueue.main) { print("MT Finish up \(Thread.current.isMainThread)") }

    print("Moving on with main thread \(Thread.current.isMainThread)")
}

private func someOtherWayOfConcurrentlyDoingThings() {

    typealias CallBack = (_ result: [Int]) -> Void

    func longCalculations (completion: @escaping CallBack) {
        let backgroundQ = DispatchQueue.global()
        let group = DispatchGroup()

        var fill:[Int] = []
        for number in 0..<100 {

            group.enter()
            backgroundQ.async(group: group,  execute: {

                Thread.sleep(forTimeInterval: 10.0)
                if number > 50 { fill.append(number) }

                group.leave()
            })
        }

        group.notify(queue: DispatchQueue.main, execute: { print("All Done"); completion(fill) })
    }

    longCalculations(){ print($0) }

    print("Moving on with main thread \(Thread.current.isMainThread)")
}
