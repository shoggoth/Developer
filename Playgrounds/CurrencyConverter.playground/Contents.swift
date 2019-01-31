import Cocoa

// Goin' all the way back to the vibe of the NeXtSTEP days, it's a Currency Converter!
// Richard Henry 2018

/*

 The data structure to contain conversion ratios.
 
 GBP is obsolete in this structure as all conversions are from GBP to some other currency.
 Good engineers think about future expansion though & it is likely that we'll need to convert back at some point or convert € to $.
 
 I could have used a Decimal for the conversion rate but I think this is usually specified more like an FP value.
 
 I have used a struct rather than a class because they're copied rather than referenced which seems more suitable.
 
 */

struct CurrencyConversion {
    
    enum CurrencyName {
        
        case GBP
        case USD
        case EUR
        case AUD
    }
    
    let fromCurrency: CurrencyName
    let toCurrency: CurrencyName
    
    let exchangeRate: Double
    
    func convert(fromAmount from: Decimal) -> Decimal {
        
        return from * Decimal(floatLiteral: exchangeRate)
    }
}

// Currency conversion ratios.

let conversionRatios = [
    CurrencyConversion(fromCurrency: .GBP, toCurrency: .USD, exchangeRate: 1.0),
    CurrencyConversion(fromCurrency: .GBP, toCurrency: .AUD, exchangeRate: 2.0),
    CurrencyConversion(fromCurrency: .GBP, toCurrency: .EUR, exchangeRate: 3.0)
]

// Demo, possibly write some tests later.

if let sterlingAmount = Decimal(string: "1.23") {

    print("\(sterlingAmount) sterling is \(conversionRatios[0].convert(fromAmount: sterlingAmount)) dollars.")
    print("\(sterlingAmount) sterling is \(conversionRatios[1].convert(fromAmount: sterlingAmount)) dollars.")
    print("\(sterlingAmount) sterling is \(conversionRatios[2].convert(fromAmount: sterlingAmount)) dollars.")
}

/*
 
 The data structure to allow logging of conversions.
 
 Again, structures are used for their copy as the conversion rate is unlikely to remain constant
 so we don't really want references.
 
 */

struct ConversionLogEntry {
    
    let amount: Decimal
    let conversion: CurrencyConversion
    let timeOfConversion: Date
    
    init(amount: Decimal, conversion: CurrencyConversion) {
        
        self.amount = amount
        self.conversion = conversion
        timeOfConversion = Date()
    }
    
    func debugDump() {
        
        print("\(conversion.fromCurrency)\(amount) to \(conversion.toCurrency)\(conversion.convert(fromAmount: amount)) at \(DateFormatter.localizedString(from: timeOfConversion, dateStyle: .short, timeStyle: .short))")
    }
}

// Create the log

var log = [ConversionLogEntry]()

var conv = CurrencyConversion(fromCurrency: .GBP, toCurrency: .USD, exchangeRate: 1.0)

log.append(ConversionLogEntry(amount: 123.45, conversion: conv))

conv = CurrencyConversion(fromCurrency: .GBP, toCurrency: .USD, exchangeRate: 2.0)

log.append(ConversionLogEntry(amount: 123.45, conversion: conv))

// Demo
for conv in log { conv.debugDump() }

/*
 
 As this is an iOS position, I hope you will take for granted that I can construct an iOS app
 that is almost entirely boiler plate code.
 
 Things such as NSFetchedResultsController are fiddly to set up, I would probably use CoreData
 to make the store so creating a model, setting up the NSFetchedResultsController, getting all that off the
 main thread etc wouldn't be doable in the hour.
 
 Thanks,
 
 Richard
 
 */

