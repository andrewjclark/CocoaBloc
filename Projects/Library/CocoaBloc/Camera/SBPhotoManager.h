//
//  SCPhotoManager.h
//  StitchCam
//
//  Created by David Skuza on 9/3/14.
//  Copyright (c) 2014 David Skuza. All rights reserved.
//

#import "SBDeviceManager.h"
#import <GPUImage/GPUImage.h>

@class SBPhotoManager;

typedef NS_ENUM(NSUInteger, SCCameraAspectRatio) {
    SCCameraAspectRatio1_1 = 0,
    SCCameraAspectRatio4_3 = 1,
};

typedef NS_ENUM(NSUInteger, SBCameraPhotoFileType) {
    SBCameraPhotoFileTypePNG = 0,
    SBCameraPhotoFileTypeJPEG = 1,
};

@interface SBPhotoManager : SBDeviceManager

@property (nonatomic, strong, readonly) GPUImageGammaFilter *filter;

/**
 * Checks whether image output should be 1:1 (square mode) or 4:3 (portrait mode)
 */
@property (nonatomic, assign) SCCameraAspectRatio aspectRatio;

/**
 * Captures still image
 */
- (void)captureImageWithFileType:(SBCameraPhotoFileType)fileType completion:(void (^)(NSData *processedPNG, NSError *error))completion;

/*
 * Helper that cast @camera property to 
 * a GPUImageStillCamera instance
 */
- (GPUImageStillCamera*) stillCamera;

@end
