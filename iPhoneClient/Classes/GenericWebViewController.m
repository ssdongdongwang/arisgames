//
//  GenericWebViewController.m
//  ARIS
//
//  Created by David Gagnon on 3/19/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import "GenericWebViewController.h"
#import "ARISAppDelegate.h"


@implementation GenericWebViewController

@synthesize webview;
@synthesize request;


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	webview.delegate = self;
	webview.hidden = YES;
	
	if (self.request) {
		[webview loadRequest:self.request];
	}
	
	//NSLog(@"Generic Web Controller is Now Loading the URL in ViewDidLoad");
	//NSLog(@"GenericWebView loaded");
	
	//[super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}
 

#pragma mark custom methods and logic
-(void) setURL: (NSString*)urlString {
	self.request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
	//webview.hidden = YES;
	//[webview loadRequest:request];
	NSLog(@"Generic Web Controller request is set to: %@",urlString);
}

-(void) setModel:(AppModel *)model{
	if(appModel != model) {
		[appModel release];
		appModel = model;
		[appModel retain];
	}
	
	NSLog(@"model set for GenericWebViewController");
}

- (void)dealloc {
	[appModel release];
    [super dealloc];
}

#pragma mark WebView Delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
//nada
	return true;
}


- (void)webViewDidStartLoad:(UIWebView *)webView {
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	[(ARISAppDelegate *)[[UIApplication sharedApplication] delegate] showWaitingIndicator:@"Loading..."];

}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	NSLog(@"Generic Web Controller Data Loaded");

	
	webview.hidden = NO;
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	//Stop Waiting Indicator
	[(ARISAppDelegate *)[[UIApplication sharedApplication] delegate] removeWaitingIndicator];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	NSLog(@"Generic Web Controller Loading Error");

	webview.hidden = NO;
	
	//Display an error message to user about the connection
	[(ARISAppDelegate *)[[UIApplication sharedApplication] delegate] showNetworkAlert];
	
	//Stop Waiting Indicator
	[(ARISAppDelegate *)[[UIApplication sharedApplication] delegate] removeWaitingIndicator];
}

@end
