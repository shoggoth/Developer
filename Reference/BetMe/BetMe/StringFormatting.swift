//
//  StringFormatting.swift
//  BetMe
//
//  Created by Rich Henry on 23/06/2017.
//  Copyright © 2017 Easysoft Ltd. All rights reserved.
//

import Foundation

func formattedNameString(dataDictionary data: [String : Any], mapping: [String : String]) -> String? {

    guard var formattedString = data["format"] as? String else { return nil }

    if let dateMapping = mapping["%D"], let dateString = data[dateMapping] as? String {

        formattedString = formattedString.replacingOccurrences(of: "%D", with: JSONDateFormatter.fetchDateTimeString(fromJSONDate: dateString, dateFormat: .none, timeFormat: .short) ?? "")
    }

    let mapFunc : (_ formatIdentifier: String) -> Void = { formatIdentifier in

        if let m = mapping[formatIdentifier], let subString = data[m] as? String {

            formattedString = formattedString.replacingOccurrences(of: formatIdentifier, with: subString)
        }
    }

    mapFunc("%E")
    mapFunc("%M")
    
    return formattedString
}
