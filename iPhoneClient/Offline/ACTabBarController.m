//
//  ACTabBarController.m
//  ARIS
//
//  Created by Miodrag Glumac on 2/1/13.
//
//

#import "ACTabBarController.h"

@implementation ACTabBarController

- (BOOL)shouldAutorotate{
    return YES;
}


- (NSUInteger)supportedInterfaceOrientations {
    
    //return self.selectedViewController.supportedInterfaceOrientations;
    return UIInterfaceOrientationMaskAll;

}
 

@end
