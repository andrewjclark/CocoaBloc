//
//  SCDeviceManager.h
//  StitchCam
//
//  Created by David Skuza on 9/3/14.
//  Copyright (c) 2014 David Skuza. All rights reserved.
//

/**
 * SCDeviceManager manages the specific devices and their settings related to capturing photo or video
 */

#import <Foundation/Foundation.h>
@import AVFoundation;
@import AssetsLibrary;

@interface SCDeviceManager : NSObject
- (instancetype)initWithCaptureSession:(AVCaptureSession *)session;
@property (nonatomic, readonly, weak) AVCaptureSession *captureSession;

/**
 * Returns the current device input
 */
@property (nonatomic, readonly) AVCaptureDeviceInput *currentInput;
/**
 * Returns either .frontFacingCamera or .rearCamera, depending on .cameraType
 */
@property (nonatomic, readonly, weak) AVCaptureDevice *currentCamera;
/**
 * Returns an instance of AVCaptureDevice instantiated for the front-facing camera
 */
@property (nonatomic, readonly) AVCaptureDevice *frontFacingCamera;
/**
 * Returns an instance of AVCaptureDevice instantiated for the rear camera
 */
@property (nonatomic, readonly) AVCaptureDevice *rearCamera;
/**
 * Returns the first available camera on a device
 */
@property (nonatomic, readonly) AVCaptureDevice *firstAvailableCamera;
/**
 * The total number of cameras on the device
 */
@property (nonatomic, readonly) NSUInteger numberOfAvailableCameras;
/**
 * The mode of focus for the current camera
 */
@property (nonatomic, assign) AVCaptureFocusMode focusMode;
/**
 * Sets the point of focus for the current camera
 */
@property (nonatomic, assign) CGPoint focusPoint;
/**
 * Sets the mode of exposure for the current camera
 */
@property (nonatomic, assign) AVCaptureExposureMode exposureMode;
/**
 * Sets the point of exposure for the current camera
 */
@property (nonatomic, assign) CGPoint exposurePoint;
/**
 * The current flash mode used by the current camera
 */
@property (nonatomic, assign) AVCaptureFlashMode flashMode;
/**
 * An NSURL pointing to the outputted captured file stored in the app's sandbox-ed temp cache
 * @warning This will return nil unless implemented by subclasses
 */
@property (nonatomic, readonly) NSURL *outputURL;
/**
 * Returns whether or not a specific camera type is available
 */
- (BOOL)hasAvailableCameraType:(SCCameraType)cameraType;

/**
 * Returns whether or not the camera can set the flashMode to @param flashMode
 */
- (BOOL)isFlashModeAvailable:(AVCaptureFlashMode)flashMode;

@end
