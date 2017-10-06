//
//  IDMugshotCollectionViewController.m
//  iDispense
//
//  Created by Richard Henry on 07/11/2013.
//  Copyright (c) 2013 Optisoft. All rights reserved.
//

#import "IDMugshotCollectionViewController.h"
#import "IDSettingsViewController.h"
#import "IDMugshotPageViewController.h"
#import "IDMugshotViewController.h"
#import "IDMovieViewController.h"
#import "IDMugshotCell.h"
#import "IDMugshot.h"
#import "IDMugshotCompositor.h"
#import "IDImageStore.h"
#import "IDSharingController.h"
#import "IDDispensingDataStore.h"


#pragma mark View Controller

@interface IDMugshotCollectionViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, IDMugshotCaptureDelegate>

@property (strong, nonatomic) IBOutlet UIView *welcomeView;

@end


@implementation IDMugshotCollectionViewController {

    // Mugshot data storage
    NSMutableArray              *mugshots;
    NSUInteger                  mugShotIndex;

    // Bar button items
    UIBarButtonItem             *addButton, *remButton, *shaButton;

    // Orientation and cell size control
    enum { kSmallCellSize, kMediumCellSize, kLargeCellSize, kNumberOfCellSizes };

    CGSize                      cellSize[kNumberOfCellSizes];
    UIInterfaceOrientation      orientation;

    BOOL                        cameraIsAvailable;
}

- (void)viewDidLoad {

    [super viewDidLoad];

    // Initial orientation unknown
    orientation = 0;

    // Do any additional setup after loading the view, typically from a nib.
    mugshots = [NSMutableArray array];
    cameraIsAvailable = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        NSBundle *mainBundle =  [NSBundle mainBundle];
        // Set up the reusable cells for use in the collection view.
        [self.collectionView registerNib:[UINib nibWithNibName:@"IDMugshotImageCell" bundle:mainBundle] forCellWithReuseIdentifier:NSStringFromClass([IDMugshotImage class])];
        [self.collectionView registerNib:[UINib nibWithNibName:@"IDMugshotMovieCell" bundle:mainBundle] forCellWithReuseIdentifier:NSStringFromClass([IDMugshotMovie class])];

        // Set up the decoration views for use by the collection view
        [self.collectionView.collectionViewLayout registerNib:[UINib nibWithNibName:@"IDSnapDecorationView" bundle:mainBundle] forDecorationViewOfKind:@"IDSnapDecorationView"];
    });

    // Set bar button items
    addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(addNewCell:)];
    remButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(clearCells:)];
    shaButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareCells:)];

    self.navigationItem.rightBarButtonItems = @[ addButton, remButton, shaButton ];

    // Set initial button statuses
    addButton.enabled = cameraIsAvailable;
    remButton.enabled = NO;
    shaButton.enabled = NO;

    // Show the welcome screen with the instructions for new users. This setting can be adjusted in the settings application of iOS.
    [self showWelcomeScreen];
}

- (void)viewDidLayoutSubviews {

    [super viewDidLayoutSubviews];
    
    // Maybe the interface orientation has changed while another of the view controllers has been presenting on the screen.
    UIInterfaceOrientation currentOrientation = [UIApplication sharedApplication].statusBarOrientation;

    if (currentOrientation != orientation) {

        orientation = currentOrientation;
        [self makeCellSizesForOrientation:orientation];
    }
}

- (void)dealloc {

    mugshots = nil;
}

#pragma mark Welcome Screen

- (void)showWelcomeScreen {

    // Show the welcome instruction screen if it has been allowed in the settings
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"show_welcome_screen_preference"] boolValue]) {

        // Load  the welcome screen from the nib file.
        [[UINib nibWithNibName:@"IDInitialOverlayView" bundle:nil] instantiateWithOwner:self options:nil];

        // Make sure that we are using autolayout and that translated constraints do not cause a conflict
        self.welcomeView.translatesAutoresizingMaskIntoConstraints = NO;

        // Add the subview we got from the nib file.
        [self.view addSubview:self.welcomeView];

        // Add the constraints
        [NSLayoutConstraint constraintWithItem:self.view
                                     attribute:NSLayoutAttributeCenterX
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.welcomeView
                                     attribute:NSLayoutAttributeCenterX
                                    multiplier:1
                                      constant:0].active = YES;

        [NSLayoutConstraint constraintWithItem:self.view
                                     attribute:NSLayoutAttributeCenterY
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.welcomeView
                                     attribute:NSLayoutAttributeCenterY
                                    multiplier:1
                                      constant:0].active = YES;
    }
}

- (void)fadeWelcomeScreen {

    // Animate the instruction view so that it faded out after giving the user a chance to see it.
    [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{

        self.welcomeView.alpha = 0;

    } completion:^(BOOL finished) {

        self.welcomeView.hidden = YES;
        [self.welcomeView removeFromSuperview];

        self.welcomeView = nil;
    }];
}

#pragma mark Data Operations

- (void)reloadMugshots {

    // Reload the collection data
    [self.collectionView reloadData];

    // If no shots have been taken, disable the remove and share buttons.
    BOOL someMugshotsTaken = (mugshots.count > 0);
    remButton.enabled = someMugshotsTaken;

    // If 8 or more shots have been taken, then disable the share button
    shaButton.enabled = someMugshotsTaken && (mugshots.count < 9);

    // If more than 15 shots have been taken, we have reached the global limit and shouldn't allow any more to be taken.
    addButton.enabled = cameraIsAvailable && (mugshots.count < 16);
}

- (void)clearMugshots {

    [mugshots removeAllObjects];

    [self reloadMugshots];
}

#pragma mark Interface Rotation

- (void)makeCellSizesForOrientation:(UIInterfaceOrientation)ori {

    const CGFloat navigationBarHeight = self.navigationController.navigationBar.frame.size.height;
    const CGRect statusBarRect = [self.view convertRect:[[UIApplication sharedApplication] statusBarFrame] fromView:self.view.window];

    CGRect frame = self.collectionView.frame;
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;

    const float border = 8;

    if (UIInterfaceOrientationIsPortrait(ori)) {

        frame.size.height -= (navigationBarHeight + statusBarRect.size.height);

        cellSize[kLargeCellSize] = frame.size;
        cellSize[kMediumCellSize] = (CGSize) { frame.size.width, (frame.size.height - border) / 2 };
        cellSize[kSmallCellSize] = (CGSize) { (frame.size.width - border) / 2, (frame.size.height - border) / 2 };

        layout.scrollDirection = UICollectionViewScrollDirectionVertical;

    } else {

        frame.size.height -= (navigationBarHeight + statusBarRect.size.height);

        cellSize[kLargeCellSize] = frame.size;
        cellSize[kMediumCellSize] = (CGSize) { (frame.size.width - border) / 2, frame.size.height };;

        // We never get small cell sizes in the horizontal direction. The zero cell size should cause the collection
        // view controller to throw an exception should something go wrong in that respect.
        cellSize[kSmallCellSize] = CGSizeZero;

        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
}

#pragma mark Cell Control

- (IBAction)clearCells:(id)sender {

    NSString *title = @"Delete All";
    NSString *message = @"Do you want to delete all images and movies?";

    [self presentViewController:({

        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {}]];
        [alert addAction:[UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {

            // Remove *all* the mugshots from the array and refresh the collection view from its data source.
            [mugshots removeAllObjects];
            mugShotIndex = 0;

            // Remove the images from the store as we won't be needing them again.
            [[IDImageStore defaultImageStore] clearImageDiskCache];
            
            [self reloadMugshots];
            
        }]];
        alert;
        
    }) animated:YES completion:nil];
}

- (IBAction)showLensComparison:(id)sender {

    [self performSegueWithIdentifier:@"pushLensCompareVC" sender:nil];

    // Fade out the welcome screen if it's there.
    if (self.welcomeView) [self fadeWelcomeScreen];
}

- (IBAction)shareCells:(id)sender {

    // Get practice details from the database.
    NSDictionary *practiceDetails = [IDDispensingDataStore defaultDataStore].practiceDetails;
    NSString *practiceName = [practiceDetails objectForKey:@"practiceName"];

    // Composite all the mugshot images to an array of images of the size we specified.
    NSArray *compositeImages = [IDMugshotCompositor compositeMugshots:mugshots];

    // Add the description and the URL to the array of objects to be shared…
    NSMutableArray *shareItems = [NSMutableArray arrayWithArray:compositeImages];
    [shareItems insertObject:@"Trial frames for comparison" atIndex:0];

    // Share the objects (images and auxiliaries)
    [[IDSharingController new] shareItems:shareItems fromViewController:self options:@{ @"sender" : sender, @"subject" : [NSString stringWithFormat:@"Frame trial at %@", practiceName] }];
}

- (IBAction)addNewCell:(id)sender {

    IDMugshotCaptureController *captureController = [IDMugshotCaptureController captureController];
    captureController.delegate = self;

    [captureController startCameraControllerFromViewController:self sender:sender];

    // Fade out the welcome screen if it's there.
    if (self.welcomeView) [self fadeWelcomeScreen];
}

- (void)clearCell:(IDMugshotCell *)cell {

    NSString *kindOfMugshot =  ([cell.mugshot isKindOfClass:[IDMugshotMovie class]]) ? @"movie" : @"image";
    NSString *title = [NSString stringWithFormat:@"Delete %@ %lu", [kindOfMugshot capitalizedString], (unsigned long)cell.mugshot.index];
    NSString *message = [NSString stringWithFormat:@"Are you sure you want to delete %@ number %lu", kindOfMugshot, (unsigned long)cell.mugshot.index];

    [self presentViewController:({

        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {}]];
        [alert addAction:[UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {

            // Remove the mugshot from the array and refresh the collection view from its data source.
            [mugshots removeObject:cell.mugshot];

            [self reloadMugshots];
            
        }]];
        alert;
        
    }) animated:YES completion:nil];
}

#pragma mark Segue Control

- (void)showSettings:(id)sender {

    // Perform the named segue to push the settings view controller onto the navigation stack
    [self performSegueWithIdentifier:@"pushSettingsVC" sender:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(IDMugshotCell *)cell {

    if ([segue.identifier isEqualToString:@"pushMugshotPageVC"])  {

        IDMugshotPageViewController *pageViewController = segue.destinationViewController;

        pageViewController.mugshots = mugshots;
        pageViewController.currentIndex = [mugshots indexOfObject:cell.mugshot];
        pageViewController.completionBlock = ^(NSArray *add, NSArray *rem) {

            dispatch_async(dispatch_get_main_queue(), ^{

                for (id <IDMugshot>mugshot in add) { [mugshots insertObject:mugshot atIndex:0]; }
                for (id <IDMugshot>mugshot in rem) { [mugshots removeObject:mugshot]; }

                mugShotIndex += add.count;

                [self reloadMugshots];
            });
        };

    } else if ([segue.identifier isEqualToString:@"pushIDMugshotImageDetailVC"])  {

        IDMugshotViewController *detailViewController = segue.destinationViewController;

        detailViewController.mugshot = cell.mugshot;
        detailViewController.delegate = self;

    } else if ([segue.identifier isEqualToString:@"pushIDMugshotMovieDetailVC"])  {

        IDMovieViewController *detailViewController = segue.destinationViewController;

        detailViewController.mugshot = cell.mugshot;

    } else if ([segue.identifier isEqualToString:@"pushSettingsVC"]) {

        // Fade out the welcome screen if it's there.
        if (self.welcomeView) [self fadeWelcomeScreen];
    }
}

#pragma mark IDMugshotCaptureDelegate Conformance

- (void)didFinishCapturingMugshotImage:(IDMugshotImage *)mugshot {

    // Index the mugshot for the image capture
    mugshot.index = ++mugShotIndex;

    // Add a new cell to the collection containing the image
    [mugshots insertObject:mugshot atIndex:0];

    [self reloadMugshots];
}

- (void)didFinishCapturingMugshotMovie:(IDMugshotMovie *)mugshot {

    // Index the mugshot for the movie capture
    mugshot.index = ++mugShotIndex;

    // Add a new cell to the collection containing the movie
    [mugshots insertObject:mugshot atIndex:0];

    [self reloadMugshots];
}

#pragma mark UICollectionViewDataSource Conformance

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView { return 1; }

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section { return [mugshots count]; }

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    // Get the mugshot from the array. This could be either a representation of an image or a representation of a movie.
    id <IDMugshot> mugshot = mugshots[indexPath.row];

    // We're going to use a custom UICollectionViewCell, which will be loaded from the nib we specified
    IDMugshotCell *cell = [cv dequeueReusableCellWithReuseIdentifier:NSStringFromClass([mugshot class]) forIndexPath:indexPath];

    // Set up the cell's data
    cell.mugshot = mugshot;

    // Set parameters for the segue from the selected cell
    cell.controller = self;

    // Mark the cell as needing to be laid out.
    [cell setNeedsLayout];

    return cell;
}

#pragma mark UICollectionViewDelegateFlowLayout Conformance

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSUInteger  count = mugshots.count;
    CGSize      layoutSize;

    if (UIInterfaceOrientationIsPortrait(orientation)) {
        
        if (count == 1) layoutSize = cellSize[kLargeCellSize];
        else if (count == 2) layoutSize = cellSize[kMediumCellSize];
        else if (count == 3) layoutSize = (indexPath.row == 0) ? cellSize[kMediumCellSize] : cellSize[kSmallCellSize];
        else layoutSize = cellSize[kSmallCellSize];
        
    } else layoutSize = (count == 1) ? cellSize[kLargeCellSize] : cellSize[kMediumCellSize];

    return layoutSize;
}

#pragma mark IDMugshotCollectionViewControllerDelegate Conformance

- (void)replaceMugshot:(id <IDMugshot>)originalMugshot withMugshot:(id <IDMugshot>)replacementMugshot {

    NSUInteger index = [mugshots indexOfObject:originalMugshot];

    if (index < mugshots.count) {

        [mugshots replaceObjectAtIndex:index withObject:replacementMugshot];
        [self reloadMugshots];
    }
}

@end
