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

@interface SBCaptureManager : NSObject

@property (nonatomic, readonly) SBVideoManager *videoManager;
@property (nonatomic, readonly) SBPhotoManager *photoManager;

@property (nonatomic, assign) SBCaptureType captureType;

- (instancetype) initWithVideoManager:(SBVideoManager)videoManager photoManager:(SBPhotoManager*)photoManager;

- (SBDeviceManager*) currentManager;

@end
