//
//  main.m
//  objCRuntime
//
//  Created by Richard Henry on 06/05/2015.
//  Copyright (c) 2015 Dogstar Industries. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/message.h>

static void swizzleClassMethods(Class c, SEL originalSelector, SEL overrideSelector) {

    Method originalMethod = class_getClassMethod(c, originalSelector);
    Method overrideMethod = class_getClassMethod(c, overrideSelector);

    c = object_getClass(c);

    if (class_addMethod(c, originalSelector, method_getImplementation(overrideMethod), method_getTypeEncoding(overrideMethod)))
        class_replaceMethod(c, overrideSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));

    else
        method_exchangeImplementations(originalMethod, overrideMethod);
}

static void swizzleInstanceMethods(Class c, SEL origSEL, SEL overrideSEL) {

    Method origMethod = class_getInstanceMethod(c, origSEL);
    Method overrideMethod = class_getInstanceMethod(c, overrideSEL);

    if (class_addMethod(c, origSEL, method_getImplementation(overrideMethod), method_getTypeEncoding(overrideMethod)))
        class_replaceMethod(c, overrideSEL, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    else
        method_exchangeImplementations(origMethod, overrideMethod);
}

@interface SwizzleClass : NSObject

@end

@implementation SwizzleClass

+ (int)printString:(NSString *)string times:(int)times {

    for (int i = 0; i < times; i++) {

        NSLog(@"%d - %@", i, string);
    }

    return 1;
}

+ (int)otherPrintString:(NSString *)string times:(int)times {

    for (int i = 0; i < times; i++) {

        NSLog(@"%d - %@ (Other)", i, string);
    }

    return 3;
}

- (void)instanceMethod {

    NSLog(@"instanceMethod");
}

@end

@implementation SwizzleClass (Swizzled)

+ (void)load {

    if (YES) {

        swizzleClassMethods(self, @selector(printString:times:), @selector(printStringSwizzled:times:));
        swizzleInstanceMethods(self, @selector(instanceMethod), @selector(instanceMethodSwizzled));
    }
}

+ (int)printStringSwizzled:(NSString *)string times:(int)times {

    for (int i = 0; i < times; i++) {

        NSLog(@"%d - %@ (Swizzled)", i, string);
    }

    return 2;
}

- (void)instanceMethodSwizzled {

    NSLog(@"instanceMethod (Swizzled)");
}

@end

int main(int argc, const char * argv[]) {

    @autoreleasepool {

        int foo = [SwizzleClass printString:@"Hello, World!!!" times:3];
        NSLog(@"SwizzleClass returned %d", foo);

        SwizzleClass *sc = [SwizzleClass new];
        [sc instanceMethod];
    }

    return 0;
}