//
//  SCVideoManager.h
//  StitchCam
//
//  Created by David Skuza on 9/3/14.
//  Copyright (c) 2014 David Skuza. All rights reserved.
//

#import "SCDeviceManager.h"
#import "SCCapturing.h"
#import <GPUImage/GPUImage.h>

@class SBMovieWriter, SCVideoManager;

@protocol SCVideManagerDelegate <NSObject>
- (GPUImageView*) videoManagerNeedsGPUImageView:(SCVideoManager*)manager;
@end

@interface SCVideoManager : NSObject <SCCapturing>

@property (nonatomic, weak) id<SCVideManagerDelegate> delegate;

@property (nonatomic, strong, readonly) GPUImageVideoCamera *videoCamera;

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

- (id)initWithMovieOutputURL:(NSURL*)ouputURL delegate:(id<SCVideManagerDelegate>)delegate;

/**
* Starts an output session
*/
- (void)startRecording;
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
