//
//  Practice+CoreDataProperties.h
//  iDispense
//
//  Created by Richard Henry on 28/06/2016.
//  Copyright © 2016 Optisoft Ltd. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Practice.h"

NS_ASSUME_NONNULL_BEGIN

@interface Practice (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *address1;
@property (nullable, nonatomic, retain) NSString *address2;
@property (nullable, nonatomic, retain) NSString *contactName;
@property (nullable, nonatomic, retain) NSDate *dateModified;
@property (nullable, nonatomic, retain) NSString *postCode;
@property (nullable, nonatomic, retain) NSString *practiceName;
@property (nullable, nonatomic, retain) NSString *telephoneNumber;
@property (nullable, nonatomic, retain) NSData *sdcData;
@property (nullable, nonatomic, retain) NSSet<DO *> *opticians;

@end

@interface Practice (CoreDataGeneratedAccessors)

- (void)addOpticiansObject:(DO *)value;
- (void)removeOpticiansObject:(DO *)value;
- (void)addOpticians:(NSSet<DO *> *)values;
- (void)removeOpticians:(NSSet<DO *> *)values;

@end

NS_ASSUME_NONNULL_END
