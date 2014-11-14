//
//  SCPhotoManager.m
//  StitchCam
//
//  Created by David Skuza on 9/3/14.
//  Copyright (c) 2014 David Skuza. All rights reserved.
//

#import "SBPhotoManager.h"
#import "SCReviewController.h"

@implementation SBPhotoManager

@synthesize camera = _camera;

- (GPUImageVideoCamera*) camera {
    return _camera;
}

- (GPUImageStillCamera*) stillCamera {
    return (GPUImageStillCamera*)self.camera;
}

- (instancetype) initWithImageView:(GPUImageView *)imageView {
    if (self = [super initWithImageView:imageView]) {
        _camera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPresetPhoto cameraPosition:AVCaptureDevicePositionBack];
        _camera.outputImageOrientation = [UIDevice currentDevice].orientation;
        _filter = [[GPUImageGammaFilter alloc] init];
        [_camera addTarget:_filter];
        [_filter addTarget:imageView];
    }
    return self;
}

- (void)captureImageWithFileType:(SBCameraPhotoFileType)fileType completion:(void (^)(NSData *processedPNG, NSError *error))completion {
    switch (fileType) {
        case SBCameraPhotoFileTypePNG:
            [self.stillCamera capturePhotoAsPNGProcessedUpToFilter:self.filter withCompletionHandler:completion];
            break;
        case SBCameraPhotoFileTypeJPEG:
            [self.stillCamera capturePhotoAsJPEGProcessedUpToFilter:self.filter withCompletionHandler:completion];
            break;
        default:
            NSLog(@"Unknown SBCameraPhotoFileType");
            break;
    }
}

@end
