/*==============================================================================
            Copyright (c) 2012 QUALCOMM Austria Research Center GmbH.
            All Rights Reserved.
            Qualcomm Confidential and Proprietary

This Vuforia(TM) sample application in source code form ("Sample Code") for the
Vuforia Software Development Kit and/or Vuforia Extension for Unity
(collectively, the "Vuforia SDK") may in all cases only be used in conjunction
with use of the Vuforia SDK, and is subject in all respects to all of the terms
and conditions of the Vuforia SDK License Agreement, which may be found at
https://ar.qualcomm.at/legal/license.

By retaining or using the Sample Code in any manner, you confirm your agreement
to all the terms and conditions of the Vuforia SDK License Agreement.  If you do
not agree to all the terms and conditions of the Vuforia SDK License Agreement,
then you may not retain or use any of the Sample Code in any manner.
==============================================================================*/

#import "VPParentViewController.h"
#import "ARViewController.h"
#import "OverlayViewController.h"
#import "EAGLView.h"


@implementation VPParentViewController // subclass of ARParentViewController

// Pass touches on to the AR view (EAGLView)
- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    [arViewController.arView touchesBegan:touches withEvent:event];
}


- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
{
    [arViewController.arView touchesEnded:touches withEvent:event];
}


- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Implemented only to prevent the super class methods from executing
}


- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Implemented only to prevent the super class methods from executing
}


// Add a movie player view as a subview of the main (parent) view
- (void)addMoviePlayerViewToMainView:(UIView*)view
{
    [parentView addSubview:view];
    moviePlayerView = view;
}


- (void)removeMoviePlayerView
{
    [moviePlayerView removeFromSuperview];
    moviePlayerView = nil;
}


// Return the AR view
- (EAGLView*)getARView
{
    return arViewController.arView;
}

@end
