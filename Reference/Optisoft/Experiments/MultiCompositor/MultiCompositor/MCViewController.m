//
//  MCViewController.m
//  MultiCompositor
//
//  Created by Richard Henry on 20/02/2014.
//  Copyright (c) 2014 Optisoft. All rights reserved.
//

#import "MCViewController.h"
#import "IDMugshotCompositor.h"


void test_image_compositor(IDMugshotCollectionViewController *mugshotController) {

    // Temporary TODO RJH
    __block IDMugshotImage *mugshot = [[IDMugshotImage alloc] initWithImage:[UIImage imageNamed:@"Boomer.jpg"]];

    NSArray *compositeImages = [IDMugshotCompositor compositeMugshots:@[ mugshot ] inImagesWithSize:(CGSize) { 740, 740 }];
    UIImage *compositeImage = [compositeImages objectAtIndex:0];


    __block UIImageView *imageView = [[UIImageView alloc] initWithImage:compositeImage];

    [mugshotController.view addSubview:imageView];

    imageView.transform = CGAffineTransformMakeTranslation(20, 100);

    [UIView animateWithDuration:1
                          delay:10
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{

                         imageView.alpha = 0;

                     }
                     completion:^(BOOL finished) {

                         [imageView removeFromSuperview];
                         mugshot = nil;
                         imageView = nil;
                     }];
}


@interface MCViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation MCViewController

- (void)viewDidLoad {

    [super viewDidLoad];

    self.imageView.image = [UIImage imageNamed:@"Boomer720x720.png"];
}

@end
