//
//  IDPDFOrder.m
//  iDispense
//
//  Created by Richard Henry on 18/11/2015.
//  Copyright © 2015 Optisoft Ltd. All rights reserved.
//

#import "IDPDFOrder.h"
#import "DataClasses.h"
#import "IDDispensingDataStore.h"
#import "iDispense-Swift.h"

@import CoreText;

extern float kConvertmmToPSPoints;

static const float cellIndents[] = { 3, 40, 220, 226 };

#pragma mark - Order form

@implementation IDPDFOrder {

    IDPDFDrawer     *pdfDrawer;

    UIFont          *bodyFont, *boldFont, *bigFont;
    CGColorRef      frameColour;

    float spacing;
}

- (instancetype)init {

    if ((self = [super init])) {

        // PDF Drawer
        pdfDrawer = [IDPDFDrawer new];

        // Fonts
        bodyFont = [UIFont systemFontOfSize:9.0];
        boldFont = [UIFont boldSystemFontOfSize:9.0];
        bigFont = [UIFont boldSystemFontOfSize:12.0];

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
    NSString *orderFileName = [NSString stringWithFormat:@"%@ iDispense Ref %@.pdf", order.patientFullName, order.prefixedOrderNumber];

    // Create the file path to the document
    NSString *docsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [docsPath stringByAppendingPathComponent:orderFileName];

    [pdfDrawer beginPDFOutputToFile:filePath];

    // Draw a pair of orders
    [self drawOrder:order atBaseLine:0 withPrices:NO];
    [self drawOrder:order atBaseLine:(pdfDrawer.pageRect.size.height - spacing) * 0.5 + spacing withPrices:YES];

    if (![IDInAppPurchases sharedIAPStore].liteUserUnlocked) [pdfDrawer drawWatermarkString:@"DEMONSTRATION ONLY"];

    [pdfDrawer endPDFOutput];

    return [NSURL fileURLWithPath:filePath];
}

- (NSURL *)drawOrderForEmailing:(Order *)order {

    // Create a new PDF drawer
    pdfDrawer = [IDPDFDrawer new];

    // Create file name from the order parameters
    NSString *orderFileName = [NSString stringWithFormat:@"%@ iDispense Ref %@.pdf", order.patientFullName, order.prefixedOrderNumber];

    // Create the file path to the document
    NSString *docsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [docsPath stringByAppendingPathComponent:orderFileName];

    [pdfDrawer beginPDFOutputToFile:filePath];

    // Draw a pair of orders
    [self drawOrder:order atBaseLine:(pdfDrawer.pageRect.size.height - spacing) * 0.5 + spacing withPrices:NO];

    if (![IDInAppPurchases sharedIAPStore].liteUserUnlocked) [pdfDrawer drawWatermarkString:@"DEMONSTRATION ONLY"];

    [pdfDrawer endPDFOutput];

    return [NSURL fileURLWithPath:filePath];
}

- (void)drawOrder:(Order *)order atBaseLine:(float)baseLine withPrices:(BOOL)prices {

    const static int numCells = 35;
    CGRect cellRects[numCells];

    // Generate form reference rects
    [self makeFormCells:cellRects atBaseLine:baseLine];

    // Draw frame cell borders
    for (int i = 0; i < numCells; i++) [pdfDrawer drawFrame:cellRects[i] inColour:frameColour];

    // Draw notes cell
    [self drawPlainString:@"Notes:" withWidth:cellIndents[1] boldString:order.comments inCell:cellRects[0]];

    // Draw Frame Cells
    [self drawFrameOrder:order inCell:cellRects[1] withPrices:prices];

    // Draw Totals
    if (prices) [self drawTotals:order inCell:cellRects[2]];

    // Draw Lens Cells
    [self drawLensOrder:order inRightCell:cellRects[3] leftCell:cellRects[4] withPrices:prices];

    { // Draw prescription cells

        NSString *(^formatDioptreString)(float) = ^NSString *(float value) {

            NSString *signString = (value > 0) ? @"+" : (value < 0) ? @"" : @" ";

            return (value == 0) ? @"" : [NSString localizedStringWithFormat:@"%@%.2f", signString, value];
        };

        NSString *(^formatPrismString)(float, int) = ^NSString *(float value, int type) {

            return (value == 0) ? @"" : [NSString stringWithFormat:@"%@ %@", formatDioptreString(value), @[@"I", @"O", @"U", @"D"][type]];
        };

        Prescription *rx = order.patient.prescriptions.anyObject;
        float f;

        [pdfDrawer drawText:@"Left" withFont:bigFont inFrame:cellRects[5] align:kIDPFDOrderAlignCentre];
        [pdfDrawer drawText:formatDioptreString(rx.left.sph.floatValue) withFont:boldFont inFrame:cellRects[6] align:kIDPFDOrderAlignCentre];
        [pdfDrawer drawText:formatDioptreString(rx.left.cyl.floatValue) withFont:boldFont inFrame:cellRects[7] align:kIDPFDOrderAlignCentre];
        if ((f = rx.left.cyl.floatValue)) [pdfDrawer drawText:[NSString localizedStringWithFormat:@"%ld", (long)rx.left.axis.integerValue] withFont:boldFont inFrame:cellRects[8] align:kIDPFDOrderAlignCentre];
        [pdfDrawer drawText:formatPrismString(rx.left.prism.floatValue, rx.left.direction.intValue) withFont:boldFont inFrame:cellRects[9] align:kIDPFDOrderAlignCentre];
        [pdfDrawer drawText:[NSString localizedStringWithFormat:@"%.1f", rx.left.centres.floatValue] withFont:boldFont inFrame:cellRects[10] align:kIDPFDOrderAlignCentre];
        if ((f = rx.left.add.floatValue)) {
            [pdfDrawer drawText:formatDioptreString(f) withFont:boldFont inFrame:cellRects[11] align:kIDPFDOrderAlignCentre];
            [pdfDrawer drawText:[NSString localizedStringWithFormat:@"%.1f", rx.left.segHeight.floatValue] withFont:boldFont inFrame:cellRects[12] align:kIDPFDOrderAlignCentre];
        }

        [pdfDrawer drawText:@"Right" withFont:bigFont inFrame:cellRects[13] align:kIDPFDOrderAlignCentre];
        [pdfDrawer drawText:formatDioptreString(rx.right.sph.floatValue) withFont:boldFont inFrame:cellRects[14] align:kIDPFDOrderAlignCentre];
        [pdfDrawer drawText:formatDioptreString(rx.right.cyl.floatValue) withFont:boldFont inFrame:cellRects[15] align:kIDPFDOrderAlignCentre];
        if ((f = rx.right.cyl.floatValue)) [pdfDrawer drawText:[NSString localizedStringWithFormat:@"%ld", (long)rx.right.axis.integerValue] withFont:boldFont inFrame:cellRects[16] align:kIDPFDOrderAlignCentre];
        [pdfDrawer drawText:formatPrismString(rx.right.prism.floatValue, rx.right.direction.intValue) withFont:boldFont inFrame:cellRects[17] align:kIDPFDOrderAlignCentre];
        [pdfDrawer drawText:[NSString localizedStringWithFormat:@"%.1f", rx.right.centres.floatValue] withFont:boldFont inFrame:cellRects[18] align:kIDPFDOrderAlignCentre];
        if ((f = rx.right.add.floatValue)) {
            [pdfDrawer drawText:formatDioptreString(f) withFont:boldFont inFrame:cellRects[19] align:kIDPFDOrderAlignCentre];
            [pdfDrawer drawText:[NSString localizedStringWithFormat:@"%.1f", rx.right.segHeight.floatValue] withFont:boldFont inFrame:cellRects[20] align:kIDPFDOrderAlignCentre];
        }

        for (int i = 0; i < 7; i++) [pdfDrawer drawText:@[@"Sph", @"Cyl", @"Axis", @"Prism", @"Centres", @"Add", @"Height"][i] withFont:bodyFont inFrame:cellRects[22 + i] align:kIDPFDOrderAlignCentre];
    }

    { // Draw title cells

        const float cellIndent = cellIndents[1];

        [self drawPlainString:@"Supplier:" withWidth:cellIndent boldString:order.supplier.name inCell:cellRects[29]];
        [self drawPlainString:@"Supply:" withWidth:34 boldString:@[@"Uncut", @"Sending Frame", @"Supply Frame"][order.frameOrder.orderType.integerValue] inCell:cellRects[30]];
        [self drawPlainString:@"Reference:" withWidth:50 boldString:order.prefixedOrderNumber inCell:cellRects[31]];
        [self drawPlainString:@"Patient:" withWidth:cellIndent boldString:order.patientFullName inCell:cellRects[32]];
        [self drawPlainString:@"Date:" withWidth:50 boldString:order.creationDateStr inCell:cellRects[33]];

        [pdfDrawer drawAddressTextForPractice:[IDDispensingDataStore defaultDataStore].practiceDetails inCell:cellRects[34] withFont:boldFont];
    }

    // Draw logo (logo will have a 0.1 scale applied to it so multiply the baseline by 10)
    [pdfDrawer drawImage:[UIImage imageNamed:@"OptisoftLogo.png"] atPoint:(CGPoint) { cellIndents[0], baseLine * 10 + cellIndents[0] }];
}

- (void)drawPlainString:(NSString *)plainString withWidth:(float)psWidth boldString:(NSString *)boldString inCell:(CGRect)cellRect {

    const float cellIndent = cellIndents[0];
    
    CGRect subRect = cellRect; subRect.origin.x += cellIndent; subRect.size.width = psWidth;
    [pdfDrawer drawText:plainString withFont:bodyFont inFrame:subRect align:kIDPFDOrderAlignLeft];

    float offset = cellIndent + psWidth;
    subRect = cellRect; subRect.origin.x += offset; subRect.size.width -= offset;
    [pdfDrawer drawText:boldString withFont:boldFont inFrame:subRect align:kIDPFDOrderAlignLeft];
}

- (void)drawLensOrder:(Order *)order inRightCell:(CGRect)rightCellRect leftCell:(CGRect)leftCellRect withPrices:(BOOL)prices {

    const float cellHeight = 0.1667;

    CGRect rect = rightCellRect; rect.origin.y += rect.size.height * (cellHeight * 5.); rect.size.height *= cellHeight;
    [pdfDrawer drawText:@"Right Lens" withFont:boldFont inFrame:rect align:kIDPFDOrderAlignCentre];

    rect.origin.x = leftCellRect.origin.x;
    [pdfDrawer drawText:@"Left Lens" withFont:boldFont inFrame:rect align:kIDPFDOrderAlignCentre];

    void(^printLensRow)(NSArray *strings, float cellPos) = ^void(NSArray *strings, float cellPos) {

        float indent = cellIndents[0];
        CGRect rect = rightCellRect; rect.origin.x += indent; rect.origin.y += rect.size.height * (cellHeight * cellPos); rect.size.height *= cellHeight;
        [pdfDrawer drawText:strings[0] withFont:bodyFont inFrame:rect align:kIDPFDOrderAlignLeft];

        rect.origin.x = leftCellRect.origin.x + indent;
        [pdfDrawer drawText:strings[0] withFont:bodyFont inFrame:rect align:kIDPFDOrderAlignLeft];

        indent = cellIndents[1] + cellIndents[0];
        rect = rightCellRect; rect.origin.x += indent; rect.origin.y += rect.size.height * (cellHeight * cellPos); rect.size.height *= cellHeight;
        [pdfDrawer drawText:strings[1] withFont:boldFont inFrame:rect align:kIDPFDOrderAlignLeft];

        rect.origin.x = leftCellRect.origin.x + indent;
        [pdfDrawer drawText:strings[2] withFont:boldFont inFrame:rect align:kIDPFDOrderAlignLeft];

        if (prices && strings.count > 3) {

            indent = cellIndents[2];
            rect = rightCellRect; rect.origin.x += indent; rect.origin.y += rect.size.height * (cellHeight * cellPos); rect.size.height *= cellHeight;
            [pdfDrawer drawText:order.currencySymbol withFont:boldFont inFrame:rect align:kIDPFDOrderAlignLeft];

            rect.origin.x = leftCellRect.origin.x + indent;
            [pdfDrawer drawText:order.currencySymbol withFont:boldFont inFrame:rect align:kIDPFDOrderAlignLeft];

            indent = cellIndents[3];
            rect = rightCellRect; rect.origin.x += indent; rect.origin.y += rect.size.height * (cellHeight * cellPos); rect.size.height *= cellHeight; rect.size.width = rightCellRect.size.width - cellIndents[0] - cellIndents[3];
            [pdfDrawer drawText:strings[3] withFont:boldFont inFrame:rect align:kIDPFDOrderAlignRight];

            rect.origin.x = leftCellRect.origin.x + indent;
            [pdfDrawer drawText:strings[4] withFont:boldFont inFrame:rect align:kIDPFDOrderAlignRight];
        }
    };

    Lens *l = order.lensOrder.left;
    Lens *r = order.lensOrder.right;

    NSMutableArray *array = [NSMutableArray arrayWithArray:@[@"Lens:", @"No Lens Selected", @"No Lens Selected", @"0.00", @"0.00"]];
    if (r) { array[1] = r.nameString; array[3] = r.rawPriceString; }
    if (l) { array[2] = l.nameString; array[4] = l.rawPriceString; }

    printLensRow(array, 4);

    __block NSString *ltn, *rtn, *ltp, *rtp;

    void (^treatmentBlock)(NSString *) = ^void(NSString *type) {

        BOOL (^treatmentTestBlock)(LensTreatment *lt, BOOL *stop) = ^BOOL(LensTreatment *lt, BOOL *stop) { return ([lt.type compare:type] == NSOrderedSame); };

        LensTreatment *t = [[order.lensOrder.leftTreatments objectsPassingTest:treatmentTestBlock] anyObject];
        ltn = (t) ? t.nameString : @"None";
        ltp = (t) ? t.rawPriceString : @"0.00";

        t = [[order.lensOrder.rightTreatments objectsPassingTest:treatmentTestBlock] anyObject];
        rtn = (t) ? t.nameString : @"None";
        rtp = (t) ? t.rawPriceString : @"0.00";
    };

    treatmentBlock(@"Tint"); printLensRow(@[@"Tint:", rtn, ltn, rtp, ltp], 3);
    treatmentBlock(@"Coat"); printLensRow(@[@"Coating:", rtn, ltn, rtp, ltp], 2);
    treatmentBlock(@"Finish"); printLensRow(@[@"Finish:", rtn, ltn, rtp, ltp], 1);

    printLensRow(@[@"Blank:", [NSString stringWithFormat:@"%@mm", order.lensOrder.rightBlankSize], [NSString stringWithFormat:@"%@mm", order.lensOrder.leftBlankSize]], 0);
}

- (void)drawFrameOrder:(Order *)order inCell:(CGRect)cellRect withPrices:(BOOL)prices {

    Frame *frame = order.frameOrder.frame;
    const float cellHeight = cellRect.size.height * 0.2;
    const float cellIndent = cellIndents[1];

    cellRect.size.height = cellHeight;
    if (prices) [self drawPlainString:@"Price:" withWidth:cellIndent boldString:frame.priceString inCell:cellRect];
    cellRect.origin.y += cellHeight;
    [self drawPlainString:@"Size:" withWidth:cellIndent boldString:frame.measurements inCell:cellRect];
    cellRect.origin.y += cellHeight;
    [self drawPlainString:@"Type:" withWidth:cellIndent boldString:frame.typeString inCell:cellRect];
    cellRect.origin.y += cellHeight;
    [self drawPlainString:@"Colour:" withWidth:cellIndent boldString:frame.style inCell:cellRect];
    cellRect.origin.y += cellHeight;
    [self drawPlainString:@"Frame:" withWidth:cellIndent boldString:frame.name inCell:cellRect];
}

- (void)drawTotals:(Order *)order inCell:(CGRect)cellRect {

    const float cellHeight = cellRect.size.height * 0.2;

    CGRect leftRect = cellRect;
    CGRect midRect = cellRect;
    CGRect rightRect = cellRect;

    leftRect.size.height = cellHeight;
    leftRect.origin.x += cellIndents[0];
    midRect.size.height = cellHeight;
    midRect.origin.x += cellIndents[2];
    rightRect.size.height = cellHeight;
    rightRect.origin.x += cellIndents[3];
    rightRect.size.width = cellRect.size.width - cellIndents[0] - cellIndents[3];

    [pdfDrawer drawText:@"Total Dispense:" withFont:boldFont inFrame:leftRect align:kIDPFDOrderAlignLeft];
    [pdfDrawer drawText:order.currencySymbol withFont:boldFont inFrame:midRect align:kIDPFDOrderAlignLeft];
    [pdfDrawer drawText:[NSString stringWithFormat:@"%.2f", order.totalPrice.floatValue] withFont:boldFont inFrame:rightRect align:kIDPFDOrderAlignRight];
    leftRect.origin.y += cellHeight; midRect.origin.y = leftRect.origin.y; rightRect.origin.y = leftRect.origin.y;

    [pdfDrawer drawText:@"Adjustments:" withFont:bodyFont inFrame:leftRect align:kIDPFDOrderAlignLeft];
    [pdfDrawer drawText:order.currencySymbol withFont:bodyFont inFrame:midRect align:kIDPFDOrderAlignLeft];
    [pdfDrawer drawText:[NSString stringWithFormat:@"%.2f", order.charges.floatValue] withFont:bodyFont inFrame:rightRect align:kIDPFDOrderAlignRight];
    leftRect.origin.y += cellHeight; midRect.origin.y = leftRect.origin.y; rightRect.origin.y = leftRect.origin.y;

    [pdfDrawer drawText:@"Frame:" withFont:bodyFont inFrame:leftRect align:kIDPFDOrderAlignLeft];
    [pdfDrawer drawText:order.currencySymbol withFont:bodyFont inFrame:midRect align:kIDPFDOrderAlignLeft];
    [pdfDrawer drawText:[NSString stringWithFormat:@"%.2f", order.frameOrder.price.floatValue] withFont:bodyFont inFrame:rightRect align:kIDPFDOrderAlignRight];
    leftRect.origin.y += cellHeight; midRect.origin.y = leftRect.origin.y; rightRect.origin.y = leftRect.origin.y;

    [pdfDrawer drawText:@"Lens Total:" withFont:bodyFont inFrame:leftRect align:kIDPFDOrderAlignLeft];
    [pdfDrawer drawText:order.currencySymbol withFont:bodyFont inFrame:midRect align:kIDPFDOrderAlignLeft];
    [pdfDrawer drawText:[NSString stringWithFormat:@"%.2f", order.lensOrder.price.floatValue] withFont:bodyFont inFrame:rightRect align:kIDPFDOrderAlignRight];
    leftRect.origin.y += cellHeight; midRect.origin.y = leftRect.origin.y; rightRect.origin.y = leftRect.origin.y;

    [pdfDrawer drawText:@"Totals" withFont:boldFont inFrame:leftRect align:kIDPFDOrderAlignCentre];
}

- (void)makeFormCells:(CGRect[35])cellRects atBaseLine:(float)baseLine {

    static const float rowHeights[9] = { 0.115, 0.192, 0.208, 0.077, 0.077, 0.054, 0.054, 0.054, 0.169 };
    static const float xInsets[2] = { 0, 0 };

    const float formWidth = pdfDrawer.pageRect.size.width - xInsets[0] - xInsets[1];
    const float formHeight = (pdfDrawer.pageRect.size.height - spacing) * 0.5;

    float w, h;

    // Row 0
    h = rowHeights[0] * formHeight;
    cellRects[0] = (CGRect) { xInsets[0], baseLine, formWidth, h };
    baseLine += h;

    // Row 1
    w = formWidth * 0.5;
    h = rowHeights[1] * formHeight;
    cellRects[1] = (CGRect) { xInsets[0], baseLine, w, h };
    cellRects[2] = (CGRect) { xInsets[0] + w, baseLine, w, h };
    baseLine += h;

    // Row 2
    h = rowHeights[2] * formHeight;
    cellRects[3] = (CGRect) { xInsets[0], baseLine, w, h };
    cellRects[4] = (CGRect) { xInsets[0] + w, baseLine, w, h };
    baseLine += h;

    // Rows 3, 4 & 5
    w = formWidth * 0.125;
    for (int row = 0; row < 3; row++) {

        h = rowHeights[3 + row] * formHeight;
        float x = xInsets[0];

        for (int col = 0; col < 8; col++) {

            int i = row * 8 + col + 5;
            cellRects[i] = (CGRect) { x, baseLine, w, h };

            x += w;
        }
        baseLine += h;
    }

    // Row 6
    w = formWidth * 0.375;
    h = rowHeights[6] * formHeight;
    float x = xInsets[0];

    cellRects[29] = (CGRect) { x, baseLine, w, h };
    x += w;
    cellRects[30] = (CGRect) { x, baseLine, w, h };
    x += w; w = formWidth * 0.25;
    cellRects[31] = (CGRect) { x, baseLine, w, h };
    baseLine += h;

    // Row 7
    h = rowHeights[7] * formHeight;
    w = formWidth * 0.75;
    cellRects[32] = (CGRect) { xInsets[0], baseLine, w, h };
    cellRects[33] = (CGRect) { xInsets[0] + w, baseLine, formWidth * 0.25, h };
    baseLine += h;

    // Row 8
    h = rowHeights[8] * formHeight;
    cellRects[34] = (CGRect) { xInsets[0], baseLine, formWidth, h };
}

@end

#pragma mark - PDF Activity provider

@implementation IDPDFOrderItemProvider

- (id)item {

    // Return the URL of the print media if the user wants to print, airdrop or send to dropbox.
    if ([self.activityType isEqualToString:UIActivityTypeAirDrop] ||
        [self.activityType isEqualToString:UIActivityTypePrint] ||
        [self.activityType isEqualToString:@"com.getdropbox.Dropbox.ActionExtension"])

        return [[IDPDFOrder new] drawOrderForPrinting:self.order];

    // Otherwise, return the URL of the media that's suitable for attaching to an email or putting on the pasteboard.
    if ([self.activityType isEqualToString:UIActivityTypeMail] || [self.activityType isEqualToString:UIActivityTypeCopyToPasteboard])

        return [[IDPDFOrder new] drawOrderForEmailing:self.order];

    // User selected something else so it's probably not suitable and all we can do is send them the placeholder item.
    return self.placeholderItem;
}

@end

