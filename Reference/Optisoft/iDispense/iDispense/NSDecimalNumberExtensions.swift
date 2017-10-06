//
//  NSDecimalNumberExtensions.swift
//  iDispense
//
//  Created by Richard Henry on 17/11/2015.
//  Copyright © 2015 Optisoft Ltd. All rights reserved.
//

import Foundation

func ==(lhs: NSDecimalNumber, rhs: NSDecimalNumber) -> Bool { return lhs.compare(rhs) == ComparisonResult.orderedSame }
func <=(lhs: NSDecimalNumber, rhs: NSDecimalNumber) -> Bool { return !(lhs > rhs) || lhs == rhs }
func >=(lhs: NSDecimalNumber, rhs: NSDecimalNumber) -> Bool { return lhs > rhs || lhs == rhs }
func >(lhs: NSDecimalNumber, rhs: NSDecimalNumber) -> Bool { return lhs.compare(rhs) == ComparisonResult.orderedDescending }
func <(lhs: NSDecimalNumber, rhs: NSDecimalNumber) -> Bool { return !(lhs > rhs) }

func +(lhs: NSDecimalNumber, rhs: NSDecimalNumber) -> NSDecimalNumber { return lhs.adding(rhs) }
func -(lhs: NSDecimalNumber, rhs: NSDecimalNumber) -> NSDecimalNumber { return lhs.subtracting(rhs) }
func *(lhs: NSDecimalNumber, rhs: NSDecimalNumber) -> NSDecimalNumber { return lhs.multiplying(by: rhs) }
func /(lhs: NSDecimalNumber, rhs: NSDecimalNumber) -> NSDecimalNumber { return lhs.dividing(by: rhs) }

func +=(lhs: inout NSDecimalNumber, rhs: NSDecimalNumber) { lhs = lhs.adding(rhs) }
func -=(lhs: inout NSDecimalNumber, rhs: NSDecimalNumber) { lhs = lhs.subtracting(rhs) }
func *=(lhs: inout NSDecimalNumber, rhs: NSDecimalNumber) { lhs = lhs.multiplying(by: rhs) }
func /=(lhs: inout NSDecimalNumber, rhs: NSDecimalNumber) { lhs = lhs.dividing(by: rhs) }

prefix func ++(lhs: inout NSDecimalNumber) -> NSDecimalNumber { return lhs.adding(NSDecimalNumber.one) }
postfix func ++(lhs: inout NSDecimalNumber) -> NSDecimalNumber {

    let copy : NSDecimalNumber = lhs.copy() as! NSDecimalNumber
    lhs = lhs.adding(NSDecimalNumber.one)
    return copy
}

prefix func --(lhs: inout NSDecimalNumber) -> NSDecimalNumber { return lhs.subtracting(NSDecimalNumber.one) }
postfix func --(lhs: inout NSDecimalNumber) -> NSDecimalNumber {

    let copy : NSDecimalNumber = lhs.copy() as! NSDecimalNumber
    lhs = lhs.subtracting(NSDecimalNumber.one)
    return copy
}

prefix func +(lhs: NSDecimalNumber) -> NSDecimalNumber { return lhs }
prefix func -(lhs: NSDecimalNumber) -> NSDecimalNumber {

    let minusOne: NSDecimalNumber = NSDecimalNumber(string: "-1")
    return lhs.multiplying(by: minusOne)
}

//infix operator ^^ { associativity left precedence 140 }
//func ^^(lhs: NSDecimalNumber, rhs: Int) -> NSDecimalNumber { return lhs.decimalNumberByRaisingToPower(rhs) }
