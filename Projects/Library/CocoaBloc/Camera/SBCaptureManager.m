//
//  SBCaptureManager.m
//  CocoaBloc
//
//  Created by Mark Glagola on 11/13/14.
//  Copyright (c) 2014 StageBloc. All rights reserved.
//

#import "SBCaptureManager.h"
#import "SBVideoManager.h"
#import "SBPhotoManager.h"

@interface SBCaptureManager ()

@end

@implementation SBCaptureManager

//@return's YES if successful
- (BOOL) setFlashMode:(SBCaptureFlashMode)flashMode {
    AVCaptureDevice *input = self.photoManager.camera.inputCamera;
    [input lockForConfiguration:nil];
    if (self.captureType == SBCaptureTypePhoto) {
        AVCaptureFlashMode mode = (AVCaptureFlashMode) flashMode;
        if ([input isFlashModeSupported:mode]) {
            input.flashMode = mode;
        } else {
            [input unlockForConfiguration];
            return NO;
        }
    } else {
        AVCaptureTorchMode mode = (AVCaptureTorchMode) flashMode;
        if ([input isTorchModeSupported:mode]) {
            input.torchMode = mode;
        } else {
            [input unlockForConfiguration];
            return NO;
        }
    }
    [input unlockForConfiguration];
    
    [self willChangeValueForKey:@"flashMode"];
    _flashMode = flashMode;
    [self didChangeValueForKey:@"flashMode"];
    
    return YES;
}

- (void) setCaptureType:(SBCaptureType)captureType {
    switch (captureType) {
        case SBCaptureTypePhoto:
            [self.videoManager.camera stopCameraCapture];
            [self.photoManager.camera startCameraCapture];
            break;
        case SBCaptureTypeVideo:
            [self.photoManager.camera stopCameraCapture];
            [self.videoManager.camera startCameraCapture];
            break;
        default: break;
    }
    _captureType = captureType;
    self.flashMode = SBCaptureFlashModeOff;
}

- (void) setVideoManager:(SBVideoManager *)videoManager photoManager:(SBPhotoManager*)photoManager {
    _videoManager = videoManager;
    _photoManager = photoManager;
    self.captureType = self.captureType;
}

- (instancetype) init {
    if (self = [super init]) {
    }
    return self;
}

- (instancetype) initWithVideoManager:(SBVideoManager*)videoManager photoManager:(SBPhotoManager*)photoManager {
    if (self = [self init]) {
        _captureType = SBCaptureTypeVideo;
        [self setVideoManager:videoManager photoManager:photoManager];
    }
    return self;
}

- (SBDeviceManager*) currentManager {
    return self.captureType == SBCaptureTypePhoto ? self.photoManager : self.videoManager;
}

- (void) cycleFlashMode {
//    int max = self.flashMode + SBCaptureFlashModeMax;
//    for (int m = self.flashMode; m < max; m++) {
//        SBCaptureFlashMode mode = max - m;
//        if ([self setFlashMode:mode])
//            break;
//    }
}

@end
