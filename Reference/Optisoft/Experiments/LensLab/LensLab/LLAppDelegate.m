//
//  LLAppDelegate.m
//  LensLab
//
//  Created by Optisoft Ltd on 07/10/2013.
//  Copyright (c) 2013 Optisoft Ltd. All rights reserved.
//


@interface LLAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

@end


@implementation LLAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    // Insert code here to initialize your application
    NSLog(@"Main view = %@", _window);
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender { return YES; }

- (IBAction)doDebugging:(id)sender {
    
    NSLog(@"Main view gc = %@", _window.graphicsContext.graphicsPort);
}

@end
