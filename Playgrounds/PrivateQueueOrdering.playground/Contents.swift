//: Playground - noun: a place where people can play

import Cocoa

let mergeQueue = DispatchQueue(label: "mobi.dogstar.merge_queue")
let dummyQueue = DispatchQueue(label: "mobi.dogstar.merge_queue")

// This shouldn't happen
if dummyQueue == mergeQueue { print("Same named queues relate to the same queue.") }

// Test timimg…

for i in 0...10 {

    mergeQueue.async {

        print("Doing merge task")
        Thread.sleep(forTimeInterval: 1.0)
        print("Finished merge task")
    }
    }

    mergeQueue.async {

        DispatchQueue.main.sync {
            
            print("Back to main queue")
        }
}
