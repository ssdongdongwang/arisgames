//
//  GPSViewController.m
//  ARIS
//
//  Created by Ben Longoria on 2/11/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import "GPSViewController.h"
#import "AppModel.h"
#import "Location.h"
#import "Player.h"
#import "ARISAppDelegate.h"
#import "AnnotationView.h"
#import "Media.h"
#import "Annotation.h"


//static int DEFAULT_ZOOM = 16;
//static float INITIAL_SPAN = 0.001;

@implementation GPSViewController

@synthesize locations;
@synthesize autoCenter;


//Override init for passing title and icon to tab bar
- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
    self = [super initWithNibName:nibName bundle:nibBundle];
    if (self) {
        self.title = @"GPS";
        self.tabBarItem.image = [UIImage imageNamed:@"gps.png"];
		appModel = [(ARISAppDelegate *)[[UIApplication sharedApplication] delegate] appModel];
		silenceNextServerUpdate = YES;
		autoCenter = YES;
		
		//register for notifications
		NSNotificationCenter *dispatcher = [NSNotificationCenter defaultCenter];
		[dispatcher addObserver:self selector:@selector(refresh) name:@"PlayerMoved" object:nil];
		[dispatcher addObserver:self selector:@selector(refreshViewFromModel) name:@"ReceivedLocationList" object:nil];
		[dispatcher addObserver:self selector:@selector(processNearbyLocationsList:) name:@"ReceivedNearbyLocationList" object:nil];
		[dispatcher addObserver:self selector:@selector(silenceNextUpdate) name:@"SilentNextUpdate" object:nil];
		[dispatcher addObserver:self selector:@selector(movieFinishedPreloading:) name:MPMoviePlayerContentPreloadDidFinishNotification object:nil];
		[dispatcher addObserver:self selector:@selector(movieFinishedPlayback:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
		
		//create a time for automatic map refresh
		NSTimer *refreshTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(refresh) userInfo:nil repeats:YES];
	}
	
    return self;
}

- (void)silenceNextUpdate {
	silenceNextServerUpdate = YES;
}
		
- (IBAction)mainButtonTouchAction{
	NSLog(@"GPSViewController: Main Button Touched");
	if (somethingNearby) {
		NSLog(@"GPSViewController: Display the closest object");
		if ([mMoviePlayer respondsToSelector:@selector(view)]) mMoviePlayer.view.hidden = NO;
		mainButton.hidden = YES;
		[mMoviePlayer play];
	}
	else {
		NSLog(@"GPSViewController: Launch the recorder");
		//launch the recorder
		AudioRecorderViewController *audioRecorderVC = [[AudioRecorderViewController alloc] initWithNibName:@"AudioRecorderViewController" bundle:nil];
		[self.view addSubview:audioRecorderVC.view];
	}

}


- (void)movieFinishedCallback:(NSNotification*) aNotification
{
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:MPMoviePlayerPlaybackDidFinishNotification
												  object:mMoviePlayer];
	[self dismissMoviePlayerViewControllerAnimated];
}



- (void)processNearbyLocationsList:(NSNotification *)notification {
    NSLog(@"GPSViewController: Recieved a Nearby Locations List Notification");
	NSArray *nearbyLocations = notification.object;
	
	bool nearbyLocationsThatAreNotPlayersExist = NO;
	for (NSObject <NearbyObjectProtocol> *curLocation in nearbyLocations) {
		if ([curLocation kind] != NearbyObjectPlayer) nearbyLocationsThatAreNotPlayersExist = YES;
	}
	
	if (!nearbyLocationsThatAreNotPlayersExist) { 
		NSLog(@"GPSViewController: No nearby Locations");
		[mainButton setTitle: @"Record" forState: UIControlStateNormal];
		[mainButton setTitle: @"Record" forState: UIControlStateHighlighted];	

		lastNearbyLocation = nil;
		
		somethingNearby = NO;
		if ([mMoviePlayer respondsToSelector:@selector(view)]) [mMoviePlayer.view removeFromSuperview];
		
		[spinner stopAnimating];
		[spinner removeFromSuperview];
		mainButton.enabled = YES;
	
		return;
	}
	
	else {
		NSLog(@"GPSViewController: Atleast one nearby Location");
				
		somethingNearby = YES;
		
		double bestDist = INFINITY;
		Location *bestLocation;
		
		//Get the closest location
		for (Location *curLocation in appModel.locationList) {
			if (curLocation.kind == NearbyObjectPlayer) continue;
			double curDist = [curLocation.location getDistanceFrom:appModel.playerLocation];
			if ( curDist < bestDist) {
				bestDist = curDist;
				bestLocation = curLocation;
			}
		}
		
		if (bestLocation.locationId != lastNearbyLocation.locationId) {
			[lastNearbyLocation release];
			lastNearbyLocation = bestLocation;
			[lastNearbyLocation retain];
			ARISAppDelegate* appDelegate = (ARISAppDelegate *)[[UIApplication sharedApplication] delegate];
			[appDelegate playAudioAlert:@"bikeBell" shouldVibrate:YES];
			
			int mediaId;
			
			switch (bestLocation.kind) {
				case NearbyObjectItem:
					NSLog(@"It was an Item");
					Item *item = [appModel fetchItem:bestLocation.objectId]; 
					mediaId = item.mediaId;
					break;
				case NearbyObjectNode:
					NSLog(@"It was a Node");
					Node *node = [appModel fetchNode:bestLocation.objectId]; 
					mediaId = node.mediaId;
					break;	
				default:
					break;
			}
			
			Media *media = [appModel mediaForMediaId:mediaId];
			
			//Create movie player object
			if (mMoviePlayer) {
				if ([mMoviePlayer respondsToSelector:@selector(view)]) [mMoviePlayer.view removeFromSuperview];
				[mMoviePlayer release];
			}
			
			mMoviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:media.url]];
			
			if ([mMoviePlayer respondsToSelector:@selector(view)]) {
				[mMoviePlayer setFullscreen:NO]; 
				[mMoviePlayer.view setFrame:CGRectMake(10, 415, 300, 20)];
				[mMoviePlayer prepareToPlay];
				mMoviePlayer.view.hidden = YES;
				[self.view addSubview:mMoviePlayer.view];
			}
			
			[mainButton setTitle: @"Preparing to Play" forState: UIControlStateNormal];
			[mainButton setTitle: @"Preparing to Play" forState: UIControlStateHighlighted];	
			mainButton.enabled = NO;
			[mainButton addSubview:spinner];
			spinner.frame = CGRectMake(40, 8, 20, 20);
			[spinner startAnimating];			

		}	

		return;
	}
	
}



- (IBAction)changeMapType: (id) sender {
	ARISAppDelegate* appDelegate = (ARISAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate playAudioAlert:@"ticktick" shouldVibrate:NO];
	
	switch (mapView.mapType) {
		case MKMapTypeStandard:
			mapView.mapType=MKMapTypeSatellite;
			break;
		case MKMapTypeSatellite:
			mapView.mapType=MKMapTypeHybrid;
			break;
		case MKMapTypeHybrid:
			mapView.mapType=MKMapTypeStandard;
			break;
	}
}

- (IBAction)refreshButtonAction: (id) sender{
	NSLog(@"GPSViewController: Refresh Button Touched");
	
	ARISAppDelegate* appDelegate = (ARISAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate playAudioAlert:@"ticktick" shouldVibrate:NO];
	
	
	//Force a location update
	[appDelegate.myCLController.locationManager stopUpdatingLocation];
	[appDelegate.myCLController.locationManager startUpdatingLocation];

	//Rerfresh all contents
	[self refresh];

}
		
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	NSLog(@"Begin Loading GPS View");

	//Setup the Map	
	NSLog(@"GPSViewController: Mapview about to be inited.");
	MKCoordinateRegion region = mapView.region;
	region.span.latitudeDelta=0.001;
	region.span.longitudeDelta=0.001;
	[mapView setRegion:region animated:NO];
	[mapView regionThatFits:region];
	mapView.showsUserLocation = YES;
	[mapView setDelegate:self]; //View will request annotation views from us
	NSLog(@"GPSViewController: Mapview inited and added to view");
	
	//Force an update of the locations
	[appModel forceUpdateOnNextLocationListFetch];
	
	spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];

	[self refresh];	
	
	

	NSLog(@"GPSViewController: View Loaded");
}

- (void)viewDidAppear:(BOOL)animated {
	NSLog(@"GPSVC viewDidAppear: Refreshing");
	[self refresh];		
	
	//remove any existing badge
	self.tabBarItem.badgeValue = nil;
	
}


// Updates the map to current data for player and locations from the server
- (void) refresh {
	if (mapView) {
		NSLog(@"GPSViewController: refresh requested");	
	
		[appModel fetchLocationList];
	
		//Zoom and Center
		[self zoomAndCenterMap];
	} else {
		NSLog(@"GPSViewController: refresh requested but ignored, as mapview is nil");	
		
	}
}

-(void) zoomAndCenterMap {
	
	//Center the map on the player
	MKCoordinateRegion region = mapView.region;
	region.center = appModel.playerLocation.coordinate;
	[mapView setRegion:region animated:YES];
	
	//Set to default zoom
	//mapView.contents.zoom = DEFAULT_ZOOM;
}



- (void)refreshViewFromModel {
	if (mapView) {
		//only refresh if there's a mapview
		NSLog(@"GPSViewController: Refreshing view from model");
	
	
		//Add a badge if this is NOT the first time data has been loaded
		if (silenceNextServerUpdate == NO) {
			self.tabBarItem.badgeValue = @"!";
		}
		else silenceNextServerUpdate = NO;
	
		//Blow away the old markers except for the player marker
		NSEnumerator *existingAnnotationsEnumerator = [[[mapView annotations] copy] objectEnumerator];
		NSObject <MKAnnotation> *annotation;
		while (annotation = [existingAnnotationsEnumerator nextObject]) {
			if (annotation != mapView.userLocation) [mapView removeAnnotation:annotation];
		}
	
		locations = appModel.locationList;
	
		//Add the freshly loaded locations from the notification
		for ( Location* location in locations ) {
			NSLog(@"GPSViewController: Adding location annotation for:%@ id:%d", location.name, location.locationId);
			if (location.hidden == YES) 
			{
				NSLog(@"No I'm not, because this location is hidden.");
				continue;
			}
			CLLocationCoordinate2D locationLatLong = location.location.coordinate;
			
			Annotation *annotation = [[Annotation alloc]initWithCoordinate:locationLatLong];
			
			annotation.title = location.name;
			//if (location.kind == NearbyObjectItem) annotation.subtitle = [NSString stringWithFormat:@"Quantity: %d",location.qty];
			NSLog(@"GPSViewController: Annotation title is %@; subtitle is %@.", annotation.title, annotation.subtitle);
			
			annotation.iconMediaId = location.iconMediaId; //if we have a custom icon
			annotation.kind = location.kind; //if we want a default icon

			[mapView addAnnotation:annotation];
			if (!mapView) {
				NSLog(@"GPSViewController: Just added an annotation to a null mapview!");
			}
			
			[annotation release];
		}
		
		//Add the freshly loaded players from the notification
		for ( Player *player in appModel.playerList ) {
			if (player.hidden == YES) continue;
			CLLocationCoordinate2D locationLatLong = player.location.coordinate;

			Annotation *aPlayer = [[Annotation alloc]initWithCoordinate:locationLatLong];
			aPlayer.title = player.name;
			[mapView addAnnotation:aPlayer];
			[aPlayer release];
		} 
	} else {
		NSLog(@"GPSViewController: Refresh requested but ignored, as mapview is nil.");
	}
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void)dealloc {
	[appModel release];
    [super dealloc];
}

-(void)movieFinishedPreloading:(NSNotification*)notification
{
	NSLog(@"Preloading Complete");
	[mainButton setTitle: @"Play" forState: UIControlStateNormal];
	[mainButton setTitle: @"Play" forState: UIControlStateHighlighted];
	[spinner stopAnimating];
	[spinner removeFromSuperview];
	mainButton.enabled = YES;
	
	

}

-(void)movieFinishedPlayback:(NSNotification*)notification
{
	NSLog(@"Playback Complete");
	if ([mMoviePlayer respondsToSelector:@selector(view)]) mMoviePlayer.view.hidden = YES;
	mainButton.hidden = NO;

}




-(UIImage *)addTitle:(NSString *)imageTitle quantity:(int)quantity toImage:(UIImage *)img {
	
	NSString *calloutString;
	if (quantity > 1) {
		calloutString = [NSString stringWithFormat:@"%@:%d",imageTitle, quantity];
	} else {
		calloutString = imageTitle;
	}
 	UIFont *myFont = [UIFont fontWithName:@"Arial" size:12];
	CGSize textSize = [calloutString sizeWithFont:myFont];
	CGRect textRect = CGRectMake(0, 0, textSize.width + 10, textSize.height);
	
	//callout path
	CGMutablePathRef calloutPath = CGPathCreateMutable();
	CGPoint pointerPoint = CGPointMake(textRect.origin.x + 0.6 * textRect.size.width,  textRect.origin.y + textRect.size.height + 5);
	CGPathMoveToPoint(calloutPath, NULL, textRect.origin.x, textRect.origin.y);
	CGPathAddLineToPoint(calloutPath, NULL, textRect.origin.x, textRect.origin.y + textRect.size.height);
	CGPathAddLineToPoint(calloutPath, NULL, pointerPoint.x - 5.0, textRect.origin.y + textRect.size.height);
	CGPathAddLineToPoint(calloutPath, NULL, pointerPoint.x, pointerPoint.y);
	CGPathAddLineToPoint(calloutPath, NULL, pointerPoint.x + 5.0, textRect.origin.y+ textRect.size.height);
	CGPathAddLineToPoint(calloutPath, NULL, textRect.origin.x + textRect.size.width, textRect.origin.y + textRect.size.height);
	CGPathAddLineToPoint(calloutPath, NULL, textRect.origin.x + textRect.size.width, textRect.origin.y);
	CGPathAddLineToPoint(calloutPath, NULL, textRect.origin.x, textRect.origin.y);
	
	
	
	CGRect imageRect = CGRectMake(0, textSize.height + 10.0, img.size.width, img.size.height);
	CGRect backgroundRect = CGRectUnion(textRect, imageRect);
	if (backgroundRect.size.width > img.size.width) {
		imageRect.origin.x = (backgroundRect.size.width - img.size.width) / 2.0;
	}
	
	CGSize contextSize = backgroundRect.size;
	UIGraphicsBeginImageContext(contextSize);
	CGContextAddPath(UIGraphicsGetCurrentContext(), calloutPath);
	[[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.6] set];
	CGContextFillPath(UIGraphicsGetCurrentContext());
	[[UIColor blackColor] set];
	CGContextAddPath(UIGraphicsGetCurrentContext(), calloutPath);
	CGContextStrokePath(UIGraphicsGetCurrentContext());
	[img drawAtPoint:imageRect.origin];
	[calloutString drawInRect:textRect withFont:myFont lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentCenter];
	UIImage *returnImage = UIGraphicsGetImageFromCurrentImageContext();
	CGPathRelease(calloutPath);
	UIGraphicsEndImageContext();
	
	return returnImage;
}


//-(UIImage *)addText:(NSString *)text1 toImage:(UIImage *)img {
//    int w = img.size.width;
//    int h = img.size.height; 
//    //lon = h - lon;
//    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//    CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace, kCGImageAlphaPremultipliedFirst);
//    
//    CGContextDrawImage(context, CGRectMake(0, 0, w, h), img.CGImage);
//    CGContextSetRGBFillColor(context, 0.0, 0.0, 1.0, 1);
//	
//    char* text	= (char *)[text1 cStringUsingEncoding:NSASCIIStringEncoding];// "05/05/09";
//    CGContextSelectFont(context, "Arial", 18, kCGEncodingMacRoman);
//    CGContextSetTextDrawingMode(context, kCGTextFill);
//    CGContextSetRGBFillColor(context, 255, 255, 255, 1);
//	
//	
//    //rotate text
//    CGContextSetTextMatrix(context, CGAffineTransformMakeRotation( -M_PI/4 ));
//	
//    CGContextShowTextAtPoint(context, 4, 52, text, strlen(text));
//	
//	
//    CGImageRef imageMasked = CGBitmapContextCreateImage(context);
//    CGContextRelease(context);
//    CGColorSpaceRelease(colorSpace);
//	
//    return [UIImage imageWithCGImage:imageMasked];
//}
//
#pragma mark Views for annotations

- (MKAnnotationView *)mapView:(MKMapView *)myMapView viewForAnnotation:(Annotation*) annotation{
	NSLog(@"GPSViewController: In viewForAnnotation");

	
	//Player
	if (annotation == mapView.userLocation)
	{
		NSLog(@"GPSViewController: Getting the annotation view for the user's location");
		 return nil; //Let it do it's own thing
	}
	
	//Other Players
	if ([annotation kind] == NearbyObjectPlayer) {
		NSLog(@"GPSViewController: Getting the annotation view for another player: %@", annotation.title);

		MKAnnotationView *playerAnnotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"OtherPlayerAnnotation"];
		playerAnnotationView.image = [UIImage imageNamed:@"player.png"];
		playerAnnotationView.canShowCallout = YES;
		return playerAnnotationView;	
	} 

	MKAnnotationView *annotationView=[[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"marker"];
	annotationView.image = [UIImage imageNamed:@"item.png"];
	annotationView.canShowCallout = YES;
	return annotationView;


}


@end
