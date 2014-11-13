//
//  SCDeviceManager.m
//  StitchCam
//
//  Created by David Skuza on 9/3/14.
//  Copyright (c) 2014 David Skuza. All rights reserved.
//

#import "SBDeviceManager.h"

@implementation SBDeviceManager

- (instancetype) initWithImageView:(GPUImageView*)imageView {
    if (self = [super init]) {
        if (imageView == nil)
            [NSException raise:NSInternalInconsistencyException format:@"imageView should not be nil! initWithMovieOutputURL:imageView:"];
        _imageView = imageView;
    
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(orientationChange:)
                                                     name:UIApplicationDidChangeStatusBarOrientationNotification
                                                   object:nil];
    }
    return self;
}

#pragma mark - Orientation Change
- (void)orientationChange:(NSNotification *)notificacion {
    UIInterfaceOrientation toOrientation = [[[notificacion userInfo]
                                             objectForKey:UIApplicationStatusBarOrientationUserInfoKey] integerValue];
    switch (toOrientation) {
        case UIDeviceOrientationLandscapeLeft:
            self.camera.outputImageOrientation = UIInterfaceOrientationLandscapeLeft;
            break;
            
        case UIDeviceOrientationLandscapeRight:
            self.camera.outputImageOrientation = UIInterfaceOrientationLandscapeRight;
            break;
            
        case UIDeviceOrientationPortrait:
            self.camera.outputImageOrientation = UIInterfaceOrientationPortrait;
            break;
            
        case UIDeviceOrientationPortraitUpsideDown:
            self.camera.outputImageOrientation = UIInterfaceOrientationPortraitUpsideDown;
            break;
        default: break; //stay the same
    }
}


@end