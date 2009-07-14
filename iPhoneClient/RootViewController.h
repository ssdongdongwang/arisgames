//
//  RootViewController.h
//  Aris
//
//  Created by Kevin Harris on 7/27/08.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MainViewController;
@class FlipsideViewController;

@interface RootViewController : UIViewController {
	IBOutlet UIButton *infoButton;
	MainViewController *mainViewController;
	FlipsideViewController *flipsideViewController;
	UINavigationBar *flipsideNavigationBar;
}

@property (nonatomic, retain) UIButton *infoButton;
@property (nonatomic, retain) MainViewController *mainViewController;
@property (nonatomic, retain) UINavigationBar *flipsideNavigationBar;
@property (nonatomic, retain) FlipsideViewController *flipsideViewController;

- (IBAction)toggleView;
- (IBAction)returnHome;
- (IBAction)returnDevHome;
-(IBAction)returnTestHome;

- (void)flipAndGoto:(NSString *)url;

@end
