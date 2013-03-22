//
//  Note.m
//  ARIS
//
//  Created by Brian Thiel on 8/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Note.h"
#import "ARISAppDelegate.h"
#import "AppModel.h"
#import "NoteEditorViewController.h"
#import "NoteDetailsViewController.h"
#import "NearbyObjectsViewController.h"
#import "NoteContent.h"

NSString *const kNoteContentTypeAudio = @"AUDIO";
NSString *const kNoteContentTypeVideo = @"VIDEO";
NSString *const kNoteContentTypePhoto = @"PHOTO";
NSString *const kNoteContentTypeText = @"TEXT";

@implementation Note

@synthesize comments;
@synthesize contents;
@synthesize creatorId;
@synthesize noteId;
@synthesize parentNoteId;
@synthesize parentRating;
@synthesize shared,text;
@synthesize title;
@synthesize numRatings;
@synthesize username;
@synthesize delegate;
@synthesize dropped;
@synthesize showOnMap;
@synthesize showOnList;
@synthesize userLiked;
@synthesize hasImage;
@synthesize hasAudio;
@synthesize tags;
@synthesize tagSection;
@synthesize latitude;
@synthesize longitude;
@synthesize displayname;

- (Note *) init
{
    self = [super init];
    if (self)
    {
        iconMediaId = 71;
        self.comments = [NSMutableArray arrayWithCapacity:5];
        self.contents = [NSMutableArray arrayWithCapacity:5];
        self.tags = [NSMutableArray arrayWithCapacity:5];
    }
    return self;	
}

- (DisplayObjectViewController *) viewControllerForDisplay
{
	return [[NoteDetailsViewController alloc] initWithNote:self];
}

-(BOOL)isUploading
{
    for (int i = 0;i < [self.contents count]; i++)
    {
        if ([[(NoteContent *)[self.contents objectAtIndex:i]type] isEqualToString:@"UPLOAD"])
            return YES;
    }
    return  NO;
}

- (NSString *)name
{
    return self.name;
}

- (int)iconMediaId
{
    return 71; 
}

@end
