//: Playground - noun: a place where people can play

import Cocoa

var startDate = "2017-06-12T11:47:00.000Z"

let dateFormatter = DateFormatter()
dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"

let foo = dateFormatter.date(from: startDate)

DateFormatter.localizedString(from: foo!, dateStyle: .none, timeStyle: .short)

let isoDateFormatter = ISO8601DateFormatter()
isoDateFormatter.formatOptions = [.withFullDate, .withDashSeparatorInDate, .withFullTime, .withColonSeparatorInTime]

let bar = isoDateFormatter.date(from: startDate)
