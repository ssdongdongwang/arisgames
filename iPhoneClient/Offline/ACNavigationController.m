//
//  ACNavigationController.m
//  ARIS
//
//  Created by Miodrag Glumac on 2/1/13.
//
//

#import "ACNavigationController.h"

@implementation ACNavigationController

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return self.topViewController.supportedInterfaceOrientations;
}

@end
