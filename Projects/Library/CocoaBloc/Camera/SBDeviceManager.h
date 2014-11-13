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
#import <GPUImage/GPUImage.h>
@import AVFoundation;
@import AssetsLibrary;

@interface SBDeviceManager : NSObject

@property (nonatomic, weak, readonly) GPUImageView *imageView;

@property (nonatomic, strong, readonly) GPUImageVideoCamera *camera;

- (instancetype)initWithImageView:(GPUImageView*)imageView;

@end
