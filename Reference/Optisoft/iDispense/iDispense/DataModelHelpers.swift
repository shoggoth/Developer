//
//  DataModelHelpers.swift
//  iDispense
//
//  Created by Richard Henry on 02/02/2015.
//  Copyright (c) 2015 Optisoft Ltd. All rights reserved.
//

import Foundation

// MARK: Data types & extensions

typealias RangeResAndCount = (base: Double, resolution: Double, count: Int)

private extension Double {

    enum Kind { case negative, zero, positive }

    var kind: Kind {

        switch self {

        case 0: return .zero

        case let x where x > 0: return .positive

        default: return .negative
        }
    }
}

class Dioptre {

    static var zeroSymbol = "0"
    static var defaultResolution = 0.25

    static var dioptreFormatter: NumberFormatter {

        let formatter = NumberFormatter()

        formatter.numberStyle = .decimal
        formatter.positivePrefix = "+"
        formatter.zeroSymbol = zeroSymbol
        formatter.minimumFractionDigits = 2

        return formatter
    }

    var resolution: Double
    var upperLimit: Double
    var lowerLimit: Double

    var value: Double = 0.0
    var index: Int {

        get { return Int((value - lowerLimit) / resolution) }
        set { value = Double(newValue) * resolution + lowerLimit }
    }

    init(dv: Double, range:(lo: Double, hi: Double) = (-10, 10), res: Double = defaultResolution) { lowerLimit = range.lo; upperLimit = range.hi; resolution = res; value = dv }
    init(iv: Int, range:(lo: Double, hi: Double) = (-10, 10), res: Double = defaultResolution) { lowerLimit = range.lo; upperLimit = range.hi; resolution = res; index = iv }

    convenience init(dv: Double, rrc: RangeResAndCount) { self.init(dv: dv, range:(rrc.base, rrc.base + rrc.resolution * Double(rrc.count)), res: rrc.resolution) }
    convenience init(iv: Int, rrc: RangeResAndCount) { self.init(iv: iv, range:(rrc.base, rrc.base + rrc.resolution * Double(rrc.count)), res: rrc.resolution) }

    func dioptreString() -> String {

        if value > upperLimit || value < lowerLimit { return "RANGE" } else { if value == 0.0 { return Dioptre.zeroSymbol } else { return String.localizedStringWithFormat("%.2f", value) }}
    }
    
    func dioptreFormattedString() -> String {

        if value > upperLimit || value < lowerLimit { return "RANGE" } else { if value == 0.0 { return Dioptre.zeroSymbol } else { return Dioptre.dioptreFormatter.string(from: NSNumber(value: value as Double))! }}
    }
    
    func dioptreAttributedString() -> NSAttributedString {

        if value > upperLimit || value < lowerLimit { return NSAttributedString(string: "RANGE", attributes: [:]) }

        return dioptrePickerStringForValueWithZeroString(value, Dioptre.zeroSymbol);
    }
}

// MARK: - Prescription extensions

extension Prescription {

    func hasAddition() -> Bool { return right?.add != 0 || left?.add != 0 }
}

// MARK: - Order extensions

extension Order {

    var currencySymbol: String {

        get {
            let formatter = NumberFormatter()
            formatter.locale = Locale.current
            formatter.numberStyle = .currency

            return formatter.currencySymbol
        }
    }

    var prefixedOrderNumber: String {

        get {

            let on = self.orderNumber?.stringValue ?? "0"
            if let op = self.orderPrefix , op != "" { return on + "-" + op } else { return on }
        }
    }

    // Pricing calculations

    var rawPrice: NSDecimalNumber {

        get {
            var rawPrice = NSDecimalNumber.zero

            // Add the lens price
            if let lensOrder = self.lensOrder { rawPrice = rawPrice + lensOrder.price }

            // Add the frame price
            if let frameOrder = self.frameOrder { rawPrice = rawPrice + frameOrder.price }

            return rawPrice
        }
    }

    var totalPrice: NSDecimalNumber {

        get {

            var adjustedPrice = NSDecimalNumber.zero
            let adjustments = sumOfAdjustments()

            // Calculate and add on the lens price
            if let lensOrder = lensOrder { adjustedPrice += lensOrder.price * adjustments[1].mult + adjustments[1].const }

            // Calculate and add on the frame price
            if let frameOrder = frameOrder { adjustedPrice += frameOrder.price * adjustments[2].mult + adjustments[2].const }

            // Add in the miscellaneous charges
            if let charges = charges { adjustedPrice = adjustedPrice + charges }

            // Calculate and add on the order price
            return adjustedPrice * adjustments[0].mult + adjustments[0].const
        }
    }
    
    var adjustmentsSummary: String {

        guard let adjustments = adjustments, adjustments.count != 0 else { return "No Adjustments Selected" }

        var adjustmentStrings: [String] = []
        let sum = sumOfAdjustments()

        var lensAdjustedPrice = NSDecimalNumber.zero
        var frameAdjustedPrice = NSDecimalNumber.zero

        // Put in a string describing what has happened to the lenses
        if let lensOrder = lensOrder, lensOrder.price != 0 && sum[1].count > 0 {

            lensAdjustedPrice = lensOrder.price * sum[1].mult + sum[1].const
            adjustmentStrings.append("Lens Order \(currencySymbol)\(lensOrder.price) \(sum[1].count) adjustment(s): \(sum[1].mult * 100)%, \(currencySymbol)\(sum[1].const) = \(currencySymbol)\(lensAdjustedPrice).")
        }
        
        // Put in a string describing what has happened to the frames
        if let frameOrder = frameOrder, frameOrder.price != 0 && sum[2].count > 0 {

            frameAdjustedPrice = frameOrder.price * sum[2].mult + sum[2].const
            adjustmentStrings.append("Frame Order \(currencySymbol)\(frameOrder.price) \(sum[2].count) adjustment(s): \(sum[2].mult * 100)%, \(currencySymbol)\(sum[2].const) = \(currencySymbol)\(frameAdjustedPrice).")
        }

        // Put in a string describing adjustments to the entire order.
        let lensAndFramePrice = lensAdjustedPrice + frameAdjustedPrice
        let adjustedPrice = (lensAndFramePrice + charges!) * sum[0].mult + sum[0].const
        adjustmentStrings.append("Total (Lens + Frame: \(currencySymbol)\(lensAndFramePrice)) + Misc. Charges: \(currencySymbol)\(self.charges!) \(sum[0].count) adjustment(s): \(sum[0].mult * 100)%, \(currencySymbol)\(sum[0].const) = \(currencySymbol)\(adjustedPrice).")

        let i = ""; let s = "\n"
        return adjustmentStrings.reduce(i) { $0 == i ? i + $1 : $0 + s + $1 }
    }

    fileprivate func sumOfAdjustments() -> [(count: NSInteger, mult: NSDecimalNumber, const: NSDecimalNumber)] {

        var adjSum: [(count: NSInteger, mult: NSDecimalNumber, const: NSDecimalNumber)] = [(0, 1, 0), (0, 1, 0), (0, 1, 0)]

        if let adjustments = adjustments {

            for adjustment in adjustments {

                // Get and check the type is within the range.
                if let t = adjustment.type?.intValue, t < adjSum.count {

                    let multiplier = adjustment.multiplier! / 100
                    let constant = adjustment.constant ?? 0

                    adjSum[t].count += 1
                    adjSum[t].mult = adjSum[t].mult + multiplier
                    adjSum[t].const = adjSum[t].const + constant
                }
            }
        }

        return adjSum
    }

    // Patient details

    enum DOBFormat { case shortStyle, longDateStyle, longStyle }

    func creationDateString(_ dobFormat : DOBFormat = DOBFormat.longDateStyle) -> String {

        if self.patient != nil {

            let dateStyle : DateFormatter.Style = dobFormat == .shortStyle ? .short : .long
            let timeStyle : DateFormatter.Style = dobFormat == .longStyle ? .short : .none

            return "\(DateFormatter.localizedString(from: self.date ?? Date(), dateStyle: dateStyle, timeStyle: timeStyle))"

        } else { return "" }
    }

    var creationDateStr : String { get { return creationDateString() }}
    var creationDateShortStr : String { get { return creationDateString(.shortStyle) }}
    var creationDateFilenameStr : String { get { return creationDateString(.shortStyle).replacingOccurrences(of: "/", with: "-"); }}

    func patientDOBString(_ dobFormat : DOBFormat = DOBFormat.longDateStyle) -> String {

        if self.patient != nil {

            let dateStyle : DateFormatter.Style = dobFormat == .shortStyle ? .short : .long
            let timeStyle : DateFormatter.Style = dobFormat == .longStyle ? .short : .none

            return "\(DateFormatter.localizedString(from: self.patient?.birthDate ?? Date(), dateStyle: dateStyle, timeStyle: timeStyle))"

        } else { return "" }
    }
    
    func patientFullName_() -> String {

        var fullName = "New Patient"

        if let patient = self.patient, let firstName = patient.firstName, let lastName = patient.surName {

            if !firstName.isEmpty && !lastName.isEmpty { fullName = "\(lastName), \(firstName)" }
        }

        return fullName
    }
    
    func patientFullName() -> String {

        var fullName = "New Patient"

        if let patient = self.patient {

            let f = patient.firstName ?? ""
            let s = patient.surName ?? ""

            if !f.isEmpty && !s.isEmpty { fullName = "\(s), \(f)" } else {

                let name = "\(f)\(s)"
                if !name.isEmpty { fullName = name }
            }
        }

        return fullName
    }
    
    // Lens details

    func lensDescription() -> String { if let lensOrder = self.lensOrder { return lensOrder.lensDescription() } else { return "No Lens Order" } }

    // Frame details
    
    func frameDescription() -> String { if let frameOrder = self.frameOrder { return frameOrder.frameDescription() } else { return "No Frame Order" } }

    // Price details

    func chargesString() -> String {

        return "\(NumberFormatter.localizedString(from: self.charges ?? NSDecimalNumber.zero, number: .currency))"
    }

    func totalPriceString() -> String {

        return "\(NumberFormatter.localizedString(from: self.totalPrice, number: .currency))"
    }

    // Status

    func statusName() -> String {

        return ["On Hold", "Confirmed", "Ordered", "Received", "Collected"][status?.intValue ?? 0]
    }
}

// MARK: - Frame extensions

extension Frame {

    override var nameString: String { get { return super.nameString + " (" + typeString() + ")" }}

    func typeString() -> String {

        switch self.type?.intValue ?? 0 {

        case 0: return "Plastic"
        case 1: return "Metal"
        case 2: return "Rimless"
        case 3: return "Supra"
        default: return "Unknown"
        }
    }
}

// MARK: - FrameOrder extensions

extension FrameOrder {

    var price: NSDecimalNumber { get { return self.frame?.price ?? NSDecimalNumber.zero } }

    func frameDescription(_ price: Bool = false) -> String {

        guard let frameDescription = self.frame?.name, !frameDescription.isEmpty else { return "No Frame Selected" }

        return frameDescription
    }

    func frameSizeDescription() -> (enabled: Bool, titles: [String], contents: [String]) {

        var frameDescription = (self.frame != nil, ["", "", ""], ["", "No Frame Sizes Selected", ""])

        if let frameSize = self.frame?.measurements {

            frameDescription.1[0] = "Size"
            frameDescription.1[1] = "Bridge"
            frameDescription.1[2] = "Length"

            frameDescription.2[0] = "\(frameSize) mm"
            frameDescription.2[1] = "\(frameSize) mm"
            frameDescription.2[2] = "\(frameSize) mm"
        }

        return frameDescription
    }
    
    func frameStyleDescription() -> (enabled: Bool, title: String) {

        return (self.frame != nil, self.frame?.style ?? "No Frame Colour Selected")
    }
}

// MARK: - Lens extensions

extension Lens {

    override var nameString: String {

        get { if let manuName = manufacturer?.name, manuName != "<Generic>" { return manuName + " " + super.nameString } else { return super.nameString }}
    }

    // TODO: Change this for an enum
    func typeString() -> String {

        switch self.visionType?.intValue ?? 0 {

        case 0: return ""
        case 1: return "Single Vision"
        case 2: return "Varifocal"
        case 3: return "Multifocal"
        default: return ""
        }
    }
}

enum PrismDirection : Int {

    case inward, out, up, down

    func directionString() -> String {

        switch self {
        case .inward:   return "In"
        case .out:  return "Out"
        case .up:   return "Up"
        case .down: return "Down"
        }
    }
}

// MARK: - LensOrder extensions

private let defaultLensDescription = "No Lens Selected"

enum LensTreatmentType: String { case None = "none", Tint = "Tint", Coat = "Coat", Finish = "Finish" }

extension LensOrder {

    var price: NSDecimalNumber {

        get {

            var tp: NSDecimalNumber = NSDecimalNumber.zero

            if let r = self.rightLens { tp += r.price! }
            if let l = self.leftLens { tp += l.price! }

            for t in self.rightTreatments! { tp += t.price! }
            for t in self.leftTreatments! { tp += t.price! }
            
            return tp
        }
    }

    func lensCount() -> UInt {

        var lensCount: UInt = 0

        if rightLens != nil { lensCount += 1; if leftLens != nil { lensCount += 1 } }

        return lensCount
    }

    func lensDescription() -> String {

        var lensDescription = defaultLensDescription

        if let r = rightLens {

            if let l = leftLens {

                if l == r { lensDescription = "2 x \(l.name!)" } else { lensDescription = "Right : \(r.name!) Left: \(l.name!)" }

            } else { lensDescription = r.name! }    // There is only one lens selected, the right lens.
        }
        
        return lensDescription
    }

    var leftLens: Lens? {

        get { return left }
        set { if left != newValue { leftTreatments!.removeAll(keepingCapacity: false); leftBlankSize = 0 }; left = newValue }
    }

    var rightLens: Lens? {

        get { return right }
        set { if right != newValue { rightTreatments!.removeAll(keepingCapacity: false); rightBlankSize = 0 }; right = newValue }
    }

    func treatment(_ type: LensTreatmentType, onLeft: Bool = false) -> LensTreatment? {

        for treatmentObject in onLeft ? self.leftTreatments! : self.rightTreatments! {

            if treatmentObject.type == type.rawValue { return treatmentObject }
        }

        return nil
    }
}

// MARK: - Purchase extensions

extension Purchase {

    var nameString: String { get { return name! } }

    var priceString: String { get { return NumberFormatter.localizedString(from: self.price ?? NSDecimalNumber.zero, number: .currency) } }

    var rawPriceString: String { get { return String(format: "%.2f", self.price?.floatValue ?? 0) } }
}

// MARK: - Adjustment extensions

extension Adjustment {

    func typeString() -> String {

        switch self.type?.intValue ?? 31337 {

        case 0: return "Order"
        case 1: return "Lenses"
        case 2: return "Frame"
        default: return "Unknown"
        }
    }
}

