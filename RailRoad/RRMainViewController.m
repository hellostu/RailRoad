//
//  RRMainViewController.m
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

#import "RRMainViewController.h"
#import "RRCameraView.h"

@interface RRMainViewController ()
{
    @private
    RRCameraView *_cameraView;
    
    GLfloat     *_byte2Float;
    GLfloat     *_removeGamma;
    
    GLfloat     *_brightnessValuePtr;
}

@end

@implementation RRMainViewController

//////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Lifecycle
//////////////////////////////////////////////////////////////////////////

- (void)dealloc
{
    free(_byte2Float);
    free(_removeGamma);
    [_cameraView release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self __initalizeLookups];
    
	_cameraView = [[RRCameraView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height)];
    _cameraView.cameraCaptureSession.delegate = self;
    
    [_cameraView intializeOpenGLWithShader:@"Brightness"];
    [_cameraView.openGL initShaderUniform:@"BrightnessValue" ofDataType:GLSL_DATA_TYPE_FLOAT];
    
    _brightnessValuePtr = [_cameraView attachNewSliderWithStartingPosition:1 min:0 max:2];
    
    
    [self.view addSubview:_cameraView];
}

- (void)__initalizeLookups
{
    _byte2Float = malloc(sizeof(float)*256);
    for(int i=0; i<256; i++)
    {
        _byte2Float[i] = ((GLfloat)i)/255.0f;
    }
    
    _removeGamma = malloc(sizeof(float)*256);
    for(int i=0; i<256; i++)
    {
        _removeGamma[i] = powf(((GLfloat)i)/255.0f,2.2);
    }
}

//////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark RRCameraCaptureSessionDelegate
//////////////////////////////////////////////////////////////////////////

- (void)cameraCaptureSession:(RRCameraCaptureSession *)session capturedImage:(UIImage *)image
{
    /*
    void (^greyWorldBlock)(GLubyte*,size_t,size_t) = ^(GLubyte *bytes, size_t width, size_t height)
    {
        size_t numberOfPixels = width*height;
        
        double rSum = 0;
        double gSum = 0;
        double bSum = 0;
        
        for(int i=0; i<numberOfPixels; i++)
        {
            
            GLubyte r = bytes[i*4];
            GLubyte g = bytes[i*4+1];
            GLubyte b = bytes[i*4+2];
            
            rSum += _removeGamma[r];
            gSum += _removeGamma[g];
            bSum += _removeGamma[b];
        }
        
        GLfloat rAvg = rSum/numberOfPixels;
        GLfloat gAvg = gSum/numberOfPixels;
        GLfloat bAvg = bSum/numberOfPixels;
        
        GLfloat mult = MAX(1/rAvg,MAX(1/gAvg,1/bAvg));
        
        GLfloat rgb[3] = {rAvg*mult,gAvg*mult,bAvg*mult};
        
        [_cameraView.openGL shaderUniform:@"Avg" setValue:rgb];
    };
    */
    void (^brightnessBlock)(GLubyte*,size_t,size_t) = ^(GLubyte *bytes, size_t width, size_t height)
    {
        CGFloat newBrightness = _brightnessValuePtr[0];
        newBrightness /= 2;
        newBrightness = newBrightness*newBrightness;
        newBrightness *= 2;
        
        [_cameraView.openGL shaderUniform:@"BrightnessValue" setValue:&newBrightness];
    };
    
    [_cameraView.openGL setupTextureWithImage:image processImageBytesBlock:brightnessBlock];
    [_cameraView.openGL render];
}

@end
