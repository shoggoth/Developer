//
//  JSONDate.swift
//  BetMe
//
//  Created by Rich Henry on 12/06/2017.
//  Copyright © 2017 Easysoft Ltd. All rights reserved.
//

import Foundation

public struct JSONDateFormatter {

    private static var jsonDateFormatter: DateFormatter = {

        let jdf = DateFormatter()

        jdf.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"

        return jdf
    }()

    public static func fetchDateTimeString(fromJSONDate dateString: String, dateFormat df: DateFormatter.Style, timeFormat tf: DateFormatter.Style) -> String? {

        guard let time = jsonDateFormatter.date(from: dateString) else { return nil }

        return DateFormatter.localizedString(from: time, dateStyle: df, timeStyle: tf)
    }
}
