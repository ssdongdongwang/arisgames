//
//  Player.h
//  ARIS
//
//  Created by David Gagnon on 5/30/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface Player : NSObject {
	NSString *name;
	CLLocation *location;
	BOOL hidden;
}

@property(nonatomic, retain) NSString *name;
@property(nonatomic, retain) CLLocation *location;
@property(readwrite) BOOL hidden;

@end
