//
//  IDDataFetchController.h
//  iDispense
//
//  Created by Richard Henry on 06/04/2016.
//  Copyright © 2016 Optisoft Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface IDDataFetchController : NSObject

- (nonnull instancetype)initWithTableView:(UITableView *__nonnull)tv entityName:(NSString *__nonnull)en sortDescriptors:(NSArray<NSSortDescriptor *> *__nonnull)sd cacheName:(NSString *__nullable)cn sectionNameKeyPath:(NSString *__nullable)sk mocToObserve:(NSManagedObjectContext *__nullable) moc;
- (nonnull instancetype)initWithTableView:(UITableView *__nonnull)tv entityName:(NSString *__nonnull)en sortDescriptors:(NSArray<NSSortDescriptor *> *__nonnull)sd cacheName:(NSString *__nullable)cn sectionNameKeyPath:(NSString *__nullable)sk;
- (nonnull instancetype)initWithTableView:(UITableView *__nonnull)tv entityName:(NSString *__nonnull)en sortDescriptors:(NSArray<NSSortDescriptor *> *__nonnull)sd cacheName:(NSString *__nullable)cn;
- (nonnull instancetype)initWithTableView:(UITableView *__nonnull)tv entityName:(NSString *__nonnull)en sortDescriptors:(NSArray<NSSortDescriptor *> *__nonnull)sd;

@property(nonatomic, readonly, nonnull) NSFetchedResultsController *fetchedResultsController;
@property(nonatomic, strong, nullable) NSPredicate *predicate;

@property(nonatomic, assign) BOOL updatesAreUserDriven;

@property(nonatomic, copy, nullable) UITableViewCell *__nullable (^cellUpdateBlock)(UITableViewCell *__nullable cell, id __nonnull object);
@property(nonatomic, copy, nullable) BOOL (^tableUpdateCompletionBlock)(UITableView *__nonnull tableView);

- (void)fetchWithCompletion:(nullable void (^)(NSArray *__nullable))completion;

@end
