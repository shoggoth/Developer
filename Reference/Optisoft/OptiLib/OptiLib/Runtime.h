//
//  Runtime.h
//  OptiLib
//
//  Created by Richard Henry on 06/05/2015.
//  Copyright (c) 2015 Optisoft. All rights reserved.
//


extern void swizzleClassMethods(Class c, SEL originalSelector, SEL overrideSelector);
extern void swizzleInstanceMethods(Class c, SEL origSEL, SEL overrideSEL);