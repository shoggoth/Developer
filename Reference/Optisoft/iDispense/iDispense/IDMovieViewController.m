//
//  IDMovieViewController.m
//  iDispense
//
//  Created by Richard Henry on 06/12/2013.
//  Copyright (c) 2013 Optisoft Ltd. All rights reserved.
//

#import "IDMovieViewController.h"
#import "IDMugshot.h"
#import "IDInAppPurchases.h"

@import MediaPlayer;


@interface IDMovieViewController ()

@property(weak, nonatomic) IBOutlet UIView  *movieView;

@end

@implementation IDMovieViewController {

    // Demo label
    __weak IBOutlet UILabel *demonstrationOnlyLabel;

    MPMoviePlayerController *mPlayer;
}

- (void)dealloc {

    [mPlayer stop];
    
    mPlayer = nil;
}

- (void)viewDidLoad {

    [super viewDidLoad];

    // Set up the navigation bar title
    self.title = [NSString stringWithFormat:@"Movie %lu", (unsigned long)self.mugshot.index];

    // Create the movie player and add its view to the existing content view as a subview.
    mPlayer = [[MPMoviePlayerController alloc] initWithContentURL:self.mugshot.movieURL];
    UIView *moviePlayerView = mPlayer.view;

    // Make sure that we are using autolayout and that translated constraints do not cause a conflict
    moviePlayerView.translatesAutoresizingMaskIntoConstraints = NO;

    // Add the subview we got from the nib file.
    [self.movieView addSubview:moviePlayerView];

    // Prepare the dictionary for visual constraint manipulation.
    NSDictionary *viewsDictionary = @{ @"playerView" : moviePlayerView };

    // Add the constraints
    [self.movieView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(44)-[playerView]-(0)-|" options:0 metrics:nil views:viewsDictionary]];
    [self.movieView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0)-[playerView]-(0)-|" options:0 metrics:nil views:viewsDictionary]];

    demonstrationOnlyLabel.hidden = [IDInAppPurchases sharedIAPStore].liteUserUnlocked;

    // Start playing the movie.
    [mPlayer play];
}

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];

    [mPlayer play];
}

- (void)viewDidDisappear:(BOOL)animated {

    [super viewDidDisappear:animated];

    [mPlayer pause];
}

@end
