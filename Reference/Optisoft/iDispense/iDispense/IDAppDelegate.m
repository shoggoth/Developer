//
//  IDAppDelegate.m
//  iDispense
//
//  Created by Optisoft Ltd on 01/10/2013.
//  Copyright (c) 2013 Optisoft Ltd. All rights reserved.
//

#import "IDAppDelegate.h"
#import "IDImageStore.h"
#import "IDInAppPurchases.h"
#import "IDDispensingDataStore.h"
#import "IDInAppPurchases.h"


@implementation IDAppDelegate

#pragma mark Application entry

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // Clear the caches
    [self clearCaches];

    // Set up application defaults
    [self setApplicationDefaults:launchOptions];

    // Add ourselves as an observer to app store transactions
    [[SKPaymentQueue defaultQueue] addTransactionObserver:[IDInAppPurchases sharedIAPStore]];

    // Everything else is done from the storyboard with regards to initialisation.
    return YES;
}

#pragma mark Application Events

- (void)applicationWillResignActive:(UIApplication *)application {

    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {

    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {

    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {

    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[IDDispensingDataStore defaultDataStore] sync];
}

- (void)applicationWillTerminate:(UIApplication *)application {

    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.

    // Remove the observer
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:[IDInAppPurchases sharedIAPStore]];

    // Clear the caches
    [self clearCaches];
}

#pragma mark Caching

- (void)clearCaches {

    // Delete the image and movie capture files within the standard capture directories.
    [[IDImageStore defaultImageStore] clearImageDiskCache];
    [[IDImageStore defaultImageStore] clearMovieDiskCache];
}

#pragma mark Defaults handling

- (void)setApplicationDefaults:(NSDictionary *)launchOptions {

    const NSUserDefaults    *defaults = [NSUserDefaults standardUserDefaults];

    // Set up application defaults
    [defaults registerDefaults:@{ @"optometrist_watermark_preference" : @NO,            // Are we going to put a watermark on the missives?
                                  @"show_lens_meridian_preference" : @NO,               // Does the user want to show the lens meridian?
                                  @"lens_comparison_top_bar_expanded" : @YES,           // Is the top bar on the comparison expanded?
                                  @"lens_comparison_bottom_bar_expanded" : @YES,        // Is the bottom bar on the comparison expanded?
                                  @"optometrist_logo_alpha_preference" : @1.0,          // How much alpha should the watermark have?
                                  @"show_welcome_screen_preference" : @YES,             // Is the welcome instruction screen going to be shown?
                                  @"jpeg_image_quality_preference" : @0.5,              // JPEG quality.
                                  @"gaussian_blur_amount_preference" : @0.0,            // Amount of soft focus on mugshots.
                                  @"vibrance_filter_amount_preference" : @0.0,          // Amount of vibrance filter on mugshouts.
                                  @"share_image_canvas_size_preference" : @2,           // Size of the image to be shared.
                                  @"sdc_active" : @NO
                                  }];
    [defaults synchronize];
}

@end
