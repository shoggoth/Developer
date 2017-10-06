//
//  IDCollectionCellBackground.m
//  iDispense
//
//  Created by Richard Henry on 08/11/2013.
//  Copyright (c) 2013 Optisoft. All rights reserved.
//

#import "IDMugshotCellBackground.h"


const float kCellCornerRadius = 5;

@implementation IDMugshotCellBackground

- (void)drawRect:(CGRect)rect {
    
    // Save the current graphics context so that we can work here without effecting the view's context and restore that when we have finished drawing.
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);

    // Draw a rounded rect bezier path filled with blue.
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:kCellCornerRadius];

    bezierPath.lineWidth = kCellCornerRadius;
    [[UIColor colorWithWhite:0 alpha:0] setStroke];
    [[UIColor colorWithWhite:0.7 alpha:1.0] setFill];
    
    [bezierPath stroke];
    [bezierPath fill];

    // Restore the view's context, leaving the view's graphical parameters undisturbed.
    CGContextRestoreGState(context);
}

@end


@implementation IDMugshotSelectedCellBackground

- (void)drawRect:(CGRect)rect {

    // Save the current graphics context so that we can work here without effecting the view's context and restore that when we have finished drawing.
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);

    // Draw a rounded rect bezier path filled with greeny blue.
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:kCellCornerRadius];

    bezierPath.lineWidth = kCellCornerRadius;
    [[UIColor colorWithWhite:0 alpha:0] setStroke];
    [[UIColor colorWithWhite:0.6 alpha:1.0] setFill];

    [bezierPath stroke];
    [bezierPath fill];
    
    // Restore the view's context, leaving the view's graphical parameters undisturbed.
    CGContextRestoreGState(context);
}

@end















/*
 
 There is a guy that is working not too far away from you in all probability, and I feel it is only right that I warn you about him.
 
 If you are reading this, I have been forced to leave Optisoft and you have been given the opportunity to continue work on the fabulous apps
 that I started. I hope you will find the code that I've written to be comprehensible and maybe even have a bit of fun working on it. I thought
 that some of the apps that were in the pipeline were really interesting and I was right looking forward to having a crack at them.
 
 It's been made sort of impossible for me, though, due to the whining and grassing of Dominic Stevens who is a support monkey with ideas above 
 his station and a stupid poncey southern accent. Watch out for him, for he is a bit of a grass and is not above exagerating any event he thinks
 will get you into trouble if he doesn't like you. I don't think there are many people he likes either.
 
 Despite him having obvious issues with his height and a pretty bad case of small man syndrome, some of the other support staff seem to be a bit
 afraid of him, often laughing albeit nervously at his shit 'jokes'.

 */
