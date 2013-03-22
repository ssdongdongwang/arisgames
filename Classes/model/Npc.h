//
//  NPC.h
//  ARIS
//
//  Created by David J Gagnon on 9/2/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DisplayObjectProtocol.h"
#import "LocationObjectProtocol.h"

@interface Npc : NSObject <DisplayableObjectProtocol, LocationObjectProtocol>
{
	int npcId;
    int iconMediaId;
    int	mediaId;
	NSString *name;
    NSString *ndescription;
	NSString *greeting;
	NSString *closing;
}

@property(nonatomic, assign) int npcId;
@property(nonatomic, assign) int iconMediaId;
@property(nonatomic, assign) int mediaId;
@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong) NSString *ndescription;
@property(nonatomic, strong) NSString *greeting;
@property(nonatomic, strong) NSString *closing;

- (BOOL) compareTo:(Npc *)other;
- (Npc *) copy;

@end
