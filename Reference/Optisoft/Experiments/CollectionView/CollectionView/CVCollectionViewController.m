//
//  CVCollectionViewController.m
//  CollectionView
//
//  Created by Richard Henry on 07/11/2013.
//  Copyright (c) 2013 Optisoft. All rights reserved.
//

#import "CVCollectionViewController.h"
#import "CVCell.h"


@interface CVCollectionViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@end


@implementation CVCollectionViewController {
    
    NSUInteger      numberOfSections, numberOfCells;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    numberOfSections = 1;
    numberOfCells = 1;
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)clearCells {
    
    numberOfCells = 0;
    
    [self.collectionView reloadData];
}

- (void)addNewCell {
    
    numberOfCells++;
    
    [self.collectionView reloadData];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"pushToDetailViewController"]) {
        
        NSIndexPath *selectedIndexPath = [[self.collectionView indexPathsForSelectedItems] objectAtIndex:0];
        
        NSLog(@"Object = %ld", (long)selectedIndexPath.row);
        
        // Load the image, to prevent it from being cached we use 'initWithContentsOfFile'
        NSString *imageNameToLoad = [NSString stringWithFormat:@"%ld_full", (long)selectedIndexPath.row];
        NSString *pathToImage = [[NSBundle mainBundle] pathForResource:imageNameToLoad ofType:@"JPG"];
        UIImage *image = [[UIImage alloc] initWithContentsOfFile:pathToImage];
        
        UIViewController *detailViewController = [segue destinationViewController];
        //detailViewController.image = image;
    }
}
#pragma mark Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return numberOfSections;
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    
    return numberOfCells;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // We're going to use a custom UICollectionViewCell, which will hold an image and its label
    CVCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"CVCell" forIndexPath:indexPath];
    
    // make the cell's title the actual NSIndexPath value
    cell.label.text = [NSString stringWithFormat:@"{%ld,%ld}", (long)indexPath.row, (long)indexPath.section];
    
    // load the image for this cell
    NSString *imageToLoad = @"test.bmp";//[NSString stringWithFormat:@"%d.JPG", indexPath.row];
    cell.image.image = [UIImage imageNamed:imageToLoad];
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    return [UICollectionReusableView new];
}

#pragma mark Delegate


@end
