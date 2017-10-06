//
//  IDSpecShape.h
//  iDispense
//
//  Created by Richard Henry on 09/12/2013.
//  Copyright (c) 2013 Optisoft Ltd. All rights reserved.
//


//
//  interface IDSpecShape
//
//  Container for spec. shapes used by the spec. shape view controller.
//

@interface IDSpecShape : NSObject

- (instancetype)initWithImage:(UIImage *)image name:(NSString *)name;

@property(nonatomic, strong) UIImage *image;
@property(nonatomic, strong) UIImage *thumbnail;

@property(nonatomic, copy) NSString *name;

@end
