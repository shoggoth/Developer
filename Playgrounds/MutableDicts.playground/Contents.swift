//: Playground - noun: a place where people can play

import Cocoa

let data  = ["data" : "none"]
var dicts = [["id" : "one", "data" : data], ["id" : "two", "data" : data], ["id" : "three", "data" : data]]

let idToChange = "two"

for var d in dicts {

    if d["id"] as? String == idToChange {

        d["added"] = "Added"
    }
}

print(dicts)

dicts[0] = ["thiswas" : "added"]

print(dicts)

for (i, d) in dicts.enumerated() {

    if d["id"] as? String == idToChange {

        dicts[i] = ["andthiswas" : "also added"]
        dicts[i]["data"] = ["yeah" : "but"]
    }
}

print(dicts)
