//
//  Odds.swift
//  BetMe
//
//  Created by Rich Henry on 10/07/2017.
//  Copyright © 2017 Easysoft Ltd. All rights reserved.
//

import Foundation

struct LadderOdds {

    static func oddsIndex(forOdds odds: Decimal?, withLadderRungs rowCount: Int) -> Int? {

        guard let odds = odds else { return nil }

        var index: Int?

        switch odds {

        case let x where x < 2:
            index = rowCount + Int(NSDecimalNumber(decimal: (1.0 - x) / 0.01))
            break

        case let x where x < 3:
            index = (rowCount - 100) + Int(NSDecimalNumber(decimal: (2.0 - x) / 0.02))
            break

        case let x where x < 4:
            index = (rowCount - 150) + Int(NSDecimalNumber(decimal: (3.0 - x) / 0.05))
            break

        case let x where x < 6:
            index = (rowCount - 170) + Int(NSDecimalNumber(decimal: (4.0 - x) / 0.1))
            break

        case let x where x < 10:
            index = (rowCount - 190) + Int(NSDecimalNumber(decimal: (6.0 - x) / 0.2))
            break

        case let x where x < 20:
            index = (rowCount - 210) + Int(NSDecimalNumber(decimal: (10.0 - x) / 0.5))
            break

        case let x where x < 30:
            index = (rowCount - 230) + Int(NSDecimalNumber(decimal: (20.0 - x) / 1.0))
            break

        case let x where x < 50:
            index = (rowCount - 240) + Int(NSDecimalNumber(decimal: (30.0 - x) / 2.0))
            break

        case let x where x < 100:
            index = (rowCount - 250) + Int(NSDecimalNumber(decimal: (50.0 - x) / 5.0))
            break

        case let x where x < 1001:
            index = (rowCount - 260) + Int(NSDecimalNumber(decimal: (100.0 - x) / 10.0))
            break

        default: break

        }

        return index
    }

    static func oddsString(forLadderIndex index: Int, withLadderRungs rowCount: Int) -> String {

        var odds = 0.0

        switch rowCount - index {

        case let x where x < 100:
            odds = Double(x) * 0.01 + 1.01
            break

        case let x where x < 150:
            odds = Double(x) * 0.02 + 0.02
            break

        case let x where x < 170:
            odds = Double(x) * 0.05 - 4.45
            break

        case let x where x < 190:
            odds = Double(x) * 0.1 - 12.9
            break

        case let x where x < 210:
            odds = Double(x) * 0.2 - 31.8
            break

        case let x where x < 230:
            odds = Double(x) * 0.5 - 94.5
            break

        case let x where x < 240:
            odds = Double(x) - 209
            break

        case let x where x < 250:
            odds = Double(x) * 2.0 - 448
            break

        case let x where x < 260:
            odds = Double(x) * 5.0 - 1195
            break
            
        case let x where x < 350:
            odds = Double(x) * 10.0 - 2490
            break
            
        default: break
        }
        
        return String(format: odds >= 50.0 ? "%.0f" : "%.2f", odds)
    }
}
