//
//  DisplayObjectQueueViewController.m
//  ARIS
//
//  Created by Phil Dougherty on 3/1/13.
//
//

#import "DisplayObjectQueueViewController.h"

@interface DisplayObjectQueueViewController ()

@end

@implementation DisplayObjectQueueViewController

- (id)initWithDelegate:(UIViewController<DisplayObjectQueueDelegate> *)d
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        delegate = d;
        
        currentlyDisplayedObject       = nil;
        currentlyDisplayedObjectOrigin = nil;
        displayQueue = [[NSMutableArray alloc] initWithCapacity:5];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dequeueDisplayPackage) name:@"DisplayObjectDismissed" object:nil];
    }
    return self;
}

- (void)display:(id<DisplayableObjectProtocol>)object from:(id<DisplayOriginProtocol>)origin
{
    NSDictionary * displayPackage = [[NSDictionary alloc] initWithObjectsAndKeys:object,@"object",origin,@"origin", nil];
    [displayQueue addObject:displayPackage];
    
    if(!currentlyDisplayedObject && !currentlyDisplayedObjectOrigin) [self dequeueDisplayPackage];
}

- (void) displayObjectViewControllerWasDismissed:(DisplayObjectViewController *)d
{    
    [self.view removeFromSuperview];
    [currentlyDisplayedObject       finishedDisplay];
    [currentlyDisplayedObjectOrigin finishedDisplayingObject];
    [delegate displayObject:currentlyDisplayedObject dismissedFrom:currentlyDisplayedObjectOrigin];
    
    currentlyDisplayedObject       = nil;
    currentlyDisplayedObjectOrigin = nil;
    if([displayQueue count] > 0) [self dequeueDisplayPackage];
}

- (void)dequeueDisplayPackage
{        
    NSDictionary *displayPackage;
    displayPackage = [displayQueue objectAtIndex:0];
    currentlyDisplayedObject         = [displayPackage objectForKey:@"object"];
    currentlyDisplayedObjectOrigin   = [displayPackage objectForKey:@"origin"];
    currentlyDisplayedViewController = [currentlyDisplayedObject viewControllerForDisplay];
    currentlyDisplayedViewController.delegate = self;
    
    [self.view addSubview:currentlyDisplayedViewController.view];
    [currentlyDisplayedObject       wasDisplayed];
    [currentlyDisplayedObjectOrigin didDisplayObject];
    
    [displayQueue removeObjectAtIndex:0];

    [delegate.view addSubview:self.view];
}

@end
