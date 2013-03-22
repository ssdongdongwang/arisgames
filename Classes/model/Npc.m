//
//  NPC.m
//  ARIS
//
//  Created by David J Gagnon on 9/2/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import "NpcViewController.h"
#import "Npc.h"
#import "AppServices.h"

@implementation Npc

@synthesize npcId;
@synthesize iconMediaId;
@synthesize mediaId;
@synthesize name;
@synthesize ndescription;
@synthesize greeting;
@synthesize closing;

- (int) objectId
{
    return npcId;
}

- (NSString *) objectType
{
    return @"Npc";
}

- (int) iconMediaId
{
	if (iconMediaId == 0) return 1;
	else return iconMediaId;
}

- (int) mediaId
{
	if (mediaId == 0) return 1;
	else return mediaId;
}

- (DisplayObjectViewController *) viewControllerForDisplay
{
	return [[NpcViewController alloc] initWithNpc:self];
}

- (void) wasDisplayed
{
    
}

- (void) finishedDisplay
{
    [[AppServices sharedAppServices] updateServerNpcViewed:npcId fromLocation:nil];
    //Phil should remove "fromLocation". The location get's its own chance to update server
}

- (BOOL) compareTo:(Npc *)other
{
	return other.npcId == self.npcId;
}

- (Npc *) copy
{
    Npc *c = [[Npc alloc] init];
    c.npcId        = self.npcId;
    c.iconMediaId  = self.iconMediaId;
    c.mediaId      = self.mediaId;
    c.name         = self.name;
    c.ndescription = self.ndescription;
    c.greeting     = self.greeting;
    c.closing      = self.closing;
    return c;
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"Npc- Id:%d\tName:%@",self.npcId,self.name];
}

@end
