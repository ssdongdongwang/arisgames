//
//  Note.h
//  ARIS
//
//  Created by Brian Thiel on 8/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DisplayObjectProtocol.h"
#import "LocationObjectProtocol.h"

extern NSString *const kNoteContentTypeAudio;
extern NSString *const kNoteContentTypeVideo;
extern NSString *const kNoteContentTypePhoto;
extern NSString *const kNoteContentTypeText;

@interface Note : NSObject <DisplayableObjectProtocol, LocationObjectProtocol>
{
    int noteId;
    int creatorId;
    NSString *username;
    NSString *displayname;
    NSString *title;
    NSString *text;
    NSMutableArray *contents;
    NSMutableArray *tags;
    NSMutableArray *comments;
    
    int iconMediaId;
    
    int numRatings;
    int parentNoteId;
    int parentRating;

    double latitude;
    double longitude;

    BOOL shared;
    BOOL dropped;
    BOOL showOnMap;
    BOOL showOnList;
    BOOL userLiked;
    BOOL hasImage;
    BOOL hasAudio;
    
    id __unsafe_unretained delegate;
}

@property (nonatomic, assign) int noteId;
@property (nonatomic, assign) int creatorId;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *displayname;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSMutableArray *comments;
@property (nonatomic, strong) NSMutableArray *contents;
@property (nonatomic, strong) NSMutableArray *tags;
@property (nonatomic, assign) int tagSection;

@property (nonatomic, assign) int iconMediaId;

@property (nonatomic, assign) int numRatings;
@property (nonatomic, assign) int parentNoteId;
@property (nonatomic, assign) int parentRating;

@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;

@property (nonatomic, assign) BOOL shared;
@property (nonatomic, assign) BOOL dropped;
@property (nonatomic, assign) BOOL showOnMap;
@property (nonatomic, assign) BOOL showOnList;
@property (nonatomic, assign) BOOL userLiked;
@property (nonatomic, assign) BOOL hasImage;
@property (nonatomic, assign) BOOL hasAudio;

@property (nonatomic, unsafe_unretained) id delegate;

-(BOOL)isUploading;

@end
