//
//  IDMugshotCaptureController.m
//  iDispense
//
//  Created by Richard Henry on 05/12/2013.
//  Copyright (c) 2013 Optisoft Ltd. All rights reserved.
//

#import "IDMugshotCaptureController.h"
#import "IDImageProcessor.h"
#import "IDMugshot.h"

#import "UIScreen+ScreenUtils.h"


#pragma mark Rotation delegate

@protocol IDMugshotCaptureRotationNotificationDelegate

- (void)cameraUIRotatedNotification:(NSNotification *)notification;

@end

#pragma mark - Image picker

@interface IDImagePickerController : UIImagePickerController

@property(nonatomic) UIInterfaceOrientation orientation;

@end

@implementation IDImagePickerController

- (instancetype)init {

    if ((self = [super init])) {

        // Initial interface orientation
        self.orientation = [UIApplication sharedApplication].statusBarOrientation;
    }

    return self;
}

#pragma mark Interface rotation

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {

    // Save the orientation as a property
    self.orientation = toInterfaceOrientation;

    // Post a notification that the rotate is about to happen for anyone that's interested.
    [[NSNotificationCenter defaultCenter] postNotificationName:@"cameraUIRotatedNotification" object:self userInfo:@{ @"rotation" : @(toInterfaceOrientation), @"duration" : @(duration) }];

    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

@end

#pragma mark - Image capture

@implementation IDMugshotCaptureController {

    __weak IBOutlet UIView      *overlayView;
}

+ (instancetype)captureController {

    static IDMugshotCaptureController   *sharedInstance;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        sharedInstance = [IDMugshotCaptureController new];
    });

    return sharedInstance;
}

#pragma mark Camera control

- (BOOL)startCameraControllerFromViewController:(UIViewController *)controller sender:(id)sender {

    if ((![IDImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) || !controller) return NO;

    IDImagePickerController *cameraUI = [IDImagePickerController new];
    cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;

    // Displays a control that allows the user to choose still image or movie capture, if both are available:
    cameraUI.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];

    // Hides the controls for moving & scaling pictures, or for trimming movies. To instead show the controls, use YES.
    cameraUI.allowsEditing = YES;
    cameraUI.showsCameraControls = YES;
    cameraUI.navigationBarHidden = YES;

    // TODO: RJH We can use this bit of code if we decide at a later date that we want some sort of overlay on the image capture dialogue.
    if (/* DISABLES CODE */ (NO)) {

        [[NSBundle mainBundle] loadNibNamed:@"IDCameraOverlayView" owner:self options:nil];
        cameraUI.cameraOverlayView = overlayView;
    }

    // Set the delegate and present the image capture view controller.
    cameraUI.delegate = self;

    // Presenting the capture dialogue in a popover has not been all that popular, removed it.
#if defined (ID_USE_POPOVER_FOR_CAMERA)
    if (NSClassFromString(@"UIPopoverPresentationController")) {

        cameraUI.modalPresentationStyle = UIModalPresentationPopover;
        if ([sender isMemberOfClass:[UIBarButtonItem class]]) cameraUI.popoverPresentationController.barButtonItem = sender;

        else if ([sender isMemberOfClass:[UIView class]]) cameraUI.popoverPresentationController.sourceView = sender;

        else cameraUI.popoverPresentationController.sourceView = controller.view;
    }
#endif

    [controller presentViewController:cameraUI animated:YES completion:^{

        // Allow the delegate to do whatever setup it needs to do now that the capture view controller has been presented.
        if ([self.delegate respondsToSelector:@selector(didPresentCaptureViewController)]) [self.delegate didPresentCaptureViewController];

        // Set the calling controller up for the rotation notifications.
        if ([controller respondsToSelector:@selector(cameraUIRotatedNotification:)])
            [[NSNotificationCenter defaultCenter] addObserver:controller selector:@selector(cameraUIRotatedNotification:) name:@"cameraUIRotatedNotification" object:cameraUI];
    }];

    return YES;
}

#pragma mark Camera delegate

- (void)imagePickerControllerDidCancel:(IDImagePickerController *)picker {

    // Inform the delegate that the user has cancelled the mugshot capture without taking a picture.
    if ([self.delegate respondsToSelector:@selector(didCancelMugshotCapture)]) [self.delegate didCancelMugshotCapture];

    // The user cancelled image capture / picking.
    [picker dismissViewControllerAnimated:YES completion:^{}];
}

- (void)imagePickerController:(IDImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {

    CFStringRef mediaType = (__bridge CFStringRef)([info objectForKey:UIImagePickerControllerMediaType]);

    // Handle a still image capture
    if (CFStringCompare(mediaType, kUTTypeImage, 0) == kCFCompareEqualTo) {

        // Discover if we want to use the edited or the original image
        UIImage *editedImage = [info objectForKey:UIImagePickerControllerEditedImage];
        UIImage *originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        UIImage *baseImage = (editedImage) ? editedImage : originalImage;

        // Dismiss the image capture view controller
        [picker dismissViewControllerAnimated:YES completion:^{

            // First, apply image filtering to the image that we just captured and then inform the delegate that the user has finished capturing and possibly editing a still image capture.
            UIImage *filteredImage = [IDImageProcessor filterImage:baseImage];

            // We have captured an image mugshot. Set up the new object and send it to the delegate to be processed.
            IDMugshotImage *mugshotImage = [[IDMugshotImage alloc] initWithImage:filteredImage];
            mugshotImage.orientation = UIInterfaceOrientationPortrait;

            [self.delegate didFinishCapturingMugshotImage:mugshotImage];
        }];
    }

    // Handle a movie capture
    else if (CFStringCompare (mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo) {

        // The movie we just recorded is now in the tmp directory.
        NSURL *movieURL = [info objectForKey:UIImagePickerControllerMediaURL];

        // Inform the delegate that the user has finished capturing a movie.
        [picker dismissViewControllerAnimated:YES completion:^{
            
            [self.delegate didFinishCapturingMugshotMovie:[[IDMugshotMovie alloc] initWithURL:movieURL]];
        }];
    }
}

@end

// Following code is to be added to the capture at some point in the future.

/*
- (IBAction)takePicture:(id)sender
{
    if ([self.imagePickerPopover isPopoverVisible]) {
        // If the popover is already up, get rid of it
        [self.imagePickerPopover dismissPopoverAnimated:YES];
        self.imagePickerPopover = nil;
        return;
    }

    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];

    // If the device ahs a camera, take a picture, otherwise,
    // just pick from the photo library
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    } else {
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }

    imagePicker.delegate = self;

    // Place image picker on the screen
    // Check for iPad device before instantiating the popover controller
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        // Create a new popover controller that will display the imagePicker
        self.imagePickerPopover = [[UIPopoverController alloc] initWithContentViewController:imagePicker];

        self.imagePickerPopover.delegate = self;

        // Display the popover controller; sender
        // is the camera bar button item
        [self.imagePickerPopover presentPopoverFromBarButtonItem:sender
                                        permittedArrowDirections:UIPopoverArrowDirectionAny
                                                        animated:YES];
    } else {
        [self presentViewController:imagePicker animated:YES completion:NULL];
    }
}
 */
