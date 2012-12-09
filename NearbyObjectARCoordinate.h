//
//  NearbyObjectARCoordinate.h
//  ARIS
//
//  Created by David J Gagnon on 12/6/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ARGeoCoordinate.h"
#import "Location.h"
#import "Node.h"


@interface NearbyObjectARCoordinate : ARGeoCoordinate {
	int mediaId;
}

@property(readwrite, assign) int mediaId;
// POSSIBLE CHANGE MADE
@property(readwrite, assign) Node *node;
// CHANGE MADE
@property(readwrite, assign) Location *loc;

+ (NearbyObjectARCoordinate *)coordinateWithNearbyLocation:(Location *)aNearbyLocation;


@end
