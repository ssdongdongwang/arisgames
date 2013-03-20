//
//  DisplayObjectQueueViewController.h
//  ARIS
//
//  Created by Phil Dougherty on 3/1/13.
//
//

#import <UIKit/UIKit.h>
#import "DisplayObjectProtocol.h"
#import "DisplayObjectViewController.h"

@protocol DisplayObjectQueueDelegate
- (void) displayObject:(id<DisplayableObjectProtocol>)object dismissedFrom:(id<DisplayOriginProtocol>)origin;
@end

@interface DisplayObjectQueueViewController : UIViewController <DisplayObjectViewControllerDelegate>
{
    UIViewController<DisplayObjectQueueDelegate> *delegate;
    
    DisplayObjectViewController * currentlyDisplayedViewController;
    id<DisplayableObjectProtocol> currentlyDisplayedObject;
    id<DisplayOriginProtocol> currentlyDisplayedObjectOrigin;
    
    NSMutableArray *displayQueue; //Full of dictionaries of format: {"object":<DisplayableObjectProtocol>, "origin":<DisplayOriginProtocol>}
}

- (id)initWithDelegate:(UIViewController<DisplayObjectQueueDelegate> *)d;
- (void)display:(id<DisplayableObjectProtocol>)object from:(id<DisplayOriginProtocol>)origin;

@end
