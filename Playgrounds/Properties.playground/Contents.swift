//: Playground - noun: a place where people can play

import Cocoa

//: Stored properties store constant and variable values as part of an instance

struct FixedLengthRange {

    var firstValue: Int
    let length: Int
}

var rangeOfThreeItems = FixedLengthRange(firstValue: 0, length: 3)
// the range represents integer values 0, 1, and 2
rangeOfThreeItems.firstValue = 6
// the range now represents integer values 6, 7, and 8
rangeOfThreeItems = FixedLengthRange(firstValue: 1, length: 7)

let rangeOfFourItems = FixedLengthRange(firstValue: 0, length: 4)
// this range represents integer values 0, 1, 2, and 3
// rangeOfFourItems.firstValue = 6
// The above will report an error, even though firstValue is a variable property

// This behavior is due to structures being value types. When an instance of a value type is marked as a constant, so are all of its properties.
// The same is not true for classes, which are reference types. If you assign an instance of a reference type to a constant, you can still change that instance’s variable properties

class CFixedLengthRange {

    var firstValue: Int
    let length: Int

    init(firstValue f: Int, length l: Int) { firstValue = f; length = l }
}

var rangeOfThreeItemsC = CFixedLengthRange(firstValue: 0, length: 3)
// the range represents integer values 0, 1, and 2
rangeOfThreeItemsC.firstValue = 6
// the range now represents integer values 6, 7, and 8
rangeOfThreeItemsC = CFixedLengthRange(firstValue: 1, length: 7)

let rangeOfFourItemsC = CFixedLengthRange(firstValue: 0, length: 4)
// this range represents integer values 0, 1, 2, and 3
rangeOfFourItemsC.firstValue = 6
// The above will not report an error as only the reference is constant due to the let

// A lazy stored property is a property whose initial value is not calculated until the first time it is used.

class DataImporter {

    /*
     DataImporter is a class to import data from an external file.
     The class is assumed to take a non-trivial amount of time to initialize.
     */
    var filename = "data.txt"
    // the DataImporter class would provide data importing functionality here
}

class DataManager {

    lazy var importer = DataImporter()
    var data = [String]()
    // the DataManager class would provide data management functionality here
}

let manager = DataManager()
manager.data.append("Some data")
manager.data.append("Some more data")
// the DataImporter instance for the importer property has not yet been created at this point

print(manager.importer.filename)
// the DataImporter instance for the importer property has now been created

//: Computed properties calculate (rather than store) a value.

struct Point {
    var x = 0.0, y = 0.0
}

struct Size {
    var width = 0.0, height = 0.0
}

struct Rect {

    // Stored properties
    var origin = Point()
    var size = Size()

    // Computed property
    var center: Point {

        get {
            let centerX = origin.x + (size.width / 2)
            let centerY = origin.y + (size.height / 2)
            return Point(x: centerX, y: centerY)
        }

        set(newCenter) {
            origin.x = newCenter.x - (size.width / 2)
            origin.y = newCenter.y - (size.height / 2)
        }
    }
}

var square = Rect(origin: Point(x: 0.0, y: 0.0), size: Size(width: 10.0, height: 10.0))
let initialSquareCenter = square.center
square.center = Point(x: 15.0, y: 15.0)
print("square.origin is now at (\(square.origin.x), \(square.origin.y))")
// Prints "square.origin is now at (10.0, 10.0)"

struct AlternativeRect {

    // Stored properties
    var origin = Point()
    var size = Size()

    // Computed property
    var center: Point {

        get {
            let centerX = origin.x + (size.width / 2)
            let centerY = origin.y + (size.height / 2)

            return Point(x: centerX, y: centerY)
        }

        set { // If a computed property’s setter does not define a name for the new value to be set, a default name of newValue is used
            origin.x = newValue.x - (size.width / 2)
            origin.y = newValue.y - (size.height / 2)
        }
    }
}

// Read-only computed properties

// You must declare computed properties—including read-only computed properties as variable properties with the var keyword, because their value is not fixed.
// The let keyword is only used for constant properties, to indicate that their values cannot be changed once they are set as part of instance initialization.

struct Cuboid {

    var width = 0.0, height = 0.0, depth = 0.0

    var volume: Double {

        return width * height * depth
    }
}

let fourByFiveByTwo = Cuboid(width: 4.0, height: 5.0, depth: 2.0)
print("the volume of fourByFiveByTwo is \(fourByFiveByTwo.volume)")
// Prints "the volume of fourByFiveByTwo is 40.0"

// Property observers

class StepCounter {

    var totalSteps: Int = 0 {

        willSet(newTotalSteps) { // Could use the default of newValue here instead.

            // Not just for properties!
            var foo: Double { return 3.7 }

            var bar: String {

                get { return "get" }
                set { print("setting bar to \(newValue)") }
            }

            bar = "Bar"
            
            var baz: String = "DefaultBaz" {

                willSet { print("Will set baz to \(newValue)") }
                didSet { print("Did set baz from \(oldValue)") }
            }

            baz = "Baz"
            
            print("About to set totalSteps to \(newTotalSteps) \(foo) \(bar) \(baz)")
        }

        didSet {
            if totalSteps > oldValue  {
                print("Added \(totalSteps - oldValue) steps")
            }
        }
    }
}
let stepCounter = StepCounter()
stepCounter.totalSteps = 200
// About to set totalSteps to 200
// Added 200 steps
stepCounter.totalSteps = 360
// About to set totalSteps to 360
// Added 160 steps
stepCounter.totalSteps = 896
// About to set totalSteps to 896
// Added 536 steps

//: Type properties

// You define type properties with the static keyword.
// For computed type properties for class types, you can use the class keyword instead to allow subclasses to override the superclass’s implementation.

struct SomeStructure {
    static var storedTypeProperty = "Some value."
    static var computedTypeProperty: Int {
        return 1
    }
}

enum SomeEnumeration {
    static var storedTypeProperty = "Some value."
    static var computedTypeProperty: Int {
        return 6
    }
}

class SomeClass {
    static var storedTypeProperty = "Some value."
    static var computedTypeProperty: Int {
        return 27
    }
    class var overrideableComputedTypeProperty: Int {
        return 107
    }
}

print(SomeStructure.storedTypeProperty)
// Prints "Some value."
SomeStructure.storedTypeProperty = "Another value."
print(SomeStructure.storedTypeProperty)
// Prints "Another value."
print(SomeEnumeration.computedTypeProperty)
// Prints "6"
print(SomeClass.computedTypeProperty)
// Prints "27"

struct AudioChannel {
    static let thresholdLevel = 10
    static var maxInputLevelForAllChannels = 0
    var currentLevel: Int = 0 {
        didSet {
            if currentLevel > AudioChannel.thresholdLevel {
                // cap the new audio level to the threshold level
                // Note this does not cause didSet to be called again.
                currentLevel = AudioChannel.thresholdLevel
            }
            if currentLevel > AudioChannel.maxInputLevelForAllChannels {
                // store this as the new overall maximum input level
                AudioChannel.maxInputLevelForAllChannels = currentLevel
            }
        }
    }
}