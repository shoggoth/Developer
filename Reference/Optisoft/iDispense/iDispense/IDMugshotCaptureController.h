//
//  IDMugshotCaptureController.h
//  iDispense
//
//  Created by Richard Henry on 05/12/2013.
//  Copyright (c) 2013 Optisoft Ltd. All rights reserved.
//


@class IDMugshotImage;
@class IDMugshotMovie;

//
//  protocol IDMugshotCaptureDelegate
//
//  A delegate can be notified on the succesful capture of either a still image or a movie.
//
//  The delegate can also optionally be notified that the capture controller was presented or
//  that the capture was cancelled in the optional methods.
//

@protocol IDMugshotCaptureDelegate <NSObject>

- (void)didFinishCapturingMugshotImage:(IDMugshotImage *)mugshot;
- (void)didFinishCapturingMugshotMovie:(IDMugshotMovie *)mugshot;

@optional
- (void)didPresentCaptureViewController;
- (void)didCancelMugshotCapture;

@end


//
//  interface IDMugshotCaptureController
//
//  Subclass of the standard image capture controller with inception support for acting on
//  the change of orientation.
//

@interface IDMugshotCaptureController : NSObject <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

+ (instancetype)captureController;

@property(nonatomic, weak) id <IDMugshotCaptureDelegate> delegate;

- (BOOL)startCameraControllerFromViewController:(UIViewController *)controller sender:(id)sender;

@end
