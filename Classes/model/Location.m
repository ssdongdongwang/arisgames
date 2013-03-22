//
//  Location.m
//  ARIS
//
//  Created by David Gagnon on 2/26/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import "Location.h"
#import "AppModel.h"
#import "NSDictionary+ValidParsers.h"
#import "Note.h" //<- this is dumb, and shouldn't need to be imported to location. See comment below: "this calculation is stupid..."

@implementation Location

@synthesize locationId;
@synthesize object;
@synthesize name;
@synthesize latlon;
@synthesize qty;
@synthesize errorRange;
@synthesize hidden;
@synthesize forcedDisplay;
@synthesize allowsQuickTravel;
@synthesize showTitle;
@synthesize wiggle;
@synthesize deleteWhenViewed;

- (id) initFromDictionary:(NSDictionary *)d
{
    if(self = [super init])
    {
        self.locationId        = [d validIntForKey:@"location_id"];
        self.name              = [d validObjectForKey:@"name"];
        self.object            = nil;
        self.latlon            = [[CLLocation alloc] initWithLatitude:[d validDoubleForKey:@"latitude"]
                                                            longitude:[d validDoubleForKey:@"longitude"]];
        self.qty               = [d validIntForKey:@"item_qty"];
        self.errorRange        = [d validIntForKey:@"error"] >= 0 ? [d validIntForKey:@"error"] : 99999999;
        self.hidden            = [d validBoolForKey:@"hidden"];
        self.forcedDisplay     = [d validBoolForKey:@"force_view"];
        self.allowsQuickTravel = [d validBoolForKey:@"allow_quick_travel"];
        self.showTitle         = [d validBoolForKey:@"show_title"];
        self.wiggle            = [d validBoolForKey:@"wiggle"];
        self.deleteWhenViewed  = [d validIntForKey:@"delete_when_viewed"];
        
        NSString *type = [d validStringForKey:@"type"];
        if([type isEqualToString:@"Node"])       self.object = [[AppModel sharedAppModel] nodeForNodeId:          [d validIntForKey:@"type_id"]];
        if([type isEqualToString:@"Npc"])        self.object = [[AppModel sharedAppModel] npcForNpcId:            [d validIntForKey:@"type_id"]];
        if([type isEqualToString:@"Item"])       self.object = [[AppModel sharedAppModel] itemForItemId:          [d validIntForKey:@"type_id"]];
        if([type isEqualToString:@"Player"])     self.object = [[AppModel sharedAppModel] itemForItemId:          [d validIntForKey:@"type_id"]];
        if([type isEqualToString:@"WebPage"])    self.object = [[AppModel sharedAppModel] webPageForWebPageID:    [d validIntForKey:@"type_id"]];
        if([type isEqualToString:@"AugBubble"])  self.object = [[AppModel sharedAppModel] panoramicForPanoramicId:[d validIntForKey:@"type_id"]];
        if([type isEqualToString:@"PlayerNote"])
        {
            self.object = [[AppModel sharedAppModel] noteForNoteId:[d validIntForKey:@"type_id"] playerListYesGameListNo:YES];
            if(!self.object)
            self.object = [[AppModel sharedAppModel] noteForNoteId:[d validIntForKey:@"type_id"] playerListYesGameListNo:NO];
            //This calculation is stupid, and should have been done on the server before sending the locations list
            if(((Note *)self.object).showOnList) self.allowsQuickTravel = YES;
            else                        self.allowsQuickTravel = NO;
        }
    }
    return self;
}

- (void) didDisplayObject
{
    
}

- (BOOL) compareTo:(Location *)other
{
    return
    [other.name isEqualToString:self.name]            &&
    other.locationId        == self.locationId        &&
    other.object            == self.object            &&
    other.latlon            == self.latlon            &&
    other.qty               == self.qty               &&
    other.errorRange        == self.errorRange        &&
    other.hidden            == self.hidden            &&
    other.forcedDisplay     == self.forcedDisplay     &&
    other.allowsQuickTravel == self.allowsQuickTravel &&
    other.showTitle         == self.showTitle         &&
    other.wiggle            == self.wiggle            &&
    other.deleteWhenViewed  == self.deleteWhenViewed;
}

- (Location *) copy
{
    Location *c = [[Location alloc] init];
    c.locationId        = self.locationId;
    c.object            = self.object;
    c.name              = self.name;
    c.latlon            = self.latlon;
    c.qty               = self.qty;
    c.errorRange        = self.errorRange;
    c.hidden            = self.hidden;
    c.forcedDisplay     = self.forcedDisplay;
    c.allowsQuickTravel = self.allowsQuickTravel;
    c.showTitle         = self.showTitle;
    c.wiggle            = self.wiggle;
    c.deleteWhenViewed  = self.deleteWhenViewed;
    return c;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"Location- Id:%d\tName:%@\tType:%@",self.locationId,self.name,self.object.objectType];
}

@end
