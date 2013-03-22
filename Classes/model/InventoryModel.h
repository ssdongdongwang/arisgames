//
//  InventoryModel.h
//  ARIS
//
//  Created by Phil Dougherty on 2/13/13.
//
//

#import <Foundation/Foundation.h>
#import "InGameItem.h"
#import "Item.h"

@interface InventoryModel : NSObject
{
    NSArray *currentInventory;
    int currentWeight;
    int weightCap;
}

@property(nonatomic, strong) NSArray *currentInventory;
@property(nonatomic, assign) int currentWeight;
@property(nonatomic, assign) int weightCap;

-(void) clearData;
-(int) removeItemFromInventory:(Item*)item qtyToRemove:(int)qty;
-(int) addItemToInventory:(Item*)item qtyToAdd:(int)qty;
-(InGameItem *) inventoryItemForId:(int)itemId;

@end
