/*==============================================================================
Copyright (c) 2012 QUALCOMM Austria Research Center GmbH .
All Rights Reserved.
Qualcomm Confidential and Proprietary
==============================================================================*/


#import "EAGLView.h"
#import "Texture.h"
#import "QCARutils.h"
#import "A_object.h"
#import "C_object.h"
#import "Q_object.h"
#import "R_object.h"
#import "location.h"
#import "AppModel.h"
#import "Quad.h"
#import "SampleMath.h"

#import <QCAR/Renderer.h>
#import <QCAR/Marker.h>
#import <QCAR/CameraDevice.h>
#import <QCAR/VideoBackgroundConfig.h>
#import <QCAR/ImageTarget.h>
#import <QCAR/Vectors.h>





#ifndef USE_OPENGL1
#import "ShaderUtils.h"
#endif

// OpenGL 2
#import "ShaderUtils.h"
#define MAKESTRING(x) #x
#define NUM_PLANE_VERTEX 12
#define NUM_PLANE_INDEX 6

namespace {
    // Letter object scale factor and translation
    const float kLetterScale = 25.0f;
    const float kLetterTranslate = 25.0f;
    const float kObjectScale = 2.0f;
    NSArray *videoArray = [NSArray arrayWithObjects:
                           @"Plaid-Square video.mp4",
                           @"LongEarrings-Square video.mp4",
                           @"Glasses-Square video.mp4",
                           @"Guilt-Square video.mp4",
                           @"Delicious-Square video.mp4",
                           @"AreYouDone-Square video.mp4",
                           @"BearMusic-Square video.mp4",
                           @"BearReveal-Square video.mp4",
                           @"PayForThat-Square video.mp4",
                           @"PurpleShirt-Square video.mp4",
                           @"TalkingAbout-Square video.mp4",
                           @"Tumeric-Square video.mp4",
                           @"WaterFountain-Square video.mp4",
                           @"YouFoundMe-Square video.mp4", nil];

    const char* textureFilenames[] = {
        "icon_play.png",
        "icon_loading.png",
        "icon_error.png",
        "Plaid.png",
        "longEarrings.png",
        "Glasses.png",
        "Guilt.png",
        "Delicious.png",
        "AreYouDone.png",
        "BearMusic.png",
        "BearReveal.png",
        "PayForThat.png",
        "PurpleShirt.png",
        "TalkingAbout.png",
        "Tumeric.png",
        "WaterFountain.png",
        "YouFoundMe.png"
    };
    
    // Texture filenames
    /*const char* textureFilenames[] = {
        "smile.png",
        "letter_C.png",
        "letter_A.png",
        "letter_R.png"
    };*/
    
    Boolean loading;
    int videoPlayingIndex;
    
    static const float planeVertices[] =
    {
        -0.5, -0.5, 0.0, 0.5, -0.5, 0.0, 0.5, 0.5, 0.0, -0.5, 0.5, 0.0,
    };
    
    static const float planeTexcoords[] =
    {
        0.0, 0.0, 1.0, 0.0, 1.0, 1.0, 0.0, 1.0
    };
    
    static const float planeNormals[] =
    {
        0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0
    };
    
    static const unsigned short planeIndices[] =
    {
        0, 1, 2, 0, 2, 3
    };
    

    
    enum tagObjectIndex {
        OBJECT_PLAY_ICON,
        OBJECT_BUSY_ICON,
        OBJECT_ERROR_ICON,
        OBJECT_KEYFRAME_1,
        OBJECT_KEYFRAME_2,
    };
    
    const NSTimeInterval DOUBLE_TAP_INTERVAL = 0.3f;
    const NSTimeInterval TRACKING_LOST_TIMEOUT = 2.0f;
    
    // Playback icon scale factors
    const float SCALE_ICON = 2.0f;
    const float SCALE_ICON_TRANSLATION = 1.98f;
    
    // Video quad texture coordinates
    const GLfloat videoQuadTextureCoords[] = {
        0.0, 1.0,
        1.0, 1.0,
        1.0, 0.0,
        0.0, 0.0,
    };
    
    
    struct tagVideoData {
        // Needed to calculate whether a screen tap is inside the target
        QCAR::Matrix44F modelViewMatrix;
        
        // Trackable dimensions
        QCAR::Vec2F targetPositiveDimensions;
        
        // Currently active flag
        BOOL isActive;
    } videoData[NUM_VIDEO_TARGETS];
    
    int touchedTarget = 0;
}


@interface EAGLView (PrivateMethods)
@end

QCAR::State state;

@implementation EAGLView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
	/*if (self)
    {
        // create list of textures we want loading - ARViewController will do this for us
        int nTextures = sizeof(textureFilenames) / sizeof(textureFilenames[0]);
        for (int i = 0; i < nTextures; ++i)
            [textureList addObject: [NSString stringWithUTF8String:textureFilenames[i]]];
    }*/
    
    if (self)
    {
        // create list of textures we want loading - ARViewController will do this for us
        int nTextures = sizeof(textureFilenames) / sizeof(textureFilenames[0]);
        for (int i = 0; i < nTextures; ++i) {
            [textureList addObject: [NSString stringWithUTF8String:textureFilenames[i]]];
        }
        
        // Ensure touch events go to the view controller, rather than directly
        // to this view
        self.userInteractionEnabled = NO;
        
        // For each target, create a VideoPlayerHelper object and zero the
        // target dimensions
        videoPlayerHelper = [[VideoPlayerHelper alloc] init];
        for (int i = 0; i < NUM_VIDEO_TARGETS; ++i) {
            //videoPlayerHelper[i] = [[VideoPlayerHelper alloc] init];
            
            videoData[i].targetPositiveDimensions.data[0] = 0.0f;
            videoData[i].targetPositiveDimensions.data[1] = 0.0f;
        }
        
        dataLock = [[NSLock alloc] init];
    }

    return self;
}

- (void)dealloc
{
   // for (int i = 0; i < NUM_VIDEO_TARGETS; ++i) {
   //     [videoPlayerHelper[i] release];
   // }
    
   // [dataLock release];
    
   // [super dealloc];
}

- (void) add3DObjectWith:(int)numVertices ofVertices:(const float *)vertices normals:(const float *)normals texcoords:(const float *)texCoords with:(int)numIndices ofIndices:(const unsigned short *)indices usingTextureIndex:(NSInteger)textureIndex
{
    Object3D *obj3D = [[Object3D alloc] init];
    
    obj3D.numVertices = numVertices;
    obj3D.vertices = vertices;
    obj3D.normals = normals;
    obj3D.texCoords = texCoords;
    
    obj3D.numIndices = numIndices;
    obj3D.indices = indices;
    
    obj3D.texture = [textures objectAtIndex:textureIndex];
    
    [objects3D addObject:obj3D];
    //[obj3D release];
}

- (void) setup3dObjects
{
    // build the array of objects we want drawn and their texture
    // in this example we have 4 textures and 4 objects - Q, C, A, R
        
   /* [self add3DObjectWith:NUM_PLANE_VERTEX ofVertices:planeVertices normals:planeNormals texcoords:planeTexcoords
                    with:NUM_PLANE_INDEX ofIndices:planeIndices usingTextureIndex:0];

    [self add3DObjectWith:NUM_C_OBJECT_VERTEX ofVertices:CobjectVertices normals:CobjectNormals texcoords:CobjectTexCoords
                    with:NUM_C_OBJECT_INDEX ofIndices:CobjectIndices usingTextureIndex:1];
    
    [self add3DObjectWith:NUM_A_OBJECT_VERTEX ofVertices:AobjectVertices normals:AobjectNormals texcoords:AobjectTexCoords
                     with:NUM_A_OBJECT_INDEX ofIndices:AobjectIndices usingTextureIndex:2];

    [self add3DObjectWith:NUM_R_OBJECT_VERTEX ofVertices:RobjectVertices normals:RobjectNormals texcoords:RobjectTexCoords
                      with:NUM_R_OBJECT_INDEX ofIndices:RobjectIndices usingTextureIndex:3];
   */ 

    // Build the array of objects we want to draw.  In this example, all we need
    // to store is the OpenGL texture ID for each object (we use the data in
    // Quad.h for object vertices, indices, etc.)
    for (int i=0; i < [textures count]; ++i) {
        Object3D* obj3D = [[Object3D alloc] init];
        obj3D.texture = [textures objectAtIndex:i];
        [objects3D addObject:obj3D];
      //  [obj3D release];
    }
    
}


////////////////////////////////////////////////////////////////////////////////
// Draw the current frame using OpenGL
//
// This method is called by QCAR when it wishes to render the current frame to
// the screen.
//
// *** QCAR will call this method on a single background thread ***
- (void)renderFrameQCAR
{
    /*if (APPSTATUS_CAMERA_RUNNING == qUtils.appStatus) {
        [self setFramebuffer];
        
        // Clear colour and depth buffers
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        
        // Retrieve tracking state and render video background and 
        state = QCAR::Renderer::getInstance().begin();
        QCAR::Renderer::getInstance().drawVideoBackground();
        
        glEnable(GL_DEPTH_TEST);
        glEnable(GL_CULL_FACE);
        
        // Did we find any trackables this frame?
        for(int i = 0; i < state.getNumActiveTrackables(); ++i) {
            // Get the trackable
            const QCAR::Trackable* trackable = state.getActiveTrackable(i);
            QCAR::Matrix44F modelViewMatrix = QCAR::Tool::convertPose2GLMatrix(trackable->getPose());        
            
            const QCAR::Marker* marker;
            const QCAR::ImageTarget* imageTarget;
            int textureIndex;
            
            // Check the type of the trackable:
            if(trackable->getType() == QCAR::Trackable::MARKER) {
                marker = static_cast<const QCAR::Marker*>(trackable);
            
                // Choose the object and texture based on the marker ID
                textureIndex = marker->getMarkerId();
                assert(textureIndex < [textures count]);
            } else if (trackable->getType() == QCAR::Trackable::IMAGE_TARGET) {
                imageTarget = static_cast<const QCAR::ImageTarget*>(trackable);
                textureIndex = 0;
            }
            
     
            Object3D *obj3D = [objects3D objectAtIndex:textureIndex];
            
            // Render with OpenGL 2
            /*QCAR::Matrix44F modelViewProjection;
            ShaderUtils::translatePoseMatrix(-kLetterTranslate, -kLetterTranslate, 0.f, &modelViewMatrix.data[0]);
            ShaderUtils::scalePoseMatrix(kLetterScale, kLetterScale, kLetterScale, &modelViewMatrix.data[0]);
            ShaderUtils::multiplyMatrix(&qUtils.projectionMatrix.data[0], &modelViewMatrix.data[0], &modelViewProjection.data[0]);
            
            glUseProgram(shaderProgramID);
            
            glVertexAttribPointer(vertexHandle, 3, GL_FLOAT, GL_FALSE, 0, obj3D.vertices);
            glVertexAttribPointer(normalHandle, 3, GL_FLOAT, GL_FALSE, 0, obj3D.normals);
            glVertexAttribPointer(textureCoordHandle, 2, GL_FLOAT, GL_FALSE, 0, obj3D.texCoords);
            
            glEnableVertexAttribArray(vertexHandle);
            glEnableVertexAttribArray(normalHandle);
            glEnableVertexAttribArray(textureCoordHandle);
            
            glActiveTexture(GL_TEXTURE0);
            glBindTexture(GL_TEXTURE_2D, [obj3D.texture textureID]);
            glUniformMatrix4fv(mvpMatrixHandle, 1, GL_FALSE, (GLfloat*)&modelViewProjection.data[0]);
            glDrawElements(GL_TRIANGLES, obj3D.numIndices, GL_UNSIGNED_SHORT, obj3D.indices);*/
           
            /*QCAR::Vec2F targetSize = ((QCAR::ImageTarget *) trackable)->getSize();
            
            QCAR::Matrix44F modelViewProjection;
            
            ShaderUtils::translatePoseMatrix(0.0f, 0.0f, kObjectScale,  &modelViewMatrix.data[0]);
            ShaderUtils::scalePoseMatrix(targetSize.data[0], targetSize.data[1], 1.0f,&modelViewMatrix.data[0]);
            ShaderUtils::multiplyMatrix(&qUtils.projectionMatrix.data[0],  &modelViewMatrix.data[0] , &modelViewProjection.data[0]);
            
            glUseProgram(shaderProgramID);
            
            glVertexAttribPointer(vertexHandle, 3, GL_FLOAT, GL_FALSE, 0, (const GLvoid*) &planeVertices[0]);
            glVertexAttribPointer(normalHandle, 3, GL_FLOAT, GL_FALSE, 0,(const GLvoid*) &planeNormals[0]);
            glVertexAttribPointer(textureCoordHandle, 2, GL_FLOAT, GL_FALSE, 0, (const GLvoid*) &planeTexcoords[0]);
            
            glEnableVertexAttribArray(vertexHandle);
            glEnableVertexAttribArray(normalHandle);
            glEnableVertexAttribArray(textureCoordHandle);
            
            glActiveTexture(GL_TEXTURE0);
            glBindTexture(GL_TEXTURE_2D, [obj3D.texture textureID]);
            glUniformMatrix4fv(mvpMatrixHandle, 1, GL_FALSE,(GLfloat*)&modelViewProjection.data[0] );
            glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_SHORT,  (const GLvoid*) &planeIndices[0]);
            
            ShaderUtils::checkGlError("FrameMarkers renderFrameQCAR");
        }
        
        glDisable(GL_DEPTH_TEST);
        glDisable(GL_CULL_FACE);
        glDisableVertexAttribArray(vertexHandle);
        glDisableVertexAttribArray(normalHandle);
        glDisableVertexAttribArray(textureCoordHandle);
        
        QCAR::Renderer::getInstance().end();
        [self presentFramebuffer];
    }
    
    // don't do this straight after startup - the view controller will do it
    if (firstTime == NO)
    {
        // do the same as when the view is shown
        [arParentViewController viewDidAppear:NO];
    }
    else {
        // Start playback from the current position on the first run of the app
        for (int i = 0; i < NUM_VIDEO_TARGETS; ++i) {
            videoPlaybackTime[i] = VIDEO_PLAYBACK_CURRENT_POSITION;
        }
    }
    */
    
    
    [self setFramebuffer];
    
    // Clear colour and depth buffers
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    // Render video background and retrieve tracking state
    QCAR::State state = QCAR::Renderer::getInstance().begin();
    QCAR::Renderer::getInstance().drawVideoBackground();
    
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_CULL_FACE);
    
    // Get the active trackables
    int numActiveTrackables = state.getNumActiveTrackables();
    
    // ----- Synchronise data access -----
    [dataLock lock];
    
    // Assume all targets are inactive (used when determining tap locations)
    
    int playerIndex = 0;
    
    
    //for (int i = 0; i < NUM_VIDEO_TARGETS; ++i) {
    //    videoData[i].isActive = NO;
    //}
       
    // Did we find any trackables this frame?
    //for (int i = 0; i < numActiveTrackables; ++i) {
    if (numActiveTrackables > 0) {
        
        int i = 0;
        // Get the trackable
        const QCAR::Trackable* trackable = state.getActiveTrackable(i);
        
        // VideoPlayerHelper to use for current target
        //playerIndex = 0;    // stones
        
        //if (strcmp(trackable->getName(), "chips") == 0)
        //{
        //    playerIndex = 1;
        //}
        
        // Mark this video (target) as active
        // Check the type of the trackable:
        
        const QCAR::Marker* marker;
        if(trackable->getType() == QCAR::Trackable::MARKER) {
           marker = static_cast<const QCAR::Marker*>(trackable);
            
            // Choose the object and texture based on the marker ID
            playerIndex = marker->getMarkerId();// *2;
        
            videoData[playerIndex].isActive = YES;
            
            
           /* if (videoData[playerIndex + 1].isActive && [videoPlayerHelper[playerIndex + 1] getStatus] == REACHED_END) {
                videoData[playerIndex + 1].isActive = NO;
            }
            
            if (videoData[playerIndex + 1].isActive) {
                videoData[playerIndex].isActive = NO;
                playerIndex = (marker->getMarkerId() * 2) + 1;
            }*/
        }
        
        // Get the target size (used to determine if taps are within the target)
        if (0.0f == videoData[playerIndex].targetPositiveDimensions.data[0] ||
            0.0f == videoData[playerIndex].targetPositiveDimensions.data[1]) {
            const QCAR::ImageTarget* imageTarget = (QCAR::ImageTarget*)trackable;
            
            videoData[playerIndex].targetPositiveDimensions = imageTarget->getSize();
            // The pose delivers the centre of the target, thus the dimensions
            // go from -width / 2 to width / 2, and -height / 2 to height / 2
            videoData[playerIndex].targetPositiveDimensions.data[0] /= 2.0f;
            videoData[playerIndex].targetPositiveDimensions.data[1] /= 2.0f;
        }
        
        // Get the current trackable pose
        const QCAR::Matrix34F& trackablePose = trackable->getPose();
        
        // This matrix is used to calculate the location of the screen tap
        videoData[playerIndex].modelViewMatrix = QCAR::Tool::convertPose2GLMatrix(trackablePose);
        
        float aspectRatio;
        const GLvoid* texCoords;
        GLuint frameTextureID;
        BOOL displayVideoFrame = YES;
        
        // Retain value between calls
        static GLuint videoTextureID[NUM_VIDEO_TARGETS] = {0};
        
       // MEDIA_STATE currentStatus = [videoPlayerHelper[playerIndex] getStatus];
        MEDIA_STATE currentStatus = [videoPlayerHelper getStatus];
        
        // --- INFORMATION ---
        // One could trigger automatic playback of a video at this point.  This
        // could be achieved by calling the play method of the VideoPlayerHelper
        // object if currentStatus is not PLAYING.  You should also call
        // getStatus again after making the call to play, in order to update the
        // value held in currentStatus.
        // --- END INFORMATION ---
        
        // auto play
        
        
       

        currentStatus = [videoPlayerHelper getStatus];
        if (videoPlayingIndex == playerIndex) {
            if (currentStatus != PLAYING && currentStatus != REACHED_END && loading == NO) {
                [videoPlayerHelper unload];
                    if (NO == [videoPlayerHelper load:videoArray[playerIndex] playImmediately:YES fromPosition:0]) {
                        NSLog(@"Failed to load media");
                        
                    }
                    loading = YES;
                    videoPlayingIndex = playerIndex;
            }
        } else {
            [videoPlayerHelper unload];
                if (NO == [videoPlayerHelper load:videoArray[playerIndex] playImmediately:YES fromPosition:0]) {
                    NSLog(@"Failed to load media");
                    
                }
                loading = YES;
                videoPlayingIndex = playerIndex;
            
        }
        

        
        
        //if (currentStatus != PLAYING && currentStatus != REACHED_END) {
        //    [videoPlayerHelper[playerIndex] play:NO fromPosition:0];
            currentStatus = [videoPlayerHelper getStatus];
            
       // }
        
        switch (currentStatus) {
            case PLAYING: {
                if (playerIndex == videoPlayingIndex) {
                // If the tracking lost timer is scheduled, terminate it
                if (nil != trackingLostTimer) {
                    // Timer termination must occur on the same thread on which
                    // it was installed
                    [self performSelectorOnMainThread:@selector(terminateTrackingLostTimer) withObject:nil waitUntilDone:YES];
                }
                
                // Upload the decoded video data for the latest frame to OpenGL
                // and obtain the video texture ID
                GLuint videoTexID = [videoPlayerHelper updateVideoData];
                
                if (0 == videoTextureID[playerIndex]) {
                    videoTextureID[playerIndex] = videoTexID;
                }
                
                loading = NO;
                }
                // Fallthrough
            }
            case PAUSED:
                if (0 == videoTextureID[playerIndex]) {
                    // No video texture available, display keyframe
                    displayVideoFrame = NO;
                }
                else {
                    // Display the texture most recently returned from the call
                    // to [videoPlayerHelper updateVideoData]
                    frameTextureID = videoTextureID[playerIndex];
                }
                loading = NO;
                break;
                
            case REACHED_END:
                //[videoPlayerHelper unload];
                videoTextureID[playerIndex] = 0;
                displayVideoFrame = NO;
                loading = NO;
                break;
                
            default:
                videoTextureID[playerIndex] = 0;
                displayVideoFrame = NO;
                break;
        }
        
        if (YES == displayVideoFrame) {
            // ---- Display the video frame -----
            aspectRatio = (float)[videoPlayerHelper getVideoHeight] / (float)[videoPlayerHelper getVideoWidth];
            texCoords = videoQuadTextureCoords;
        }
        else {
            // ----- Display the keyframe -----
            Object3D* obj3D = [objects3D objectAtIndex:OBJECT_KEYFRAME_1 + playerIndex];
            frameTextureID = [[obj3D texture] textureID];
            aspectRatio = (float)[[obj3D texture] height] / (float)[[obj3D texture] width];
            texCoords = quadTexCoords;
        }
        
        // If the current status is valid (not NOT_READY or ERROR), render the
        // video quad with the texture we've just selected
        if (NOT_READY != currentStatus) {
            // Convert trackable pose to matrix for use with OpenGL
            QCAR::Matrix44F modelViewMatrixVideo = QCAR::Tool::convertPose2GLMatrix(trackablePose);
            QCAR::Matrix44F modelViewProjectionVideo;
            
            ShaderUtils::translatePoseMatrix(0.0f, 0.0f, videoData[playerIndex].targetPositiveDimensions.data[0],
                                             &modelViewMatrixVideo.data[0]);
            
            ShaderUtils::scalePoseMatrix(videoData[playerIndex].targetPositiveDimensions.data[0] * 1.4,
                                         videoData[playerIndex].targetPositiveDimensions.data[0] * aspectRatio * 1.4,
                                         videoData[playerIndex].targetPositiveDimensions.data[0],
                                         &modelViewMatrixVideo.data[0]);
            
            ShaderUtils::multiplyMatrix(&qUtils.projectionMatrix.data[0],
                                        &modelViewMatrixVideo.data[0] ,
                                        &modelViewProjectionVideo.data[0]);
            
            glUseProgram(shaderProgramID);
            
            glVertexAttribPointer(vertexHandle, 3, GL_FLOAT, GL_FALSE, 0, quadVertices);
            glVertexAttribPointer(normalHandle, 3, GL_FLOAT, GL_FALSE, 0, quadNormals);
            glVertexAttribPointer(textureCoordHandle, 2, GL_FLOAT, GL_FALSE, 0, texCoords);
            
            glEnableVertexAttribArray(vertexHandle);
            glEnableVertexAttribArray(normalHandle);
            glEnableVertexAttribArray(textureCoordHandle);
            
            glActiveTexture(GL_TEXTURE0);
            glBindTexture(GL_TEXTURE_2D, frameTextureID);
            glUniformMatrix4fv(mvpMatrixHandle, 1, GL_FALSE, (GLfloat*)&modelViewProjectionVideo.data[0]);
            glDrawElements(GL_TRIANGLES, NUM_QUAD_INDEX, GL_UNSIGNED_SHORT, quadIndices);
            
            glDisableVertexAttribArray(vertexHandle);
            glDisableVertexAttribArray(normalHandle);
            glDisableVertexAttribArray(textureCoordHandle);
            
            glUseProgram(0);
        }
        
        // If the current status is not PLAYING, render an icon
        if (PLAYING != currentStatus) {
            GLuint iconTextureID;
            
            switch (currentStatus) {
                case READY:
                case REACHED_END:
                case PAUSED:
                case STOPPED: {
                    // ----- Display play icon -----
                    Object3D* obj3D = [objects3D objectAtIndex:OBJECT_PLAY_ICON];
                    iconTextureID = [[obj3D texture] textureID];
                    break;
                }
                    
                case ERROR: {
                    // ----- Display error icon -----
                    Object3D* obj3D = [objects3D objectAtIndex:OBJECT_ERROR_ICON];
                    iconTextureID = [[obj3D texture] textureID];
                    break;
                }
                    
                default: {
                    // ----- Display busy icon -----
                    //Object3D* obj3D = [objects3D objectAtIndex:OBJECT_BUSY_ICON];
                    //iconTextureID = [[obj3D texture] textureID];

                    Object3D* obj3D = [objects3D objectAtIndex:OBJECT_BUSY_ICON];
                    iconTextureID = [[obj3D texture] textureID];
                    break;
                }
            }
            
            // Convert trackable pose to matrix for use with OpenGL
            QCAR::Matrix44F modelViewMatrixButton = QCAR::Tool::convertPose2GLMatrix(trackablePose);
            QCAR::Matrix44F modelViewProjectionButton;
            
            ShaderUtils::translatePoseMatrix(0.0f, 0.0f, videoData[playerIndex].targetPositiveDimensions.data[1] / SCALE_ICON_TRANSLATION, &modelViewMatrixButton.data[0]);
            
            ShaderUtils::scalePoseMatrix(videoData[playerIndex].targetPositiveDimensions.data[1] / SCALE_ICON,
                                         videoData[playerIndex].targetPositiveDimensions.data[1] / SCALE_ICON,
                                         videoData[playerIndex].targetPositiveDimensions.data[1] / SCALE_ICON,
                                         &modelViewMatrixButton.data[0]);
            
            ShaderUtils::multiplyMatrix(&qUtils.projectionMatrix.data[0],
                                        &modelViewMatrixButton.data[0] ,
                                        &modelViewProjectionButton.data[0]);
            
            glDepthFunc(GL_LEQUAL);
            
            glUseProgram(shaderProgramID);
            
            glVertexAttribPointer(vertexHandle, 3, GL_FLOAT, GL_FALSE, 0, quadVertices);
            glVertexAttribPointer(normalHandle, 3, GL_FLOAT, GL_FALSE, 0, quadNormals);
            glVertexAttribPointer(textureCoordHandle, 2, GL_FLOAT, GL_FALSE, 0, quadTexCoords);
            
            glEnableVertexAttribArray(vertexHandle);
            glEnableVertexAttribArray(normalHandle);
            glEnableVertexAttribArray(textureCoordHandle);
            
            // Blend the icon over the background
            glEnable(GL_BLEND);
            glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
            
            glActiveTexture(GL_TEXTURE0);
            glBindTexture(GL_TEXTURE_2D, iconTextureID);
            glUniformMatrix4fv(mvpMatrixHandle, 1, GL_FALSE, (GLfloat*)&modelViewProjectionButton.data[0] );
            glDrawElements(GL_TRIANGLES, NUM_QUAD_INDEX, GL_UNSIGNED_SHORT, quadIndices);
            
            glDisable(GL_BLEND);
            
            glDisableVertexAttribArray(vertexHandle);
            glDisableVertexAttribArray(normalHandle);
            glDisableVertexAttribArray(textureCoordHandle);
            
            glUseProgram(0);
            
            glDepthFunc(GL_LESS);
        }
        
        ShaderUtils::checkGlError("VideoPlayback renderFrameQCAR");
    }
    
    // --- INFORMATION ---
    // One could pause automatic playback of a video at this point.  Simply call
    // the pause method of the VideoPlayerHelper object without setting the
    // timer (as below).
    // --- END INFORMATION ---
    
    // If a video is playing on texture and we have lost tracking, create a
    // timer on the main thread that will pause video playback after
    // TRACKING_LOST_TIMEOUT seconds
    //for (int i = 0; i < NUM_VIDEO_TARGETS; ++i) {
    //    if (nil == trackingLostTimer && NO == videoData[i].isActive && PLAYING == [videoPlayerHelper[i] getStatus]) {
    //        [self performSelectorOnMainThread:@selector(createTrackingLostTimer) withObject:nil waitUntilDone:YES];
    //        break;
    //    }
    //}
    
    [dataLock unlock];
    // ----- End synchronise data access -----
    
    glDisable(GL_DEPTH_TEST);
    glDisable(GL_CULL_FACE);
    
    QCAR::Renderer::getInstance().end();
    [self presentFramebuffer];


}

// touch handlers
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    /*UITouch* touch = [touches anyObject];
    
    if (1 == [touch tapCount])
    {
        // Show camera control action sheet
        //[overlayViewController showOverlay];
    }*/
    
    UITouch* touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    
    // Store the current touch location
    touchLocation_X = point.x;
    touchLocation_Y = point.y;
    
    // Determine which target was touched (if no target was touch, touchedTarget
    // will be -1)
    touchedTarget = [self tapInsideTargetWithID];
    
    [videoPlayerHelper play:NO fromPosition:0];
    
  /*  [videoPlayerHelper[touchedTarget] stop];
    [videoPlayerHelper[touchedTarget + 1] play:NO fromPosition:0];
    videoData[touchedTarget + 1].isActive = YES;
*/
    
    //[videoPlayerHelper[touchedTarget] play:NO fromPosition:0];
    
    // Ignore touches when videoPlayerHelper is playing in fullscreen mode
    /*if (-1 != touchedTarget && PLAYING_FULLSCREEN != [videoPlayerHelper[touchedTarget] getStatus]) {
        if (NO == tapPending) {
            [NSTimer scheduledTimerWithTimeInterval:DOUBLE_TAP_INTERVAL target:self selector:@selector(tapTimerFired:) userInfo:nil repeats:NO];
        }
    }*/
    
    
    // iOS requires all events handled if touchesBegan is handled and not forwarded
    //UITouch* touch = [touches anyObject];
    /*CGPoint location = [touch locationInView:self];
    NSLog(@"touch x: %f", location.x);
    NSLog(@"touch y: %f", location.y);
    
    float smallestDistance = 9999999.9f;
    int selectedTrackableID = -1;
    
    // Did we find any trackables this frame?
    for(int i = 0; i < state.getNumActiveTrackables(); ++i) {
        // Get the trackable
        const QCAR::Trackable* trackable = state.getActiveTrackable(i);
        QCAR::Matrix44F modelViewMatrix = QCAR::Tool::convertPose2GLMatrix(trackable->getPose());
        
        // Check the type of the trackable:
        const QCAR::Marker* marker;
        const QCAR::ImageTarget* imageTarget;
        if(trackable->getType() == QCAR::Trackable::MARKER)
            marker = static_cast<const QCAR::Marker*>(trackable);
        else
            imageTarget = static_cast<const QCAR::ImageTarget*>(trackable);
        
        // if found on frame
        if (trackable->getStatus() == QCAR::Trackable::DETECTED) {
            
            //project center point of target to 2D screen cooordinates'
            const QCAR::CameraCalibration& cameraCalibration = QCAR::CameraDevice::getInstance().getCameraCalibration();
            QCAR::Vec2F cameraPoint = QCAR::Tool::projectPoint(cameraCalibration, trackable->getPose(), QCAR::Vec3F(0,0,0));
            
            //QCAR::Vec2F screenPoint = cameraPointToScreenPoint(cameraPoint);
            //screenPoint.data[0] +=
            
            NSLog(@"trackable %i cameraPoint x: %f", trackable->getId(), cameraPoint.data[0]);
            NSLog(@"trackable %i cameraPoint y: %f", trackable->getId(), cameraPoint.data[1]);
            // NSLog(@"trackable %i screenpoint x: %f", trackable->getId(), screenPoint.data[0]);
            // NSLog(@"trackable %i screenpoint y: %f", trackable->getId(), screenPoint.data[1]);
            
            // get distance between center point of trackable and touch point
            float distance = sqrt(pow(cameraPoint.data[0] - location.x, 2.0f) + pow(cameraPoint.data[1] - location.y, 2.0f));
            
            // if lowest distance so far, this is the trackable to open
            if (distance < smallestDistance) {
                smallestDistance = distance;
                selectedTrackableID = trackable->getId();
            }
            
        }
        
    }
    
    [videoPlayerHelper[selectedTrackableID] play:NO fromPosition:0];
    */
    // switch between videos for this target
    /*if (fmod(selectedTrackableID,2) ==0) {
     [videoPlayerHelper[selectedTrackableID] stop];
     [videoPlayerHelper[selectedTrackableID + 1] play:NO fromPosition:10];
     videoData[selectedTrackableID + 1].isActive = YES;
     }*/
    
    // Open ARIS object associated with this trackable
    /*NSLog(@"selected Trackable: %i", selectedTrackableID);
     NSMutableArray *locationsArray = [[NSMutableArray alloc] initWithArray:[AppModel sharedAppModel].locationList];
     for (int j = 0; j < [locationsArray count]; j++) {
     Location *location = [locationsArray objectAtIndex:j];
     //if (location.locationId == selectedTrackableID)
     if (j == selectedTrackableID)
     [location display];
     }*/
    // Ignore touches when videoPlayerHelper is playing in fullscreen mode
    /*if (-1 != touchedTarget && PLAYING_FULLSCREEN != [videoPlayerHelper[touchedTarget] getStatus]) {
     // If the user double-tapped the screen
     if (YES == tapPending) {
     tapPending = NO;
     MEDIA_STATE mediaState = [videoPlayerHelper[touchedTarget] getStatus];
     
     if (ERROR != mediaState && NOT_READY != mediaState) {
     // Play the video
     NSLog(@"Playing video with native player");
     [videoPlayerHelper[touchedTarget] play:YES fromPosition:VIDEO_PLAYBACK_CURRENT_POSITION];
     }
     
     // If any on-texture video is playing, pause it
     for (int i = 0; i < NUM_VIDEO_TARGETS; ++i) {
     if (PLAYING == [videoPlayerHelper[i] getStatus]) {
     [videoPlayerHelper[i] pause];
     }
     }
     }
     else {
     tapPending = YES;
     }
     }*/

}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    // iOS requires all events handled if touchesBegan is handled and not forwarded
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    
    

}

// Fires if the user tapped the screen (no double tap)
- (void)tapTimerFired:(NSTimer*)timer
{
    if (YES == tapPending) {
        tapPending = NO;
        
        // Get the state of the video player for the target the user touched
        MEDIA_STATE mediaState = [videoPlayerHelper getStatus];
        
#ifdef EXAMPLE_CODE_REMOTE_FILE
        // With remote files, single tap starts playback using the native player
        if (ERROR != mediaState && NOT_READY != mediaState) {
            // Play the video
            NSLog(@"Playing video with native player");
            [videoPlayerHelper[touchedTarget] play:YES fromPosition:VIDEO_PLAYBACK_CURRENT_POSITION];
        }
#else
        // If any on-texture video is playing, pause it
       
        
        //for (int i = 0; i < NUM_VIDEO_TARGETS; ++i) {
        //    if (PLAYING == [videoPlayerHelper[i] getStatus]) {
       //         [videoPlayerHelper[i] pause];
       //     }
        //}
        
        // For the target the user touched
        if (ERROR != mediaState && NOT_READY != mediaState && PLAYING != mediaState) {
            // Play the video
            NSLog(@"Playing video with on-texture player");
            [videoPlayerHelper play:NO fromPosition:VIDEO_PLAYBACK_CURRENT_POSITION];
        }
#endif
    }
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    // iOS requires all events handled if touchesBegan is handled and not forwarded
}

// Determine whether a screen tap is inside the target
- (int)tapInsideTargetWithID
{
    QCAR::Vec3F intersection, lineStart, lineEnd;
    QCAR::Matrix44F projectionMatrix = [QCARutils getInstance].projectionMatrix;
    QCAR::Matrix44F inverseProjMatrix = SampleMath::Matrix44FInverse(projectionMatrix);
    CGRect rect = [self bounds];
    int touchInTarget = -1;
    
    // ----- Synchronise data access -----
    [dataLock lock];
    
    // The target returns as pose the centre of the trackable.  Thus its
    // dimensions go from -width / 2 to width / 2 and from -height / 2 to
    // height / 2.  The following if statement simply checks that the tap is
    // within this range
    for (int i = 0; i < NUM_VIDEO_TARGETS; ++i) {
        SampleMath::projectScreenPointToPlane(inverseProjMatrix, videoData[i].modelViewMatrix, rect.size.width, rect.size.height,
                                              QCAR::Vec2F(touchLocation_X, touchLocation_Y), QCAR::Vec3F(0, 0, 0), QCAR::Vec3F(0, 0, 1), intersection, lineStart, lineEnd);
        
        if ((intersection.data[0] >= -videoData[i].targetPositiveDimensions.data[0]) && (intersection.data[0] <= videoData[i].targetPositiveDimensions.data[0]) &&
            (intersection.data[1] >= -videoData[i].targetPositiveDimensions.data[1]) && (intersection.data[1] <= videoData[i].targetPositiveDimensions.data[1])) {
            // The tap is only valid if it is inside an active target
            if (YES == videoData[i].isActive) {
                touchInTarget = i;
                break;
            }
        }
    }
    
    [dataLock unlock];
    // ----- End synchronise data access -----
    
    return touchInTarget;
}

// Get a pointer to a VideoPlayerHelper object held by this EAGLView
- (VideoPlayerHelper*)getVideoPlayerHelper:(int)index
{
    return videoPlayerHelper;
}

QCAR::Vec2F cameraPointToScreenPoint(QCAR::Vec2F cameraPoint)
{
    QCAR::VideoMode videoMode = QCAR::CameraDevice::getInstance().getVideoMode(QCAR::CameraDevice::MODE_DEFAULT);
    QCAR::VideoBackgroundConfig config = QCAR::Renderer::getInstance().getVideoBackgroundConfig();
    
    int xOffset = (480 - config.mSize.data[0]) / 2.0f + config.mPosition.data[0];
    int yOffset = (320 - config.mSize.data[1]) / 2.0f - config.mPosition.data[1];
    xOffset = 0;
    yOffset = 0;

    if ([[UIDevice currentDevice] orientation] == UIInterfaceOrientationPortrait)
    {
        // camera image is rotated 90 degrees
        int rotatedX = videoMode.mHeight - cameraPoint.data[1];
        int rotatedY = cameraPoint.data[0];
        
        return QCAR::Vec2F(rotatedX * config.mSize.data[0] / (float) videoMode.mHeight + xOffset,
                           rotatedY * config.mSize.data[1] / (float) videoMode.mWidth + yOffset);
    }
    else
    {
        return QCAR::Vec2F(cameraPoint.data[0] * config.mSize.data[0] / (float) videoMode.mWidth + xOffset,
                           cameraPoint.data[1] * config.mSize.data[1] / (float) videoMode.mHeight + yOffset);
    }
}

////////////////////////////////////////////////////////////////////////////////
// Initialise OpenGL rendering (overriding AR_EAGLView method)
- (void)initRendering
{
    if (renderingInited) {
        return;
    }
    
    // The super class does most of the initialisation
    [super initRendering];
    
    // For each OpenGL texture object, set appropriate texture parameters
    for (Texture* texture in textures) {
        glBindTexture(GL_TEXTURE_2D, [texture textureID]);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    }
}

// called after QCAR is initialised but before the camera starts
- (void) postInitQCAR
{
    // These two calls to setHint tell QCAR to split work over multiple
    // frames.  Depending on your requirements you can opt to omit these.
    QCAR::setHint(QCAR::HINT_IMAGE_TARGET_MULTI_FRAME_ENABLED, 1);
    QCAR::setHint(QCAR::HINT_IMAGE_TARGET_MILLISECONDS_PER_MULTI_FRAME, 25);
    
    // Set the number of simultaneous trackables to two
    QCAR::setHint(QCAR::HINT_MAX_SIMULTANEOUS_IMAGE_TARGETS, NUM_VIDEO_TARGETS);
    
    // Here we could also make a QCAR::setHint call to set the maximum
    // number of simultaneous targets
    // QCAR::setHint(QCAR::HINT_MAX_SIMULTANEOUS_IMAGE_TARGETS, 2);
}

// Create the tracking lost timer
- (void)createTrackingLostTimer
{
    trackingLostTimer = [NSTimer scheduledTimerWithTimeInterval:TRACKING_LOST_TIMEOUT target:self selector:@selector(trackingLostTimerFired:) userInfo:nil repeats:NO];
}


// Terminate the tracking lost timer
- (void)terminateTrackingLostTimer
{
    [trackingLostTimer invalidate];
    trackingLostTimer = nil;
}


// Tracking lost timer fired, pause video playback
- (void)trackingLostTimerFired:(NSTimer*)timer
{
    // Tracking has been lost for TRACKING_LOST_TIMEOUT seconds, pause playback
    // (we can safely do this on all our VideoPlayerHelpers objects)
    
    
    //for (int i = 0; i < NUM_VIDEO_TARGETS; ++i) {
        [videoPlayerHelper pause];
    //}
    trackingLostTimer = nil;
}

@end
