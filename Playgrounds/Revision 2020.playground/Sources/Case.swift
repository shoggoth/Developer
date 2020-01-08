import Foundation

public func caseExperiments() {
    
    multiMatches()
}

func multiMatches() {
    
    let vegetable = "red pepper"

    switch vegetable {

    case "celery":
        print("Add some raisins and make ants on a log.")
    case "cucumber", "watercress":
        print("That would make a good tea sandwich.")
    case let x where x.hasPrefix("red"):
        print("Is it a brightly coloured \(x)?")
    case let x where x.hasSuffix("pepper"):
        print("Is it a spicy \(x)?")
    default:
        print("Everything tastes good in soup.")
    }
}
