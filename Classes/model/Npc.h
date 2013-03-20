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

@property(readwrite, assign) int npcId;
@property(readwrite, assign) int iconMediaId;
@property(readwrite, assign) int mediaId;
@property(copy, readwrite) NSString *name;
@property(copy, readwrite) NSString *ndescription;
@property(copy, readwrite) NSString *greeting;
@property(copy, readwrite) NSString *closing;

- (BOOL) compareTo:(Npc *)other;
- (Npc *) copy;

@end
