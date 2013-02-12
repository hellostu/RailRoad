//
//  RRStaticMaths.m
//  RailRoad
//
//  Created by Stuart Lynch on 09/02/2013.
//  Copyright (c) 2013 UEA. All rights reserved.
//

#import "RRStaticMaths.h"

@implementation RRStaticMaths

+ (size_t) nextPowerOfTwo:(size_t)n
{
    size_t po2 = 2;
    while(po2<n) {
        po2 = po2*2;
    }
    return po2;
}

+ (GLfloat) radiansFromDegrees:(GLfloat) degrees
{
    return degrees * M_PI / 180;
};

+ (GLfloat) degreesFromRadians:(GLfloat) radians
{
    return radians * 180 / M_PI;
};

@end
