//
//  ArisAppDelegate.m
//  Aris
//
//  Created by Kevin Harris on 7/27/08.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import "ArisAppDelegate.h"
#import "RootViewController.h"

@implementation ArisAppDelegate


@synthesize window;
@synthesize rootViewController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {
	[application setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
	[window addSubview:[rootViewController view]];
	[window makeKeyAndVisible];
}


- (void)dealloc {
	[rootViewController release];
	[window release];
	[super dealloc];
}

@end
