//
//  IDDispensingDataStore.h
//  iDispense
//
//  Created by Richard Henry on 14/11/2014.
//  Copyright (c) 2014 Optisoft Ltd. All rights reserved.
//

@import CoreDataStore;

#import "IDContextWatcher.h"
#import "DataClasses.h"

//
//  interface IDDispensingDataStore
//
//  Data store wrapper with functionality related to dispensing.
//

@interface IDDispensingDataStore : NSObject

+ (nonnull instancetype)defaultDataStore;

// Properties
@property(nonatomic) BOOL usingSync;
@property(nonatomic, readonly, nonnull) NSManagedObjectContext *managedObjectContext;

// Data properties
@property(nonatomic, readonly, nullable) NSDictionary *practiceDetails;

// Database functions
- (void)performBlock:(nullable CDSContextBlock)contextBlock withCompletion:(nullable CDSCompletionBlock)completionBlock;

- (void)rollback;
- (void)save;
- (void)sync;

// Object create (context)
- (void)addOrderWithCompletionBlock:(nullable CDSCompletionBlock)completionBlock;
- (void)setPracticeDetails:(NSDictionary *__nonnull)pd;

// Object creation (return value)
- (Lens *__nullable)addLensWithName:(NSString *__nonnull)name manuName:(NSString *__nonnull)mn price:(NSDecimalNumber *__nonnull)p material:(NSNumber *__nullable)m visType:(NSNumber *__nullable)vt;
- (LensTreatment *__nullable)addLensTreatmentWithName:(NSString *__nonnull)name price:(NSDecimalNumber *__nonnull)p type:(NSString *__nonnull)tt manuName:(NSString *__nonnull)mn;
- (LensManufacturer *__nullable)addLensManufacturerNamed:(NSString *__nullable)lensManName;
- (Supplier *__nullable)addSupplierWithName:(NSString *__nonnull)supplierName acctNumber:(NSString *__nonnull)acctNum email:(NSString *__nonnull)emailString;

// Object delete (context)
- (void)deleteObject:(nullable id)object;

// Object queries (return value)
- (NSUInteger)countEntitiesNamed:(NSString *__nonnull)entityName;
- (NSDecimalNumber *__nonnull)fetchOrderTotalsFromDate:(NSDate *__nonnull)date;
- (NSDecimalNumber *__nonnull)fetchOrderTotalsFromDate:(NSDate *__nonnull)fromDate toDate:(NSDate *__nonnull)toDate;

@end
