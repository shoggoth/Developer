//
//  OSPlatform.h
//  OptiLib
//
//  Created by Richard Henry on 04/11/2013.
//  Copyright (c) 2013 Optisoft. All rights reserved.
//

#ifndef OptiLib_OSPlatform_h
#define OptiLib_OSPlatform_h

static inline BOOL OSIsiPhone() {
    
    // Is the device we're running on an iPhone?
    return ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone);
}

static inline NSString *OSSystemVersionString() {

    return [UIDevice currentDevice].systemVersion;
}

static inline BOOL OSSystemVersionIsGreaterThanOrEqualTo(NSString *checkVersionString) {

    return ([OSSystemVersionString() compare:checkVersionString options:NSNumericSearch] != NSOrderedAscending);
}

#endif
