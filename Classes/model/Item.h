//
//  Item.h
//  ARIS
//
//  Created by David Gagnon on 4/1/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DisplayObjectProtocol.h"
#import "LocationObjectProtocol.h"

@interface Item : NSObject <DisplayableObjectProtocol, LocationObjectProtocol>
{
	int itemId;
    int iconMediaId;
	int mediaId;
	int qty;
	int maxQty;
    int weight;
    BOOL isAttribute;
	BOOL isDroppable;
	BOOL isDestroyable;
    BOOL isTradeable;
    NSString *name;
    NSString *idescription;
    NSString *url;
    NSString *type;
}

@property (nonatomic, assign) int itemId;
@property (nonatomic, assign) int iconMediaId;
@property (nonatomic, assign) int mediaId;
@property (nonatomic, assign) int qty;
@property (nonatomic, assign) int maxQty;
@property (nonatomic, assign) int weight;
@property (nonatomic, assign) BOOL isAttribute;
@property (nonatomic, assign) BOOL isDroppable;
@property (nonatomic, assign) BOOL isDestroyable;
@property (nonatomic, assign) BOOL isTradeable;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *idescription;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *type;

- (BOOL) compareTo:(Item *)other;
- (Item *) copy;

@end
