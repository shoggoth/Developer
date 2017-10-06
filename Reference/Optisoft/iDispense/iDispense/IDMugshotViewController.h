//
//  IDMugshotViewController.h
//  iDispense
//
//  Created by Optisoft Ltd on 23/10/2013.
//  Copyright (c) 2013 Optisoft Ltd. All rights reserved.
//

#import "IDMugshotCaptureController.h"
#import "IDSpecShapeViewController.h"
#import "IDMugshot.h"


//
//  protocol IDMugshotCollectionViewControllerDelegate
//
//  Detail delegate protocol for returning the edited mugshot to the master.
//

@protocol IDMugshotCollectionViewControllerDelegate <NSObject>

- (void)replaceMugshot:(id <IDMugshot>)originalMugshot withMugshot:(id <IDMugshot>)replacementMugshot;

@end

//
//  interface IDMugshotViewController
//
//  View controller for dealing with the editing of still captures.
//

@class IDMugshotImage;

@interface IDMugshotViewController : UIViewController <IDMugshotCaptureDelegate, IDSpecShapePickerDelegate, UIGestureRecognizerDelegate>

@property(nonatomic, strong) IDMugshotImage *mugshot;
@property(nonatomic) id <IDMugshotCollectionViewControllerDelegate> delegate;

// Actions
- (IBAction)captureImage:(id)sender;
- (IBAction)share:(id)sender;

@end
