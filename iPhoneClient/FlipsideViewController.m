//
//  FlipsideViewController.m
//  Aris
//
//  Created by Kevin Harris on 7/27/08.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import "FlipsideViewController.h"
#import "MyCLController.h"


@implementation FlipsideViewController


- (void)viewDidLoad {
	self.view.backgroundColor = [UIColor viewFlipsideBackgroundColor];
	if ([MyCLController sharedInstance].locationManager.locationServicesEnabled) {
		[locToggle setOn: YES animated: NO];
	}
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}


- (void)dealloc {
	[super dealloc];
}

#pragma mark --- Location Tracking Toggle ---
-(IBAction)toggleLocationTracking:(id)sender {
	if ([sender isOn] 
		&& [MyCLController sharedInstance].locationManager.locationServicesEnabled)
	{
		[[MyCLController sharedInstance].locationManager startUpdatingLocation];
	}
	else {
		[[MyCLController sharedInstance].locationManager stopUpdatingLocation];
	}
}
@end
