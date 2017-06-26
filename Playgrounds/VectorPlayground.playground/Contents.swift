//: Playground - noun: a place where people can play

import Cocoa
import SpriteKit

struct Vec2 {

    let x: Float
    let y: Float

    var len: Float { return hypotf(x, y) }

    var norm: Vec2 {

        let l = len

        return Vec2(x: x / l, y: y / l)
    }

    func dot(_ v: Vec2) -> Float {

        return x * v.x + y * v.y
    }
}

let vec = Vec2(x: 0.707, y: 0.707)
let xAxis = Vec2(x: 1, y: 0)
let yAxis = Vec2(x: 0, y: 1)
let dAxis = Vec2(x: 1, y: 1).norm

let xProj = xAxis.dot(vec)
let yProj = yAxis.dot(vec)
let dProj = dAxis.dot(vec)


let skv = Vector2(