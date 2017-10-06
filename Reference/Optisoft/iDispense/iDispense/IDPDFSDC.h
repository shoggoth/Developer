//
//  IDPDFSDC.h
//  iDispense
//
//  Created by Richard Henry on 18/11/2015.
//  Copyright © 2015 Optisoft Ltd. All rights reserved.
//

#import "IDPDFDrawer.h"

@class Order;
@class LensOrder;

//
//  interface IDPDFSDC
//
//  Lets us provide an alternative URL of a PDF that is more suitable for print media.
//

@interface SDCCalculator : NSObject

@property(nonatomic, strong) NSDecimalNumber *chargeRate;

- (NSArray *)lensPriceFor:(LensOrder *)lensOrder;
- (NSArray *)framePriceFor:(NSDecimalNumber *)totalPrice;

@end

//
//  interface IDPDFSDC
//
//  Lets us provide an alternative URL of a PDF that is more suitable for print media.
//

@interface IDPDFSDC : NSObject

- (NSURL *)drawOrderForPrinting:(Order *)order;
- (NSURL *)drawOrderForPreview:(Order *)order;

@end

//
//  interface IDPDFSDCItemProvider
//
//  Lets us provide an alternative URL of a PDF that is more suitable for print media.
//

@interface IDPDFSDCItemProvider : UIActivityItemProvider

@property(nonatomic, strong) Order *order;

@end
