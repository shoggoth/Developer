//
//  ViewController.m
//  DatabaseTool
//
//  Created by Richard Henry on 23/01/2015.
//  Copyright (c) 2015 Dogstar Industries. All rights reserved.
//

#import "ViewController.h"
#import "IDDispensingDataStore.h"

@interface DBTDispensingDataStore : IDDispensingDataStore

@property(nonatomic) NSInteger guid;

@end

@implementation DBTDispensingDataStore

- (void)deleteDataBaseFiles {

    void (^deleteFileIfExists)(NSString *) = ^(NSString *fileName) {

        NSURL           *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:fileName];
        NSError         *error;
        NSFileManager   *fileManager = [NSFileManager defaultManager];

        // If the expected store doesn't exist, copy the default store.
        if ([fileManager fileExistsAtPath:[storeURL path]]) {

            [fileManager removeItemAtURL:storeURL error:&error];
        }
    };

    deleteFileIfExists([NSString stringWithFormat:@"%@.sqlite", self.dataModelName]);
    deleteFileIfExists([NSString stringWithFormat:@"%@.sqlite-wal", self.dataModelName]);
    deleteFileIfExists([NSString stringWithFormat:@"%@.sqlite-shm", self.dataModelName]);
}


- (NSURL *)applicationDocumentsDirectory {

    return [[super applicationDocumentsDirectory] URLByAppendingPathComponent:@"Code/iDispense/iDispense"];
}

- (NSInteger)incrementOrderGUID {

    return ++_guid;
}

@end

@implementation ViewController

- (void)viewDidLoad {

    [super viewDidLoad];

    // Do any additional setup after loading the view.
    self.guidBase = @"0";
    self.createBackingData = YES;
    self.createOrders = NO;
}

- (void)setRepresentedObject:(id)representedObject {

    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
    NSLog(@"What is this?");
}

#pragma mark Actions

- (IBAction)createDatabasePressed:(NSButton *)sender {

    [self.view.window endEditingFor:self.guidTextField];

    [self createDefaultDataSet];
}

#pragma mark DB

- (void)createDefaultDataSet {

    DBTDispensingDataStore *dataStore = [[DBTDispensingDataStore alloc] initWithDataModelName:@"IDDispensingDataStore"];

    dataStore.guid = self.guidBase.integerValue;

    [self appendLogText:@"Creating new database\n" highlight:YES];
    [dataStore deleteDataBaseFiles];

    if (self.createBackingData) {

        [self appendLogText:@"Adding backing data\n" highlight:YES];

        // Make some lenses
        [dataStore addLensWithName:@"MondoVision 1.6" manuName:@"Essilor" price:15 + (rand() % 100 * 0.1) material:rand() % 4 visType:rand() % 4];
        [dataStore addLensWithName:@"Brownout versifier" manuName:@"Zeiss" price:15 + (rand() % 100 * 0.1) material:rand() % 4 visType:rand() % 4];
        [dataStore addLensWithName:@"Bisto tint 1.67" manuName:@"Hoya" price:15 + (rand() % 100 * 0.1) material:rand() % 4 visType:rand() % 4];
        [dataStore addLensWithName:@"PlusVision L Series" manuName:@"Essilor" price:15 + (rand() % 100 * 0.1) material:rand() % 4 visType:rand() % 4];
        [dataStore addLensWithName:@"Eagle Trend Bifocal" manuName:@"Essilor" price:15 + (rand() % 100 * 0.1) material:rand() % 4 visType:rand() % 4];
        [dataStore addLensWithName:@"Spheroid Engine" manuName:@"Zeiss" price:15 + (rand() % 100 * 0.1) material:rand() % 4 visType:rand() % 4];
        [dataStore addLensWithName:@"Moke magnifier" manuName:@"Hoya" price:15 + (rand() % 100 * 0.1) material:rand() % 4 visType:rand() % 4];
        [dataStore addLensWithName:@"Zoom Max 1.9" manuName:@"Essilor" price:15 + (rand() % 100 * 0.1) material:rand() % 4 visType:rand() % 4];
        [dataStore addLensWithName:@"Extreme Thin" manuName:@"Zeiss" price:15 + (rand() % 100 * 0.1) material:rand() % 4 visType:rand() % 4];
        [dataStore addLensWithName:@"EuroVision 1.6" manuName:@"Hoya" price:15 + (rand() % 100 * 0.1) material:rand() % 4 visType:rand() % 4];

        // Make some frames
        Frame *frame = [dataStore addFrameWithName:@"Hipster specials" manuName:@"DNKY" price:30 + (rand() % 500 * 0.1) frameType:rand() % 5];
        [dataStore addFrameStyleWithStyle:@"HS_STYLE" colour:@"Puce" toFrame:frame];
        [dataStore addFrameSizeWithSize:1 length:2 bridge:3 toFrame:frame];

        frame = [dataStore addFrameWithName:@"Eldritch" manuName:@"DNKY" price:30 + (rand() % 500 * 0.1) frameType:rand() % 5];
        [dataStore addFrameStyleWithStyle:@"ELD1" colour:@"Green" toFrame:frame];
        [dataStore addFrameStyleWithStyle:@"ELD2" colour:@"Green" toFrame:frame];
        [dataStore addFrameSizeWithSize:2 length:3 bridge:4 toFrame:frame];

        frame = [dataStore addFrameWithName:@"Rugose" manuName:@"Armani" price:30 + (rand() % 500 * 0.1) frameType:rand() % 5];
        [dataStore addFrameStyleWithStyle:@"RUG1" colour:@"Red" toFrame:frame];
        [dataStore addFrameStyleWithStyle:@"RUG2" colour:@"Blue" toFrame:frame];
        [dataStore addFrameSizeWithSize:1 length:2 bridge:3 toFrame:frame];

        frame = [dataStore addFrameWithName:@"Trondheim" manuName:@"Jeff Banks" price:30 + (rand() % 500 * 0.1) frameType:rand() % 5];
        [dataStore addFrameStyleWithStyle:@"TRNEDY" colour:@"Orange" toFrame:frame];
        [dataStore addFrameStyleWithStyle:@"TRENDY" colour:@"Metallic Turquoise" toFrame:frame];
        [dataStore addFrameSizeWithSize:1 length:2 bridge:3 toFrame:frame];

        frame = [dataStore addFrameWithName:@"Trondheim" manuName:@"Stvdio" price:30 + (rand() % 500 * 0.1) frameType:rand() % 5];
        [dataStore addFrameStyleWithStyle:@"TRNEDY" colour:@"Orange and Pink" toFrame:frame];
        [dataStore addFrameStyleWithStyle:@"TRENDY" colour:@"Teal" toFrame:frame];
        [dataStore addFrameSizeWithSize:1 length:3 bridge:3 toFrame:frame];

        frame = [dataStore addFrameWithName:@"Ikea browsers" manuName:@"DNKY" price:30 + (rand() % 500 * 0.1) frameType:rand() % 5];
        [dataStore addFrameStyleWithStyle:@"FURGLE" colour:@"Orange and Pink" toFrame:frame];
        [dataStore addFrameStyleWithStyle:@"FRUGLE" colour:@"White" toFrame:frame];
        [dataStore addFrameSizeWithSize:2 length:1 bridge:3 toFrame:frame];

        frame = [dataStore addFrameWithName:@"Rolling Palm" manuName:@"Armani" price:30 + (rand() % 500 * 0.1) frameType:rand() % 5];
        [dataStore addFrameStyleWithStyle:@"WOPP67" colour:@"Grey" toFrame:frame];
        [dataStore addFrameStyleWithStyle:@"WOPP98" colour:@"Cream" toFrame:frame];
        [dataStore addFrameSizeWithSize:2 length:1 bridge:3 toFrame:frame];

        frame = [dataStore addFrameWithName:@"Spencer Tracy" manuName:@"Oakley" price:30 + (rand() % 500 * 0.1) frameType:rand() % 5];
        [dataStore addFrameSizeWithSize:4 length:1 bridge:3 toFrame:frame];
        [dataStore addFrameSizeWithSize:2 length:4 bridge:3 toFrame:frame];
        [dataStore addFrameSizeWithSize:2 length:1 bridge:4 toFrame:frame];

        frame = [dataStore addFrameWithName:@"Lennonesque" manuName:@"Oakley" price:30 + (rand() % 500 * 0.1) frameType:rand() % 5];
        [dataStore addFrameStyleWithStyle:@"WOMP67" colour:@"Gold" toFrame:frame];
        [dataStore addFrameStyleWithStyle:@"WOMP98" colour:@"Brown" toFrame:frame];
        [dataStore addFrameSizeWithSize:2 length:1 bridge:3 toFrame:frame];

        // Make some treatments
        [dataStore addLensTreatmentWithName:@"Rose Tint" price:15 + (rand() % 100 * 0.1) type:@"Tint" manuName:@"Essilor"];
        [dataStore addLensTreatmentWithName:@"Anti-reflection" price:15 + (rand() % 100 * 0.1) type:@"Coat" manuName:@"Essilor"];
        [dataStore addLensTreatmentWithName:@"Blue frosting" price:15 + (rand() % 100 * 0.1) type:@"Finish" manuName:@"Essilor"];
    }

    if (self.createOrders) {

        [self appendLogText:@"Creating orders\n" highlight:YES];

        // Add some noddy orders
        void (^addOrder)() = ^(NSString *pFirstName, NSString *pSurName, LensOrder *lensOrder, FrameOrder *frameOrder) {

            Order   *order = [dataStore addOrder];

            order.patient = [dataStore addPatientWithFirstName:pFirstName surName:pSurName birthDate:nil];

            // Set up order
            order.lensOrder = lensOrder;
            order.frameOrder = frameOrder;
            order.charges = 25 + (rand() % 1000 * 0.1);

            [self appendLogText:[NSString stringWithFormat:@"Order %lld added (%@, %@).\n", order.guid, order.patient.surName, order.patient.firstName] highlight:NO];
        };

        addOrder(@"Richard", @"Henry", nil, nil);
    }

    // Save data
    [self appendLogText:@"Saving database\n" highlight:YES];
    [dataStore save];
}

#pragma mark Utility

- (void)appendLogText:(NSString *)logString highlight:(BOOL)highlight {

    static NSFont       *logTextFont;
    static NSDictionary *unhighlightedParameters = nil;
    static NSDictionary *highlightedParameters = nil;

    if (!logTextFont) logTextFont = [NSFont fontWithName:@"Monaco" size:12];

    if (!unhighlightedParameters) {

        unhighlightedParameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                   logTextFont, NSFontAttributeName,
                                   nil];
    }

    if (!highlightedParameters) {

        highlightedParameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                 logTextFont, NSFontAttributeName,
                                 [NSColor redColor], NSForegroundColorAttributeName,
                                 nil];
    }

    NSTextView *textView = self.textView;
    NSTextStorage *ts = textView.textStorage;
    NSDictionary *attributeDictionary = (highlight) ? highlightedParameters : unhighlightedParameters;

    // Append the log string
    dispatch_async(dispatch_get_main_queue(), ^{

        [ts beginEditing];
        [ts appendAttributedString:[[NSAttributedString alloc] initWithString:logString attributes:attributeDictionary]];
        [ts endEditing];

        // Get the length of the textview contents
        [textView scrollRangeToVisible:NSMakeRange([[textView string] length], 0)];
    });
}

@end
