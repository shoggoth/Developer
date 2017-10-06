//
//  DSButtonItem.h
//  Dogstar Engine (unified version)
//
//  Created by Richard Henry on 01/01/2011.
//  Copyright 2011 Dogstar Diversions. http://www.dogstar.mobi
//


typedef void (^DSButtonItemAction)(void);

@interface DSButtonItem : NSObject {

    NSString            *label;
    DSButtonItemAction  action;
}

@property (nonatomic, strong) NSString *label;
@property (nonatomic, copy) void (^action)();

+(id)item;
+(id)itemWithLabel:(NSString *)inLabel;
+(id)itemWithLabel:(NSString *)inLabel action:(DSButtonItemAction)action;

@end

