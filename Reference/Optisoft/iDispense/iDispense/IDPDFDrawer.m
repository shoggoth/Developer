 //
//  IDPDFDrawer.m
//  iDispense
//
//  Created by Richard Henry on 18/11/2015.
//  Copyright © 2015 Optisoft Ltd. All rights reserved.
//

#import "IDPDFDrawer.h"

@import CoreText;

const float kConvertmmToPSPoints = 2.835;
//static const float kConvertPSPointsTomm = 0.353;

static const CGSize kPaperSizeA4 = { 595, 842 };
//static const CGSize kPaperSizeLetter = { 612, 792 };
static const CGSize kPaperMargin = { 12 * kConvertmmToPSPoints, 12 * kConvertmmToPSPoints };

static CGRect CGRectCentreInCGRect(CGRect innerRect, CGRect outerRect) {

    return CGRectMake(outerRect.origin.x + (outerRect.size.width - innerRect.size.width) * 0.5, outerRect.origin.y + (outerRect.size.height - innerRect.size.height) * 0.5, innerRect.size.width, innerRect.size.height);
}

static CGRect CGRectAlignLeftInCGRect(CGRect innerRect, CGRect outerRect) {

    return CGRectMake(outerRect.origin.x, outerRect.origin.y + (outerRect.size.height - innerRect.size.height) * 0.5, innerRect.size.width, innerRect.size.height);
}

static CGRect CGRectAlignRightInCGRect(CGRect innerRect, CGRect outerRect) {

    return CGRectMake(outerRect.origin.x + (outerRect.size.width - innerRect.size.width), outerRect.origin.y + (outerRect.size.height - innerRect.size.height) * 0.5, innerRect.size.width, innerRect.size.height);
}


#pragma mark - PDF Drawing

@implementation IDPDFDrawer {

    BOOL                pdfIsOpen;
    CGContextRef        context;
}

+ (void)clearPDFFilesFromDocumentFolder {

    // Delete the image capture files within the standard image capture directory.
    NSError  *err;
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSArray  *directoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsPath error:&err];

    for (NSString *fileName in directoryContents) {

        if ([fileName containsString:@".pdf"]) [[NSFileManager defaultManager] removeItemAtPath:[documentsPath stringByAppendingPathComponent:fileName] error:&err];
    }
}

#pragma mark Lifecycle

- (instancetype)init {

    if ((self = [super init])) {

        // Property defaults.
        _pageSize = kPaperSizeA4;
        _pageMargins = kPaperMargin;
        _frameLineWidth = .25;
        _debug = NO;

        // Reminder!!!
        // We can use [NSValue valueWithCGRect:rect] to store the page values in the user preferences.
        // 612 * 792 postscript points if the size of the Letter page
        // 595 * 842 postscript points if the size of the A4 page

        // Initialisation
        pdfIsOpen = NO;
    }

    return self;
}

- (void)dealloc {

    if (pdfIsOpen) [self endPDFOutput];
}

#pragma mark Document

- (void)beginPDFOutputToFile:(NSString *)fileName {

    if (!pdfIsOpen) {

        // Create the PDF context using the default page size of 612 x 792.
        UIGraphicsBeginPDFContextToFile(fileName, CGRectZero, nil);

        // Get the graphics context.
        context = UIGraphicsGetCurrentContext();

        // Create the initial page.
        [self openNewPage];

        pdfIsOpen = YES;
    }
}

- (void)endPDFOutput {

    if (pdfIsOpen) {

        // Close the current page.
        [self closeCurrentPage];

        // Close the PDF context and write the contents out.
        UIGraphicsEndPDFContext();

        pdfIsOpen = NO;
    }
}

#pragma mark Page

- (void)openNewPage {

    // Mark the beginning of a new page.
    UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, _pageSize.width, _pageSize.height), nil);

    // Reset the dimensions for the new page
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);

    // Core Text draws from the bottom-left corner up, so flip the current transform prior to drawing.
    CGContextTranslateCTM(context, _pageMargins.width, _pageSize.height - _pageMargins.height);
    CGContextScaleCTM(context, 1.0, -1.0);

    _pageRect = (CGRect) { 0, 0, _pageSize.width - _pageMargins.width * 2, _pageSize.height - _pageMargins.height * 2 };
}

- (void)closeCurrentPage {

    _pageCount++;
}

#pragma mark Drawing

- (CFMutableAttributedStringRef)makeStringRefFromText:(NSString *)text withFont:(UIFont *)font {

    if (!text) text = @"";
    
    //  When you create an attributed string the default paragraph style has a leading
    //  of 0.0. Create a paragraph style that will set the line adjustment equal to
    //  the leading value of the font.
    CTFontRef ctFont = CTFontCreateWithName((__bridge CFStringRef)font.fontName, font.pointSize, NULL);
    CGFloat leading = font.lineHeight - font.ascender + font.descender;
    CTParagraphStyleSetting paragraphSettings[1] = { kCTParagraphStyleSpecifierLineSpacingAdjustment, sizeof (CGFloat), &leading };
    
    CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(paragraphSettings, 1);

    //  Create an empty mutable string big enough to hold our test
    CFMutableAttributedStringRef string = CFAttributedStringCreateMutable(kCFAllocatorDefault, text.length);
    
    //  Inject our text into it
    CFAttributedStringReplaceString(string, CFRangeMake(0, 0), (__bridge CFStringRef)text);
    
    //  Apply our font and line spacing attributes over the span
    const CFRange textRange = CFRangeMake(0, text.length);
    CFAttributedStringSetAttribute(string, textRange, kCTFontAttributeName, ctFont);
    CFAttributedStringSetAttribute(string, textRange, kCTParagraphStyleAttributeName, paragraphStyle);

    return string;
}

- (void)drawFrame:(CGRect)frame inColour:(CGColorRef)colour {

    // Draw the frame
    CGContextSaveGState(context);

    CGMutablePathRef framePath = CGPathCreateMutable();
    CGPathAddRect(framePath, NULL, frame);

    CGContextSetStrokeColorWithColor(context, colour);
    CGContextSetLineWidth(context, _frameLineWidth);
    CGContextAddPath(context, framePath);
    CGContextStrokePath(context);

    CGPathRelease(framePath);

    // Restore the context's transform.
    CGContextRestoreGState(context);
}

- (void)drawLineFrom:(CGPoint)from to:(CGPoint)to inColour:(CGColorRef)colour {

    // Draw the frame
    CGContextSaveGState(context);

    CGMutablePathRef framePath = CGPathCreateMutable();
    CGPathMoveToPoint(framePath, NULL, from.x, from.y);
    CGPathAddLineToPoint(framePath, NULL, to.x, to.y);

    CGContextSetStrokeColorWithColor(context, colour);
    CGContextSetLineWidth(context, _frameLineWidth);
    CGContextAddPath(context, framePath);
    CGContextStrokePath(context);

    CGPathRelease(framePath);

    // Restore the context's transform.
    CGContextRestoreGState(context);
}

- (void)drawText:(NSString *)text withFont:(UIFont *)font inFrame:(CGRect)textFrame align:(IDPFDOrderAlignment)align {

    CFMutableAttributedStringRef string = [self makeStringRefFromText:text withFont:font];

    // Save the context state
    CGContextSaveGState(context);

    // Prepare the text using a Core Text Framesetter.
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(string);
    CFRange fitRange;

    CGSize textSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, text.length), nil, textFrame.size, &fitRange);
    CGMutablePathRef framePath = CGPathCreateMutable();

    if (align == kIDPFDOrderAlignLeft) CGPathAddRect(framePath, NULL, CGRectAlignLeftInCGRect((CGRect) { textFrame.origin, textSize }, textFrame));
    else if (align == kIDPFDOrderAlignCentre) CGPathAddRect(framePath, NULL, CGRectCentreInCGRect((CGRect) { textFrame.origin, textSize }, textFrame));
    else if (align == kIDPFDOrderAlignRight) CGPathAddRect(framePath, NULL, CGRectAlignRightInCGRect((CGRect) { textFrame.origin, textSize }, textFrame));

    if (_debug) {

        CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
        CGContextAddPath(context, framePath);
        CGContextStrokePath(context);

        CGMutablePathRef outerFramePath = CGPathCreateMutable();
        CGPathAddRect(outerFramePath, NULL, textFrame);
        CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
        CGContextAddPath(context, outerFramePath);
        CGContextStrokePath(context);
        CGPathRelease(outerFramePath);
    }

    // Get the frame that will do the rendering.
    CFRange currentRange = CFRangeMake(0, 0);
    CTFrameRef frameRef = CTFramesetterCreateFrame(framesetter, currentRange, framePath, NULL);
    CGPathRelease(framePath);

    // Draw the frame.
    @try { CTFrameDraw(frameRef, context); }
    @catch (NSException *exception) { NSLog(@"Exception %@", exception); }
    @finally { CFRelease(frameRef); }

    CFRelease(string);
    CFRelease(framesetter);

    // Restore the context's state.
    CGContextRestoreGState(context);
}

- (void)drawImage:(UIImage *)image atPoint:(CGPoint)drawPoint {

    // Save the context state
    CGContextSaveGState(context);

    // Reset the CTM
    CGContextTranslateCTM(context, 0, _pageSize.height - _pageMargins.height * 2);
    CGContextScaleCTM(context, 0.1, -0.1);

    [image drawAtPoint:drawPoint];

    // Restore the context's state.
    CGContextRestoreGState(context);
}

- (void)drawWatermarkString:(NSString *)string {

    // Save the context state
    CGContextSaveGState(context);

    CALayer *dimLayer = [CATextLayer layer];
    CATextLayer *textLayer = [CATextLayer layer];

    dimLayer.frame = CGRectMake(0, 0, _pageSize.width, _pageSize.height);
    dimLayer.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4].CGColor;

    textLayer.frame = dimLayer.frame;
    textLayer.foregroundColor = [UIColor colorWithWhite:1 alpha:0.3].CGColor;
    textLayer.string = string;
    textLayer.font = (__bridge CFTypeRef)(@"Helvetica");
    textLayer.fontSize = 48;
    textLayer.alignmentMode = kCAAlignmentCenter;

    // Reset the CTM
    CGContextTranslateCTM(context, -_pageMargins.width, _pageSize.height - _pageMargins.height);
    CGContextScaleCTM(context, 1, -1);

    [dimLayer renderInContext:context];

    // Rotate the text now that the dimmed background has been drawn.
    CGContextRotateCTM(context, M_PI * -0.25);
    CGContextSetBlendMode(context, kCGBlendModeDifference);
    CGContextTranslateCTM(context, -400, 0);

    const float lineSpacing = textLayer.fontSize * 2;

    for (int y = 0; y < _pageSize.height * 1.2; y += lineSpacing) {

        [textLayer renderInContext:context];

        // Move down a line
        CGContextTranslateCTM(context, 0, lineSpacing);
    }

    // Restore the context's state.
    CGContextRestoreGState(context);
}

#pragma mark Utility

- (void)drawAddressTextForPractice:(NSDictionary *)practiceDetails inCell:(CGRect)cellRect withFont:(UIFont *)font {

    // Get optometrist's details
    cellRect.size.height *= 0.25;

    NSString *string = [[NSUserDefaults standardUserDefaults] stringForKey:@"optometrist_contact_name_preference"];
    if (string) {

        [self drawText:[NSString stringWithFormat:@"Contact: %@", string] withFont:font inFrame:cellRect align:kIDPFDOrderAlignCentre];
        cellRect.origin.y += cellRect.size.height;
    }

    if ((string = [practiceDetails objectForKey:@"telephoneNumber"])) {

        [self drawText:string withFont:font inFrame:cellRect align:kIDPFDOrderAlignCentre];
        cellRect.origin.y += cellRect.size.height;
    }

    if ((string = [practiceDetails objectForKey:@"address1"])) {

        string = [NSString stringWithFormat:@"%@ %@ %@", string, [practiceDetails objectForKey:@"address2"], [practiceDetails objectForKey:@"postCode"]];
        [self drawText:string withFont:font inFrame:cellRect align:kIDPFDOrderAlignCentre];
        cellRect.origin.y += cellRect.size.height;
    }

    if ((string = [practiceDetails objectForKey:@"practiceName"])) {

        [self drawText:string withFont:font inFrame:cellRect align:kIDPFDOrderAlignCentre];
        cellRect.origin.y += cellRect.size.height;
    }
}

@end
