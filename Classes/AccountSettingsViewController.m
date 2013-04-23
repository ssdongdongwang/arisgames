//
//  AccountSettingsViewController.m
//  ARIS
//
//  Created by Ben Longoria on 2/11/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import "AccountSettingsViewController.h"
#import "RootViewController.h"
#import "ForgotViewController.h"

@implementation AccountSettingsViewController

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
    self = [super initWithNibName:nibName bundle:nibBundle];
    if (self) {
        self.title = @"Account";
        self.tabBarItem.image = [UIImage imageNamed:@"123-id-card"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	warningLabel.text = NSLocalizedString(@"LogoutWarningKey", @"");
	[logoutButton setTitle:NSLocalizedString(@"LogoutKey",@"") forState:UIControlStateNormal];
}

- (IBAction) logoutButtonPressed:(id)sender
{
	NSLog(@"NSNotification: LogoutRequested");
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"LogoutRequested" object:self]];
}

- (IBAction) passButtonPressed:(id)sender
{
	ForgotViewController *forgotPassViewController = [[ForgotViewController alloc]
                                                      initWithNibName:@"ForgotViewController" bundle:[NSBundle mainBundle]];
	[[self navigationController] pushViewController:forgotPassViewController animated:YES];
}

- (IBAction) profileButtonPressed:(id)sender
{
    [[RootViewController sharedRootViewController] displayPlayerSettings];
}

@end