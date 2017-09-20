//
//  AppDelegate.m
//  CIMessing
//
//  Created by Richard Henry on 11/07/2008.
//  Copyright 2008 University of Teesside. All rights reserved.
//

#import "AppDelegate.h"


@implementation AppDelegate

#pragma mark Application delegate messages

-(void)applicationDidFinishLaunching:(NSNotification*)aNotification {
	
	NSDictionary		*error;
	
	// Play a random track in iTunes
	NSAppleScript *script = [[NSAppleScript alloc] initWithSource:@"tell application \"iTunes\"\nset myPlaylist to playlist \"Library\"\ntell myPlaylist\nrepeat 5 times\nset shuffle to false\nset shuffle to true\nend repeat\nplay\nend tell\nend tell"];
	[script executeAndReturnError:&error];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)app { return YES; }

- (void)applicationWillTerminate:(NSNotification *)aNotification {
	
	NSDictionary		*error;
	
	// Pause iTunes
	NSAppleScript *script = [[NSAppleScript alloc] initWithSource:@"tell application \"iTunes\" to pause"];
	[script executeAndReturnError:&error];
	
	// Undo bindings and release democontroller
	[paramController setContent:nil];
}

@end
