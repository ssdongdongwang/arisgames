//
//  InGameItem.m
//  ARIS
//
//  Created by Phil Dougherty on 3/22/13.
//
//

/*
 *  The purpose of this object is to decouple the notion of 'game data' from 'instance data' in items.
 *  For example, if you just want to know the iconMediaId of an item, it's weird that the 'item' you spawn has a qty.
 *  Any questions, ask Phil.
 */

#import "InGameItem.h"
#import "NSDictionary+ValidParsers.h"

@implementation InGameItem

@synthesize qty;
@synthesize item;

- (id) initFromDictionary:(NSDictionary *)d
{
    return [self initWithItem:[[Item alloc] initFromDictionary:d] qty:[d validIntForKey:@"qty"]];
}

- (id) initWithItem:(Item *)i qty:(int)q
{
    if(self = [super init])
    {
        qty = q;
        item = i;
    }
    return self;
}

@end
