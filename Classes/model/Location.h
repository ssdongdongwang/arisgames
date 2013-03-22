//
//  Location.h
//  ARIS
//
//  Created by David Gagnon on 2/26/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "DisplayObjectProtocol.h"
#import "LocationObjectProtocol.h"

@interface Location : NSObject <MKAnnotation, DisplayOriginProtocol>
{
    int locationId;
    NSObject<DisplayableObjectProtocol, LocationObjectProtocol> *object;
	NSString *name;
	CLLocation *latlon;
    int qty;
	int errorRange;
	bool hidden;
	bool forcedDisplay;
	bool allowsQuickTravel;
    bool showTitle;
    bool wiggle;
    bool deleteWhenViewed;
}

@property (nonatomic, assign) int locationId;
@property (nonatomic, strong) NSObject<DisplayableObjectProtocol, LocationObjectProtocol> *object;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) CLLocation *latlon;
@property (nonatomic, assign) int qty;
@property (nonatomic, assign) int errorRange;
@property (nonatomic, assign) bool hidden;
@property (nonatomic, assign) bool forcedDisplay;
@property (nonatomic, assign) bool allowsQuickTravel;
@property (nonatomic, assign) bool showTitle;
@property (nonatomic, assign) bool wiggle;
@property (nonatomic, assign) bool deleteWhenViewed;

- (Location *) initFromDictionary:(NSDictionary *)d;
- (BOOL) compareTo:(Location *)other;
- (Location *) copy;

@end
