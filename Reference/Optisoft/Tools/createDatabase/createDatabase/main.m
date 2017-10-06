//
//  main.m
//  createDatabase
//
//  Created by Richard Henry on 23/01/2015.
//  Copyright (c) 2015 Dogstar Industries. All rights reserved.
//

@import Foundation;

#import "IDDispensingDataStore.h"

int main(int argc, const char * argv[]) {

    @autoreleasepool {

        IDDispensingDataStore *dataStore = [[IDDispensingDataStore alloc] initWithDataModelName:@"IDDispensingDataStore"];

        [dataStore createDefaultDataSet];
    }

    return 0;
}
