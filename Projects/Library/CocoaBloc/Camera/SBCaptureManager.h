//
//  SBCaptureManager.h
//  CocoaBloc
//
//  Created by Mark Glagola on 11/13/14.
//  Copyright (c) 2014 StageBloc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SBVideoManager, SBPhotoManager, SBDeviceManager;

typedef NS_ENUM(NSUInteger, SBCaptureType) {
    SBCaptureTypePhoto = 0,
    SBCaptureTypeVideo = 1,
};

typedef NS_ENUM(NSUInteger, SBCaptureFlashMode) {
    SBCaptureFlashModeOff = 0, //AVCaptureFlashModeOff & AVCaptureTorchModeOff
    SBCaptureFlashModeOn = 1, //AVCaptureFlashModeOn & AVCaptureTorchOn
    SBCaptureFlashModeAuto = 2, //AVCaptureFlashModeAuto & AVCaptureTorchModeAuto
};

@interface SBCaptureManager : NSObject

@property (nonatomic, strong, readonly) SBVideoManager *videoManager;
@property (nonatomic, strong, readonly) SBPhotoManager *photoManager;

@property (nonatomic, assign) SBCaptureType captureType;
@property (nonatomic, assign, readonly) SBCaptureFlashMode flashMode;

- (instancetype) initWithVideoManager:(SBVideoManager*)videoManager photoManager:(SBPhotoManager*)photoManager;

- (void) setVideoManager:(SBVideoManager *)videoManager photoManager:(SBPhotoManager*)photoManager;

- (SBDeviceManager*) currentManager;

@end