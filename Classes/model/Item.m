//
//  Item.m
//  ARIS
//
//  Created by David Gagnon on 4/1/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import "Item.h"
#import "ItemViewController.h"
#import "AppServices.h"

@implementation Item

@synthesize itemId;
@synthesize iconMediaId;
@synthesize mediaId;
@synthesize qty;
@synthesize maxQty;
@synthesize weight;
@synthesize isAttribute;
@synthesize isDroppable;
@synthesize isDestroyable;
@synthesize isTradeable;
@synthesize name;
@synthesize idescription;
@synthesize url;
@synthesize type;

- (int) objectId
{
    return itemId;
}

- (NSString *) objectType
{
    return @"Item";
}

- (int) iconMediaId
{
	if (iconMediaId == 0) return 2;
	else return iconMediaId;
}

- (int) mediaId
{
	if (mediaId == 0) return 2;
	else return mediaId;
}

- (DisplayObjectViewController *) viewControllerForDisplay
{
	ItemViewController *itemVC = [[ItemViewController alloc] initWithItem:self];
	itemVC.inInventory = NO;
    return itemVC;
}

- (void) wasDisplayed
{
    
}

- (void) finishedDisplay
{
    [[AppServices sharedAppServices] updateServerItemViewed:itemId fromLocation:nil];
    //Phil should remove "fromLocation". The location get's its own chance to update server
}

- (BOOL) compareTo:(Item *)other
{
	return other.itemId == self.itemId;
}

- (Item *) copy
{
    Item *c = [[Item alloc] init];
    c.itemId        = self.itemId;
    c.iconMediaId   = self.iconMediaId;
    c.mediaId       = self.mediaId;
    c.qty           = self.qty;
    c.maxQty        = self.maxQty;
    c.weight        = self.weight;
    c.isAttribute   = self.isAttribute;
    c.isDroppable   = self.isDroppable;
    c.isDestroyable = self.isDestroyable;
    c.isTradeable   = self.isTradeable;
    c.name          = self.name;
    c.idescription  = self.idescription;
    c.url           = self.url;
    c.type          = self.type;
    return c;
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"Item- Id:%d\tName:%@\tAttribute:%d\tQty:%d",self.itemId,self.name,self.isAttribute,self.qty];
}

@end
