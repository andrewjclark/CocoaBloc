//
//  SCVideoManager.h
//  StitchCam
//
//  Created by David Skuza on 9/3/14.
//  Copyright (c) 2014 David Skuza. All rights reserved.
//

#import "SBDeviceManager.h"
#import <GPUImage/GPUImage.h>

@class SBMovieWriter, SBVideoManager;

@interface SBVideoManager : SBDeviceManager

@property (nonatomic, strong, readonly) SBMovieWriter *movieWriter;

@property (nonatomic, copy, readonly) NSURL *ouputURL;

@property (nonatomic, copy) NSString *captureSessionPreset;

@property (nonatomic, assign) AVCaptureDevicePosition capturePosition;

/**
 * Maximum duration to record video.
 * If shouldStitchVideo, this will be the total duration of all stitches combined
 * If !shouldStitchVideo, this will be the total duration of a single recorded video
 */
@property (nonatomic, assign) CMTime maxVideoDuration;

- (instancetype) initWithImageView:(GPUImageView *)imageView outputURL:(NSURL*)outputURL;

/**
* Starts an output session
*/
- (void)startRecording;
/**
 * Resumes an output session
 */
- (void)pauseRecording;
/**
 * Stops an output session
*/
- (void)stopRecording;
- (void)stopRecordingWithCompletion:(void (^)(NSURL *fileURL))completion;

/**
 * Save's video locally
 @param path - the video file path where your video lives (i.e. most likely the @ouputURL property)
 @param completion - [async] called when attempting local save
 */
- (void) saveVideoAtPath:(NSURL*)path toLibraryWithCompletion:(ALAssetsLibraryWriteVideoCompletionBlock)completion;

@end
