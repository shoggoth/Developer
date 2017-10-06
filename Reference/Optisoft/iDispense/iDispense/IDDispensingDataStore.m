//
//  IDDispensingDataStore.m
//  iDispense
//
//  Created by Richard Henry on 14/11/2014.
//  Copyright (c) 2014 Optisoft Ltd. All rights reserved.
//

#import "IDDispensingDataStore.h"
#import "NSDate+Limits.h"

#pragma mark Practice details

@interface PracticeDetails : NSObject

@property(nonatomic, readonly) NSDictionary *practiceDetails;

@end

@implementation PracticeDetails {

    IDContextWatcher    *pdWatcher;
    NSDictionary        *pdDict;
}

@synthesize practiceDetails = pdDict;

- (instancetype)initFromDataStore:(CDSDataStore *)dataStore {

    if ((self = [super init])) {

        // Convert to dictionary
        NSDictionary *(^convertPracticeToDict)(Practice *) = ^NSDictionary *(Practice *prac) {

            NSMutableDictionary *dict = [NSMutableDictionary dictionary];

            if (prac.contactName) [dict setObject:prac.contactName forKey:@"contactName"];
            if (prac.practiceName) [dict setObject:prac.practiceName forKey:@"practiceName"];
            if (prac.address1) [dict setObject:prac.address1 forKey:@"address1"];
            if (prac.address2) [dict setObject:prac.address2 forKey:@"address2"];
            if (prac.postCode) [dict setObject:prac.postCode forKey:@"postCode"];
            if (prac.telephoneNumber) [dict setObject:prac.telephoneNumber forKey:@"telephoneNumber"];
            if (prac.sdcData) [dict setObject:prac.sdcData forKey:@"sdcData"];

            return dict;
        };

        // Initial fetch
        [dataStore performBlock:^NSDictionary *(CDSDataStore *ds) {

            // Try and fetch the practice
            NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Practice"];
            request.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"dateModified" ascending:NO]];

            NSError *error;
            NSArray *result = [ds.moc executeFetchRequest:request error:&error];
            if (error || !result) { [NSException raise:@"Practice details fetch failed" format:@"Reason: %@", [error localizedDescription]]; }

            Practice *practice;

            // If it doesn't exist, create an empty.
            if (!result.count) { practice = nil; }
            
            else practice = [result lastObject];

            return convertPracticeToDict(practice);


        } withCompletion:^(NSDictionary *d) { pdDict = d; }];

        // Practice details update
        pdWatcher = [IDContextWatcher new];
        [pdWatcher addEntityToWatch:@"Practice" withPredicate:[NSPredicate predicateWithValue:YES]];
        pdWatcher.updateBlock = ^(NSDictionary *changes) {

            for (NSManagedObject *update in [changes objectForKey:@"updated"]) {

                if ([update isKindOfClass:[Practice class]]) {

                    pdDict = convertPracticeToDict((Practice *)update);
                }
            }
        };
    }

    return self;
}

@end

#pragma mark - Dispensing Data Store

@implementation IDDispensingDataStore {

    CDSDataStore        *dataStore;
    PracticeDetails     *practiceDetails;
    NSString            *deviceID;
}

#pragma mark Init

+ (instancetype)defaultDataStore {

    static IDDispensingDataStore    *defaultDispensingDataStore;
    static dispatch_once_t          onceToken;

    // Make sure that the initialisation only happens once, even in a multithreaded environment.
    dispatch_once(&onceToken, ^{

        defaultDispensingDataStore = [[IDDispensingDataStore alloc] initWithDataModelName:@"IDDispensingDataStore"];
    });

    return defaultDispensingDataStore;
}

- (instancetype)init {

    // Don't allow the init to be called. Notify that this is a singleton and the static initialiser should
    // be used instead.
    [NSException raise:@"Singleton" format:@"Use +[IDDispensingDataStore defaultDataStore] for access."];

    return nil;
}

- (instancetype)initWithDataModelName:(NSString *)dataModelName {

    if ((self = [super init])) {

        // Initialisation
        deviceID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];

        // Create the data store.
        dataStore = [[CDSDataStore alloc] initWithDataModelName:dataModelName];

        // Fetch practice details
        practiceDetails = [[PracticeDetails alloc] initFromDataStore:dataStore];
    }
    
    return self;
}

#pragma mark Properties

- (NSManagedObjectContext *)managedObjectContext { return dataStore.moc; }


- (BOOL)syncAvailable {

    return dataStore.usingSync;
}

- (BOOL)usingSync {

    return dataStore.usingSync;
}

- (void)setUsingSync:(BOOL)usingSync {

    dataStore.usingSync = usingSync;
}

- (NSDictionary *)practiceDetails { return practiceDetails.practiceDetails; }

#pragma mark Block queries

- (void)performBlock:(CDSContextBlock)contextBlock withCompletion:(CDSCompletionBlock)completionBlock {

    [dataStore performBlock:contextBlock withCompletion:completionBlock];
}

#pragma mark Object queries

- (NSArray *)fetchObjectsWithEntityName:(NSString *)eName predicate:(NSPredicate *)predicate {

    // Check if exists
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:eName];
    request.predicate = predicate;

    NSError *error;
    NSArray *result = [self.managedObjectContext executeFetchRequest:request error:&error];
    if (error || !result) { [NSException raise:@"Fetch failed" format:@"Reason: %@", [error localizedDescription]]; }

    return result;
}

- (id)fetchAnyObjectWithEntityName:(NSString *)eName predicate:(NSPredicate *)predicate {

    NSArray *array = [self fetchObjectsWithEntityName:eName predicate:predicate];

    if (!array.count) return nil; else return array[0];
}

- (Purchase *)fetchPurchaseWithUUID:(NSString *)uuid {

    return [self fetchAnyObjectWithEntityName:@"Purchase" predicate:[NSPredicate predicateWithFormat:@"uuid == %@", uuid]];
}

// Patient

- (NSArray *)allPrescriptionsforPatient:(Patient *)patient {

    return [self fetchObjectsWithEntityName:@"Prescription" predicate:[NSPredicate predicateWithFormat:@"patient == %@", patient]];
}

- (Prescription *)latestPrescriptionForPatient:(Patient *)patient {

    return [[self allPrescriptionsforPatient:patient] lastObject];
}

#pragma mark Expression queries

- (NSDecimalNumber *)fetchOrderTotalsWithPredicate:(NSPredicate *)predicate {

    NSDecimalNumber *(^queryBlock)(NSPredicate *) = ^(NSPredicate *predicate) {

        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Order"];
        request.predicate = predicate;

        NSError *error = nil;
        NSArray *orders = [self.managedObjectContext executeFetchRequest:request error:&error];

        NSDecimalNumber *totalCharges = [orders valueForKeyPath:@"@sum.charges"];

        totalCharges = [totalCharges decimalNumberByAdding:[orders valueForKeyPath:@"@sum.frameOrder.price"]];
        totalCharges = [totalCharges decimalNumberByAdding:[orders valueForKeyPath:@"@sum.lensOrder.price"]];

        return totalCharges;
    };

    return queryBlock(predicate);
}

- (NSDecimalNumber *)fetchOrderTotalsFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate {

    return [self fetchOrderTotalsWithPredicate:[NSPredicate predicateWithFormat:@"date >= %@ AND date <= %@", fromDate, toDate]];
}

- (NSDecimalNumber *)fetchOrderTotalsFromDate:(NSDate *)date {

    return [self fetchOrderTotalsWithPredicate:[NSPredicate predicateWithFormat:@"date >= %@", date]];
}

- (void)deleteObject:(id)object {

    [self performBlock:^(CDSDataStore *ds) { [ds.moc deleteObject:object]; return ds; } withCompletion:nil];
}

#pragma mark Order

- (void)addOrderWithCompletionBlock:(CDSCompletionBlock)completionBlock {

    [self performBlock:^(CDSDataStore *ds) {

        // Create the order
        Order *order = [NSEntityDescription insertNewObjectForEntityForName:@"Order" inManagedObjectContext:self.managedObjectContext];

        // Set up the order
        order.orderNumber = [NSNumber numberWithInteger:[self incrementOrderGUID]];
        order.uuid = [NSString stringWithFormat:@"%@/%@", deviceID, order.orderNumber];
        order.orderPrefix = [[NSUserDefaults standardUserDefaults] stringForKey:@"optometrist_contact_initials_preference"];

        order.date = [NSDate date];
        order.dateModified = [NSDate date];

        // Create a frame order if it doesn't already exist
        if (!order.frameOrder) {

            order.frameOrder = [NSEntityDescription insertNewObjectForEntityForName:@"FrameOrder" inManagedObjectContext:self.managedObjectContext];
            order.frameOrder.frame = [NSEntityDescription insertNewObjectForEntityForName:@"Frame" inManagedObjectContext:self.managedObjectContext];

        }

        // Create a lens order if it doesn't already exist
        if (!order.lensOrder) { order.lensOrder = [NSEntityDescription insertNewObjectForEntityForName:@"LensOrder" inManagedObjectContext:self.managedObjectContext]; }

        // Create an empty patient record if one doesn't already exist
        if (!order.patient) {

            order.patient = [NSEntityDescription insertNewObjectForEntityForName:@"Patient" inManagedObjectContext:self.managedObjectContext];

            // Create a default-valued prescription if none exists
            if (!order.patient.prescriptions.count) {

                Prescription *rx = [NSEntityDescription insertNewObjectForEntityForName:@"Prescription" inManagedObjectContext:self.managedObjectContext];

                rx.right = [NSEntityDescription insertNewObjectForEntityForName:@"EyePrescription" inManagedObjectContext:self.managedObjectContext];
                rx.left  = [NSEntityDescription insertNewObjectForEntityForName:@"EyePrescription" inManagedObjectContext:self.managedObjectContext];

                rx.examDate = [NSDate date];
                rx.uuid = [[NSUUID UUID] UUIDString];

                [order.patient addPrescriptionsObject:rx];
            }
        }

        // Add an empty note
        order.comments = @"";

        return order;

    } withCompletion:^(Order *order) { completionBlock(order); }];
}

- (NSUInteger)countEntitiesNamed:(NSString *)entityName {

    NSError *err;

    return [self.managedObjectContext countForFetchRequest:[NSFetchRequest fetchRequestWithEntityName:entityName] error:&err];
}

#pragma mark Lenses

- (Lens *)addLensWithName:(NSString *)name manuName:(NSString *)mn price:(NSDecimalNumber *)p material:(NSNumber *)mt visType:(NSNumber *)vt {

    Lens *lens = [self fetchAnyObjectWithEntityName:@"Lens" predicate:[NSPredicate predicateWithFormat:@"name == %@ AND manufacturer.name == %@ and price == %@ and hidden == NO", name, mn, p]];

    if (!lens) lens = [NSEntityDescription insertNewObjectForEntityForName:@"Lens" inManagedObjectContext:self.managedObjectContext];

    if (lens) {

        lens.name = name;
        lens.manufacturer = [self addLensManufacturerNamed:mn];
        lens.price = p;

        if (mt) lens.material = mt;
        if (vt) lens.visionType = vt;

        lens.dateModified = [NSDate date];
        lens.hidden = @NO;
    }

    return lens;
}

- (LensTreatment *)addLensTreatmentWithName:(NSString *)name price:(NSDecimalNumber *)p type:(NSString *)tt manuName:(NSString *)mn {

    LensTreatment *lensTreatment = [self fetchAnyObjectWithEntityName:@"LensTreatment" predicate:[NSPredicate predicateWithFormat:@"name == %@ AND manufacturer.name == %@ and price == %@ and type == %@ and hidden == NO", name, mn, p, tt]];

    if (!lensTreatment) lensTreatment = [NSEntityDescription insertNewObjectForEntityForName:@"LensTreatment" inManagedObjectContext:self.managedObjectContext];

    if (lensTreatment) {

        lensTreatment.name = name;
        lensTreatment.manufacturer = [self addLensManufacturerNamed:mn];
        lensTreatment.price = p;

        lensTreatment.type = tt;

        lensTreatment.dateModified = [NSDate date];

    }

    return lensTreatment;
}

- (LensManufacturer *)addLensManufacturerNamed:(NSString *)lensManName {

    if (!lensManName) return nil;

    // Check if this manufacturer already exists and add a record for him if not.
    LensManufacturer *lensMan = [self fetchAnyObjectWithEntityName:@"LensManufacturer" predicate:[NSPredicate predicateWithFormat:@"name == %@", lensManName]];

    if (!lensMan) {

        lensMan = [NSEntityDescription insertNewObjectForEntityForName:@"LensManufacturer" inManagedObjectContext:self.managedObjectContext];

        lensMan.name = lensManName;
    }

    return lensMan;
}

#pragma mark Supplier

- (Supplier *)addSupplierWithName:(NSString *)supplierName acctNumber:(NSString *)acctNum email:(NSString *)emailString {

    // Does this supplier already exist?
    Supplier *supplier = [self fetchAnyObjectWithEntityName:@"Supplier" predicate:[NSPredicate predicateWithFormat:@"name == %@ AND accountNumber == %@ AND emailAddress == %@", supplierName, acctNum, emailString]];

    if (!supplier) {

        supplier = [NSEntityDescription insertNewObjectForEntityForName:@"Supplier" inManagedObjectContext:self.managedObjectContext];

        supplier.name = supplierName;
        supplier.accountNumber = acctNum;
        supplier.emailAddress = emailString;
    }

    return supplier;
}

#pragma mark Practice details

- (void)setPracticeDetails:(NSDictionary *)pd {

    // Write to object
    [dataStore performBlock:^id(CDSDataStore *ds) {

        // Try and fetch the practice
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Practice"];
        request.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"dateModified" ascending:NO]];

        NSError *error;
        NSArray *result = [ds.moc executeFetchRequest:request error:&error];
        if (error || !result) { [NSException raise:@"Practice details fetch failed" format:@"Reason: %@", [error localizedDescription]]; }

        Practice *practice;

        // If it doesn't exist. Let's create one.
        if (!result.count) { practice = [NSEntityDescription insertNewObjectForEntityForName:@"Practice" inManagedObjectContext:ds.moc]; }

        else practice = [result lastObject];

        if (practice) {

            NSString *str;
            if ((str = pd[@"contactName"])) practice.contactName = str;
            if ((str = pd[@"practiceName"])) practice.practiceName = str;
            if ((str = pd[@"address1"])) practice.address1 = str;
            if ((str = pd[@"address2"])) practice.address2 = str;
            if ((str = pd[@"postCode"])) practice.postCode = str;
            if ((str = pd[@"telephoneNumber"])) practice.telephoneNumber = str;

            NSData *data = pd[@"sdcData"];
            if (data) { practice.sdcData = data; }

            practice.dateModified = [NSDate date];
        }
        
        return nil;
        
    } withCompletion:nil];
}

#pragma mark Save

- (void)rollback { [dataStore rollbackWithCompletion:nil]; }
- (void)save { [dataStore saveWithCompletion:nil]; }

- (void)saveWithCompletion:(CDSCompletionBlock)completionBlock { [dataStore saveWithCompletion:completionBlock]; }
- (void)rollbackWithCompletion:(CDSCompletionBlock)completionBlock { [dataStore rollbackWithCompletion:completionBlock]; }

- (void)sync { [dataStore sync]; }

#pragma mark Auto-increment

- (NSInteger)incrementOrderGUID {

    return [self highestOrderGUID] + 1;
}

- (NSInteger)highestOrderGUID {

    NSFetchRequest *fetchRequest = [NSFetchRequest new];

    fetchRequest.entity = [NSEntityDescription entityForName:@"Order" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"orderNumber" ascending:NO]];
    fetchRequest.fetchLimit = 1;

    NSError *error;
    NSArray *array = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];

    if (!error) {

        Order *order = [array lastObject];
        return [order.orderNumber integerValue];
    }

    return 0;
}

@end
