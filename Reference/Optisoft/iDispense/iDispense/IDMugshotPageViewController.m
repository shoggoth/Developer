//
//  IDMugshotPageViewController.m
//  iDispense
//
//  Created by Richard Henry on 04/06/2014.
//  Copyright (c) 2014 Optisoft Ltd. All rights reserved.
//

#import "IDMugshotPageViewController.h"
#import "IDMugshotViewController.h"
#import "IDMovieViewController.h"
#import "IDMugshot.h"


@implementation IDMugshotPageViewController {

    UIPageViewController    *pageViewController;
    NSMutableDictionary     *mugshotViewControllers;

    NSMutableArray          *mug, *add, *rem;
    NSUInteger              mugShotIndex;
    BOOL                    capturing;

    UIViewController        *currentViewController;
    UIBarButtonItem         *capButton, *remButton, *shaButton;
}

- (void)viewDidLoad {

    [super viewDidLoad];

    // Array to cache the view controllers
    mugshotViewControllers = [NSMutableDictionary dictionary];

    // Arrays for adding and deleting mugshots
    add = [NSMutableArray array];
    rem = [NSMutableArray array];

    mug = [self.mugshots mutableCopy];

    // Work out which index new captures will have
    for (id <IDMugshot> m in mug) if (m.index > mugShotIndex) mugShotIndex = m.index;

    // Set bar button items
    capButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(capture:)];
    remButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(delete:)];
    shaButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(share:)];

    self.navigationItem.rightBarButtonItems = @[ capButton, remButton, shaButton ];

    // This is the root view so we need the view to get its dimensions from the window
    self.view.translatesAutoresizingMaskIntoConstraints = YES;

    // Configure the page view controller and add it as a child view controller.
    pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    pageViewController.dataSource = self;
    pageViewController.delegate = self;

    // Stop the indicator bar from popping in
    pageViewController.view.backgroundColor = [UIColor blackColor];

    // Make sure that we are using autolayout and that translated constraints do not cause a conflict
    pageViewController.view.translatesAutoresizingMaskIntoConstraints = YES;

    // Start with the zeroth view controller (initially without any animation)
    currentViewController = [self viewControllerAtIndex:self.currentIndex];
    [pageViewController setViewControllers:@[ currentViewController ] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    [self setupPageForCurrentViewController];

    // Add it as a child view controller and add its view as a subview of this view controller's root view.
    [self addChildViewController:pageViewController];
    [self.view addSubview:pageViewController.view];

    // Notify that the page view controller has had its parent changed.
    [pageViewController didMoveToParentViewController:self];

    // Add the page view controller's gesture recognizers to the book view controller's view so that the gestures are started more easily.
    self.view.gestureRecognizers = pageViewController.gestureRecognizers;
}

- (void)dealloc {

    mug = nil; add = nil; rem = nil;
}

#pragma mark Lifecycle

- (void)viewWillDisappear:(BOOL)animated {

    [super viewWillDisappear:animated];

    if (!capturing) {
        // Do completion block
        if (self.completionBlock && (add.count || rem.count)) self.completionBlock(add, rem);
    }
}

#pragma mark Action

- (IBAction)capture:(id)sender {

    capturing = YES;

    IDMugshotCaptureController *captureController = [IDMugshotCaptureController captureController];
    captureController.delegate = self;

    [captureController startCameraControllerFromViewController:self sender:sender];
}

- (IBAction)delete:(id)sender {

    id <IDMugshot> mugshot = [mug objectAtIndex:_currentIndex];

    NSString *kindOfMugshot =  ([mugshot isKindOfClass:[IDMugshotMovie class]]) ? @"movie" : @"image";
    NSString *title = [NSString stringWithFormat:@"Delete %@ %lu", [kindOfMugshot capitalizedString], (unsigned long)mugshot.index];
    NSString *message = [NSString stringWithFormat:@"Are you sure you want to delete %@ number %lu", kindOfMugshot, (unsigned long)mugshot.index];

    [self presentViewController:({

        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {}]];
        [alert addAction:[UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {

            // Remove the mugshot from the array and refresh the collection view from its data source.
            [rem addObject:mugshot];
            [add removeObject:mugshot];
            [mug removeObject:mugshot];

            [mugshotViewControllers removeAllObjects];

            if (_currentIndex) _currentIndex--;

            currentViewController = [self viewControllerAtIndex:_currentIndex];
            [pageViewController setViewControllers:@[ currentViewController ] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
            [self setupPageForCurrentViewController];
            
        }]];
        alert;

    }) animated:YES completion:nil];
}

- (IBAction)share:(id)sender {

    [(IDMugshotViewController *)currentViewController share:shaButton];
}

- (void)setupPageForCurrentViewController {

    self.title = currentViewController.title;
    self.currentIndex = [self indexOfViewController:currentViewController];

    BOOL currentVCIsMugshot = [currentViewController isKindOfClass:[IDMugshotViewController class]];

    // If more than 15 shots have been taken, we have reached the global limit and shouldn't allow any more to be taken.
    capButton.enabled = (mug.count < 16);
    // Don't allow the last image to be deleted or what are we going to show to the user when returning to the collection view?
    remButton.enabled = (mug.count > 1);
    shaButton.enabled = currentVCIsMugshot;
}

#pragma mark Viewcontroller helpers

- (UIViewController *)viewControllerAtIndex:(NSUInteger)index {

    UIViewController *returnValue = mugshotViewControllers[@(index)];

    if (!returnValue) {
        
        if (index < mug.count) {

            id <IDMugshot> mugshot = mug[index];

            if ([mugshot isKindOfClass:[IDMugshotImage class]]) {

                IDMugshotViewController *mugshotVC = [self.storyboard instantiateViewControllerWithIdentifier:@"mugshotViewController"];
                mugshotVC.mugshot = mug[index];

                returnValue = mugshotVC;

            } else {

                IDMovieViewController *movieVC = [self.storyboard instantiateViewControllerWithIdentifier:@"movieViewController"];
                movieVC.mugshot = mug[index];

                returnValue =  movieVC;
            }
            
            mugshotViewControllers[@(index)] = returnValue;
        }
    }

    return returnValue;
}

- (NSInteger)indexOfViewController:(UIViewController *)viewController {

    NSArray *allKeys = [mugshotViewControllers allKeysForObject:viewController];

    if (!allKeys.count) return -1;

    return [[allKeys firstObject] integerValue];
}

#pragma mark IDMugshotCaptureDelegate Conformance

- (void)didFinishCapturingMugshotImage:(IDMugshotImage *)mugshot {

    // Index the mugshot for the image capture
    mugshot.index = ++mugShotIndex;

    // Add a new cell to the collection containing the image
    [mug insertObject:mugshot atIndex:0];
    [add addObject:mugshot];

    self.currentIndex = 0;
    [mugshotViewControllers removeAllObjects];
    
    currentViewController = [self viewControllerAtIndex:self.currentIndex];
    [pageViewController setViewControllers:@[ currentViewController ] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    [self setupPageForCurrentViewController];

    capturing = NO;
}

- (void)didFinishCapturingMugshotMovie:(IDMugshotMovie *)mugshot {

    // Index the mugshot for the movie capture
    mugshot.index = ++mugShotIndex;

    // Add a new cell to the collection containing the movie
    [mug insertObject:mugshot atIndex:0];
    [add addObject:mugshot];

    self.currentIndex = 0;
    [mugshotViewControllers removeAllObjects];

    currentViewController = [self viewControllerAtIndex:self.currentIndex];
    [pageViewController setViewControllers:@[ currentViewController ] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    [self setupPageForCurrentViewController];

    capturing = NO;
}

#pragma mark UIPageViewControllerDataSource conformance

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {

    NSInteger vcIndex = [self indexOfViewController:viewController];

    if (vcIndex < 0) return nil;

    return [self viewControllerAtIndex:vcIndex + 1];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {

    NSInteger vcIndex = [self indexOfViewController:viewController];

    if (vcIndex <= 0) return nil;

    return [self viewControllerAtIndex:vcIndex - 1];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {

    return mug.count;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {

    return [self indexOfViewController:currentViewController];
}

- (void)pageViewController:(UIPageViewController *)pvc didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {

    currentViewController = pvc.viewControllers.firstObject;

    [self setupPageForCurrentViewController];
}

@end
