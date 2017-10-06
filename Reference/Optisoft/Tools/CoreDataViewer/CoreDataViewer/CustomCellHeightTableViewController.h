//
//  CustomCellHeightTableViewController.h
//  CoreDataViewer
//
//  Created by Richard Henry on 25/08/2015.
//  Copyright (c) 2015 Optisoft Ltd. All rights reserved.
//

@import CloudStorage;

@interface CustomCellHeightTableViewController : TableViewController <UIActionSheetDelegate>

@property(nonatomic, strong, nonnull) UIActionSheet *clearConfirmActionSheet;

@end
