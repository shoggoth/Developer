//
//  IDPDFOrder.h
//  iDispense
//
//  Created by Richard Henry on 18/11/2015.
//  Copyright © 2015 Optisoft Ltd. All rights reserved.
//

#import "IDPDFDrawer.h"

@class Order;

//
//  interface IDPDFOrder
//
//  Lets us provide an alternative URL of a PDF that is more suitable for print media.
//

@interface IDPDFOrder : NSObject

- (NSURL *)drawOrderForPrinting:(Order *)order;
- (NSURL *)drawOrderForEmailing:(Order *)order;

@end

//
//  interface IDPDFOrderItemProvider
//
//  Lets us provide an alternative URL of a PDF that is more suitable for print media.
//

@interface IDPDFOrderItemProvider : UIActivityItemProvider

@property(nonatomic, strong) Order *order;

@end
