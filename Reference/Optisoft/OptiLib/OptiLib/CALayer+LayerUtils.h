//
//  CALayer+LayerUtils.h
//  OptiLib
//
//  Created by Richard Henry on 29/01/2014.
//  Copyright (c) 2014 Optisoft. All rights reserved.
//

@import QuartzCore;


@interface CALayer (LayerUtils)

@property(nonatomic) CGPoint frameOrigin;
@property(nonatomic) CGSize frameSize;
@property(nonatomic) CGFloat frameX;
@property(nonatomic) CGFloat frameY;
@property(nonatomic) CGFloat frameWidth;
@property(nonatomic) CGFloat frameHeight;
@property(nonatomic) CGFloat frameMinX;
@property(nonatomic) CGFloat frameMidX;
@property(nonatomic) CGFloat frameMaxX;
@property(nonatomic) CGFloat frameMinY;
@property(nonatomic) CGFloat frameMidY;
@property(nonatomic) CGFloat frameMaxY;
@property(nonatomic) CGPoint frameTopLeftPoint;
@property(nonatomic) CGPoint frameTopMiddlePoint;
@property(nonatomic) CGPoint frameTopRightPoint;
@property(nonatomic) CGPoint frameMiddleRightPoint;
@property(nonatomic) CGPoint frameBottomRightPoint;
@property(nonatomic) CGPoint frameBottomMiddlePoint;
@property(nonatomic) CGPoint frameBottomLeftPoint;
@property(nonatomic) CGPoint frameMiddleLeftPoint;
@property(nonatomic) CGPoint boundsOrigin;
@property(nonatomic) CGSize boundsSize;
@property(nonatomic) CGFloat boundsX;
@property(nonatomic) CGFloat boundsY;
@property(nonatomic) CGFloat boundsWidth;
@property(nonatomic) CGFloat boundsHeight;
@property(nonatomic) CGFloat boundsMinX;
@property(nonatomic) CGFloat boundsMidX;
@property(nonatomic) CGFloat boundsMaxX;
@property(nonatomic) CGFloat boundsMinY;
@property(nonatomic) CGFloat boundsMidY;
@property(nonatomic) CGFloat boundsMaxY;
@property(nonatomic) CGPoint boundsTopLeftPoint;
@property(nonatomic) CGPoint boundsTopMiddlePoint;
@property(nonatomic) CGPoint boundsTopRightPoint;
@property(nonatomic) CGPoint boundsMiddleRightPoint;
@property(nonatomic) CGPoint boundsBottomRightPoint;
@property(nonatomic) CGPoint boundsBottomMiddlePoint;
@property(nonatomic) CGPoint boundsBottomLeftPoint;
@property(nonatomic) CGPoint boundsMiddleLeftPoint;
@property(nonatomic) CGFloat positionX;
@property(nonatomic) CGFloat positionY;

+ (id)layerWithFrame:(CGRect)frame;
- (id)initWithFrame:(CGRect)frame;

- (void)setAnchorPointAndPreserveCurrentFrame:(CGPoint)anchorPoint;

+ (CGFloat)smallestWidthInLayers:(NSArray *)layers;
+ (CGFloat)smallestHeightInLayers:(NSArray *)layers;
+ (CGFloat)largestWidthInLayers:(NSArray *)layers;
+ (CGFloat)largestHeightInLayers:(NSArray *)layers;

- (CALayer *)presentationCALayer;
- (CALayer *)modelCALayer;

- (void)addDefaultFadeTransition;
- (void)addDefaultMoveInTransitionWithSubtype:(NSString *)subtype;
- (void)addDefaultPushTransitionWithSubtype:(NSString *)subtype;
- (void)addDefaultRevealTransitionWithSubtype:(NSString *)subtype;
- (void)addFadeTransitionWithDuration:(NSTimeInterval)duration;
- (void)addMoveInTransitionWithSubtype:(NSString *)subtype duration:(NSTimeInterval)duration;
- (void)addPushTransitionWithSubtype:(NSString *)subtype duration:(NSTimeInterval)duration;
- (void)addRevealTransitionWithSubtype:(NSString *)subtype duration:(NSTimeInterval)duration;

- (void)addAnimation:(CAAnimation *)animation;
- (void)addAnimation:(CAAnimation *)animation forKey:(NSString *)key withStopBlock:(void (^)(BOOL finished))stopBlock;
- (void)addAnimation:(CAAnimation *)animation forKey:(NSString *)key withStartBlock:(void (^)(void))startBlock stopBlock:(void (^)(BOOL finished))stopBlock;
- (void)replaceAnimationForKey:(NSString *)key withAnimation:(CAAnimation *)animation;
- (NSArray *)keyedAnimations;

- (UIImage *)renderToImage;
- (UIImage *)renderToImageWithContextSize:(CGSize)contextSize;
- (UIImage *)renderToImageWithContextSize:(CGSize)contextSize contextTransform:(CGAffineTransform)contextTransform;

#ifdef DEBUG
- (void)enableDebugBordersRecursively:(BOOL)recursively;
#endif

@end