//
//  IDPDFSDC.m
//  iDispense
//
//  Created by Richard Henry on 18/11/2015.
//  Copyright © 2015 Optisoft Ltd. All rights reserved.
//

#import "IDPDFSDC.h"
#import "DataClasses.h"
#import "IDDispensingDataStore.h"
#import "iDispense-Swift.h"

@import CoreText;

extern float kConvertmmToPSPoints;

static const float baseLines[3] = { 0, 0.15, 0.9 };
static const float cellProportions[] = { 0.5, 0.2, 0.3 };

static CGRect (^makeInsetRect)(int insetIndex, CGRect bodyRect) = ^CGRect(int insetIndex, CGRect bodyRect) {

    CGRect insetRect = bodyRect;

    switch (insetIndex) {

        case 0:
            insetRect.size.width = cellProportions[0] * bodyRect.size.width;
            break;

        case 1:
            insetRect.origin.x += cellProportions[0] * bodyRect.size.width;
            insetRect.size.width = cellProportions[1] * bodyRect.size.width;
            break;

        case 2:
            insetRect.origin.x += (cellProportions[0] + cellProportions[1]) * bodyRect.size.width;
            insetRect.size.width = cellProportions[2] * bodyRect.size.width;
            break;

        default:
            break;
    }

    return insetRect;
};

#pragma mark SDC Calculator

@implementation SDCCalculator {

    NSArray         *lensMatrix;
    NSArray         *frameMatrix;
}

- (instancetype)init {

    if ((self = [super init])) {

        // Initialisation
        self.chargeRate = [NSDecimalNumber zero];

        [self loadSDCMatrices];
    }

    return self;
}

- (BOOL)loadSDCMatrices {

    NSDictionary *practiceDict = [IDDispensingDataStore defaultDataStore].practiceDetails;

    if (practiceDict) {

        NSData *data = [practiceDict objectForKey:@"sdcData"];

        if (!data) return NO;

        NSArray *matrix = [NSKeyedUnarchiver unarchiveObjectWithData:data];

        if (matrix.count != 2) return NO;

        lensMatrix = [matrix objectAtIndex:0];
        frameMatrix = [matrix objectAtIndex:1];

        return YES;
    }

    return NO;
}

- (NSArray *)pricesFor:(NSDecimalNumber *)price inMatrix:(NSArray *)matrix withMultiplier:(NSDecimalNumber *)mult {

    NSDecimalNumber *dispensingFee = [NSDecimalNumber zero];

    // Pro-rata charge rate
    NSDecimalNumber *chargeAmount = [price decimalNumberByMultiplyingBy:self.chargeRate];
    price = [price decimalNumberByAdding:chargeAmount];

    for (NSUInteger i = 0; i < matrix.count; i += 2) {

        NSDecimalNumber *bandStart = [matrix objectAtIndex:i];

        if ([price compare:bandStart] != NSOrderedAscending) { dispensingFee = [matrix objectAtIndex:i + 1]; }
    }

    if (dispensingFee) {

        NSDecimalNumber *vatableAmount = nil;

        if ([price compare:dispensingFee] == NSOrderedAscending) {

            // If fees are less than the product charges, 60% of product charges.
            dispensingFee = [price decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:@"0.6"]];
            vatableAmount = [price decimalNumberBySubtracting:dispensingFee];

        } else {

            // Dispensing fee multiplier
            if (mult) dispensingFee = [dispensingFee decimalNumberByMultiplyingBy:mult];

            vatableAmount = [price decimalNumberBySubtracting:dispensingFee];
        }

        // There can be or there could be but there probably are not the reasons to actually do these things.
        //NSLog(@"for %@: vatable %@ not vatable %@", totalPrice, vatableAmount, dispensingFee);

        return @[vatableAmount, dispensingFee];
    }

    return @[price, [NSDecimalNumber zero]];
}

- (NSArray *)lensPriceFor:(LensOrder *)lensOrder {

    if (lensOrder.lensCount == 1) {

        // If only one lens has been ordered, 50% of the fee applies
        return [self pricesFor:lensOrder.price inMatrix:lensMatrix withMultiplier:[NSDecimalNumber decimalNumberWithString:@"0.5"]];
    }

    return [self pricesFor:lensOrder.price inMatrix:lensMatrix withMultiplier:nil];
}

- (NSArray *)framePriceFor:(NSDecimalNumber *)framePrice { return [self pricesFor:framePrice inMatrix:frameMatrix withMultiplier:nil]; }


@end

#pragma mark - Order form

@implementation IDPDFSDC {

    IDPDFDrawer     *pdfDrawer;
    SDCCalculator   *calculator;

    UIFont          *bodyFont, *boldFont, *bigFont;
    CGColorRef      frameColour;

    float spacing;
}

- (instancetype)init {

    if ((self = [super init])) {

        // PDF Drawer
        pdfDrawer = [IDPDFDrawer new];

        // SDC Calculator
        calculator = [SDCCalculator new];

        // Fonts
        bodyFont = [UIFont systemFontOfSize:14.0];
        boldFont = [UIFont boldSystemFontOfSize:14.0];
        bigFont = [UIFont boldSystemFontOfSize:15.0];

        // Colours
        frameColour = [UIColor blueColor].CGColor;

        // Dimensions
        spacing = 6 * kConvertmmToPSPoints;
    }

    return self;
}

- (NSURL *)drawOrderForPrinting:(Order *)order {

    // Create a new PDF drawer
    pdfDrawer = [IDPDFDrawer new];

    // Create file name from the order parameters
    NSString *orderFileName = @"PDFSDC_Print.pdf";

    // Create the file path to the document
    NSString *docsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [docsPath stringByAppendingPathComponent:orderFileName];

    [pdfDrawer beginPDFOutputToFile:filePath];

    [self drawSDCFooter];
    [self drawSDCBody:order];
    [self drawSDCHeaderWithPracticeDetails:YES];

    [pdfDrawer endPDFOutput];

    return [NSURL fileURLWithPath:filePath];
}

- (NSURL *)drawOrderForPreview:(Order *)order {

    // Create a new PDF drawer
    pdfDrawer = [IDPDFDrawer new];

    // Create file name from the order parameters
    NSString *orderFileName = @"PDFSDC.pdf";

    // Create the file path to the document
    NSString *docsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [docsPath stringByAppendingPathComponent:orderFileName];

    [pdfDrawer beginPDFOutputToFile:filePath];

    [self drawSDCBody:order];
    [self drawSDCHeaderWithPracticeDetails:NO];

    [pdfDrawer endPDFOutput];

    return [NSURL fileURLWithPath:filePath];
}

- (void)drawSDCHeaderWithPracticeDetails:(BOOL)withPDs {

    CGRect headerRect = pdfDrawer.pageRect;
    const float ph = headerRect.size.height;

    headerRect.origin.y += baseLines[2] * ph;
    headerRect.size.height = (1.0 - baseLines[2]) * ph;

    if (withPDs) {

        [pdfDrawer drawAddressTextForPractice:[IDDispensingDataStore defaultDataStore].practiceDetails inCell:headerRect withFont:boldFont];

    } else {

        [pdfDrawer drawText:@"Separately Disclosed Charges" withFont:bigFont inFrame:headerRect align:kIDPFDOrderAlignCentre];
    }
}

#pragma mark Body

- (void)drawSDCBody:(Order *)order {

    NSDecimalNumber *rp = order.rawPrice;

    // Make sure we don't get a divide by zero here if the user hasn't enteres anything into the matrix.
    if ([rp compare:[NSDecimalNumber zero]] == NSOrderedSame) calculator.chargeRate = [NSDecimalNumber zero];
    else calculator.chargeRate = [order.charges decimalNumberByDividingBy:order.rawPrice];

    CGRect bodyRect = pdfDrawer.pageRect;
    const float ph = bodyRect.size.height;

    bodyRect.origin.y += baseLines[1] * ph;
    bodyRect.size.height = (baseLines[2] - baseLines[1]) * ph;

    // There are 5 sections in the body
    const float sectionHeight = bodyRect.size.height * 0.2;
    bodyRect.size.height = sectionHeight;

    // 5 Total section
    [self drawTotalSectionInRect:bodyRect forOrder:order];

    // 4 Lenses section
    bodyRect.origin.y += sectionHeight;
    [self drawLensSectionInRect:bodyRect forOrder:order];

    // 3 Frames section
    bodyRect.origin.y += sectionHeight;
    [self drawFrameSectionInRect:bodyRect forOrder:order];

    // 2 Info section
    bodyRect.origin.y += sectionHeight;
    [self drawInfoSectionInRect:bodyRect forOrder:order];

    // 1 Header section
    bodyRect.origin.y += sectionHeight;
    [self drawHeaderSectionInRect:bodyRect];
}

#pragma mark Sections

- (void)drawTotalSectionInRect:(CGRect)rect forOrder:(Order *)order {

    // Totals section
    [pdfDrawer drawText:@"Total Inc. VAT" withFont:bigFont inFrame:makeInsetRect(0, rect) align:kIDPFDOrderAlignLeft];

    CGRect r = makeInsetRect(1, rect);
    [pdfDrawer drawText:[NSNumberFormatter localizedStringFromNumber:order.totalPrice numberStyle:NSNumberFormatterCurrencyStyle] withFont:bigFont inFrame:r align:kIDPFDOrderAlignLeft];

    CGPoint p1 = CGPointMake(r.origin.x, r.origin.y + r.size.height * 0.75);
    CGPoint p2 = CGPointMake(r.origin.x + r.size.width, r.origin.y + r.size.height * 0.75);
    [pdfDrawer drawLineFrom:p1 to:p2 inColour:[UIColor redColor].CGColor];
    p1 = CGPointMake(r.origin.x, r.origin.y + r.size.height * 0.25);
    p2 = CGPointMake(r.origin.x + r.size.width, r.origin.y + r.size.height * 0.25);
    [pdfDrawer drawLineFrom:p1 to:p2 inColour:[UIColor redColor].CGColor];

}

- (void)drawLensSectionInRect:(CGRect)rect forOrder:(Order *)order {

    NSArray *fees = [calculator lensPriceFor:order.lensOrder];
    NSString *costOfGoods = [NSNumberFormatter localizedStringFromNumber:fees[0] numberStyle:NSNumberFormatterCurrencyStyle];
    NSString *dispensingFees = [NSNumberFormatter localizedStringFromNumber:fees[1] numberStyle:NSNumberFormatterCurrencyStyle];

    const float h = rect.size.height / 3;

    // Left section
    CGRect r = makeInsetRect(0, rect);
    r.size.height = h;
    [pdfDrawer drawText:@"Professional Dispensing Fees" withFont:bodyFont inFrame:r align:kIDPFDOrderAlignLeft];
    r.origin.y += h;
    [pdfDrawer drawText:@"Cost of Goods" withFont:bigFont inFrame:r align:kIDPFDOrderAlignLeft];
    r.origin.y += h;
    [pdfDrawer drawText:@"LENSES" withFont:boldFont inFrame:r align:kIDPFDOrderAlignLeft];

    // Middle section
    r = makeInsetRect(1, rect);
    r.size.height = h;
    [pdfDrawer drawText:dispensingFees withFont:bodyFont inFrame:r align:kIDPFDOrderAlignLeft];
    r.origin.y += h;
    [pdfDrawer drawText:costOfGoods withFont:bigFont inFrame:r align:kIDPFDOrderAlignLeft];

    // Right section
    r = makeInsetRect(2, rect);
    r.size.height = h;
    [pdfDrawer drawText:@"Exempt of VAT" withFont:bodyFont inFrame:r align:kIDPFDOrderAlignLeft];
    r.origin.y += h;
    [pdfDrawer drawText:@"Including VAT" withFont:bodyFont inFrame:r align:kIDPFDOrderAlignLeft];
}

- (void)drawFrameSectionInRect:(CGRect)rect forOrder:(Order *)order {

    NSArray *fees = [calculator framePriceFor:order.frameOrder.price];
    NSString *costOfGoods = [NSNumberFormatter localizedStringFromNumber:fees[0] numberStyle:NSNumberFormatterCurrencyStyle];
    NSString *dispensingFees = [NSNumberFormatter localizedStringFromNumber:fees[1] numberStyle:NSNumberFormatterCurrencyStyle];

    const float h = rect.size.height / 3;

    // Left section
    CGRect r = makeInsetRect(0, rect);
    r.size.height = h;
    [pdfDrawer drawText:@"Professional Dispensing Fees" withFont:bodyFont inFrame:r align:kIDPFDOrderAlignLeft];
    r.origin.y += h;
    [pdfDrawer drawText:@"Cost of Goods" withFont:bigFont inFrame:r align:kIDPFDOrderAlignLeft];
    r.origin.y += h;
    [pdfDrawer drawText:@"FRAMES" withFont:boldFont inFrame:r align:kIDPFDOrderAlignLeft];

    // Middle section
    r = makeInsetRect(1, rect);
    r.size.height = h;
    [pdfDrawer drawText:dispensingFees withFont:bodyFont inFrame:r align:kIDPFDOrderAlignLeft];
    r.origin.y += h;
    [pdfDrawer drawText:costOfGoods withFont:bigFont inFrame:r align:kIDPFDOrderAlignLeft];

    // Right section
    r = makeInsetRect(2, rect);
    r.size.height = h;
    [pdfDrawer drawText:@"Exempt of VAT" withFont:bodyFont inFrame:r align:kIDPFDOrderAlignLeft];
    r.origin.y += h;
    [pdfDrawer drawText:@"Including VAT" withFont:bodyFont inFrame:r align:kIDPFDOrderAlignLeft];
}

- (void)drawInfoSectionInRect:(CGRect)rect forOrder:(Order *)order {

    NSString *ref = order.prefixedOrderNumber;
    NSString *preparedFor = order.patientFullName;
    NSString *dateString = order.creationDateShortStr;

    const float h = rect.size.height / 3;

    // Left section
    CGRect r = makeInsetRect(0, rect);
    r.size.height = h;
    [pdfDrawer drawText:@"Date:" withFont:bodyFont inFrame:r align:kIDPFDOrderAlignLeft];
    r.origin.y += h;
    [pdfDrawer drawText:@"Prepared for:" withFont:bodyFont inFrame:r align:kIDPFDOrderAlignLeft];
    r.origin.y += h;
    [pdfDrawer drawText:@"Ref:" withFont:bodyFont inFrame:r align:kIDPFDOrderAlignLeft];

    // Middle section
    r = makeInsetRect(1, rect);
    r.size.height = h;
    [pdfDrawer drawText:dateString withFont:bodyFont inFrame:r align:kIDPFDOrderAlignLeft];
    r.origin.y += h;
    [pdfDrawer drawText:preparedFor withFont:bodyFont inFrame:r align:kIDPFDOrderAlignLeft];
    r.origin.y += h;
    [pdfDrawer drawText:ref withFont:bodyFont inFrame:r align:kIDPFDOrderAlignLeft];
}

- (void)drawHeaderSectionInRect:(CGRect)rect {

    rect.size.height /= 3;
    rect.origin.y += rect.size.height;
    [pdfDrawer drawText:@"For Professional Service and Supply of Spectacles" withFont:boldFont inFrame:rect align:kIDPFDOrderAlignCentre];

    rect.origin.y += rect.size.height;
    [pdfDrawer drawText:@"Order/Confirmation" withFont:bigFont inFrame:rect align:kIDPFDOrderAlignCentre];
}

#pragma mark Footer

- (void)drawSDCFooter {

    CGRect footerRect = pdfDrawer.pageRect;
    const float ph = footerRect.size.height;

    footerRect.origin.y += baseLines[0] * ph;
    footerRect.size.height = (baseLines[1]) * ph * 0.5;     // Leave some space in the top half of the footer for the customer to sign his signature.

    [pdfDrawer drawText:@"Signature of Patient  ........................................................................................." withFont:boldFont inFrame:footerRect align:kIDPFDOrderAlignLeft];

    footerRect.origin.y += footerRect.size.height * 1.25;    // Mov up to the top to display the warning.
    [pdfDrawer drawText:@"A full VAT receipt will be issued at the time of spectacle supply." withFont:bodyFont inFrame:footerRect align:kIDPFDOrderAlignCentre];
}

@end

#pragma mark - PDF Activity provider

@implementation IDPDFSDCItemProvider

- (id)item {

    // Return the URL of the print media if the user wants to print, airdrop or send to dropbox.
    if ([self.activityType isEqualToString:UIActivityTypeAirDrop] ||
        [self.activityType isEqualToString:UIActivityTypePrint] ||
        [self.activityType isEqualToString:UIActivityTypeMail] ||
        [self.activityType isEqualToString:UIActivityTypeCopyToPasteboard] ||
        [self.activityType isEqualToString:@"com.getdropbox.Dropbox.ActionExtension"])

        return [[IDPDFSDC new] drawOrderForPrinting:self.order];

    // User selected something else so it's probably not suitable and all we can do is send them the placeholder item.
    return self.placeholderItem;
}

@end

