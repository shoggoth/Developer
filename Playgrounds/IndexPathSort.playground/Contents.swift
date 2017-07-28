//: Playground - noun: a place where people can play

import Cocoa

let paths: [IndexPath] = [IndexPath(item: 98, section: 0), IndexPath(item: 99, section: 0), IndexPath(item: 0, section: 1), IndexPath(item: 1, section: 1)]

let sorted = paths.sorted{ $0.section == $1.section ? $0.item > $1.item : $0.section > $1.section }

print(sorted)