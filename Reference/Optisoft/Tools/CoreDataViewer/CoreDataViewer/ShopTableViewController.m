//
//  ShopTableViewController.m
//  CoreDataViewer
//
//  Created by Richard Henry on 26/08/2015.
//  Copyright (c) 2015 Optisoft Ltd. All rights reserved.
//

#import "ShopTableViewController.h"
#import "Deduplicator.h"
#import "DataClasses.h"

@interface ShopTableViewController ()

@end

@implementation ShopTableViewController

- (void)configureFetch {

    CoreDataHelper *cdh = [CoreDataHelper sharedHelper];

    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Person"];
    request.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];

    self.frc = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                   managedObjectContext:cdh.context
                                                     sectionNameKeyPath:nil
                                                              cacheName:nil];

    self.frc.delegate = self;
}

- (void)viewDidLoad {

    [super viewDidLoad];

    [self configureFetch];
    [self performFetch];
}

- (void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];

    //CoreDataHelper *cdh = [CoreDataHelper sharedHelper];

    //[Deduplicator deDuplicateEntityWithName:@"Person" withUniqueAttributeName:@"name" withImportContext:cdh.importContext];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(performFetch)
                                                 name:@"SomethingChanged"
                                               object:nil];
}

#pragma mark Boilerplate

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *cellIdentifier = @"DefaultCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    Person *person = [self.frc objectAtIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"From: %@", person.name];
    cell.detailTextLabel.text = person.nick;

    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {

    if (editingStyle == UITableViewCellEditingStyleDelete) {

        NSManagedObject *deleteTarget = [self.frc objectAtIndexPath:indexPath];
        [self.frc.managedObjectContext deleteObject:deleteTarget];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }

    CoreDataHelper *cdh = [CoreDataHelper sharedHelper];
    [cdh backgroundSaveContext];
}

- (IBAction)add:(id)sender {

    CoreDataHelper *cdh = [CoreDataHelper sharedHelper];
    Person *object = [NSEntityDescription insertNewObjectForEntityForName:@"Person" inManagedObjectContext:cdh.context];
    NSError *error = nil;
    if (![cdh.context obtainPermanentIDsForObjects:[NSArray arrayWithObject:object] error:&error]) { NSLog(@"Couldn't obtain a permanent ID for object %@", error); }

    UIDevice *thisDevice = [UIDevice new];
    object.name = thisDevice.name;
    object.nick = [NSString stringWithFormat:@"Person: %@", [[NSUUID UUID] UUIDString]];

    [cdh backgroundSaveContext];
}
                        
@end
