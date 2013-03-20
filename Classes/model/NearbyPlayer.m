//
//  NearbyPlayer.m
//  ARIS
//
//  Created by Phil Dougherty on 3/19/13.
//
//

#import "NearbyPlayer.h"

@implementation NearbyPlayer

@synthesize playerId;
@synthesize name;

- (int) objectId
{
    return playerId;
}

- (NSString *) objectType
{
    return @"Player";
}

- (int) iconMediaId
{
	return 2;
}


@end
