//
//  IDSpecView.h
//  iDispense
//
//  Created by Optisoft Ltd on 24/10/2013.
//  Copyright (c) 2013 Optisoft Ltd. All rights reserved.
//


//
//  interface IDSpecView
//
//  View that allows a still image to have a spec. overlay added on top of it and manipulated by the user.
//

@interface IDSpecView : UIView

@property(nonatomic, strong) UIImage *mugshotImage;
@property(nonatomic, strong) UIImage *specImage;
@property(nonatomic, assign) CGAffineTransform specTransform;

@end

//
//  interface IDMovieView
//
//  Movie capture view.
//

@interface IDMovieView : UIView

@property(nonatomic, strong) NSURL *movieUrl;

@end