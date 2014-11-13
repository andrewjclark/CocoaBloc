//
//  SCVideoManager.m
//  StitchCam
//
//  Created by David Skuza on 9/3/14.
//  Copyright (c) 2014 David Skuza. All rights reserved.
//

#import "SBVideoManager.h"
#import "SBMovieWriter.h"
#import <ReactiveCocoa/RACEXTScope.h>

@interface SBVideoManager () <AVCaptureFileOutputRecordingDelegate>

@property (nonatomic, readonly) NSDictionary *sizesForSessionPreset;
@property (nonatomic, readonly) CGSize videoSize;

@property (nonatomic, strong, readonly) ALAssetsLibrary *assetLibrary;

@end

@implementation SBVideoManager

@synthesize videoSize = _videoSize, assetLibrary = _assetLibrary, camera = _camera;

- (ALAssetsLibrary*) assetLibrary {
    if (!_assetLibrary)
        _assetLibrary = [[ALAssetsLibrary alloc] init];
    return _assetLibrary;
}

- (GPUImageVideoCamera*) camera {
    return _camera;
}

- (void) setCamera:(GPUImageVideoCamera *)videoCamera movieWriter:(SBMovieWriter*)writer {
    if (_camera == videoCamera && _movieWriter == writer)
        return; //do nothing
    
    [_camera stopCameraCapture];
    [_camera removeTarget:self.imageView];
    [_camera removeTarget:_movieWriter];
    if (_camera != videoCamera) {
        [self willChangeValueForKey:@"camera"];
        _camera = videoCamera;
        [self didChangeValueForKey:@"camera"];
    }
    if (_movieWriter != writer) {
        [self willChangeValueForKey:@"movieWriter"];
        _movieWriter = writer;
        [self didChangeValueForKey:@"movieWriter"];
    }
    [_camera addTarget:_movieWriter];
    [_camera addTarget:self.imageView];
    [_camera startCameraCapture];
    _camera.audioEncodingTarget = _movieWriter;
}

- (void) setCamera:(GPUImageVideoCamera*)camera {
    [self setCamera:camera movieWriter:self.movieWriter];
}
- (void) setMovieWriter:(SBMovieWriter *)movieWriter {
    [self setCamera:self.camera movieWriter:movieWriter];
}

- (void) setCaptureSessionPreset:(NSString *)captureSessionPreset {
    [self willChangeValueForKey:@"captureSessionPreset"];
    _captureSessionPreset = [captureSessionPreset copy];
    [self didChangeValueForKey:@"captureSessionPreset"];
    self.camera.captureSessionPreset = captureSessionPreset;
    
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

    self.camera = [[GPUImageVideoCamera alloc] initWithSessionPreset:_captureSessionPreset cameraPosition:_capturePosition];
}

- (void) loadBestCaptureSessionPreset {
    if ([self.camera.captureSession canSetSessionPreset:AVCaptureSessionPreset1920x1080]) {
        self.captureSessionPreset = AVCaptureSessionPreset1920x1080;
    } else if ([self.camera.captureSession canSetSessionPreset:AVCaptureSessionPreset1280x720]) {
        self.captureSessionPreset = AVCaptureSessionPreset1280x720;
    } else if ([self.camera.captureSession canSetSessionPreset:AVCaptureSessionPreset640x480]) {
        self.captureSessionPreset = AVCaptureSessionPreset640x480;
    } else if ([self.camera .captureSession canSetSessionPreset:AVCaptureSessionPreset352x288]) {
        self.captureSessionPreset = AVCaptureSessionPreset352x288;
    } else {
        NSLog(@"Cannot set any session preset");
    }
}

- (instancetype) initWithImageView:(GPUImageView *)imageView outputURL:(NSURL*)url {
    if (self = [super initWithImageView:imageView]) {
        _sizesForSessionPreset = @{AVCaptureSessionPreset1920x1080 : [NSValue valueWithCGSize:CGSizeMake(1920, 1080)],
                                   AVCaptureSessionPreset1280x720 : [NSValue valueWithCGSize:CGSizeMake(1280, 720)],
                                   AVCaptureSessionPreset640x480 : [NSValue valueWithCGSize:CGSizeMake(640, 480)],
                                   AVCaptureSessionPreset352x288 : [NSValue valueWithCGSize:CGSizeMake(352, 288)]};
        _captureSessionPreset = AVCaptureSessionPresetHigh;
        _ouputURL = [url copy];
        _camera = [[GPUImageVideoCamera alloc] initWithSessionPreset:_captureSessionPreset cameraPosition:AVCaptureDevicePositionBack];
        [self loadBestCaptureSessionPreset];
    }
    return self;
}

- (void)startRecording {
    //add targets if they don't exist already
    if (!self.camera.audioEncodingTarget)
        self.camera.audioEncodingTarget = self.movieWriter;
    
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
        self.camera.audioEncodingTarget = nil;
        if (completion)
            completion(self.ouputURL);
    }];
}

- (void) saveVideoAtPath:(NSURL*)path toLibraryWithCompletion:(ALAssetsLibraryWriteVideoCompletionBlock)completion {
    [self.assetLibrary writeVideoAtPathToSavedPhotosAlbum:path completionBlock:completion];
}

@end
