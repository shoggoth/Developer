//
//  TCViewController.m
//  ThumbCompositor
//
//  Created by Richard Henry on 10/02/2014.
//  Copyright (c) 2014 Optisoft. All rights reserved.
//

#import "TCViewController.h"
#import "UIImage+ImageUtils.h"

@interface TCViewController ()

@property(nonatomic, weak) IBOutlet UIImageView *imageView;

@property(nonatomic, weak) IBOutlet NSLayoutConstraint *widthConstraint;
@property(nonatomic, weak) IBOutlet NSLayoutConstraint *heightConstraint;

@property(nonatomic, weak) IBOutlet UILabel *widthLabel;
@property(nonatomic, weak) IBOutlet UILabel *heightLabel;
@property(nonatomic, weak) IBOutlet UILabel *scaleTypeLabel;

@end


@implementation TCViewController {

    UIImage             *boomer;
    CGSize              imageSize;
    unsigned            resizeMethod;
}

- (void)viewDidLoad {

    [super viewDidLoad];

    // Do any additional setup after loading the view, typically from a nib.
    self.imageView.image = boomer = [UIImage imageNamed:@"Boomer.jpg"];

    imageSize = boomer.size;

    self.scaleTypeLabel.text = @"Image is at natural resolution";
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {

    NSLog(@"Rotate finish = %@", self);
}

#pragma mark Image manipulation

- (void)doImageResize {

    NSString *resizeMethodString;

    switch (resizeMethod) {
            
        case 0:
            self.imageView.image = [boomer imageScaledToSize:imageSize];
            resizeMethodString = @"imageScaledToSize";
            break;
            
        case 1:
            self.imageView.image = [boomer imageScaledAndCroppedToSize:imageSize];
            resizeMethodString = @"imageScaledAndCroppedToSize";
            break;

        case 2:
            self.imageView.image = [boomer imageScaledProportionallyToSize:imageSize];
            resizeMethodString = @"imageScaledProportionallyToSize";
            break;
            
        case 3:
            self.imageView.image = [boomer imageScaledProportionallyToMinimumSize:imageSize];
            resizeMethodString = @"imageScaledProportionallyToMinimumSize";
            break;
            
        default:
            break;
    }
    
    self.widthConstraint.constant = imageSize.width + 20;
    self.heightConstraint.constant = imageSize.height + 20;

    self.scaleTypeLabel.text = [NSString stringWithFormat:@"Resize to %@ (real %@) message %@", NSStringFromCGSize(imageSize), NSStringFromCGSize(self.imageView.image.size), resizeMethodString];
}

#pragma mark Actions

- (IBAction)widthSliderChanged:(UISlider *)slider {

    imageSize.width = floor(slider.value);

    self.widthLabel.text = [NSString stringWithFormat:@"%.2f", imageSize.width];
}

- (IBAction)heightSliderChanged:(UISlider *)slider {

    imageSize.height = floor(slider.value);

    self.heightLabel.text = [NSString stringWithFormat:@"%.2f", imageSize.height];
}

- (IBAction)sliderRefresh:(id)sender {

    [self doImageResize];
}

- (IBAction)switchScalingMethod:(id)sender {

    resizeMethod = (++resizeMethod % 4);

    [self doImageResize];
}

@end
