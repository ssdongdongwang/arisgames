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

#import <QCAR/Renderer.h>
#import <QCAR/Marker.h>
#import <QCAR/CameraDevice.h>
#import <QCAR/VideoBackgroundConfig.h>

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
    
    // Texture filenames
    const char* textureFilenames[] = {
        "smile.png",
        "letter_C.png",
        "letter_A.png",
        "letter_R.png"
    };
    
    
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
    
}


@interface EAGLView (PrivateMethods)
@end

QCAR::State state;

@implementation EAGLView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
	if (self)
    {
        // create list of textures we want loading - ARViewController will do this for us
        int nTextures = sizeof(textureFilenames) / sizeof(textureFilenames[0]);
        for (int i = 0; i < nTextures; ++i)
            [textureList addObject: [NSString stringWithUTF8String:textureFilenames[i]]];
    }
    return self;
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
    [obj3D release];    
}

- (void) setup3dObjects
{
    // build the array of objects we want drawn and their texture
    // in this example we have 4 textures and 4 objects - Q, C, A, R
        
    [self add3DObjectWith:NUM_PLANE_VERTEX ofVertices:planeVertices normals:planeNormals texcoords:planeTexcoords
                    with:NUM_PLANE_INDEX ofIndices:planeIndices usingTextureIndex:0];

    [self add3DObjectWith:NUM_C_OBJECT_VERTEX ofVertices:CobjectVertices normals:CobjectNormals texcoords:CobjectTexCoords
                    with:NUM_C_OBJECT_INDEX ofIndices:CobjectIndices usingTextureIndex:1];
    
    [self add3DObjectWith:NUM_A_OBJECT_VERTEX ofVertices:AobjectVertices normals:AobjectNormals texcoords:AobjectTexCoords
                     with:NUM_A_OBJECT_INDEX ofIndices:AobjectIndices usingTextureIndex:2];

    [self add3DObjectWith:NUM_R_OBJECT_VERTEX ofVertices:RobjectVertices normals:RobjectNormals texcoords:RobjectTexCoords
                      with:NUM_R_OBJECT_INDEX ofIndices:RobjectIndices usingTextureIndex:3];
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
    if (APPSTATUS_CAMERA_RUNNING == qUtils.appStatus) {
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
            
            // Check the type of the trackable:
            assert(trackable->getType() == QCAR::Trackable::MARKER);
            const QCAR::Marker* marker = static_cast<const QCAR::Marker*>(trackable);
            
            // Choose the object and texture based on the marker ID
            int textureIndex = marker->getMarkerId();
            assert(textureIndex < [textures count]);
            
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
           
            QCAR::Vec2F targetSize = ((QCAR::ImageTarget *) trackable)->getSize();
            
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
    
    

}

// touch handlers
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch* touch = [touches anyObject];
    
    if (1 == [touch tapCount])
    {
        // Show camera control action sheet
        //[overlayViewController showOverlay];
    }
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    // iOS requires all events handled if touchesBegan is handled and not forwarded
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    // iOS requires all events handled if touchesBegan is handled and not forwarded
    UITouch* touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
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
        assert(trackable->getType() == QCAR::Trackable::MARKER);
        const QCAR::Marker* marker = static_cast<const QCAR::Marker*>(trackable);
        
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
    
    // Open ARIS object associated with this trackable
    NSLog(@"selected Trackable: %i", selectedTrackableID);
    NSMutableArray *locationsArray = [[NSMutableArray alloc] initWithArray:[AppModel sharedAppModel].locationList];
    for (int j = 0; j < [locationsArray count]; j++) {
        Location *location = [locationsArray objectAtIndex:j];
        //if (location.locationId == selectedTrackableID)
        if (j == selectedTrackableID)
             [location display];
    }
    
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    // iOS requires all events handled if touchesBegan is handled and not forwarded
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

@end
