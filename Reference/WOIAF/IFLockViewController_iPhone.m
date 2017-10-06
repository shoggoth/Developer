//
//  IFLockViewController_iPhone.m
//  WOIAF
//
//  Created by Simon Hardie on 06/11/2012.
//  Copyright (c) 2012 Smashing Ideas. All rights reserved.
//

#import "IFLockViewController_iPhone.h"
#import "IFRootViewController_iPhone.h"
#import "IFCoreDataStore.h"

#import "ItemBase.h"
#import "Person.h"
#import "Place.h"
#import "House.h"
#import "ItemBase+LockState.h"

@interface IFLockViewController_iPhone ()

@end

@implementation IFLockViewController_iPhone {
    
    // State control
    enum { hidden, shown }      state;
    
    CGPoint                     lockViewShownCentre;
    CGPoint                     lockViewHiddenCentre;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    lockViewShownCentre = self.view.center;
    lockViewHiddenCentre = CGPointMake(self.view.center.x, self.view.center.y - 1024);
    //self.view.center = lockViewShownCentre;
    
    lockedBookTextView.font = [UIFont fontWithName: @"Palatino" size:18];
    spoilerBookTextView.font = [UIFont fontWithName: @"Palatino" size:18];
    
    [self hide:nil];
}

- (void)viewDidUnload {
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
	return interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

#pragma mark - Operations

- (BOOL)showItem:(ItemBase *)item {
    
    static NSString *bookNames[] = { @"", @"A Game of Thrones", @"A Clash of Kings", @"A Storm of Swords", @"A Feast for Crows", @"A Dance with Dragons" };
    
    if (!item) {
        
        initialContentView.hidden = NO;
        lockedContentView.hidden = YES;
        spoileredContentView.hidden = YES;
        
        [self show:nil];
        
        return YES;
        
    } else {
    BOOL needsLockScreen = (item.isPurchaseLocked || item.isSpoilerLocked);
    
        if (state == hidden && needsLockScreen) {
            
            initialContentView.hidden = YES;
            lockedContentView.hidden = !item.isPurchaseLocked;
            spoileredContentView.hidden = item.isPurchaseLocked;
            
            NSString *typeOfThing = @"map";
            
            if ([item isKindOfClass:[Person class]]) typeOfThing = @"person";
            else if ([item isKindOfClass:[House class]]) typeOfThing = @"house";
            else if ([item isKindOfClass:[Place class]]) typeOfThing = @"place";
            
            if (item.isPurchaseLocked) {
                
                lockedBookTextView.text = [NSString stringWithFormat:@"%@ first appears in '%@'.\n\nTo see information about this %@, go to the Books Read menu and purchase the info pack for %@.", item.name, bookNames[item.book.intValue], typeOfThing, bookNames[item.book.intValue]];
            }
            
            else if (item.isSpoilerLocked) {
                
                spoilerBookTextView.text = [NSString stringWithFormat:@"%@ first appears in '%@'.\n\nTo see information about this %@, go to the Books Read menu and move the spoiler slider past book %@. Beware: this may reveal spoilers you might not want to see.", item.name, bookNames[item.book.intValue], typeOfThing, bookNames[item.book.intValue]];
            }
            
            [self show:nil];
        }
        
        return needsLockScreen;
    }
}

#pragma mark - Animation

- (void)hide:(id)sender {
    
    if (state == hidden) return;
    
    self.view.hidden = YES;
    state = hidden;
}

- (void)show:(id)sender {
    
    if (state == shown) return;
    
    self.view.hidden = NO;
    state = shown;
}

@end
