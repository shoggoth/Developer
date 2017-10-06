//
//  PrepareTableViewController.m
//  CoreDataViewer
//
//  Created by Richard Henry on 25/08/2015.
//  Copyright (c) 2015 Optisoft Ltd. All rights reserved.
//

#import "PrepareTableViewController.h"
#import "DataClasses.h"

@interface PrepareTableViewController ()

@end

@implementation PrepareTableViewController

- (void)viewDidLoad {

    [super viewDidLoad];

    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 44.0;

    [self configureFetch];
    [self performFetch];

    self.clearConfirmActionSheet.delegate = self;
}

- (void)configureFetch {

    CloudDataStore *dataStore = [CloudDataStore sharedDataStore];

    [dataStore subscribeToNotifications:self selector:@selector(refresh:)];

    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Person"];

    // RJH This is important
    request.fetchBatchSize = 10;
    request.sortDescriptors = @[
                                [NSSortDescriptor sortDescriptorWithKey:@"place.name" ascending:YES],
                                [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]
                                ];

    self.frc = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:dataStore.context sectionNameKeyPath:nil cacheName:nil];
    self.frc.delegate = self;
}

- (void)refresh:(NSNotification *)note {

    [self performFetch];
}

#pragma mark Action

- (IBAction)clear:(id)sender {

    NSError *error;
    DataStore *store = [DataStore sharedDataStore];

    NSFetchRequest *request = [store.model fetchRequestTemplateForName:@"OriOrHamFolk"];
    NSArray *nameLikes = [store.context executeFetchRequest:request error:&error];

    if (nameLikes.count) {

        self.clearConfirmActionSheet = [[UIActionSheet alloc] initWithTitle:@"Clear Names Like blah?"
                                                                   delegate:self
                                                          cancelButtonTitle:@"Cancel"
                                                     destructiveButtonTitle:@"Clear"
                                                          otherButtonTitles:nil];

        [self.clearConfirmActionSheet showFromTabBar:self.navigationController.tabBarController.tabBar];

    } else {

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Nothing to Clear"
                                                        message:@"Add items to the Shop tab by tapping them on the Prepare tab. Remove all items from the Shop tab by clicking Clear on the Prepare tab"
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
         [alert show];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {

    if (actionSheet == self.clearConfirmActionSheet) {

        if (buttonIndex == [actionSheet destructiveButtonIndex])

            [self performSelector:@selector(clearList)];

        else if (buttonIndex == [actionSheet cancelButtonIndex])

            [actionSheet dismissWithClickedButtonIndex: [actionSheet cancelButtonIndex] animated:YES];
    }
}

- (void)clearList {

    NSError *error;
    DataStore *store = [DataStore sharedDataStore];

    NSFetchRequest *request = [store.model fetchRequestTemplateForName:@"OriOrHamFolk"];
    NSArray *nameLikes = [store.context executeFetchRequest:request error:&error];

    for (Person *person in nameLikes) {

        person.name = @"Deleted";
    }
}

#pragma mark View

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    Person *person = [self.frc objectAtIndexPath:indexPath];

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DefaultCell" forIndexPath:indexPath];

    NSMutableString *title = [NSMutableString stringWithFormat:@"%@ %@ %@", person.name, person.nick, person.place.name];
    [title replaceOccurrencesOfString:@"(null)" withString:@"???" options:0 range:NSMakeRange(0, [title length])];
    cell.textLabel.text = title;

    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {

    if (editingStyle == UITableViewCellEditingStyleDelete) {


        [self.frc.managedObjectContext deleteObject:[self.frc objectAtIndexPath:indexPath]];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    NSManagedObjectID *thingID = [[self.frc objectAtIndexPath:indexPath] objectID];

    NSError *error;
    Thing *thing = (Thing *)[self.frc.managedObjectContext existingObjectWithID:thingID error:&error];

    if (!thing.name) thing.name = @"Touched"; else thing.name = nil;

    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

@end
