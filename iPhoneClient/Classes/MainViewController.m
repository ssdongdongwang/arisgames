//
//  MainViewController.m
//  Aris
//
//  Created by Kevin Harris on 7/27/08.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import "MainViewController.h"
#import "MainView.h"

@implementation MainViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		// Custom initialization
	}
	return self;
}


// If you need to do additional setup after loading the view, override viewDidLoad.
 - (void)viewDidLoad {
	 [MyCLController sharedInstance].delegate = self;

	 NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
														  NSUserDomainMask, YES);
	 NSString *lastSite = [NSString stringWithContentsOfFile:[[paths objectAtIndex:0]
						   stringByAppendingPathComponent:@".aris.conf"]];
	 if (lastSite == nil) {
		 lastSite = [self homeURL];
	 }
	 [self goToURL:lastSite];
	 
	 if ([MyCLController sharedInstance].locationManager.locationServicesEnabled) {
		 [[MyCLController sharedInstance].locationManager startUpdatingLocation];
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
	[lastLatitude dealloc];
	[lastLongitude dealloc];
	[super dealloc];
}

#pragma mark --- WebViewDelegate Stuff ---
-(void) webViewDidStartLoad: (UIWebView *)webView {
	[activityView startAnimating];
}

-(void) webViewDidFinishLoad: (UIWebView *)wView {
	[activityView stopAnimating];

	// TODO: Make this a method
	if ([MyCLController sharedInstance].locationManager.locationServicesEnabled
		&& [webView stringByEvaluatingJavaScriptFromString:
		 [NSString stringWithFormat:@"update_location(%@, %@);", 
		  lastLatitude, lastLongitude]] == nil)
	{
		NSLog(@"Couldn't execute script!");
	}
	else NSLog(@"update_location() executed successfully.");
		 
	// Save the location
	NSLog(@"Now at %@", webView.request);
	NSError *error;
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
														 NSUserDomainMask, YES);
	NSString *fileName = [[paths objectAtIndex:0]
						  stringByAppendingPathComponent:@".aris.conf"];
	
	BOOL wroteOk = [[[webView.request URL] absoluteString] writeToFile: fileName
		atomically: YES	encoding: NSUTF8StringEncoding error: &error];
	if (!wroteOk) NSLog(@"Couldn't write to log: %@", [error localizedFailureReason]);
}

#pragma mark --- Delegate methods for MyCLController ---
- (void)updateLatitude: (NSString *)latitude andLongitude:(NSString *) longitude {
	// Check if we're updating locations, and then update the label, too.
	if (lastLatitude != nil) [lastLatitude dealloc];
	if (lastLongitude != nil) [lastLongitude dealloc];
	lastLatitude = [latitude copy];
	lastLongitude = [longitude copy];
	
	NSLog(@"Updating location: %@, %@", lastLatitude, lastLongitude);
	// TODO: Make this a method
	if ([webView stringByEvaluatingJavaScriptFromString:
		 [NSString stringWithFormat:@"update_location(%@, %@);", 
		  lastLatitude, lastLongitude]] == nil)
	{
		NSLog(@"Couldn't execute script!");
	}
	else NSLog(@"update_location() executed successfully.");
}

- (void)newError: (NSString *)text {
	NSLog(text);
}

- (void)goToURL:(NSString *)URL {
	[webView loadRequest:
	 [NSURLRequest requestWithURL:
	  [NSURL URLWithString:URL]]];	
}

- (NSString *)homeURL {
	return @"http://arisgames.org/games";
}

- (NSString *)homeDevURL {
	return @"http://atsosxdev.doit.wisc.edu/aris/games/";
}

- (NSString *)homeTestURL {
	return @"http://atsosxdev.doit.wisc.edu/arislive/games/";
}

@end
