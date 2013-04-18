//
//  LocalData.h
//  ARIS
//
//  Created by Miodrag Glumac on 2/22/12.
//  Copyright (c) 2012 Amherst College. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CLLocation.h>
#import "JSONResult.h"

typedef void(^store_locally_block_t)(NSString *name, float progress, BOOL done);

@class MGame, MPlayer, MItem, MLocation, MNpc, MNode, MQuest, Game;

@interface LocalData : NSObject {
    NSManagedObjectContext *_managedObjectContext;
    NSManagedObjectModel *_managedObjectModel;
    NSPersistentStoreCoordinator *_persistentStoreCoordinator;
}

@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)storeGame:(Game*)game completion:(store_locally_block_t)block;
- (void)updateServer:(void (^)(BOOL success))block;

- (void)storeRequirements:(NSArray *)gamesDictionary game:(MGame*)game;
- (void)storePlayerLogs:(NSArray *)logsDictionary game:(MGame*)game player:(MPlayer *)player;
- (void)storeTabs:(NSArray *)tabsDictionary game:(MGame*)game;
- (void)storePlayerItems:(NSArray *)playerLogsDictionary game:(MGame*)game player:(MPlayer*)player;
- (void)storeNpcConversations:(NSArray *)npcConverationsDictionary game:(MGame*)game;
- (void)storeQRCodes:(NSArray *)rqCodesDictionary game:(MGame*)game;
- (void)storePlayerStateChanges:(NSArray *)playerStateChangesDictionary game:(MGame*)game;
- (void)storeOverlays:(NSArray *)overlaysArray game:(MGame*)game;
- (MPlayer*)storePlayer:(NSDictionary*)playerDictionary;

// network replacement calls
- (MGame*)gameForId:(NSUInteger)gameId;
- (MPlayer*)playerForId:(NSUInteger)playerId;
- (MItem*)itemForId:(NSUInteger)itemId;
- (MLocation*)locationForId:(NSUInteger)locationId;
- (MNpc*)npcForId:(NSUInteger)npcId;
- (MNode*)nodeForId:(NSUInteger)nodeId;


- (void)updatePlayerLocation:(MPlayer*)player game:(MGame*)game latitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude;
- (JSONResult*)gamesForPlayer:(int)playerId latitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude distance:(CLLocationDistance)distance locational:(BOOL)locational includeGamesInDevelopment:(BOOL)includeGamesInDevelopment;
- (JSONResult*)tabBarItemsForGame:(MGame*)mgame;
- (void)updatePlayer:(MPlayer*)player game:(MGame*)game;
- (JSONResult*)itemsForGame:(MGame*)game;
- (JSONResult*)npcsForGame:(MGame*)game;
- (JSONResult*)nodesForGame:(MGame*)game;
- (JSONResult*)mediasForGame:(MGame *)game;
- (JSONResult*)locationsForPlayer:(MPlayer*)player game:(MGame*)game;
- (JSONResult*)questsForPlayer:(MPlayer*)player game:(MGame*)game;
- (JSONResult*)itemsForPlayer:(MPlayer*)player game:(MGame*)game;
- (void)pickupItem:(MItem*)item player:(MPlayer*)player game:(MGame*)game location:(MLocation*)location qty:(NSNumber*)qty;
- (void)dropItem:(MItem*)item player:(MPlayer*)player game:(MGame*)game location:(CLLocation*)location qty:(NSNumber*)qty;
- (void)mapViewedByPlayer:(MPlayer*)player game:(MGame*)game;
- (void)itemViewedByPlayer:(MPlayer*)player game:(MGame*)game item:(MItem*)item;
- (void)npcViewedByPlayer:(MPlayer*)player game:(MGame*)game npc:(MNpc*)npc;
- (void)nodeViewedByPlayer:(MPlayer*)player game:(MGame*)game node:(MNode*)node;
- (void)questsViewedByPlayer:(MPlayer*)player game:(MGame*)game;
- (void)inventoryViewedByPlayer:(MPlayer*)player game:(MGame*)game;
- (JSONResult*)conversationsForPlayer:(MPlayer*)player afterViewingNode:(MNode*)node npc:(MNpc*)npc game:(MGame*)game;
- (JSONResult*)recentGamesForPlayer:(MPlayer*)player latitude:(double)latitude longitude:(double)longitude bool:(BOOL)showGamesInDevelopment;
- (JSONResult*)qrCodeForCode:(NSString*)code player:(MPlayer*)player game:(MGame*)game;
- (void)startOverGameForPlayer:(MPlayer*)player game:(MGame*)game;
- (void)giveItem:(MItem*)item toPlayer:(MPlayer*)player amount:(NSInteger)amount game:(MGame*)game;
- (void)takeItem:(MItem*)item fromPlayer:(MPlayer*)player amount:(NSInteger)amount game:(MGame*)game;
- (void)adjustItem:(MItem*)item player:(MPlayer*)player amount:(NSInteger)amount game:(MGame*)game;
- (JSONResult*)currentOverlaysForPlayer:(MPlayer*)player game:(MGame*)game;

+(NSNumberFormatter *)numberFormatter;
+(NSDateFormatter *)dateFormatter;
+(LocalData*)sharedLocal;



@end
