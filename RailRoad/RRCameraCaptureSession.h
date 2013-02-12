//
//  RRCameraCaptrueSession.h
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
@class RRCameraCaptureSession;
@protocol RRCameraCaptureSessionDelegate;

/**
 A class to deal with the frames captured from the camera. 
 @author Stuart Lynch stuart.lynch@uea.ac.uk
 */
@interface RRCameraCaptureSession : NSObject

/**
 The delegate class. This is where the UIImage's of each frame are passed to. 
 */
@property(nonatomic, readwrite, assign) id<RRCameraCaptureSessionDelegate> delegate;

/**
 Start capturing. Will start the calling of the delegate method to provide the image frames. 
 */
- (void)start;

/**
 Stop capturing.
 */
- (void)stop;

@end

/**
 A protocol which contains one method for accessing the captured frames. 
 @author Stuart Lynch stuart.lynch@uea.ac.uk
 */
@protocol RRCameraCaptureSessionDelegate <NSObject>

@optional
/**
 A method to provide the captured image at each frame.
 @param session This camera capture session.
 @param image A UIImage of the current captured frame. 
 */
- (void)cameraCaptureSession:(RRCameraCaptureSession *)session capturedImage:(UIImage *)image;
@end
