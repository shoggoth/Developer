//
//  Person.m
//  iDispense
//
//  Created by Richard Henry on 18/02/2016.
//  Copyright © 2016 Optisoft Ltd. All rights reserved.
//

#import "Person.h"

@implementation Person

// Insert code here to add functionality to your managed object subclass

- (NSString *)uuid { return [NSString stringWithFormat:@"%@/%@", self.surName, self.firstName]; }

@end
