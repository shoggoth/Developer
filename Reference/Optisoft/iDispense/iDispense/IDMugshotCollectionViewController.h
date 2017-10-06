//
//  IDMugshotCollectionViewController.h
//  iDispense
//
//  Created by Richard Henry on 07/11/2013.
//  Copyright (c) 2013 Optisoft. All rights reserved.
//

#import "IDMugshotViewController.h"


//
//  interface IDMugshotCollectionViewController
//
//  Collection view of the mugshots that have been captured with adaptive layout.
//

@class IDMugshotCell;

@interface IDMugshotCollectionViewController : UICollectionViewController <IDMugshotCollectionViewControllerDelegate>

- (void)clearCell:(IDMugshotCell *)cell;

@end
