//
//  ViewController.h
//  DatabaseTool
//
//  Created by Richard Henry on 23/01/2015.
//  Copyright (c) 2015 Dogstar Industries. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ViewController : NSViewController

// Outlets
@property(unsafe_unretained) IBOutlet   NSTextView *textView;
@property(weak) IBOutlet                NSTextField *guidTextField;

// Bindings
@property(nonatomic) NSString *guidBase;
@property(nonatomic) BOOL createBackingData;
@property(nonatomic) BOOL createOrders;

@end

