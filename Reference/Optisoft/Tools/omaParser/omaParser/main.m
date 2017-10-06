//
//  main.m
//  omaParser
//
//  Created by Richard Henry on 02/05/2014.
//  Copyright (c) 2014 Optisoft. All rights reserved.
//

@import Foundation;

#import "DSMaths.h"
#import <unistd.h>


@class OSOMAParser;

typedef NSString *(^OMAFormatBlock)(OSOMAParser *parser);


@interface OSOMAParser : NSObject {

    // Buffers
    float       *eyeRadii[2], *currentRadiusBuffer;
}

@property(nonatomic, readonly) NSUInteger radiusCount;

@end


@implementation OSOMAParser

- (instancetype)init {

    if ((self = [super init])) {

        // Initialisation
        eyeRadii[0] = eyeRadii[1] = currentRadiusBuffer = NULL;
    }

    return self;
}

- (void)parseOMAFileAtURL:(NSURL *)fileName {

    @try {

        NSError     *err;
        NSString    *fileContents = [NSString stringWithContentsOfURL:fileName encoding:NSUTF8StringEncoding error:&err];

        // For each line in the file
        for (NSString *line in [fileContents componentsSeparatedByString:@"\n"]) {

            NSArray     *records = [line componentsSeparatedByString:@"="];
            NSString    *recordType = records[0];
            NSUInteger  radiiLeftToRead;

            // Found the Trace Format specifier
            if ([recordType isEqualToString:@"TRCFMT"]) {

                NSArray *traceFormat = [records[1] componentsSeparatedByString:@";"];

                // Decode the trace format and check that we can actually deal with data in this format.
                NSInteger dataType = [traceFormat[0] integerValue];
                if (dataType != 1) @throw [NSException exceptionWithName:@"UnreadableOMADataType" reason:@"Can't read this type of OMA data" userInfo:nil];

                // Get the expected radius count for this record
                _radiusCount = radiiLeftToRead = [traceFormat[1] integerValue];

                // Get the radius mode (E|U)
                NSString *radiusModeIdentifier = traceFormat[2];
                if (![radiusModeIdentifier isEqualToString:@"E"])[NSException exceptionWithName:@"UnreadableRadiusMode" reason:@"Can't read these radii records yet" userInfo:nil];

                // Get the eye identifier (R|L|B)
                NSString *eyeIdentifier = traceFormat[3];
                if ([eyeIdentifier isEqualToString:@"L"]) currentRadiusBuffer = eyeRadii[1] = malloc(sizeof(float) * radiiLeftToRead);
                else if ([eyeIdentifier isEqualToString:@"R"]) currentRadiusBuffer = eyeRadii[0] = malloc(sizeof(float) * radiiLeftToRead);
                else if ([eyeIdentifier isEqualToString:@"B"]) currentRadiusBuffer = eyeRadii[1] = eyeRadii[0] = malloc(sizeof(float) * radiiLeftToRead);

                // Get the trace type (F|P|D)
                // NSString *traceType = traceFormat[4];

                NSLog(@"Reading %lu radii…", radiiLeftToRead);
            }

            // Found one of the radius specifiers
            else if ([recordType isEqualToString:@"R"]) {

                NSArray             *radii = [records[1] componentsSeparatedByString:@";"];
                const NSUInteger    radiiInThisRecord = radii.count;

                radiiLeftToRead -= radiiInThisRecord;
                for (int i = 0; i < radiiInThisRecord; i++) {

                    // In ASCII absolute, the measurements are in hundredths of a millimeter
                    *currentRadiusBuffer++ = [radii[i] floatValue] * 0.01;
                }
            }
        }
    }

    @catch (NSException *exception) {

        NSLog(@"%@ Error (%@)", exception.name, exception.reason);

        @throw exception;
    }
}

- (float)parsedRadiusForTurns:(float)turns forEyeIndex:(int)eyeIndex {

    float   lookupIndex = turns * _radiusCount;
    int     firstIndex = (int)floorf(lookupIndex) % _radiusCount;
    float   firstValue = eyeRadii[eyeIndex][firstIndex];
    float   secondValue = eyeRadii[eyeIndex][firstIndex + 1];
    float   interp = lookupIndex - floorf(lookupIndex);

    return firstValue + (secondValue - firstValue) * interp;
}

- (NSString *)writeOMADataToNSStringWithFormatBlock:(OMAFormatBlock) block {

    return block(self);
}

@end


int main(int argc, const char * argv[]) {

    @autoreleasepool {

        NSURL    *fileName = [NSURL fileURLWithPath:@"/Users/rjhenry/Documents/Code/Tools/omaParser/StandardShapes/shape1.oma"];
        OSOMAParser *parser = [OSOMAParser new];

        const BOOL emitPolarCoordinates = YES;
        const float traceScale = .1;

        [parser parseOMAFileAtURL:fileName];

        const NSUInteger    angleDivisions = 64;
        const NSUInteger    numberOfVectorsInRow = 8;

        OMAFormatBlock foo = ^(OSOMAParser *parser) {

            NSString            *header = @"";

            for (int c = 0; c < 2; c++) {

                header = [header stringByAppendingString:[NSString stringWithFormat:@"\n\nGLKVector2 %@_%@_%@[SHAPE_ARRAY_SIZE] = { // %lu coordinates.\n", [[fileName lastPathComponent] stringByReplacingOccurrencesOfString:@"." withString:@"_"], (emitPolarCoordinates) ? @"polar" : @"rectangular", (c) ? @"left" : @"right", angleDivisions]];

                for (int i = 0; i < angleDivisions; i++) {

                    const float turns = i / (float)angleDivisions;
                    const float theta = (turns * 2 * M_PI) - M_PI * 0.5;
                    const float radius = [parser parsedRadiusForTurns:turns forEyeIndex:c] * traceScale;

                    if (emitPolarCoordinates) {

                        if ((i + 1) == angleDivisions)
                            header = [header stringByAppendingString:[NSString stringWithFormat:@"{ %f, %f } ", radius, theta]];
                        else if ((i + 1) % numberOfVectorsInRow)
                            header = [header stringByAppendingString:[NSString stringWithFormat:@"{ %f, %f }, ", radius, theta]];
                        else
                            header = [header stringByAppendingString:[NSString stringWithFormat:@"{ %f, %f }, \n ", radius, theta]];

                    } else {

                        const GLKVector2 rect = DSPolarToRectangular((GLKVector2) { radius, theta });

                        if ((i + 1) == angleDivisions)
                            header = [header stringByAppendingString:[NSString stringWithFormat:@"{ %f, %f, 0 } ", rect.x, rect.y]];
                        else if ((i + 1) % numberOfVectorsInRow)
                            header = [header stringByAppendingString:[NSString stringWithFormat:@"{ %f, %f, 0 }, ", rect.x, rect.y]];
                        else
                            header = [header stringByAppendingString:[NSString stringWithFormat:@"{ %f, %f, 0 }, \n", rect.x, rect.y]];
                    }
                }
                
                header = [header stringByAppendingString:@"};"];
            }
            
            return header;
        };
        
        NSString *output = [parser writeOMADataToNSStringWithFormatBlock:foo];
        
        NSLog(@"Object = %@", output);
        
        [parser parsedRadiusForTurns:1. / 128 forEyeIndex:0];
    }
    
    return 0;
}
