//
//  Node.h
//  ARIS
//
//  Created by David J Gagnon on 8/31/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DisplayObjectProtocol.h"
#import "LocationObjectProtocol.h"

@interface Node : NSObject <DisplayableObjectProtocol, LocationObjectProtocol>
{
	int      nodeId;
	int	     iconMediaId;
    int      mediaId;
	NSString *name;
	NSString *text;
}

@property(nonatomic, assign) int nodeId;
@property(nonatomic, assign) int iconMediaId;
@property(nonatomic, assign) int mediaId;
@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong) NSString *text;

- (BOOL) compareTo:(Node *)other;
- (Node *) copy;

@end
