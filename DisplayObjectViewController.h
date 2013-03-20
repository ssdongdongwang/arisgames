//
//  DisplayObjectViewController.h
//  ARIS
//
//  Created by Phil Dougherty on 3/18/13.
//
//

#import <UIKit/UIKit.h>

@class DisplayObjectViewController;
@protocol DisplayObjectViewControllerDelegate
- (void) displayObjectViewControllerWasDismissed:(DisplayObjectViewController *)d;
@end

@interface DisplayObjectViewController : UIViewController
{
    id<DisplayObjectViewControllerDelegate> delegate;
}

@property (nonatomic, strong) id<DisplayObjectViewControllerDelegate> delegate;

@end
