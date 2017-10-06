//
//  IDPDFDrawer.h
//  iDispense
//
//  Created by Richard Henry on 18/11/2015.
//  Copyright © 2015 Optisoft Ltd. All rights reserved.
//

@import UIKit;

typedef enum { kIDPFDOrderAlignLeft, kIDPFDOrderAlignCentre, kIDPFDOrderAlignRight } IDPFDOrderAlignment;

//
//  interface IDPDFDrawer
//
//  Lets us provide an alternative URL of a PDF that is more suitable for print media.
//

@interface IDPDFDrawer : NSObject

@property(assign) CGSize pageSize;
@property(assign) CGSize pageMargins;
@property(readonly) CGRect pageRect;

@property(assign) float frameLineWidth;

@property(assign) BOOL debug;

@property(readonly) NSUInteger pageCount;

// Documents
+ (void)clearPDFFilesFromDocumentFolder;

// Document
- (void)beginPDFOutputToFile:(NSString *)fileName;
- (void)endPDFOutput;

// Page
- (void)openNewPage;
- (void)closeCurrentPage;

// Drawing
- (void)drawText:(NSString *)text withFont:(UIFont *)font inFrame:(CGRect)textFrame align:(IDPFDOrderAlignment)align;
- (void)drawFrame:(CGRect)frame inColour:(CGColorRef)colour;
- (void)drawLineFrom:(CGPoint)from to:(CGPoint)to inColour:(CGColorRef)colour;
- (void)drawImage:(UIImage *)image atPoint:(CGPoint)drawPoint;
- (void)drawWatermarkString:(NSString *)string;

// Utility
- (void)drawAddressTextForPractice:(NSDictionary *)practiceDetails inCell:(CGRect)cellRect withFont:(UIFont *)font;

@end
