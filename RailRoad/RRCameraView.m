//
//  RRCameraView.m
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

#import "RRCameraView.h"
#import <QuartzCore/QuartzCore.h>

@interface RRCameraView ()
{
    @private
    CAEAGLLayer     *_eaglLayer;
    
    NSMutableArray  *_sliders;
    GLfloat         *_sliderValues;
}

@end

@implementation RRCameraView

//////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Lifecycle
//////////////////////////////////////////////////////////////////////////

- (id)initWithFrame:(CGRect)frame
{
    if ( (self = [super initWithFrame:frame]) != nil)
    {
        [self __initialize];
    }
    return self;
}

- (void)__initialize
{
    [self __setupLayer];
    _sliders = [[NSMutableArray alloc] initWithCapacity:3];
    _sliderValues = malloc(sizeof(GLfloat)*3);
    
    _cameraCaptureSession = [[RRCameraCaptureSession alloc] init];
    [_cameraCaptureSession start];
}

- (void)intializeOpenGLWithShader:(NSString *)fragmentShader
{
    _openGL = [[RROpenGL alloc] initWithLayer:_eaglLayer vertexShader:@"vertexShader" fragmentShader:fragmentShader];
}

+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

- (void)__setupLayer
{
    _eaglLayer = (CAEAGLLayer*) self.layer;
    _eaglLayer.opaque = YES;
}

- (void)dealloc
{
    free(_sliderValues);
    [_sliders release];
    [_openGL release];
    [super dealloc];
}

//////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Methods
//////////////////////////////////////////////////////////////////////////

- (float *)attachNewSliderWithStartingPosition:(GLfloat)start min:(GLfloat)min max:(GLfloat)max;
{
    GLint sliderIndex = [_sliders count];
    if (sliderIndex > 2)
    {
        [NSException raise:@"Too Many Sliders" format:@"Cannot add more than 3 sliders"];
        return nil;
    }
    else
    {
        _sliderValues[sliderIndex] = start;
        
        UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(5, self.frame.size.height-((sliderIndex+1)*30), self.frame.size.width-10, 30)];
        slider.tag = sliderIndex;
        slider.minimumValue = min;
        slider.maximumValue = max;
        slider.value = start;
        
        [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        
        [_sliders addObject:slider];
        [self addSubview:slider];
        
        GLfloat *indexPointer = &(_sliderValues[sliderIndex]);
        
        return indexPointer;
    }
}

//////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Actions
//////////////////////////////////////////////////////////////////////////

- (void)sliderValueChanged:(UISlider *)slider
{
    _sliderValues[slider.tag] = slider.value;
}

@end
