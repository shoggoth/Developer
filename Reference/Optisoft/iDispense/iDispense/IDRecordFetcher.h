//
//  IDDispensingDataStore.h
//  iDispense
//
//  Created by Richard Henry on 14/11/2014.
//  Copyright (c) 2014 Optisoft Ltd. All rights reserved.
//

@import CoreData;

#import "Order.h"
#import "Patient.h"
#import "Prescription.h"

#import "Frame.h"
#import "FrameSize.h"
#import "FrameManufacturer.h"

#import "Lens.h"
#import "LensManufacturer.h"

@interface IDRecordFetcher : NSObject

- (instancetype)initWithEntityName:(NSString *)eName sortDescriptors:(NSArray *)sortDesc;

@property(nonatomic, copy) NSString *entityName;
@property(nonatomic, strong) NSPredicate *predicate;
@property(nonatomic, strong) NSArray *sortingDescriptors;

@property(nonatomic, readonly) NSFetchedResultsController *fetchedResultsController;

- (NSArray *)fetch;

@end
