//
//  MainViewController.h
//  Aris
//
//  Created by Kevin Harris on 7/27/08.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyCLController.h"

@interface MainViewController : UIViewController <UIWebViewDelegate, MyCLControllerDelegate> {
	IBOutlet UIWebView *webView;
	IBOutlet UIActivityIndicatorView *activityView;
	
	NSString *lastLatitude;
	NSString *lastLongitude;
}

- (void)goToURL:(NSString *)URL;
- (NSString *)homeURL;
- (NSString *)homeDevURL;

@end
