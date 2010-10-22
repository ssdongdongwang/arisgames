//
//  ARISAppDelegate.m
//  ARIS
//
//  Created by Ben Longoria on 2/11/09.
//  Copyright University of Wisconsin 2009. All rights reserved.
//

#import "ARISAppDelegate.h"
#import "Node.h"

@implementation ARISAppDelegate

@synthesize appModel;
@synthesize window;
@synthesize tabBarController;
@synthesize loginViewController;
@synthesize nearbyBar;
@synthesize nearbyObjectNavigationController;
@synthesize myCLController;
@synthesize waitingIndicator;
@synthesize networkAlert;

//@synthesize toolbarViewController;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	
	//Don't sleep
	application.idleTimerDisabled = YES;
	
	//init app model
	appModel = [[AppModel alloc] init];
	//appModel.baseAppURL = @"http://davembp.local/server/";
	appModel.baseAppURL = @"http://arisgames.org/stagingserver1/";

	NSURL *url = [NSURL URLWithString:appModel.baseAppURL];
	appModel.serverName = [NSString stringWithFormat:@"http://%@:%d", [url host], 
					   ([url port] ? [[url port] intValue] : 80)];
	appModel.jsonServerBaseURL = [NSString stringWithFormat:@"%@%@",
							  appModel.baseAppURL, @"json.php/aris"];	
	appModel.gameId = 200;
	[appModel retain];
	
	
	//Check for Internet conductivity
	NSLog(@"AppDelegate: Verifying Connection to: %@",appModel.baseAppURL);
	Reachability *r = [Reachability reachabilityWithHostName:@"arisgames.org"];
	NetworkStatus internetStatus = [r currentReachabilityStatus];
	BOOL connection = (internetStatus == ReachableViaWiFi) || (internetStatus == ReachableViaWWAN);
	//connection = YES; //For debugging locally
	if (!connection) {
		NSLog(@"AppDelegate: Internet Connection Failed");
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"No connection to the Internet" message: @"Please connect to the internet and restart Bike Box" delegate: self cancelButtonTitle: nil otherButtonTitles: nil];
		[alert show];
		[alert release];
		return;
	} else {
		NSLog(@"AppDelegate: Internet Connection Functional");
	}
	
	//register for notifications from views
	NSNotificationCenter *dispatcher = [NSNotificationCenter defaultCenter];
	[dispatcher addObserver:self selector:@selector(performUserLogin:) name:@"PerformUserLogin" object:nil];
	[dispatcher addObserver:self selector:@selector(selectGame:) name:@"SelectGame" object:nil];
	[dispatcher addObserver:self selector:@selector(performLogout:) name:@"LogoutRequested" object:nil];
	[dispatcher addObserver:self selector:@selector(displayNearbyObjects:) name:@"NearbyButtonTouched" object:nil];

	//Setup GPS View
	GPSViewController *gpsViewController = [[GPSViewController alloc] initWithNibName:@"GPS" bundle:nil];


	//Setup Audio Recorder View
	AudioRecorderViewController *audioRecorderViewController = [[AudioRecorderViewController alloc] initWithNibName:@"AudioRecorderViewController" bundle:nil];


	

	[loginViewController retain]; //This view may be removed and readded to the window

	//Login View
	loginViewController = [[[LoginViewController alloc] initWithNibName:@"Login" bundle:nil] autorelease];
	[loginViewController setModel:appModel];
	loginViewController.view.frame = CGRectMake(0,20,320,460);
	[loginViewController retain];

	gpsViewController.view.frame = CGRectMake(0,20,320,460);
	[window addSubview:gpsViewController.view];
	[gpsViewController release];


	
	//Setup Location Manager
	myCLController = [[MyCLController alloc] initWithAppModel:appModel];
	[myCLController.locationManager startUpdatingLocation];
		
	//Display the login screen if this user is not logged in
	if (appModel.loggedIn == YES) {
	}
	else {
		NSLog(@"Appdelegate: Player not logged in, display login");
		[window addSubview:loginViewController.view];
	}
	
}


- (void) showNetworkAlert{
	NSLog (@"AppDelegate: Showing Network Alert");
	
	if (!self.networkAlert) {
		networkAlert = [[UIAlertView alloc] initWithTitle:@"Network Warning" message:
						@"Your internet connection is slow or unreliable."
												 delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
	}
	
	if (self.networkAlert.visible == NO) [networkAlert show];
		
}

- (void) removeNetworkAlert {
	NSLog (@"AppDelegate: Removing Network Alert");
	
	if (self.networkAlert != nil) {
		[self.networkAlert dismissWithClickedButtonIndex:0 animated:YES];
	}
	

}




- (void) showWaitingIndicator:(NSString *)message displayProgressBar:(BOOL)displayProgressBar {
	NSLog (@"AppDelegate: Showing Waiting Indicator");
	if (!self.waitingIndicator) {
		self.waitingIndicator = [[WaitingIndicatorViewController alloc] initWithNibName:@"WaitingIndicator" bundle:nil];
	}
	self.waitingIndicator.message = message;
	self.waitingIndicator.progressView.hidden = !displayProgressBar;
	
	//by adding a subview to window, we make sure it is put on top
	if (appModel.loggedIn == YES) [self.window addSubview:self.waitingIndicator.view]; 

}

- (void) removeWaitingIndicator {
	NSLog (@"AppDelegate: Removing Waiting Indicator");
	if (self.waitingIndicator != nil) [self.waitingIndicator.view removeFromSuperview ];
}

- (void) playAudioAlert:(NSString*)wavFileName shouldVibrate:(BOOL)shouldVibrate{
	NSLog(@"AppDelegate: Playing an audio Alert sound");
	
	//Vibrate
	if (shouldVibrate == YES) [NSThread detachNewThreadSelector:@selector(vibrate) toTarget:self withObject:nil];	
	//Play the sound on a background thread
	[NSThread detachNewThreadSelector:@selector(playAudio:) toTarget:self withObject:wavFileName];
}

//Play a sound
- (void) playAudio:(NSString*)wavFileName {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];  

	
	AVAudioPlayer *player;
	NSString *soundPath = [[NSBundle mainBundle] pathForResource:wavFileName ofType:@"wav"];
	player =[[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath: soundPath] error:nil];
	[soundPath release];
	player.volume = 1.0;
	player.numberOfLoops = 0;
	[player prepareToPlay];
	[player play];
				  
	[pool release];
}

//Vibrate
- (void) vibrate {
	AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);  
}



- (void)newError: (NSString *)text {
	NSLog(@"%@", text);
}

- (void)displayNearbyObjectView:(UIViewController *)nearbyObjectViewController {
	//Hide the nearby bar
	nearbyBar.hidden = YES;
	
	//nearbyObjectNavigationController = [[UINavigationController alloc] initWithRootViewController:nearbyObjectViewController];
	//nearbyObjectNavigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
		
	//Display
	[window addSubview:nearbyObjectViewController.view];
}




- (void)performUserLogin:(NSNotification *)notification {
	NSLog(@"AppDelegate: Login Requested");
	
	NSDictionary *userInfo = notification.userInfo;
	
	NSLog(@"AppDelegate: Perform Login for: %@ Paswword: %@", [userInfo objectForKey:@"username"], [userInfo objectForKey:@"password"]);
	appModel.username = [userInfo objectForKey:@"username"];
	appModel.password = [userInfo objectForKey:@"password"];

	[appModel login];
	
	//handle login response
	if(appModel.loggedIn) {
		NSLog(@"AppDelegate: Login Success");
		[loginViewController.view removeFromSuperview];
		[appModel updateServerGameSelected];
		[appModel fetchMediaList];
		[appModel fetchLocationList];
	} 
	else {
		NSLog(@"AppDelegate: Login Failed, check for a network issue");
		if (self.networkAlert) NSLog(@"AppDelegate: Network is down, skip login alert");
		else {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Invalid username or password."
														   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
			[alert show];	
			[alert release];
		}

		
	}
	
}





#pragma mark Tab Bar delegate

// A Player selected a tab from the tab bar
- (void)tabBarController:(UITabBarController *)tabController didSelectViewController:(UIViewController *)viewController {
		
	UINavigationController *navigationController;
	UIViewController *visibleViewController;
	
	//Get the naviation controller and visible view controller
	if ([viewController isKindOfClass:[UINavigationController class]]) {
		navigationController = (UINavigationController*)viewController;
		visibleViewController = [navigationController visibleViewController];
	}
	else {
		navigationController = nil;
		visibleViewController = viewController;
	}
	
	NSLog(@"AppDelegate: %@ selected",[visibleViewController title]);
	
	//Hides the existing Controller
	UIViewController *selViewController = [tabBarController selectedViewController];
	[selViewController.navigationController.view removeFromSuperview];
	
	[self playAudioAlert:@"click" shouldVibrate:NO];
	
}


#pragma mark navigation controller delegate
- (void)navigationController:(UINavigationController *)navigationController 
	   didShowViewController:(UIViewController *)viewController 
					animated:(BOOL)animated {
	
}

#pragma mark Memory Management

-(void) applicationWillTerminate:(UIApplication *)application {
	NSLog(@"Begin Application Termination");
	
}

- (void)dealloc {
	[appModel release];
	[super dealloc];
}
@end

