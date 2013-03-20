//
//  WebPage.m
//  ARIS
//
//  Created by Brian Thiel on 6/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "WebPage.h"
#import "WebPageViewController.h"

@implementation WebPage

@synthesize webPageId;
@synthesize iconMediaId;
@synthesize name;
@synthesize url;

- (int) objectId
{
    return webPageId;
}

- (NSString *) objectType
{
    return @"WebPage";
}

- (int) iconMediaId
{
	if (iconMediaId == 0) return 4;
	else return iconMediaId;
}

- (DisplayObjectViewController *) viewControllerForDisplay
{
	return [[WebPageViewController alloc] initWithWebPage:self];
}

- (void) wasDisplayed
{
    
}

- (void) finishedDisplay
{
    [[AppServices sharedAppServices] updateServerItemViewed:webPageId fromLocation:nil];
    //Phil should remove "fromLocation". The location get's its own chance to update server
}

- (BOOL) compareTo:(WebPage *)other
{
	return other.webPageId == self.webPageId;
}

- (WebPage *) copy
{
    WebPage *c = [[WebPage alloc] init];
    c.webPageId   = self.webPageId;
    c.iconMediaId = self.iconMediaId;
    c.name        = self.name;
    c.url         = self.url;
    return c;
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"WebPage- Id:%d\tName:%@\tUrl:%@",self.webPageId,self.name,self.url];
}

@end
