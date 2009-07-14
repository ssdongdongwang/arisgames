//
//  FilesViewController.m
//  ARIS
//
//  Created by Ben Longoria on 2/11/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import "FilesViewController.h"


@implementation FilesViewController

@synthesize webview;
@synthesize moduleName;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	moduleName = @"RESTInventory";
	
	NSLog(@"Inventory View");
}

- (void)viewDidAppear {
	[webview loadRequest:[appModel getURLForModule:moduleName]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

-(void) setModel:(AppModel *)model {
	if(appModel != model) {
		[appModel release];
		appModel = model;
		[appModel retain];
	}
	[webview loadRequest:[appModel getURLForModule:moduleName]];
	
	NSLog(@"model set for FILES");
}

- (void)dealloc {
	[appModel release];
	[moduleName release];
    [super dealloc];
}


@end
