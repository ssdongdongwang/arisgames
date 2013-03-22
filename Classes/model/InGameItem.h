//
//  InGameItem.h
//  ARIS
//
//  Created by Phil Dougherty on 3/22/13.
//
//

#import <Foundation/Foundation.h>
#import "Item.h"

@interface InGameItem : NSObject
{
    int qty;
    Item *item;
}

@property (nonatomic, assign) int qty;
@property (nonatomic, strong) Item *item;

- (id) initFromDictionary:(NSDictionary *)d;
- (id) initWithItem:(Item *)i qty:(int)q;

@end
