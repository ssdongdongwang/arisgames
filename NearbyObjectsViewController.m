//
//  NearbyObjectsViewController.m
//  ARIS
//
//  Created by David J Gagnon on 2/13/11.
//  Copyright 2011 University of Wisconsin. All rights reserved.
//

#import "NearbyObjectsViewController.h"
#import "AppModel.h"
#import "ARISAppDelegate.h"
#import "AppServices.h"
#import "NearbyObjectCell.h"

@implementation NearbyObjectsViewController

@synthesize nearbyLocationsList;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
		self.tabBarItem.image = [UIImage imageNamed:@"73-radar"];
		self.title = NSLocalizedString(@"NearbyObjectsTabKey",@"");
		self.navigationItem.title = NSLocalizedString(@"NearbyObjectsTitleKey",@"");
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshViewFromModel) name:@"PlayerMoved"                        object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshViewFromModel) name:@"NewlyAvailableLocationsAvailable"   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshViewFromModel) name:@"NewlyUnavailableLocationsAvailable" object:nil];
		self.nearbyLocationsList = [NSMutableArray arrayWithCapacity:5];
		forceDisplayQueue = [NSMutableArray arrayWithCapacity:5];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidAppear:(BOOL)animated
{
	[self refresh];
    self.tabBarItem.badgeValue = nil;
}

-(void)dismissTutorial
{
	[[RootViewController sharedRootViewController].tutorialViewController dismissTutorialPopupWithType:tutorialPopupKindNearbyTab];
}

- (void)refresh
{
    [[AppServices sharedAppServices] fetchPlayerLocationList];
}

-(void)refreshViewFromModel
{
    if ([AppModel sharedAppModel].currentlyInteractingWithObject)
        return;
    
    NSMutableArray *newNearbyLocationsList = [NSMutableArray arrayWithCapacity:5];
    
    //Find locations that are "nearby" from the list of all locations
    for(Location *location in [AppModel sharedAppModel].currentGame.locationsModel.currentLocations)
    {
        BOOL match = NO;
        for (Location *oldLocation in self.nearbyLocationsList)
            if (oldLocation.locationId == location.locationId) match = YES;
        if(!match && [[AppModel sharedAppModel].playerLocation distanceFromLocation:location.latlon] < location.errorRange &&
           ([location.object.objectType isEqualToString:@"Item"] || location.qty != 0) && ![location.object.objectType isEqualToString:@"Player"])
            [newNearbyLocationsList addObject:location];
        else if(match && (location.errorRange >= 2147483637 || [[AppModel sharedAppModel].playerLocation distanceFromLocation:location.latlon] < location.errorRange+10) &&
           (![location.object.objectType isEqualToString:@"Item"] || location.qty != 0) && ![location.object.objectType isEqualToString:@"Player"])
            [newNearbyLocationsList addObject:location];
    }
    
    //Find new nearby locations to be force displayed
    for(Location *location in newNearbyLocationsList)
    {
        BOOL match = NO;
        for (Location *oldLocation in self.nearbyLocationsList)
            if (oldLocation.locationId == location.locationId) match = YES;
        for(Location *oldForceDisplay in forceDisplayQueue)
            if(oldForceDisplay.locationId == location.locationId) match = YES;
        if(match == NO && location.forcedDisplay)
            [forceDisplayQueue addObject:location];
    }
    
    //Will refactor this to have a global queue of objects to display. 
    if([forceDisplayQueue count] > 0 && ![AppModel sharedAppModel].currentlyInteractingWithObject)
        [self dequeueForceDisplay];
    
    self.nearbyLocationsList = newNearbyLocationsList;
    
    if ([self.nearbyLocationsList count] == 0)
    {
        self.navigationController.tabBarItem.badgeValue = nil;
        [[RootViewController sharedRootViewController] showNearbyTab:NO];
    }
    else
    {
        self.navigationController.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d",[self.nearbyLocationsList count]];
        [[RootViewController sharedRootViewController] showNearbyTab:YES];
        
        if (![AppModel sharedAppModel].hasSeenNearbyTabTutorial)
        {
            [[RootViewController sharedRootViewController].tutorialViewController showTutorialPopupPointingToTabForViewController:self.navigationController
                                                                                                                             type:tutorialPopupKindNearbyTab
                                                                                                                            title:@"Something Nearby"
                                                                                                                          message:@"There is something nearby! Touch below to see what it is."];
            [AppModel sharedAppModel].hasSeenNearbyTabTutorial = YES;
            [self performSelector:@selector(dismissTutorial) withObject:nil afterDelay:5.0];
        }
    }
    
    [nearbyTable reloadData];
}

- (void)dequeueForceDisplay
{
    [[forceDisplayQueue objectAtIndex:0] display];
    [forceDisplayQueue removeObjectAtIndex:0];
}

#pragma mark UITableView Data Source and Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.nearbyLocationsList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"Cell";
    NearbyObjectCell *cell = (NearbyObjectCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
	if (cell == nil)
    {
		UIViewController *temporaryController = [[UIViewController alloc] initWithNibName:@"NearbyObjectCell" bundle:nil];
		cell = (NearbyObjectCell *)temporaryController.view;
	}
	
	Location *l = [self.nearbyLocationsList objectAtIndex:indexPath.row];
	
	if([l.object.objectType isEqualToString:@"Item"] && l.qty > 1)
        cell.title.text = [NSString stringWithFormat:@"%@ (x%d)",l.name,l.qty];
	else
        cell.title.text = l.name;
	
	Media *iconMedia = [[AppModel sharedAppModel] mediaForMediaId:l.object.iconMediaId];
    [cell.iconView loadImageFromMedia:iconMedia];
    
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	Location *l = [self.nearbyLocationsList objectAtIndex:indexPath.row];
    [[RootViewController sharedRootViewController] display:l.object from:l];
}

@end
