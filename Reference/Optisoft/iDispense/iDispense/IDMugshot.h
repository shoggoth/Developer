//
//  IDMugshot.h
//  iDispense
//
//  Created by Richard Henry on 04/12/2013.
//  Copyright (c) 2013 Optisoft Ltd. All rights reserved.
//


//
//  protocol IDMugshot
//
//  Mugshot base protocol
//

@protocol IDMugshot <NSObject>

@property(nonatomic) UIInterfaceOrientation orientation;
@property(nonatomic) NSUInteger index;

// Generate and return a preview image from the contents to be displayed in the collection view cell.
- (UIImage *)generatePreviewImageOfSize:(CGSize)previewImageSize;

@end

//
//  interface IDMugshot
//
//  Mugshot base class
//

@interface IDMugshot : NSObject <IDMugshot> {

    NSString        *imageKey;
}

// Property auto-synthesis from protocol
@property(nonatomic) UIInterfaceOrientation orientation;
@property(nonatomic) NSUInteger index;

@end


//
//  interface IDMugshotImage
//
//  Image-specifics
//

@interface IDMugshotImage : IDMugshot

- (instancetype)initWithImage:(UIImage *)image;

// Contents of the mugshot. This is a still capture so it contains an image
@property(nonatomic, readonly) UIImage *image;

@end


//
//  interface IDMugshotMovie
//
//  Movie-specifics
//

@interface IDMugshotMovie : IDMugshot

- (instancetype)initWithURL:(NSURL *)url;

// Contents of the mugshot. This is a movie capture so it contains the URL of the captured movie.
@property(nonatomic, copy) NSURL *movieURL;

@end
