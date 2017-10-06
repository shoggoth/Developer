//
//  IDLayoutTransitionController.h
//  iDispense
//
//  Created by Richard Henry on 18/11/2013.
//  Copyright (c) 2013 Optisoft Ltd. All rights reserved.
//


@protocol IDLayoutTransitionControllerDelegate <NSObject>

-(void)interactionBeganAtPoint:(CGPoint)p;

@end

@interface IDLayoutTransitionController : NSObject <UINavigationControllerDelegate, UIViewControllerAnimatedTransitioning, UIViewControllerInteractiveTransitioning>

-(instancetype)initWithCollectionView:(UICollectionView *)collectionView;

@property(nonatomic, weak) id <IDLayoutTransitionControllerDelegate> delegate;

@property(nonatomic, assign) UINavigationControllerOperation navigationOperation;
@property(nonatomic, readonly) BOOL hasActiveInteraction;

@end
