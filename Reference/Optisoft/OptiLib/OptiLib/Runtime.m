//
//  Runtime.m
//  OptiLib
//
//  Created by Richard Henry on 06/05/2015.
//  Copyright (c) 2015 Optisoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/message.h>

void swizzleClassMethods(Class c, SEL originalSelector, SEL overrideSelector) {

    Method originalMethod = class_getClassMethod(c, originalSelector);
    Method overrideMethod = class_getClassMethod(c, overrideSelector);

    c = object_getClass(c);

    if (class_addMethod(c, originalSelector, method_getImplementation(overrideMethod), method_getTypeEncoding(overrideMethod)))
        class_replaceMethod(c, overrideSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));

    else
        method_exchangeImplementations(originalMethod, overrideMethod);
}

void swizzleInstanceMethods(Class c, SEL origSEL, SEL overrideSEL) {

    Method origMethod = class_getInstanceMethod(c, origSEL);
    Method overrideMethod = class_getInstanceMethod(c, overrideSEL);

    if (class_addMethod(c, origSEL, method_getImplementation(overrideMethod), method_getTypeEncoding(overrideMethod)))
        class_replaceMethod(c, overrideSEL, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    else
        method_exchangeImplementations(origMethod, overrideMethod);
}
