//
//  SCVideoManager.m
//  StitchCam
//
//  Created by David Skuza on 9/3/14.
//  Copyright (c) 2014 David Skuza. All rights reserved.
//

#import "SCVideoManager.h"
#import "SBMovieWriter.h"
#import <ReactiveCocoa/RACEXTScope.h>

@interface SCVideoManager () <AVCaptureFileOutputRecordingDelegate>

@property (nonatomic, readonly) NSDictionary *sizesForSessionPreset;
@property (nonatomic, readonly) CGSize videoSize;

@property (nonatomic, strong, readonly) ALAssetsLibrary *assetLibrary;

@end

@implementation SCVideoManager

@synthesize videoSize = _videoSize, assetLibrary = _assetLibrary;

- (ALAssetsLibrary*) assetLibrary {
    if (!_assetLibrary)
        _assetLibrary = [[ALAssetsLibrary alloc] init];
    return _assetLibrary;
}

- (void) setVideoCamera:(GPUImageVideoCamera *)videoCamera movieWriter:(SBMovieWriter*)writer {
    if (_videoCamera == videoCamera && _movieWriter == writer)
        return; //do nothing
    
    [_videoCamera stopCameraCapture];
    GPUImageView *imageView = [self.delegate videoManagerNeedsGPUImageView:self];
    [_videoCamera removeTarget:imageView];
    [_videoCamera removeTarget:_movieWriter];
    if (_videoCamera != videoCamera) {
        [self willChangeValueForKey:@"videoCamera"];
        _videoCamera = videoCamera;
        [self didChangeValueForKey:@"videoCamera"];
    }
    if (_movieWriter != writer) {
        [self willChangeValueForKey:@"movieWriter"];
        _movieWriter = writer;
        [self didChangeValueForKey:@"movieWriter"];
    }
    [_videoCamera addTarget:_movieWriter];
    [_videoCamera addTarget:imageView];
    [_videoCamera startCameraCapture];
    _videoCamera.audioEncodingTarget = _movieWriter;
}

- (void) setVideoCamera:(GPUImageVideoCamera *)videoCamera {
    [self setVideoCamera:videoCamera movieWriter:self.movieWriter];
}
- (void) setMovieWriter:(SBMovieWriter *)movieWriter {
    [self setVideoCamera:self.videoCamera movieWriter:movieWriter];
}

- (void) setCaptureSessionPreset:(NSString *)captureSessionPreset {
    [self willChangeValueForKey:@"captureSessionPreset"];
    _captureSessionPreset = [captureSessionPreset copy];
    [self didChangeValueForKey:@"captureSessionPreset"];
    self.videoCamera.captureSessionPreset = captureSessionPreset;
    
    //adjust video size (if needed)
    CGSize newVideoSize = [((NSValue*)[self.sizesForSessionPreset objectForKey:captureSessionPreset]) CGSizeValue];
    if (!CGSizeEqualToSize(_videoSize, CGSizeZero) && CGSizeEqualToSize(newVideoSize, _videoSize))
        return;
    
    [self willChangeValueForKey:@"videoSize"];
    _videoSize = newVideoSize;
    [self didChangeValueForKey:@"videoSize"];
    
    self.movieWriter = [[SBMovieWriter alloc] initWithMovieURL:self.ouputURL size:self.videoSize];
}

- (void) setCapturePosition:(AVCaptureDevicePosition)capturePosition {
    [self willChangeValueForKey:@"capturePosition"];
    _capturePosition = capturePosition;
    [self didChangeValueForKey:@"capturePosition"];

    self.videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:_captureSessionPreset cameraPosition:_capturePosition];
}

- (void) loadBestCaptureSessionPreset {
    if ([self.videoCamera.captureSession canSetSessionPreset:AVCaptureSessionPreset1920x1080]) {
        self.captureSessionPreset = AVCaptureSessionPreset1920x1080;
    } else if ([self.videoCamera.captureSession canSetSessionPreset:AVCaptureSessionPreset1280x720]) {
        self.captureSessionPreset = AVCaptureSessionPreset1280x720;
    } else if ([self.videoCamera.captureSession canSetSessionPreset:AVCaptureSessionPreset640x480]) {
        self.captureSessionPreset = AVCaptureSessionPreset640x480;
    } else if ([self.videoCamera .captureSession canSetSessionPreset:AVCaptureSessionPreset352x288]) {
        self.captureSessionPreset = AVCaptureSessionPreset352x288;
    } else {
        NSLog(@"Cannot set any session preset");
    }
}

- (id)initWithMovieOutputURL:(NSURL*)ouputURL delegate:(id<SCVideManagerDelegate>)delegate {
    if (self = [super init]) {
        _sizesForSessionPreset = @{AVCaptureSessionPreset1920x1080 : [NSValue valueWithCGSize:CGSizeMake(1920, 1080)],
                                   AVCaptureSessionPreset1280x720 : [NSValue valueWithCGSize:CGSizeMake(1280, 720)],
                                   AVCaptureSessionPreset640x480 : [NSValue valueWithCGSize:CGSizeMake(640, 480)],
                                   AVCaptureSessionPreset352x288 : [NSValue valueWithCGSize:CGSizeMake(352, 288)]};
        _delegate = delegate;
        _captureSessionPreset = AVCaptureSessionPresetHigh;
        _ouputURL = [ouputURL copy];
        _videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:_captureSessionPreset cameraPosition:AVCaptureDevicePositionBack];
        [self loadBestCaptureSessionPreset];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(orientationChange:)
                                                     name:UIApplicationDidChangeStatusBarOrientationNotification
                                                   object:nil];
    }
    return self;
}

- (void)startRecording {
    //add targets if they don't exist already
    if (!self.videoCamera.audioEncodingTarget)
        self.videoCamera.audioEncodingTarget = self.movieWriter;
    
    //resumes recording
    if (self.movieWriter.isPaused) {
        self.movieWriter.paused = NO;
    }
    
    //starts recording
    else {
        [self.movieWriter startRecording];
    }
}

- (void)pauseRecording {
    self.movieWriter.paused = YES;
}

- (void)stopRecording {
    [self stopRecordingWithCompletion:nil];
}

- (void)stopRecordingWithCompletion:(void (^)(NSURL *fileURL))completion {
    @weakify(self);
    [self.movieWriter finishRecordingWithCompletionHandler:^{
        @strongify(self);
        self.videoCamera.audioEncodingTarget = nil;
        if (completion)
            completion(self.ouputURL);
    }];
}

- (void) saveVideoAtPath:(NSURL*)path toLibraryWithCompletion:(ALAssetsLibraryWriteVideoCompletionBlock)completion {
    [self.assetLibrary writeVideoAtPathToSavedPhotosAlbum:path completionBlock:completion];
}

#pragma mark - Orientation Change
- (void)orientationChange:(NSNotification *)notificacion {
    UIInterfaceOrientation toOrientation = [[[notificacion userInfo]
                                             objectForKey:UIApplicationStatusBarOrientationUserInfoKey] integerValue];
    switch (toOrientation) {
        case UIDeviceOrientationLandscapeLeft:
            self.videoCamera.outputImageOrientation = UIInterfaceOrientationLandscapeLeft;
            break;
            
        case UIDeviceOrientationLandscapeRight:
            self.videoCamera.outputImageOrientation = UIInterfaceOrientationLandscapeRight;
            break;
            
        case UIDeviceOrientationPortrait:
            self.videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
            break;
            
        case UIDeviceOrientationPortraitUpsideDown:
            self.videoCamera.outputImageOrientation = UIInterfaceOrientationPortraitUpsideDown;
            break;
        default: break; //stay the same
    }
}

@end
