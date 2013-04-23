//
//  LoginViewController.m
//  ARIS
//
//  Created by Ben Longoria on 2/11/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import "LoginViewController.h"
#import "SelfRegistrationViewController.h"
#import "ARISAppDelegate.h"
#import "ChangePasswordViewController.h"
#import "ForgotViewController.h"
#import "QRCodeReader.h"
#import "BumpTestViewController.h"

@interface LoginViewController ()
{
    BOOL create;
    BOOL museumMode;
    int  quickGameId;
}

@end

@implementation LoginViewController

- (id) initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
    self = [super initWithNibName:nibName bundle:nibBundle];
    if (self)
    {
        self.title = NSLocalizedString(@"LoginTitleKey", @"");
        create = NO;
        museumMode = NO;
        quickGameId = 0;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlLoginAttempt:) name:@"NewLoginResponseReady" object:nil];
    }
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];

    usernameField.placeholder = NSLocalizedString(@"UsernameKey", @"");
    passwordField.placeholder = NSLocalizedString(@"PasswordKey", @"");
    [loginButton setTitle:NSLocalizedString(@"LoginKey",@"") forState:UIControlStateNormal];
    newAccountMessageLabel.text = NSLocalizedString(@"NewAccountMessageKey", @"");
    [newAccountButton setTitle:NSLocalizedString(@"CreateAccountKey",@"") forState:UIControlStateNormal];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    if(textField == usernameField)
        [passwordField becomeFirstResponder];
    if(textField == passwordField)
        [self loginButtonTouched:nil];
    return YES;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [usernameField resignFirstResponder];
    [passwordField resignFirstResponder];
}

- (IBAction) loginButtonTouched:(id)sender
{
    [usernameField resignFirstResponder];
    [passwordField resignFirstResponder];
 
    [[RootViewController sharedRootViewController] showWaitingIndicator:@"Logging In..." displayProgressBar:NO];
    [[AppServices sharedAppServices] loginWithUsername:usernameField.text password:passwordField.text];
}

- (IBAction) QRButtonTouched
{
    ZXingWidgetController *widController = [[ZXingWidgetController alloc] initWithDelegate:self showCancel:YES OneDMode:NO];
    widController.readers = [[NSMutableSet alloc ] initWithObjects:[[QRCodeReader alloc] init], nil];
    [self presentModalViewController:widController animated:NO];
}

- (void) changePassTouch
{
    ForgotViewController *forgotPassViewController = [[ForgotViewController alloc] initWithNibName:@"ForgotViewController" bundle:[NSBundle mainBundle]];
    [[self navigationController] pushViewController:forgotPassViewController animated:NO];
}

- (IBAction) newAccountButtonTouched:(id)sender
{
    SelfRegistrationViewController *selfRegistrationViewController = [[SelfRegistrationViewController alloc] initWithNibName:@"SelfRegistration" bundle:[NSBundle mainBundle]];
    [[self navigationController] pushViewController:selfRegistrationViewController animated:NO];
}

- (void) interpretLoginScan:(NSString *)scanString
{
    NSArray *terms  = [scanString componentsSeparatedByString:@","];
    if([terms count] > 1)
    {
        if([terms count] > 0) create = [[terms objectAtIndex:0] boolValue];
        
        if(create)
        {
            NSString *groupname;
            
            if([terms count] > 1) groupname   = [terms objectAtIndex:1]; //Group Name
            if([terms count] > 2) quickGameId = [[terms objectAtIndex:2] intValue];
            if([terms count] > 3) museumMode  = [[terms objectAtIndex:3] boolValue];
            
            [[RootViewController sharedRootViewController] showWaitingIndicator:@"Creating User And Logging In..." displayProgressBar:NO];
            [[AppServices sharedAppServices] createUserAndLoginWithGroup:[NSString stringWithFormat:@"%d-%@", quickGameId, groupname]];
        }
        else
        {
            NSString *username;
            NSString *password;
            
            if([terms count] > 1) username    = [terms objectAtIndex:1]; //Username
            if([terms count] > 2) password    = [terms objectAtIndex:2]; //Password
            if([terms count] > 3) quickGameId = [[terms objectAtIndex:3] intValue];
            if([terms count] > 4) museumMode  = [[terms objectAtIndex:4] boolValue];
            
            [[RootViewController sharedRootViewController] showWaitingIndicator:@"Logging In..." displayProgressBar:NO];
            [[AppServices sharedAppServices] loginWithUsername:username password:password];
        }
    }
}

- (void) handleLoginAttempt:(NSNotification *)n
{
    if([AppModel sharedAppModel].playerId) //logged in
    {
        if(create)           [self pickPlayerSettings];
        else if(quickGameId) [self loadQuickGame];
        else                 [self finishLogin];
    }
    else
    {
        [[RootViewController sharedRootViewController] showAlert:NSLocalizedString(@"LoginErrorTitleKey",@"") message:NSLocalizedString(@"LoginErrorMessageKey",@"")];
	}
}

- (void) pickPlayerSettings
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerSettingsPicked:) name:@"PlayerSettingsDismissed" object:nil];
    [[RootViewController sharedRootViewController] displayPlayerSettings];
}

- (void) playerSettingsPicked:(NSNotification *)n
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"PlayerSettingsDismissed" object:nil];
    if(quickGameId) [self loadQuickGame];
    else            [self finishLogin];
}

- (void) loadQuickGame
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(quickGameLoaded:) name:@"NewOneGameGameListReady" object:nil];
    [[AppServices sharedAppServices] fetchOneGameGameList:quickGameId];
}

- (void) quickGameLoaded:(NSNotification *)n
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NewOneGameGameListReady" object:nil];
    if(museumMode) 
        ;
    else 
        ;
    [self finishLogin];
}

- (void) finishLogin
{
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"LoginSuccessful" object:self userInfo:nil]];
}

- (void) zxingController:(ZXingWidgetController*)controller didScanResult:(NSString *)result
{
    [self dismissModalViewControllerAnimated:NO];
    if([result isEqualToString:@"TEST_BUMP"])
    {
        BumpTestViewController *b = [[BumpTestViewController alloc] initWithNibName:@"BumpTestViewController" bundle:nil];
        [self presentViewController:b animated:NO completion:nil];
    }
    else
        [self interpretLoginScan:result];
}

- (void) zxingControllerDidCancel:(ZXingWidgetController*)controller
{
    [self dismissModalViewControllerAnimated:NO];
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
