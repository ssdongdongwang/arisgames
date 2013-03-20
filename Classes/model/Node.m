//
//  Node.m
//  ARIS
//
//  Created by David J Gagnon on 8/31/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import "Node.h"
#import "NodeViewController.h"
#import "AppServices.h"

@implementation Node

@synthesize nodeId;
@synthesize iconMediaId;
@synthesize mediaId;
@synthesize name;
@synthesize text;

- (int) objectId
{
    return nodeId;
}

- (NSString *) objectType
{
    return @"Node";
}

- (int) iconMediaId
{
	if (iconMediaId == 0) return 3;
	else return iconMediaId;
}

- (int) mediaId
{
	if (mediaId == 0) return 3;
	else return mediaId;
}

- (DisplayObjectViewController *) viewControllerForDisplay
{
	return [[NodeViewController alloc] initWithNode:self];
}

- (void) wasDisplayed
{
    
}

- (void) finishedDisplay
{
    [[AppServices sharedAppServices] updateServerItemViewed:nodeId fromLocation:nil];
    //Phil should remove "fromLocation". The location get's its own chance to update server
}

- (BOOL) compareTo:(Node *)other
{
	return other.nodeId == self.nodeId;
}

- (Node *) copy
{
    Node *c = [[Node alloc] init];
    c.nodeId      = self.nodeId;
    c.iconMediaId = self.iconMediaId;
    c.mediaId     = self.mediaId;
    c.name        = self.name;
    c.text        = self.text;
    return c;
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"Node- Id:%d\tName:%@",self.nodeId,self.name];
}

@end
