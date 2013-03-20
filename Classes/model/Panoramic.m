//
//  Panoramic.m
//  ARIS
//
//  Created by Brian Thiel on 6/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Panoramic.h"
#import "PanoramicViewController.h"
#import "AppServices.h"

@implementation Panoramic

@synthesize panoramicId;
@synthesize iconMediaId;
@synthesize alignMediaId;
@synthesize name;
@synthesize description;
@synthesize textureArray;
@synthesize mediaArray;

- (int) objectId
{
    return panoramicId;
}

- (NSString *) objectType
{
    return @"Panoramic";
}

- (int) iconMediaId
{
	if (iconMediaId == 0) return 5;
	else return iconMediaId;
}

- (DisplayObjectViewController *) viewControllerForDisplay
{
	return [[PanoramicViewController alloc] initWithPanoramic:self];
}

- (void) wasDisplayed
{
    
}

- (void) finishedDisplay
{
    [[AppServices sharedAppServices] updateServerItemViewed:panoramicId fromLocation:nil];
    //Phil should remove "fromLocation". The location get's its own chance to update server
}

- (BOOL) compareTo:(Panoramic *)other
{
	return other.panoramicId == self.panoramicId;
}

- (Panoramic *) copy
{
    Panoramic *c = [[Panoramic alloc] init];
    c.panoramicId  = self.panoramicId;
    c.iconMediaId  = self.iconMediaId;
    c.alignMediaId = self.alignMediaId;
    c.name         = self.name;
    c.description  = self.description;
    c.textureArray = [self.textureArray copy];
    c.mediaArray   = [self.mediaArray copy];
    return c;
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"Panoramic- Id:%d\tName:%@",self.panoramicId,self.name];
}

@end
