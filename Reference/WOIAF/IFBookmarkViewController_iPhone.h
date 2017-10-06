//
//  IFBookmarkViewController_iPhone.h
//  WOIAF
//
//  Created by Simon Hardie on 06/11/2012.
//  Copyright (c) 2012 Smashing Ideas. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IFRootViewController_iPhone;
@class IFItemViewController_iPhone;

@interface IFBookmarkViewController_iPhone : UIViewController {
    
    __weak IBOutlet UITableView     *tableView;
    
    __weak IBOutlet UIView          *lockedView;
}

// Operations
- (void)loadSavedBookmarks;
- (BOOL)itemIsBookmarked:(id)item;
- (BOOL)bookmarkItem:(id)item;
- (BOOL)removeBookmarkForItem:(id)item;

- (NSUInteger)bookmarkCount;

- (void)saveUserDefaults;

- (void)reloadBookmarks;

- (IBAction)closeBookmarks:(id)sender;

@property (weak, nonatomic) IFRootViewController_iPhone *rootViewController;
@property (weak, nonatomic) IFItemViewController_iPhone *itemViewController;


@end
