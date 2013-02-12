//
//  RRCameraCaptrueSession.m
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

#import "RRCameraCaptureSession.h"
#import <AVFoundation/AVFoundation.h>

@interface RRCameraCaptureSession () <AVCaptureVideoDataOutputSampleBufferDelegate>
{
    @private
    AVCaptureSession    *_captureSession;
    dispatch_queue_t    _captureQueue;
    int                 _count;
}
@end

@implementation RRCameraCaptureSession

//////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Lifecycle
//////////////////////////////////////////////////////////////////////////

- (id)init
{
    if ( (self = [super init]) != nil)
    {
        NSError *error = nil;
        
        // Create the session
        _captureSession = [[AVCaptureSession alloc] init];
        
        // Configure the session to produce lower resolution video frames, if your
        // processing algorithm can cope. We'll specify medium quality for the
        // chosen device.
        _captureSession.sessionPreset = AVCaptureSessionPresetMedium;
        
        // Find a suitable AVCaptureDevice
        AVCaptureDevice *device = [AVCaptureDevice
                                   defaultDeviceWithMediaType:AVMediaTypeVideo];
        
        // Create a device input with the device and add it to the session.
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device
                                                                            error:&error];
        if (input == nil)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:@"Unable to start camera session. Unavailable input device."
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
            [alertView release];
        }
        else
        {
            [_captureSession addInput:input];
            
            // Create a VideoDataOutput and add it to the session
            AVCaptureVideoDataOutput *output = [[[AVCaptureVideoDataOutput alloc] init] autorelease];
            [_captureSession addOutput:output];
            
            // Configure your output.
            _captureQueue = dispatch_queue_create("captureQueue", NULL);
            
            [output setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
            
            
            // Specify the pixel format
            output.videoSettings =
            [NSDictionary dictionaryWithObject:
             [NSNumber numberWithInt:kCVPixelFormatType_32BGRA]
                                        forKey:(id)kCVPixelBufferPixelFormatTypeKey];
            
            
            // If you wish to cap the frame rate to a known value, such as 15 fps, set
            // minFrameDuration.
            //output.minFrameDuratio = CMTimeMake(1, 15);
            
            // Start the session running to start the flow of data
            [_captureSession startRunning];
        }
    }
    return self;
}

- (void)dealloc
{
    [_captureSession stopRunning];
    [_captureSession release];
    dispatch_release(_captureQueue);
    [super dealloc];
}

//////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark AVCaptureVideoDataOutputSampleBufferDelegate
//////////////////////////////////////////////////////////////////////////

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{
    if([self.delegate respondsToSelector:@selector(cameraCaptureSession:capturedImage:)])
    {
        UIImage *image = [self __imageFromSampleBuffer:sampleBuffer];
        [self.delegate cameraCaptureSession:self capturedImage:image];
    }
}

//////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private Methods
//////////////////////////////////////////////////////////////////////////

- (UIImage *)__imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer
{
    // Get a CMSampleBuffer's Core Video image buffer for the media data
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    // Get the number of bytes per row for the pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    
    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // Create a bitmap graphics context with the sample buffer data
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    // Create a Quartz image from the pixel data in the bitmap graphics context
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // Unlock the pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    // Free up the context and color space
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    // Create an image object from the Quartz image
    UIImage *image = [UIImage imageWithCGImage:quartzImage scale:1.0f orientation:UIImageOrientationRight];
    
    // Release the Quartz image
    CGImageRelease(quartzImage);
    
    return (image);
}

//////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public Methods
//////////////////////////////////////////////////////////////////////////

- (void) start
{
    [_captureSession startRunning];
}

- (void) stop
{
    [_captureSession stopRunning];
}

@end
