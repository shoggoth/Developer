//
//  IDSharingController.h
//  iDispense
//
//  Created by Richard Henry on 18/12/2013.
//  Copyright (c) 2013 Optisoft Ltd. All rights reserved.
//


//
//  interface IDSharingController
//
//  Helper class for sharing of media to social networking sites.
//

@interface IDSharingController : NSObject

@property(nonatomic, nullable, copy) NSArray *mailRecipientsArray;

+ (CGRect)shareImageRect;

+ (float)shareImageFontSize;
+ (float)shareImageOptometristFontSize;

- (void)shareItems:(nonnull NSArray *)items fromViewController:(nonnull UIViewController *)controller options:(nullable NSDictionary *)options;

@end

//
//  interface IDEmailTextItemProvider
//
//  Lets us provide an alternative URL of a PDF that is more suitable for print media.
//

@interface IDEmailTextItemProvider : UIActivityItemProvider

@property(nonatomic, nullable, strong) id emailItem;

@end
