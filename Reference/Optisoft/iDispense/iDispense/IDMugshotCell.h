//
//  IDMugshotCell.h
//  iDispense
//
//  Created by Richard Henry on 08/11/2013.
//  Copyright (c) 2013 Optisoft. All rights reserved.
//


@protocol IDMugshot;

@class IDMugshotCollectionViewController;

//
//  interface IDMugshotCell
//
//  Collection view cell for mugshots (still and movie)
//

@interface IDMugshotCell : UICollectionViewCell

// Cell subview properties
@property(nonatomic, weak) IBOutlet UIImageView *image;
@property(nonatomic, weak) IBOutlet UIView *overlay;
@property(nonatomic, weak) IBOutlet UILabel *mugshotNumberLabel;


// Segue properties
@property(nonatomic, weak) IDMugshotCollectionViewController *controller;

// Data properties
@property(nonatomic, strong) id <IDMugshot> mugshot;

- (void)dump;

@end
