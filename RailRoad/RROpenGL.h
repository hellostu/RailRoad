//
//  RROpenGL.h
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

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

/**
 An enumeration of GLSL data types.
 */
typedef enum {
    GLSL_DATA_TYPE_FLOAT,   /**< A float (or a 1D vector). */
    GLSL_DATA_TYPE_VEC2,    /**< A 2D Vector of floats. */
    GLSL_DATA_TYPE_VEC3,    /**< A 3D Vector of floats. */
    GLSL_DATA_TYPE_VEC4,    /**< A 4D Vector of floats. */
    GLSL_DATA_TYPE_INT,     /**< An int (or a 1D vector) */
    GLSL_DATA_TYPE_IVEC2,   /**< A 2D Vector of ints */
    GLSL_DATA_TYPE_IVEC3,   /**< A 3D Vector of ints */
    GLSL_DATA_TYPE_IVEC4,   /**< A 4D Vector of ints */
    GLSL_DATA_TYPE_MAT2,    /**< A 2x2 Matrix of floats */
    GLSL_DATA_TYPE_MAT3,    /**< A 3x3 Matrix of floats */
    GLSL_DATA_TYPE_MAT4,    /**< A 4x4 Matrix of floats */
} GLSL_DATA_TYPE;


/**
A class to handle the OpenGL calls for an image processing application. A single texture is used and it is operating on using GLSL (shaders). The class is designed to process a UIImage of a byte array image on the graphics chip easily. 
 @author Stuart Lynch stuart.lynch@uea.ac.uk
 */
@interface RROpenGL : NSObject

/**
 Initialize an OpenGL object. The app shouldn't need more than one instance of this at a time. 
 @param layer The OpenGL layer to draw to.
 @param vertexShader The name of the vertexShader file. A ".glsl" file is assumed. 
 @param fragmentShader The name of the fragmentShader file. A ".glsl" file is assumed. 
 @returns a new instance of RROpenGL.
 */
- (id)initWithLayer:(CAEAGLLayer *)layer vertexShader:(NSString *)vertexShader fragmentShader:(NSString *)fragmentShader;

/**
 Render the current frame. Should be called on a regularly basis to keep the screen up to date.
 */
- (void)render;

/**
 The class assumes a single texture, which is drawn on a 2D plane parralel to the screen. This method initizes the texture with a byte array of rgba's. 
 @param bytes A pointer to an array of bytes, representing the image.
 @param imgSize The width and height of the image in pixels.
 */
- (void)setupTextureWithImageBytes:(void *)bytes imageSize:(CGSize)imgSize;

/**
 The class assumes a single texture, which is drawn on a 2D plane parralel to the screen. This method initizes the texture with UIImage.
 @param img A UIImage.
 @param processImageBytes This block is called after the bytes are extracted from the UIImage. Any extra processing that needs to be done to the image before it is processed on the graphics chip is done here. 
 */
- (void)setupTextureWithImage:(UIImage *)img processImageBytesBlock:(void (^)(GLubyte *bytes, size_t width, size_t height))processImageBytes;

/**
 This method allows a uniform variable to be passed to the fragment shader.
 @param name A string of the name of the variable to accessed in the shader. This has to exactly match the name used in the shader code.
 @param dataType The GLSL datatype associated with the variable. 
 */
- (void)initShaderUniform:(NSString *)name ofDataType:(GLSL_DATA_TYPE)dataType;

/**
 A method to set the value of a uniform variable that can be accessed by the fragment shader. 
 @param name A string of the name of the variable to accessed in the shader. This has to exactly match the name used in the shader code.
 @param value A point to the value or values to be passed to the shader uniform variable. The array should contain the number of elements that the specified GLSL data type can hold. 
 */
- (void)shaderUniform:(NSString *)name setValue:(void *)value;
@end
