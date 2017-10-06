//
//  IFBookmarkViewController.h
//  WOIAF
//
//  Created by Richard Henry on 19/09/2012.
//  Copyright (c) 2012 Smashing Ideas. All rights reserved.
//


@class IFRootViewController;

@interface IFBookmarkViewController : UIViewController {
    
    __weak IBOutlet UITableView     *tableView;
}

// Interface
- (void)loadSavedBookmarks;
- (BOOL)itemIsBookmarked:(id)item;
- (BOOL)bookmarkItem:(id)item;
- (BOOL)removeBookmarkForItem:(id)item;

- (NSUInteger)bookmarkCount;

- (void)saveUserDefaults;

- (void)reloadBookmarks;

@property (weak, nonatomic) IFRootViewController *rootViewController;
@property (weak, nonatomic) UIPopoverController *parentPopover;


@end
