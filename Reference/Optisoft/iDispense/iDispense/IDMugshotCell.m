//
//  IDMugshotCell.m
//  iDispense
//
//  Created by Richard Henry on 08/11/2013.
//  Copyright (c) 2013 Optisoft. All rights reserved.
//

#import "IDMugshotCell.h"
#import "IDMugshotCellBackground.h"
#import "IDMugshotCollectionViewController.h"
#import "IDMugshot.h"
#import "IDInAppPurchases.h"


@implementation IDMugshotCell {

    // Demo label
    __weak IBOutlet UILabel *demonstrationOnlyLabel;

    id <IDMugshot>          mugshot;
}

- (instancetype)initWithFrame:(CGRect)frame {

    if (self = [super initWithFrame:frame]) { [self setup]; }

    return self;
}

- (instancetype)initWithCoder:(NSCoder *)decoder {

    if (self = [super initWithCoder:decoder]) { [self setup]; }

    return self;
}

- (void)setup {

    // Change to our custom selected background view
    self.backgroundView = [[IDMugshotCellBackground alloc] initWithFrame:self.bounds];
    self.selectedBackgroundView = [[IDMugshotSelectedCellBackground alloc] initWithFrame:CGRectZero];

    // Make sure that the image view clips to its bounds because we are using the centred mode.
    self.image.clipsToBounds = YES;
}

- (void)prepareForReuse {

    [super prepareForReuse];

    // Zero references to our properties so that we don't have any memory leaks.
    mugshot = nil;
    self.image.image = nil;
}

#pragma mark Sizing

- (void)layoutSubviews {

    [super layoutSubviews];

    // Having a few problems with the ordering of layout calls here so I have decided
    // to turn off autolayout for the case that we have a collection view cell because it could cause a processing spike
    // when we are using adaptive thumbnail sizes and because it is such a simple layout in any case that it hardly justifies
    // the use of autolayout.

    const float imageBorderSize = 5;
    CGSize layoutImageSize = (CGSize) { self.frame.size.width - imageBorderSize, self.frame.size.height - imageBorderSize };

    UIImageView *imageView = self.image;

    // Get the preview image. If a preview image of an appropriate size has already been generated, use that.
    imageView.image = [mugshot generatePreviewImageOfSize:layoutImageSize];

    imageView.layer.cornerRadius = kCellCornerRadius;
    imageView.layer.masksToBounds = YES;
    imageView.layer.borderColor = [UIColor colorWithWhite:0 alpha:0.1].CGColor;
    imageView.layer.borderWidth = 0;
}

#pragma mark Actions

- (IBAction)delete:(id)sender {

    // Delete this cell from the controller.
    [self.controller clearCell:self];
}

#pragma mark Selection handling

- (void)setSelected:(BOOL)selected {

    // Prevent a double call to the segue by checking that the calling controller's view is loaded and that it's at the root level (has a window).
    if (self.controller.isViewLoaded && self.controller.view.window) {

        // Prevent a double call to the segue by checking that the controller is at the top of the navigation stack.
        if (self.controller && (self.controller == self.controller.navigationController.topViewController))

            if (selected) [self.controller performSegueWithIdentifier:@"pushMugshotPageVC" sender:self];

            // Call the appropriate segue depending on the class of the mugshot that's attached to this cell.
            // if (selected) [self.controller performSegueWithIdentifier:[NSString stringWithFormat:@"push%@DetailVC", NSStringFromClass([mugshot class])] sender:self];
    }
    
    [super setSelected:selected];
}

#pragma mark Dynamic properties

- (id <IDMugshot>)mugshot { return mugshot; }

- (void)setMugshot:(id <IDMugshot>)m {

    // Set the dynamic-synthesized internal variable
    mugshot = m;

    // Set up the cell's appearance…
    // I have removed the setting of the actual thumbnail image from here and placed it in layoutSubViews to avoid duplication.
    // Setting of the label can stay here as it is immutable data.
    self.mugshotNumberLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)mugshot.index];

    demonstrationOnlyLabel.hidden = [IDInAppPurchases sharedIAPStore].liteUserUnlocked;
}

#pragma mark Debug

- (void)dump {

    NSLog(@"self.bounds = %@", NSStringFromCGRect(self.bounds));
    NSLog(@"self.frame  = %@", NSStringFromCGRect(self.frame));

    NSLog(@"self.contentView.bounds = %@", NSStringFromCGRect(self.contentView.bounds));
    NSLog(@"self.contentView.frame  = %@", NSStringFromCGRect(self.contentView.frame));

    NSLog(@"self.image.bounds = %@", NSStringFromCGRect(self.image.bounds));
    NSLog(@"self.image.frame  = %@", NSStringFromCGRect(self.image.frame));
}
@end
