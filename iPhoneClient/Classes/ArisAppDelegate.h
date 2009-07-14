//
//  ArisAppDelegate.h
//  Aris
//
//  Created by Kevin Harris on 7/27/08.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;

@interface ArisAppDelegate : NSObject <UIApplicationDelegate> {
	IBOutlet UIWindow *window;
	IBOutlet RootViewController *rootViewController;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) RootViewController *rootViewController;

@end

