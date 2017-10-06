//
//  DSFilter.h
//  Dogstar Engine (unified version)
//
//  Created by Richard Henry on 01/01/2011.
//  Copyright 2011 Dogstar Diversions. http://www.dogstar.mobi
//


//
//  DSFilter protocol
//
//  TODO: Document this
//

@protocol DSFilter <NSObject>

- (float)filterValue:(float)value;

@end


//
//  DSLowPassFilter class interface
//
//  TODO: Document this
//

@interface DSLowPassFilter : NSObject <DSFilter> {
    
    float       filterFactor;
}

@property(nonatomic) float filterFactor;

@end


//
//  DSHighPassFilter class interface
//
//  TODO: Document this
//

@interface DSHighPassFilter : DSLowPassFilter

@end
