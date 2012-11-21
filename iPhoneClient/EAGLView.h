/*==============================================================================
 Copyright (c) 2012 QUALCOMM Austria Research Center GmbH.
 All Rights Reserved.
 Qualcomm Confidential and Proprietary
 ==============================================================================*/

#import "AR_EAGLView.h"
#import "VideoPlayerHelper.h"

// Define to load and p                                     lay a video file from a remote location
//#define EXAMPLE_CODE_REMOTE_FILE

#define NUM_VIDEO_TARGETS 14

// This class wraps the CAEAGLLayer from CoreAnimation into a convenient UIView
// subclass.  The view content is basically an EAGL surface you render your
// OpenGL scene into.  Note that setting the view non-opaque will only work if
// the EAGL surface has an alpha channel.
@interface EAGLView : AR_EAGLView
{
@private
    // Instantiate one VideoPlayerHelper per target
    VideoPlayerHelper* videoPlayerHelper;
    
    // Used to differentiate between taps and double taps
    BOOL tapPending;
    
    // Timer to pause on-texture video playback after tracking has been lost.
    // Note: written/read on two threads, but never concurrently
    NSTimer* trackingLostTimer;
    
    // Coordinates of user touch
    float touchLocation_X;
    float touchLocation_Y;
    
    // Lock to synchronise data that is (potentially) accessed concurrently
    NSLock* dataLock;
}

- (VideoPlayerHelper*)getVideoPlayerHelper:(int)index;
- (int)tapInsideTargetWithID;

@end