//
//  NCViewController.m
//  NibCollection
//
//  Created by Richard Henry on 25/11/2013.
//  Copyright (c) 2013 Optisoft. All rights reserved.
//

#import "NCViewController.h"
#import "NCCollectionCell.h"
#import "NCDetailViewController.h"


@implementation NCViewController {

    IBOutlet UIBarButtonItem    *addButton;
    IBOutlet UIBarButtonItem    *trashButton;

    NSUInteger                  numberOfSections, numberOfCells;
    UIInterfaceOrientation      orientation;
}

#pragma mark Override

- (void)viewDidLoad {

    [super viewDidLoad];

    numberOfSections = 1;
    numberOfCells = 1;
    orientation = UIInterfaceOrientationPortrait;

    // Register the type of cell we want to use with the collection view
    [self.collectionView registerNib:[UINib nibWithNibName:@"NCCollectionCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"NCCollectionCell"];
    //[self.collectionView registerNib:[UINib nibWithNibName:@"NCDecorationCell" bundle:[NSBundle mainBundle]] forSupplementaryViewOfKind:@"NCDecorationCell" withReuseIdentifier:@"NCDecorationCell"];

    self.collectionView.backgroundColor = [UIColor grayColor];

    // Set bar button items
    self.navigationItem.rightBarButtonItems = @[ addButton, trashButton ];
}

- (void)didReceiveMemoryWarning {

    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Actions

- (IBAction)clearCells:(id)sender {

    numberOfCells = 0;

    [self.collectionView reloadData];
}

- (IBAction)addNewCell:(id)sender {

    numberOfCells++;

    [self.collectionView reloadData];
}

- (IBAction)cellTapped:(UITapGestureRecognizer *)tapGesture {

    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:[tapGesture locationInView:self.collectionView]];

    if (indexPath)

        [self performSegueWithIdentifier:@"pushDetail" sender:[self.collectionView cellForItemAtIndexPath:indexPath]];
}

#pragma mark Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(NCCollectionCell *)sender {

    NSLog(@"Object = %@ -> %@ %@", segue.sourceViewController, segue.destinationViewController, sender);

    NCDetailViewController *detailViewController = segue.destinationViewController;

    detailViewController.myBlock = ^(float f) {

        sender.f = f;
        [self.navigationController popViewControllerAnimated:YES];
    };
}

#pragma mark Orientaion

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {

    orientation = toInterfaceOrientation;

    [self.collectionView.collectionViewLayout invalidateLayout];
}

#pragma mark Datasource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {

    return numberOfSections;
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {

    return numberOfCells;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    // We're going to use a custom UICollectionViewCell, which will hold an image and its label
    NCCollectionCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"NCCollectionCell" forIndexPath:indexPath];

    cell.backgroundColor = [UIColor redColor];

    /* Make the cell's title the actual NSIndexPath value
    cell.label.text = [NSString stringWithFormat:@"{%ld,%ld}", (long)indexPath.row, (long)indexPath.section];

    // load the image for this cell
    NSString *imageToLoad = @"test.bmp";//[NSString stringWithFormat:@"%d.JPG", indexPath.row];
    cell.image.image = [UIImage imageNamed:imageToLoad];*/

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {

    NSLog(@"contentOffset=(%f, %f)", self.collectionView.contentOffset.x, self.collectionView.contentOffset.y);
    [self.collectionView setCollectionViewLayout:[[UICollectionViewFlowLayout alloc] init] animated:YES];
    NSLog(@"contentOffset=(%f, %f)", self.collectionView.contentOffset.x, self.collectionView.contentOffset.y);
    [self performSegueWithIdentifier:@"pushDetail" sender:[self.collectionView cellForItemAtIndexPath:indexPath]];
}

#pragma mark Delegate

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {

    UICollectionReusableView *decorationView = nil;

    NSLog(@"Requesting kind = %@", kind);

    return decorationView;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {

    NSLog(@"Count = %lu index = %ld", (unsigned long)numberOfCells, (long)indexPath.row);

    if (UIInterfaceOrientationIsPortrait(orientation))

        return (CGSize) { 128, 128 };
    else
        return (CGSize) { 256, 256 };
}

@end
