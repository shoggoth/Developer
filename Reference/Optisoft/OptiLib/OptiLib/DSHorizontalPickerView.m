//
//  DSHorizontalPickerView.m
//  Dogstar Engine (unified version)
//
//  Created by Richard Henry on 01/01/2011.
//  Copyright 2011 Dogstar Diversions. http://www.dogstar.mobi
//

#import "DSHorizontalPickerView.h"

#import <Availability.h>

#pragma mark Collection view cell

@interface DSCollectionViewCell : UICollectionViewCell

@property(nonatomic, strong) UILabel *label;

@end

@implementation DSCollectionViewCell

- (void)setup {

	self.label = [[UILabel alloc] initWithFrame:self.bounds];

	self.label.backgroundColor = [UIColor clearColor];
	self.label.textAlignment = NSTextAlignmentCenter;
	self.label.textColor = [UIColor grayColor];
	self.label.numberOfLines = 1;
	self.label.lineBreakMode = NSLineBreakByTruncatingTail;
	self.label.highlightedTextColor = [UIColor blackColor];
	self.label.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];

	[self.contentView addSubview:self.label];
}

- (instancetype)initWithFrame:(CGRect)frame {

	if ((self = [super initWithFrame:frame])) [self setup];

	return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {

	if ((self = [super initWithCoder:aDecoder])) [self setup];
    
	return self;
}

@end


#pragma mark - Collection view layout

@interface DSCollectionViewLayout : UICollectionViewFlowLayout

@property(nonatomic, assign) CGFloat width;
@property(nonatomic, assign) CGFloat midX;
@property(nonatomic, assign) CGFloat maxAngle;

@end

@implementation DSCollectionViewLayout

- (instancetype)init {

	if ((self = [super init])) {

		self.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
		self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
		self.minimumLineSpacing = 0;
	}

	return self;
}

- (void)prepareLayout {

	CGRect visibleRect = (CGRect) { self.collectionView.contentOffset, self.collectionView.bounds.size };
	self.midX = CGRectGetMidX(visibleRect);
	self.width = CGRectGetWidth(visibleRect) / 2;
	self.maxAngle = M_PI_2;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {

    return YES;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {

	UICollectionViewLayoutAttributes *attributes = [super layoutAttributesForItemAtIndexPath:indexPath];

	CGFloat distance = CGRectGetMidX(attributes.frame) - self.midX;
	CGFloat currentAngle = self.maxAngle * distance / self.width;
	CGFloat delta = sinf(currentAngle) * self.width - distance;

	attributes.transform3D = CATransform3DConcat(CATransform3DMakeRotation(currentAngle, 0, 1, 0), CATransform3DMakeTranslation(delta, 0, 0));

	attributes.alpha = (ABS(distance) < self.width);

	return attributes;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {

	NSMutableArray *attributes = [NSMutableArray array];

	if ([self.collectionView numberOfSections]) {

		for (NSInteger i = 0; i < [self.collectionView numberOfItemsInSection:0]; i++) {

			[attributes addObject:[self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]]];
		}
	}
    
    return attributes;
}

@end

#pragma mark - Horizontal picker view

@interface DSHorizontalPickerView () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property(nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic, assign) NSUInteger selectedItem;

- (CGFloat)offsetForItem:(NSUInteger)item;
- (void)didEndScrolling;

@end

@implementation DSHorizontalPickerView

- (void)setup {

    self.font = self.font ? : [UIFont fontWithName:@"HelveticaNeue-Light" size:20];
	self.textColour = self.textColour ? : [UIColor darkGrayColor];
	self.highlightedTextColour = self.highlightedTextColour ? : [UIColor blackColor];

	[self.collectionView removeFromSuperview];

    self.collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:[DSCollectionViewLayout new]];

    self.collectionView.showsHorizontalScrollIndicator = NO;
	self.collectionView.backgroundColor = [UIColor clearColor];
	self.collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
	self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.collectionView.delegate = self;
	self.collectionView.dataSource = self;

	[self.collectionView registerClass:[DSCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([DSCollectionViewCell class])];

    [self addSubview:self.collectionView];

	CAGradientLayer *maskLayer = [CAGradientLayer layer];

    maskLayer.frame = self.collectionView.bounds;
	maskLayer.colors = @[ (id)[[UIColor clearColor] CGColor], (id)[[UIColor blackColor] CGColor], (id)[[UIColor blackColor] CGColor], (id)[[UIColor clearColor] CGColor] ];
	maskLayer.locations = @[ @0.0, @0.33, @0.66, @1.0 ];
	maskLayer.startPoint = CGPointMake(0.0, 0.0);
	maskLayer.endPoint = CGPointMake(1.0, 0.0);

    self.collectionView.layer.mask = maskLayer;
}

- (instancetype)initWithFrame:(CGRect)frame {

    if ((self = [super initWithFrame:frame])) [self setup];

    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {

	if ((self = [super initWithCoder:aDecoder])) [self setup];

	return self;
}

#pragma mark Layout

- (void)layoutSubviews {

	[super layoutSubviews];

	[self.collectionView.collectionViewLayout invalidateLayout];
	[self scrollToItem:self.selectedItem animated:NO];

	self.collectionView.layer.mask.frame = self.collectionView.bounds;
}

#pragma mark Properties

- (void)setFont:(UIFont *)font {

	if (![_font isEqual:font]) {

        _font = font;
		[self setup];
	}
}

#pragma mark Data selection

- (void)reloadData {

	[self.collectionView reloadData];
}

- (CGFloat)offsetForItem:(NSUInteger)item {

	CGFloat offset = 0;

	for (NSInteger i = 0; i < item; i++) {

		DSCollectionViewCell *cell = (DSCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
		offset += cell.bounds.size.width;
	}

	CGSize firstSize = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]].bounds.size;
	CGSize selectedSize = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:item inSection:0]].bounds.size;

    offset -= (firstSize.width - selectedSize.width) / 2;
	offset += self.interitemSpacing * item;
    
	return offset;
}

- (void)scrollToItem:(NSUInteger)item animated:(BOOL)animated {

	[self.collectionView setContentOffset:CGPointMake([self offsetForItem:item], self.collectionView.contentOffset.y) animated:animated];
}

- (void)selectItem:(NSUInteger)item animated:(BOOL)animated {

	[self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:item inSection:0] animated:animated scrollPosition:UICollectionViewScrollPositionNone];
	[self scrollToItem:item animated:animated];

	self.selectedItem = item;

	if ([self.delegate respondsToSelector:@selector(pickerView:didSelectItem:)]) [self.delegate pickerView:self didSelectItem:item];
}

- (void)didEndScrolling {

	if ([self.delegate numberOfItemsInPickerView:self]) {

		for (NSUInteger i = 0; i < [self collectionView:self.collectionView numberOfItemsInSection:0]; i++) {

			DSCollectionViewCell *cell = (DSCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];

            if ([self offsetForItem:i] + cell.bounds.size.width / 2 > self.collectionView.contentOffset.x) {

                [self selectItem:i animated:YES];
				break;
			}
		}
	}
}

#pragma mark UICollectionViewDataSource conformance

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {

	return ([self.delegate numberOfItemsInPickerView:self] > 0);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

	return [self.delegate numberOfItemsInPickerView:self];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

	NSString *title = [self.delegate pickerView:self titleForItem:indexPath.item];

	DSCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([DSCollectionViewCell class]) forIndexPath:indexPath];

    cell.label.textColor = self.textColour;
	cell.label.highlightedTextColor = self.highlightedTextColour;
	cell.label.font = self.font;
	
	if ([cell.label respondsToSelector:@selector(setAttributedText:)])
		cell.label.attributedText = [[NSAttributedString alloc] initWithString:title attributes:@{ NSFontAttributeName: self.font }];
	else
		cell.label.text = title;

	[cell.label sizeToFit];

	return cell;
}

#pragma mark UICollectionViewDelegateFlowLayout conformance

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {

	NSString *title = [self.delegate pickerView:self titleForItem:indexPath.item];
	CGSize size = [title sizeWithAttributes:@{ NSFontAttributeName : self.font }];

    return CGSizeMake(ceilf(size.width), ceilf(size.height));
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {

	return self.interitemSpacing;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {

	NSInteger numberOfItemsInSection = [self collectionView:collectionView numberOfItemsInSection:section];

    CGSize firstSize = [self collectionView:collectionView layout:collectionViewLayout sizeForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
	CGSize lastSize = [self collectionView:collectionView layout:collectionViewLayout sizeForItemAtIndexPath:[NSIndexPath indexPathForItem:numberOfItemsInSection - 1 inSection:section]];

    return UIEdgeInsetsMake((collectionView.bounds.size.height - ceilf(self.font.lineHeight)) / 2,
							(collectionView.bounds.size.width - firstSize.width) / 2,
							(collectionView.bounds.size.height - ceilf(self.font.lineHeight)) / 2,
							(collectionView.bounds.size.width - lastSize.width) / 2);
}

#pragma mark UICollectionViewDelegate conformance

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

	[self selectItem:indexPath.item animated:YES];
}

#pragma mark UIScrollViewDelegate conformance

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {

	[self didEndScrolling];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {

	if (!decelerate) [self didEndScrolling];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
	self.collectionView.layer.mask.frame = self.collectionView.bounds;
	[CATransaction commit];
}

@end
