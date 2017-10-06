//
//  IDMugshotViewController.m
//  iDispense
//
//  Created by Optisoft Ltd on 23/10/2013.
//  Copyright (c) 2013 Optisoft Ltd. All rights reserved.
//

#import "IDMugshotViewController.h"
#import "IDMugshotCompositor.h"
#import "IDMugshot.h"
#import "IDSharingController.h"
#import "IDDispensingDataStore.h"
#import "IDSpecView.h"
#import "IDInAppPurchases.h"


typedef struct {
    
    CGFloat     rotate;
    CGFloat     scale;
    CGPoint     translate;

} transform_t;

#pragma mark Spec view controller

@implementation IDMugshotViewController {

    // Demo label
    __weak IBOutlet UILabel *demonstrationOnlyLabel;

    // Gesture recogniser outlets
    __weak IBOutlet UIPanGestureRecognizer *panGestureRecogniser;
    __weak IBOutlet UIPinchGestureRecognizer *pinchGestureRecogniser;
    __weak IBOutlet UIRotationGestureRecognizer *rotateGestureRecogniser;
    __weak IBOutlet UILongPressGestureRecognizer *longPressGestureRecogniser;

    // Auxiliary view outlets
    __weak IBOutlet IDSpecView  *specView;
    __weak IBOutlet UIImageView *imageView;

    // Internal variables
    transform_t                 transform;
    UIPopoverController         *specImageSelectionPopover;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];

    // Set up the view's image and the navigation bar title
    imageView.image = self.mugshot.image;
    self.title = [NSString stringWithFormat:@"Image %lu", (unsigned long)self.mugshot.index];

    // Set up the gesture recognisers
    panGestureRecogniser.minimumNumberOfTouches = 1;
    panGestureRecogniser.maximumNumberOfTouches = 2;

    // Set up the initial transform parameters
    transform.rotate = 0;
    transform.scale = 1;
    transform.translate = CGPointMake(specView.frame.size.width * 0.5, specView.frame.size.height * 0.5);

    // Set up controls
    longPressGestureRecogniser.enabled = NO;        // This is for future expansion

    demonstrationOnlyLabel.hidden = [IDInAppPurchases sharedIAPStore].liteUserUnlocked;
}

#pragma mark - Control actions

- (IBAction)captureImage:(id)sender {

    IDMugshotCaptureController *captureController = [IDMugshotCaptureController captureController];
    captureController.delegate = self;

    if ([captureController startCameraControllerFromViewController:self sender:sender]) {
        
    }
}

- (IBAction)share:(id)sender {

    // Get the size of the composited image from the user preferences.
    NSDictionary *practiceDetails = [IDDispensingDataStore defaultDataStore].practiceDetails;
    NSString *practiceName = [practiceDetails objectForKey:@"practiceName"];

    // Composite all the mugshot images to an array of images of the size we specified.
    NSArray *compositeImages = [IDMugshotCompositor compositeMugshots:@[ self.mugshot ]];
    // Add the description and the URL to the array of objects to be shared…
    NSMutableArray *shareItems = [NSMutableArray arrayWithArray:compositeImages];
    [shareItems insertObject:[NSString stringWithFormat:@"%@ frame trial", practiceName] atIndex:0];

    [[IDSharingController new] shareItems:shareItems fromViewController:self options:@{ @"sender" : sender, @"subject" : [NSString stringWithFormat:@"Frame %lu at %@", (unsigned long)self.mugshot.index, practiceName] }];
}

#pragma mark Gesture actions

- (IBAction)panGesture:(UIPanGestureRecognizer *)recogniser {
    
    static CGPoint lastPosition;
    CGPoint position = [recogniser translationInView:recogniser.view.superview];
    
    if (recogniser.state == UIGestureRecognizerStateBegan) lastPosition = position;
    
    else {
        
        CGPoint delta = CGPointMake(position.x - lastPosition.x, position.y - lastPosition.y);
        
        transform.translate.x += delta.x;
        transform.translate.y += delta.y;
        
        [self refreshSpecOverlay];
        
        lastPosition = position;
    }
}

- (IBAction)pinchGesture:(UIPinchGestureRecognizer *)recogniser {
    
    // Get the pinch gesture scaling factor in the gesture recogniser's view's superview
    static CGFloat lastScale = 1;
    
    if (recogniser.state == UIGestureRecognizerStateEnded) lastScale = 1;
    
    else {
        
        transform.scale *= 1.0f - (lastScale - recogniser.scale);
        
        lastScale = recogniser.scale;
        
        [self refreshSpecOverlay];
    }
}

- (IBAction)rotateGesture:(UIRotationGestureRecognizer *)recogniser {
    
    // Get the rotate gesture scaling factor in the gesture recogniser's view's superview
    static CGFloat lastRotation = 0;
    
    if (recogniser.state == UIGestureRecognizerStateEnded) lastRotation = 0;
    
    else {
        
        transform.rotate += 2.0 * M_PI - (lastRotation - recogniser.rotation);

        lastRotation = recogniser.rotation;
        
        [self refreshSpecOverlay];
    }
}

- (IBAction)longPressGesture:(UILongPressGestureRecognizer *)recogniser {

    if (recogniser.state == UIGestureRecognizerStateBegan) {

        // Create the spectacle shape picker popover
        IDSpecShapeViewController *specImageSelectionViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"specImageSelectionViewController"];
        specImageSelectionViewController.delegate = self;

        specImageSelectionPopover = [[UIPopoverController alloc] initWithContentViewController:specImageSelectionViewController];

        // Show the popover from the long press recogniser actuation point.
        CGPoint longPressLocation = [recogniser locationInView:specView];
        CGRect popoverRect = CGRectMake(longPressLocation.x, longPressLocation.y, 1, 1);
        [specImageSelectionPopover presentPopoverFromRect:popoverRect inView:specView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

#pragma mark - IDMugshotCaptureDelegate conformance

- (void)didFinishCapturingMugshotImage:(IDMugshotImage *)mugshot {

    // Copy relevant data from the old mugshot to the one we just captured.
    mugshot.index = self.mugshot.index;

    // Inform the delegate that there is a new mugshot to replace the one in the collection.
    [self.delegate replaceMugshot:self.mugshot withMugshot:mugshot];

    // Transfer the image that we just captured so that it
    self.mugshot = mugshot;

    // Set the image view's content to the image we just captured.
    imageView.image = mugshot.image;

    [self refreshSpecOverlay];
}

- (void)didFinishCapturingMugshotMovie:(IDMugshotMovie *)mugshot {

    // Set the image view's content to the image we just captured.
    NSLog(@"Just removed : imageView.image = mugshot.thumbnail;");
}

- (void)didCancelMugshotCapture {

    // Dismiss the underlying view controller that's at the top of the navigation controller's stack.
    // As the taking of the picture has been cancelled, there is no real point in showing the user a
    // blank view.
    [self.navigationController popViewControllerAnimated:NO];
}

#pragma mark IDSpecShapePickerDelegate conformance

- (void)didPickFrameShape:(UIImage *)frameShape {

    specView.specImage = frameShape;

    [self refreshSpecOverlay];
}

#pragma mark UIGestureRecognizerDelegate conformance

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gr1 shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)gr2 {

    // All of the gesture recognisers need to be simultaneous apart from the long press gesture recogniser.
    return !(gr1 == longPressGestureRecogniser || gr2 == longPressGestureRecogniser);
}

#pragma mark View control

- (void)refreshSpecOverlay {
    
    CGAffineTransform specTransform = CGAffineTransformIdentity;

    specTransform = CGAffineTransformTranslate(specTransform, transform.translate.x, transform.translate.y);
    specTransform = CGAffineTransformRotate(specTransform, transform.rotate);
    specTransform = CGAffineTransformScale(specTransform, transform.scale, transform.scale);

    specView.specTransform = specTransform;
    
    [specView setNeedsDisplay];
}

@end