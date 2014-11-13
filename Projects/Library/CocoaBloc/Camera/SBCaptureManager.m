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

@implementation SBCaptureManager

- (instancetype) initWithVideoManager:(SBVideoManager)videoManager photoManager:(SBPhotoManager*)photoManager {
    if (self = [super init]) {
        _videoManager = videoManager;
        _photoManager = photoManager;
    }
    return self;
}

- (SBDeviceManager*) currentManager {
    return self.captureType == SBCaptureTypePhoto ? self.photoManager : self.videoManager;
}

@end
