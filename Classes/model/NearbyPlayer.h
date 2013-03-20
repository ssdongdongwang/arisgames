//
//  NearbyPlayer.h
//  ARIS
//
//  Created by Phil Dougherty on 3/19/13.
//
//

#import <Foundation/Foundation.h>
#import "LocationObjectProtocol.h"

@interface NearbyPlayer : NSObject <LocationObjectProtocol>
{
    int playerId;
    NSString *name;
}

@property (nonatomic, assign) int playerId;
@property (nonatomic, strong) NSString *name;

@end
