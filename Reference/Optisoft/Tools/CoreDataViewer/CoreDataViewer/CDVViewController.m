//
//  ViewController.m
//  CoreDataViewer
//
//  Created by Richard Henry on 12/08/2015.
//  Copyright (c) 2015 Optisoft Ltd. All rights reserved.
//

#import "CDVViewController.h"
#import "DataClasses.h"

static NSString *makeSillyPersonName() {

    static NSArray          *parts = nil;
    static dispatch_once_t  once;

    dispatch_once(&once, ^{

        parts = @[
                  @[@"fl", @"tr", @"g", @"gr", @"pl", @"m", @"sc", @"c", @"my"],
                  @[@"op", @"ip", @"arp", @"ull", @"or", @"ori", @"og", @"eb", @"app", @"er", @"un", @"uc", @"an"],
                  @[@"row", @"ula", @"ham", @"son", @"stein", @"bont", @"bul", @"ton", @"ns", @"ti"],
                  ];
    });

    NSString *(^randomFractionFromArrayIndex)(int) = ^NSString *(int arrayIndex) { return parts[arrayIndex][rand() % ((NSArray *)parts[arrayIndex]).count]; };

    NSString *(^makeRandomName)() = ^NSString *() {

        NSString *name = (rand() % 1000 > 250) ? randomFractionFromArrayIndex(0) : randomFractionFromArrayIndex(1);
        for (int i = 0; i < rand() % 2 + 1; i++) { name = [name stringByAppendingString:randomFractionFromArrayIndex(1)]; }
        name = [name stringByAppendingString:randomFractionFromArrayIndex(2)];

        return name;
    };

    return [[makeRandomName() capitalizedString] stringByAppendingFormat:@", %@", [makeRandomName() capitalizedString]];
}

@interface CDVViewController ()

@end

@implementation CDVViewController {

    __weak IBOutlet UISwitch *iCloudToggleSwitch;
    __weak IBOutlet UILabel *iCloudLabel;

    CloudDataStore      *cloudDataStore;
    CloudKitStore       *cloudKitStore;
    ContextWatcher      *watcher;
}

+ (void)initialize {

    srand((unsigned)time(NULL));
}

- (void)viewDidLoad {

    [super viewDidLoad];

    cloudDataStore = [CloudDataStore sharedDataStore];
    cloudDataStore.dataStoreName = @"CoreDataViewer";

    iCloudToggleSwitch.on = cloudDataStore.iCloudEnabledByUser;

    watcher = [ContextWatcher new];
    watcher.updateBlock = ^(NSDictionary *changes) {

        for (Thing *thing in [changes objectForKey:NSInsertedObjectsKey]) { NSLog(@"Inserted thing = %@", thing.name); }
        for (Thing *thing in [changes objectForKey:NSDeletedObjectsKey]) { NSLog(@"Deleted thing = %@", thing.name); }
        for (Thing *thing in [changes objectForKey:NSUpdatedObjectsKey]) { NSLog(@"Updated thing = %@", thing.name); }
    };
    
    [watcher addEntityToWatch:[NSEntityDescription entityForName:@"Person" inManagedObjectContext:cloudDataStore.context] withPredicate:[NSPredicate predicateWithValue:YES]];
    [watcher subscribeToStoreChangeNotifications:cloudDataStore];

    cloudKitStore = [CloudKitStore new];
    [cloudKitStore test];
}

- (void)didReceiveMemoryWarning {

    [super didReceiveMemoryWarning];

    NSLog(@"Warning: didReceiveMemoryWarning (Dispose of any resources that can be recreated.)");
}

#pragma mark Actions

- (IBAction)toggleiCloud:(UISwitch *)sender {

    NSLog(@"iCloud = %d (No longer functions)", sender.on);
    //cloudDataStore.iCloudEnabledByUser = iCloudToggleSwitch.on;
}

- (IBAction)addItem:(UIBarButtonItem *)sender {

    Person *newPerson = [cloudDataStore addEntityNamed:@"Person"];

    newPerson.name = makeSillyPersonName();
}

- (IBAction)mutateItem:(UIButton *)sender {

    NSArray *people = [cloudDataStore fetchEntitiesNamed:@"Person"];

    Person *person = [people objectAtIndex:rand() % people.count];

    person.nick = [person.name stringByAppendingString:@"io (nick)"];
    person.name = [person.name stringByAppendingString:@" mutated"];

    person.beheaded = @YES;
}

- (IBAction)deleteItem:(UIButton *)sender {

    [cloudDataStore deleteObject:[[cloudDataStore fetchEntitiesNamed:@"Person"] lastObject]];
}

- (IBAction)dumpItems:(UIButton *)sender {

    NSPredicate *predicate = [NSPredicate predicateWithValue:YES];
    NSSortDescriptor *sortByName = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];

    // These sorts of block based compare don't work with core data.
    // They'll work with arrays but that would mean fetching all the data and then sorting.
    // NSSortDescriptor *sortByNameLength = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES comparator:^(NSString * obj1, NSString *obj2) { if (obj1.length == obj2.length) return NSOrderedSame; else return (obj1.length > obj2.length) ? NSOrderedAscending : NSOrderedDescending; }];

    NSArray *arr;
    arr = [cloudDataStore fetchEntitiesNamed:@"Person" withPredicate:predicate sortedWith:@[ sortByName ]];
    arr = [cloudDataStore fetchEntitiesWithTemplateName:@"NameLike" withSubstitutions:@{ @"foo" : @"*ori*", @"bar" : @"ham" } sortedWith:@[ sortByName ]];
    arr = [cloudDataStore fetchEntitiesWithTemplateName:@"OriOrHamFolk" withSubstitutions:@{} sortedWith:@[ sortByName ]];

    for (Person *person in arr) {

        NSLog(@"Person name %@ nick %@ shouty %@", person.name, person.nick, person.shoutyName);
    }
}

- (IBAction)save:(UIButton *)sender {

    [cloudDataStore saveContextAsynchronously];
}

@end
