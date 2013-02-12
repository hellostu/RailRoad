//
//  RRCameraView.h
//  RailRoad
//
//
//  ==== LICENCE ====
//
// This file is part of RailRoad.
//
// RailRoad is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// RailRoad is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with RailRoad.  If not, see <http://www.gnu.org/licenses/>.
//
//  Created by Stuart Lynch on 09/02/2013.
//  Copyright (c) 2013 UEA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RROpenGL.h"
#import "RRCameraCaptureSession.h"

/**
 A class to handle the displaying of the processed camera frames. This class extends the UIView class (from the UIKit). This view has an OpenGL layer, so displays whatever is drawn by the active OpenGL session. The class also handles an RRCameraCaptureSession, which deals with pulling the image frames from the camera. 
 @author Stuart Lynch stuart.lynch@uea.ac.uk
 */

@interface RRCameraView : UIView

/**
 An instance of the OpenGL manager. This class deals with all of the OpenGL calls, which are specific to a single image texture displayed to fit the view. 
 */
@property(nonatomic, readonly) RROpenGL *openGL;

/**
 The RRCameraCaptureSession handles the grabbing of frames from the camera. 
 */
@property(nonatomic, readonly) RRCameraCaptureSession *cameraCaptureSession;

/**
 Initializes the OpenGL object. The method takes the filename of the fragment shader as input. The vertex shader is taken from the file "vertexShader". The suffix ".glsl" is assumed.
 @param fragmentShader The name of the fragmentShader file. A ".glsl" file is assumed.
 */
- (void)intializeOpenGLWithShader:(NSString *)fragmentShader;

/**
 Adds a new slider to the view. This method allows for easy generation of user editable variables via a UISlider. 
 @param start The starting position of the slider.
 @param min The minimum value of the slider.
 @param max The maximum value of the slider.
 @returns A pointer to a float representing the current value of the slider. This should be stored and accessed when required.
 */
- (float *)attachNewSliderWithStartingPosition:(GLfloat)start min:(GLfloat)min max:(GLfloat)max;

@end
