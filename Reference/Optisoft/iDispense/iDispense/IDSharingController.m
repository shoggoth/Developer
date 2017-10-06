//
//  IDSharingController.m
//  iDispense
//
//  Created by Richard Henry on 18/12/2013.
//  Copyright (c) 2013 Optisoft Ltd. All rights reserved.
//

#import "IDSharingController.h"
#import "IDAppDelegate.h"
#import "IDMugshot.h"

#import "OSPlatform.h"
#import "Runtime.h"

#import <MobileCoreServices/MobileCoreServices.h>
#import <Social/Social.h>

#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>


#pragma mark Mail composer swizzler

@implementation MFMailComposeViewController (Recipient)

+ (void)load {

    swizzleInstanceMethods(self, @selector(setMessageBody:isHTML:), @selector(setMessageBodySwizzled:isHTML:));
}

- (void)setMessageBodySwizzled:(NSString *)body isHTML:(BOOL)isHTML {

    if (isHTML) {

        // Case insensitive regex search for our HTML tags.
        NSRange range = [body rangeOfString:@"<torecipients>.*</torecipients>" options:NSRegularExpressionSearch | NSCaseInsensitiveSearch];

        if (range.location != NSNotFound) {

            NSScanner *scanner = [NSScanner scannerWithString:body];
            [scanner setScanLocation:range.location + 14];

            NSString *recipientsString = [NSString string];

            // Found some email recipients in the tag so let's set the to: field in the email compose
            if ([scanner scanUpToString:@"</torecipients>" intoString:&recipientsString]) {

                [self setToRecipients:[recipientsString componentsSeparatedByString:@";"]];
            }

            // Remove the tag from the body content.
            body = [body stringByReplacingCharactersInRange:range withString:@""];
        }
    }

    [self setMessageBodySwizzled:body isHTML:isHTML];
}

@end

#pragma mark - Sharing controller

@implementation IDSharingController {

    UIActivityViewController    *activityViewController;
}

+ (CGRect)shareImageRect {

    static const CGRect shareSizes[] = {

        { 0, 0, 96,  128  },    // Tiny
        { 0, 0, 192, 256  },    // Small
        { 0, 0, 384, 512  },    // Medium
        { 0, 0, 576, 768  },    // Large
        { 0, 0, 768, 1024 }     // Extra Large
    };

    NSInteger index = [[[NSUserDefaults standardUserDefaults] objectForKey:@"share_image_canvas_size_preference"] integerValue];

    return shareSizes[index];
}

+ (float)shareImageFontSize {

    static const float shareSizes[] = {

        14,    // Tiny
        16,    // Small
        18,    // Medium
        24,    // Large
        32     // Extra Large
    };

    NSInteger index = [[[NSUserDefaults standardUserDefaults] objectForKey:@"share_image_canvas_size_preference"] integerValue];

    return shareSizes[index];
}

+ (float)shareImageOptometristFontSize {

    static const float shareSizes[] = {

        7,     // Tiny
        11,    // Small
        14,    // Medium
        16,    // Large
        18     // Extra Large
    };

    NSInteger index = [[[NSUserDefaults standardUserDefaults] objectForKey:@"share_image_canvas_size_preference"] integerValue];

    return shareSizes[index];
}

#pragma mark Sharing

- (void)shareItems:(NSArray *)shareItems fromViewController:(UIViewController *)controller options:(NSDictionary *)options {

    // Create a new activity controller for the sharing
    activityViewController = [[UIActivityViewController alloc] initWithActivityItems:shareItems applicationActivities:nil];

    // Set basic options for the activity sharing
    activityViewController.excludedActivityTypes = @[ UIActivityTypeAssignToContact ];
    activityViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;

    // Set enhanced options for the activity sharing
    if (options) {

        NSArray *excludeActivities = [options valueForKey:@"excludeActivities"];
        if (excludeActivities) activityViewController.excludedActivityTypes = excludeActivities;

        NSString *subject = [options valueForKey:@"subject"];
        if (subject) [activityViewController setValue:subject forKey:@"subject"];

        // iOS 8.0 onwards displays the sharing sheet in a pop-up.
        if (NSClassFromString(@"UIPopoverPresentationController")) {

            id sender = [options valueForKey:@"sender"];

            if ([sender isMemberOfClass:[UIBarButtonItem class]]) activityViewController.popoverPresentationController.barButtonItem = sender;

            else if ([sender isMemberOfClass:[UIView class]]) activityViewController.popoverPresentationController.sourceView = sender;
        }
    }

    // Show the sharing view
    [controller presentViewController:activityViewController animated:YES completion:nil];
}

@end

#pragma mark - Email Text Activity provider

@implementation IDEmailTextItemProvider

- (id)item {

    // Otherwise, return the URL of the media that's suitable for attaching to an email or putting on the pasteboard.
    if ([self.activityType isEqualToString:UIActivityTypeMail])

        return self.emailItem;

    // User selected something else so it's probably not suitable and all we can do is send them the placeholder item.
    return self.placeholderItem;
}

@end

