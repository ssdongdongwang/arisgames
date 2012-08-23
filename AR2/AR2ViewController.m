/*
     File: pARkViewController.m
 Abstract: Simple view controller for the pARk example. Provides a hard-coded list of places-of-interest to its associated ARView when loaded, starts the ARView when it appears, and stops it when it disappears.
  Version: 1.0
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2011 Apple Inc. All Rights Reserved.
 
 */

#import "AR2ViewController.h"
#import "PlaceOfInterest.h"
#import "AR2View.h"

#import "AsyncMediaImageView.h"
#import "AsyncMediaPlayerButton.h"
#import "NearbyObjectARCoordinate.h"
#import "Location.h"


#import <CoreLocation/CoreLocation.h>

@implementation AR2ViewController

@synthesize playerViewController = _playerViewController;
@synthesize placesOfInterest = _placesOfInterest;

//Override init for passing title and icon to tab bar
- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
    self = [super initWithNibName:nibName bundle:nibBundle];
    if (self) {
        self.title = NSLocalizedString(@"ARViewTitleKey",@"");
        self.tabBarItem.image = [UIImage imageNamed:@"camera.png"];
    }
    NSLog(@"=-=-=-= %@", [self description]);
    return self;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];
	AR2View *arView = (AR2View *)self.view;
	NSLog(@"ARVIEW ::: %@", [arView description]);		
    
    //Init with the nearby locations in the model
	NSMutableArray *tempLocationArray = [[NSMutableArray alloc] initWithCapacity:10];
	
	NearbyObjectARCoordinate *tempCoordinate;
    
    for (Location *nbl in [AppModel sharedAppModel].nearbyLocationsList) {
        
        NSLog(@"nbl desc.: %@", [nbl description]);
        
    }
        
    NSLog(@"nearby: %@", [AppModel sharedAppModel].nearbyLocationsList);
	for ( Location *nearbyLocation in [AppModel sharedAppModel].nearbyLocationsList ) {
        
        NSLog(@"type: %@", nearbyLocation.objectType);
        NSLog(@"kind: %lu", nearbyLocation.kind);
        
        if (nearbyLocation.kind == NearbyObjectNode) {
        
            tempCoordinate = [NearbyObjectARCoordinate coordinateWithNearbyLocation: nearbyLocation];
//            if (nearbyLocation.kind == NearbyObjectNode) {
                tempCoordinate.node = (Node*)nearbyLocation.object;
//            }
            [tempLocationArray addObject:tempCoordinate];
            NSLog(@"AR2ViewController: Added %@", tempCoordinate.title);
            
        }
	}

    self.placesOfInterest = [NSMutableArray arrayWithCapacity:[tempLocationArray count]];
    int t = 0;
    NSLog(@"temp loc array: %@", tempLocationArray);
    for (NearbyObjectARCoordinate *noc in tempLocationArray) {
        
//        UIView *movieView = [[UIView alloc] initWithFrame:CGRectZero];
//        MPMoviePlayerController *mpc = [[MPMoviePlayerController alloc] init];
        
        if (noc.node.kind == NearbyObjectNode) {
        
        NSLog(@"displaying(?) node id: %i, %lu", noc.node.nodeId, noc.node.kind);
        
            Media *m = [[AppModel sharedAppModel] mediaForMediaId:noc.node.mediaId];
            NSLog(@"M TYPE: %@", m.type);
            if ([m.type compare:@"Image"] == NSOrderedSame) {
                
                NSLog(@"ITEM!");
                AsyncMediaImageView *imgView = [[AsyncMediaImageView alloc] initWithFrame:CGRectZero andMedia:[[AppModel sharedAppModel] mediaForMediaId:noc.node.mediaId]];
                
                imgView.frame = CGRectMake(0, 0, 200, 200);
                
                PlaceOfInterest *poi = [PlaceOfInterest placeOfInterestWithView:imgView at:[[[CLLocation alloc] initWithLatitude:noc.geoLocation.coordinate.latitude longitude:noc.geoLocation.coordinate.longitude] autorelease]];

                [self.placesOfInterest insertObject:poi atIndex:t];
                t++;

            } else if ([m.type compare:@"Video"] == NSOrderedSame) {
                
                AsyncMediaPlayerButton *player = [[AsyncMediaPlayerButton alloc] initWithFrame:CGRectZero media:[[AppModel sharedAppModel] mediaForMediaId:noc.node.mediaId] presentingController:self];

                player.frame = CGRectMake(0, 0, 200, 200);
            
                NSLog(@"player: %i: %@", t, player);
                NSLog(@"player: %f, %f", noc.geoLocation.coordinate.latitude, noc.geoLocation.coordinate.longitude);
                
                PlaceOfInterest *poi = [PlaceOfInterest placeOfInterestWithView:player at:[[[CLLocation alloc] initWithLatitude:noc.geoLocation.coordinate.latitude longitude:noc.geoLocation.coordinate.longitude] autorelease]];
                [self.placesOfInterest insertObject:poi atIndex:t];
                NSLog(@"pois: %@", self.placesOfInterest);
                t++;
            }
        }
    }
    NSLog(@"ar view: %@", [arView description]);
    [(AR2View *)arView setPlacesOfInterest:self.placesOfInterest];	
    
}

//- (void)playMovieForTag:(int)tag {
//    for (PlaceOfInterest *poi in self.placesOfInterest) {
//        if ([poi.view viewWithTag:tag] != nil) {
//            [poi.view viewWithTag:tag] superview
//        }
//    }
//}
             
- (void)freezeVideo:(UIButton *)button {
        
    NSLog(@"freezeVideo called (tag: %i)", button.tag);
    if (button.tag >= 1000) {
        
        NSLog(@"movie view: %@", button.superview.description);
        
        int index = button.tag - 1000;
        PlaceOfInterest *poi = [self.placesOfInterest objectAtIndex:index];
        
        poi.frozen = !poi.frozen;
        
    }
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	AR2View *arView = (AR2View *)self.view;
	[arView start];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	AR2View *arView = (AR2View *)self.view;
	[arView stop];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return interfaceOrientation == UIInterfaceOrientationPortrait;
}

@end
