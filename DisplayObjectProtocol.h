//
//  DisplayObjectProtocol.h
//  ARIS
//
//  Created by Phil Dougherty on 3/18/13.
//
//

#import <Foundation/Foundation.h>

enum
{
	DisplayOriginNil	   = 0,
	DisplayOriginLocation  = 1,
	DisplayOriginCharacter = 2
};
typedef UInt32 DisplayOriginType;

@protocol DisplayOriginProtocol
- (DisplayOriginType) type;
- (void) didDisplayObject;
- (void) finishedDisplayingObject;
@end

@class DisplayObjectViewController;
@protocol DisplayableObjectProtocol
- (DisplayObjectViewController *) viewControllerForDisplay;
- (void) wasDisplayed;
- (void) finishedDisplay;
@end
