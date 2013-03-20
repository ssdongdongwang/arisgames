//
//  WebPage.h
//  ARIS
//
//  Created by Brian Thiel on 6/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DisplayObjectProtocol.h"
#import "LocationObjectProtocol.h"

@interface WebPage : NSObject <DisplayableObjectProtocol, LocationObjectProtocol>
{
    int webPageId;
    int iconMediaId;
	NSString *name;
	NSString *url;    
}

@property(nonatomic, assign) int webPageId;
@property(nonatomic, assign) int iconMediaId;
@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong) NSString *url;

- (BOOL) compareTo:(WebPage *)other;
- (WebPage *) copy;

@end
