//
//  IDBeautificationSettingsViewController.m
//  iDispense
//
//  Created by Richard Henry on 07/03/2014.
//  Copyright (c) 2014 Optisoft Ltd. All rights reserved.
//

#import "IDBeautificationSettingsViewController.h"
#import "IDImageProcessor.h"


@implementation IDBeautificationSettingsViewController {

    __weak IBOutlet UIImageView *imageView;
    __weak IBOutlet UISlider    *softFocusSlider;
    __weak IBOutlet UISlider    *vibranceSlider;

    __weak IBOutlet UILabel     *softFocusAmountLabel;
    __weak IBOutlet UILabel     *vibranceAmountLabel;

    CIImage                     *previewImage;

    float                       vibranceAmount, blurAmount;
    CIFilter                    *blurFilter, *vibranceFilter;
    CIImage                     *vibrantImage, *softFocusImage;
}

- (void)viewDidLoad {

    [super viewDidLoad];

    vibranceAmount = [[[NSUserDefaults standardUserDefaults] objectForKey:@"vibrance_filter_amount_preference"] floatValue];
    blurAmount = [[[NSUserDefaults standardUserDefaults] objectForKey:@"gaussian_blur_amount_preference"] floatValue];

    softFocusAmountLabel.text = [NSString stringWithFormat:@"%.2f", blurAmount];
    vibranceAmountLabel.text = [NSString stringWithFormat:@"%.2f", vibranceAmount];

    // Set slider values
    vibranceSlider.value = vibranceAmount;
    softFocusSlider.value = blurAmount;
    previewImage = [[CIImage alloc] initWithCGImage:[UIImage imageNamed:@"Model.png"].CGImage];

    // Create a vibrance filter to enhance the colors a little bit (and leave pleasing fleshtones).
    vibranceFilter = [CIFilter filterWithName:@"CIVibrance" keysAndValues:kCIInputImageKey, previewImage, nil];
    // Create a core image Gaussian Blur filter. Everybody loves a little bit of soft focus don't they.
    blurFilter = [CIFilter filterWithName:@"CIGaussianBlur" keysAndValues:kCIInputImageKey, [vibranceFilter valueForKey:kCIOutputImageKey], nil];

    [self refresh];
}

- (void)refresh {

    [vibranceFilter setValue:@(vibranceAmount) forKey:@"inputAmount"];
    [blurFilter setValue:@(blurAmount) forKey:kCIInputRadiusKey];
    [blurFilter setValue:[vibranceFilter valueForKey:kCIOutputImageKey] forKey:kCIInputImageKey];

    // Get the filtered image.
    CIImage *filteredImage = [blurFilter valueForKey:kCIOutputImageKey];

    // Create a CG image from the CI image the filter returned.
    // It turns out that if the image is converted straight to a UIImage from a CIImage, we can't convert it to a JPG later
    // on because it doesn't have a CGImageRef (see the documentation for UIImageJPEGRepresentation).
    CGImageRef cgImage = [[CIContext contextWithOptions:nil] createCGImage:filteredImage fromRect:filteredImage.extent];

    // Create the UIImage that the caller expects from the CGImage and then release the CGImage.
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);

    imageView.image = image;
}

#pragma mark Actions

- (IBAction)sliderValueChanged:(UISlider *)sender {

    if (sender == softFocusSlider) {

        blurAmount = sender.value;
        softFocusAmountLabel.text = [NSString stringWithFormat:@"%.2f", blurAmount];

    } else if (sender == vibranceSlider) {

        vibranceAmount = sender.value;
        vibranceAmountLabel.text = [NSString stringWithFormat:@"%.2f", vibranceAmount];
    }
}

- (IBAction)sliderValueSelected:(UISlider *)sender {

    if (sender == softFocusSlider)
        [[NSUserDefaults standardUserDefaults] setObject:@(sender.value) forKey:@"gaussian_blur_amount_preference"];
    else if (sender == vibranceSlider)
        [[NSUserDefaults standardUserDefaults] setObject:@(sender.value) forKey:@"vibrance_filter_amount_preference"];

    [[NSUserDefaults standardUserDefaults] synchronize];

    [self refresh];
}

@end
