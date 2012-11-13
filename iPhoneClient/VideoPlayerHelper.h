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

#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>


// Media states
typedef enum tagMEDIA_STATE {
    REACHED_END,
    PAUSED,
    STOPPED,
    PLAYING,
    READY,
    PLAYING_FULLSCREEN,
    NOT_READY,
    ERROR
} MEDIA_STATE;


// Used to specify that playback should start from the current position when
// calling the load and play methods
static const float VIDEO_PLAYBACK_CURRENT_POSITION = -1.0f;


@interface VideoPlayerHelper : NSObject {
@private
    // AVPlayer
    AVPlayer* player;
    CMTime playerCursorStartPosition;
    
    // Native playback
    MPMoviePlayerController* moviePlayer;
    BOOL resumeOnTexturePlayback;
    
    // Timing
    CFTimeInterval mediaStartTime;
    CFTimeInterval playerCursorPosition;
    NSTimer* frameTimer;
    BOOL stopFrameTimer;
    
    // Asset
    NSURL* mediaURL;
    AVAssetReader* assetReader;
    AVAssetReaderTrackOutput* assetReaderTrackOutputVideo;
    AVURLAsset* asset;
    BOOL seekRequested;
    float requestedCursorPosition;
    BOOL localFile;
    BOOL playImmediately;
    
    // Playback status
    MEDIA_STATE mediaState;
    
    // Class data lock
    NSLock* dataLock;
    
    // Sample and pixel buffers for video frames
    CMSampleBufferRef latestSampleBuffer;
    CMSampleBufferRef currentSampleBuffer;
    NSLock* latestSampleBufferLock;
    
    // Video properties
    CGSize videoSize;
    Float64 videoLengthSeconds;
    float videoFrameRate;
    BOOL playVideo;
    
    // Audio properties
    float currentVolume;
    BOOL playAudio;
    
    // OpenGL data
    GLuint videoTextureHandle;
    
    // Audio/video synchronisation state
    enum tagSyncState {
        SYNC_DEFAULT,
        SYNC_READY,
        SYNC_AHEAD,
        SYNC_BEHIND
    } syncStatus;
    
    // Media player type
    enum tagPLAYER_TYPE {
        PLAYER_TYPE_ON_TEXTURE,
        PLAYER_TYPE_NATIVE
    } playerType;
}

- (BOOL)load:(NSString*)filename playImmediately:(BOOL)playOnTextureImmediately fromPosition:(float)seekPosition;
- (BOOL)unload;
- (BOOL)isPlayableOnTexture;
- (BOOL)isPlayableFullscreen;
- (MEDIA_STATE)getStatus;
- (int)getVideoHeight;
- (int)getVideoWidth;
- (float)getLength;
- (BOOL)play:(BOOL)fullscreen fromPosition:(float)seekPosition;
- (BOOL)pause;
- (BOOL)stop;
- (GLuint)updateVideoData;
- (BOOL)seekTo:(float)position;
- (float)getCurrentPosition;
- (BOOL)setVolume:(float)volume;

@end
