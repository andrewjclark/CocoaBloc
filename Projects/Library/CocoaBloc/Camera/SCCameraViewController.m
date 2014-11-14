//
//  SCCameraViewController.m
//  StitchCam
//
//  Created by David Skuza on 8/29/14.
//  Copyright (c) 2014 David Skuza. All rights reserved.
//

#import "SCCameraViewController.h"
#import "SCCaptureView.h"
#import "SCReviewController.h"
#import "SCImagePickerController.h"
#import "SCAssetsManager.h"
#import "SCCameraView.h"
#import "SCPageView.h"
#import "SCProgressBar.h"
#import "SCRecordButton.h"
#import "SCAlbumViewController.h"
#import "UIColor+FanClub.h"
#import "SBVideoManager.h"
#import "SBPhotoManager.h"
#import "SBCaptureManager.h"

#import <PureLayout/PureLayout.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/RACEXTScope.h>

@interface SCCameraViewController () <UIActionSheetDelegate, SCProgressBarDelegate, SCRecordButtonDelegate, SCReviewControllerDelegate>

@property (nonatomic, strong) SCCameraView *cameraView;

@property (nonatomic, strong) SBCaptureManager *captureManager;

@end

@implementation SCCameraViewController

- (SBCaptureManager*) captureManager {
    if (!_captureManager)
        _captureManager = [[SBCaptureManager alloc] init];
    return _captureManager;
}

- (SCCameraView*) cameraView {
    if (!_cameraView) {
        _cameraView = [[SCCameraView alloc] initWithFrame:self.view.frame captureManager:self.captureManager];
        
        _cameraView.recordButton.delegate = self;
        _cameraView.recordButton.holdingInterval = 0.2f;
        
        [_cameraView.chooseExistingButton addTarget:self action:@selector(chooseExistingButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_cameraView.closeButton addTarget:self action:@selector(closeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_cameraView.flashModeButton addTarget:self action:@selector(flashModeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_cameraView.toggleCameraButton addTarget:self action:@selector(cameraToggleButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        _cameraView.progressBar.delegate = self;
    }
    return _cameraView;
}

- (instancetype) initWithCaptureType:(SBCaptureType)captureType {
    if (self = [super init]) {
        self.captureManager.captureType = captureType;
    }
    return self;
}

#pragma mark - View state
- (void)viewDidLoad {
    [super viewDidLoad];
    
    long timeInterval =  (long)[[NSDate date] timeIntervalSince1970];
    NSString *pathToVideo = [NSString stringWithFormat:@"%@%ld%@", NSTemporaryDirectory(), timeInterval, @"video.m4v"];
    NSURL *path = [NSURL fileURLWithPath:pathToVideo];
    
    GPUImageView *gpuView = self.cameraView.captureView;
    [self.captureManager setVideoManager: [[SBVideoManager alloc] initWithImageView:gpuView outputURL:path]
                            photoManager:[[SBPhotoManager alloc] initWithImageView:gpuView]];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];

    self.view.backgroundColor = [UIColor blackColor];
    
    [self.view addSubview:self.cameraView];
    [self.cameraView autoCenterInSuperview];
    [self.cameraView autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.view];
    [self.cameraView autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self.view];
    
    //set current index to match capture type
    NSInteger page = self.captureManager.captureType == SBCaptureTypeVideo ? 0 : 1;
    [self.cameraView.pageView setIndex:page duration:0];
    
    __weak typeof(self) weakSelf = self;
    [RACObserve(self.cameraView.progressBar, timeElapsed) subscribeNext:^(NSNumber *n) {
        NSTimeInterval elapsed = n.floatValue;
        NSInteger mins = elapsed / 60;
        NSInteger secs = elapsed - mins;
        weakSelf.cameraView.timeLabel.text = secs <= 9 ? [NSString stringWithFormat:@"%d:0%d", mins, secs] : [NSString stringWithFormat:@"%d:%d", mins, secs];
        BOOL shouldHidePageView = (secs > 0 || mins > 0);
        weakSelf.cameraView.pageView.hidden = shouldHidePageView;
        weakSelf.cameraView.timeLabel.hidden = !shouldHidePageView;
    }];
    
    [RACObserve(self.cameraView.pageView, index) subscribeNext:^(NSNumber *n) {
        NSInteger index = n.integerValue;

        weakSelf.cameraView.stateToolbar.backgroundColor = [UIColor clearColor];
        weakSelf.cameraView.stateToolbar.hidden = NO;

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self switchedToPage:index];
        });
        [weakSelf showBlur];
    }] ;
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    [doubleTap setNumberOfTapsRequired: 2];
    [self.view addGestureRecognizer:doubleTap];
    doubleTap.delegate = self;

    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [singleTap setNumberOfTapsRequired: 1];
    [self.view addGestureRecognizer:singleTap];
    [singleTap requireGestureRecognizerToFail:doubleTap];
    singleTap.delegate = self;
    
    UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeLeftGesture:)];
    swipeGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeGesture];
    swipeGesture.delegate = self;
    
    swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeRightGesture:)];
    swipeGesture.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeGesture];
    swipeGesture.delegate = self;
}

#pragma mark - Recording Methods
- (void) startRecording {
    NSLog(@"Started/Resumed recording");
    [self.captureManager.videoManager startRecording];
    [self.cameraView animateHudHidden:YES completion:nil];
    [self.cameraView.progressBar start];
}

- (void) pauseRecording {
    NSLog(@"Paused recording");
    [self.captureManager.videoManager pauseRecording];
    [self.cameraView animateHudHidden:NO completion:nil];
    [self.cameraView.progressBar pause];
}

- (void) stopRecording {
    NSLog(@"Stopped Recording");
    @weakify(self);
    [self.captureManager.videoManager stopRecordingWithCompletion:^(NSURL *fileURL) {
        @strongify(self);
        [self.captureManager.videoManager saveVideoAtPath:fileURL toLibraryWithCompletion:^(NSURL *assetURL, NSError *error) {
            NSLog(@"Saved to library!");
        }];
    }];
}

#pragma mark - Capture Photo
- (void) capturePhoto {
    [self.cameraView animateShutterWithDuration:.1 completion:nil];
    
    __weak typeof(self) weakSelf = self;
    [self.captureManager.photoManager captureImageWithFileType:SBCameraPhotoFileTypeJPEG completion:^(NSData *processedPNG, NSError *error) {
        if (error) {
            NSLog(@"Error taking photo!");
            return;
        }
        UIImage *image = [UIImage imageWithData:processedPNG];
        SCReviewController *vc = [[SCReviewController alloc] initWithImage:image];
        vc.delegate = weakSelf;
        [weakSelf.navigationController pushViewController:vc animated:YES];
    }];
}

#pragma mark - Camera state handling
- (void) switchedToPage:(NSInteger)page {
    AVCaptureFlashMode prevFlashMode = AVCaptureFlashModeOff;//self.captureManager.currentManager.flashMode;
    switch (page) {
        case 0:
            self.captureManager.captureType = SBCaptureTypeVideo;
            self.cameraView.recordButton.allowHold = YES;
            break;
        case 1:
            self.captureManager.captureType = SBCaptureTypePhoto;
            self.captureManager.photoManager.aspectRatio = SBCameraAspectRatio4_3;
            self.cameraView.recordButton.allowHold = NO;
            break;
        case 2:
            self.captureManager.captureType = SBCaptureTypePhoto;
            self.captureManager.photoManager.aspectRatio = SBCameraAspectRatio1_1;
            self.cameraView.recordButton.allowHold = NO;
            break;
        default:
            break;
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateUIForNewPage) object:nil];
    [self performSelectorOnMainThread:@selector(updateUIForNewPage) withObject:nil waitUntilDone:NO];
}

- (void) updateUIForNewPage {
    NSInteger page = self.cameraView.pageView.index;
    switch (page) {
        case 0: [self.cameraView setVideoCaptureType]; break;
        case 1: [self.cameraView setPhotoCaptureTypeWithAspectRatio:SBCameraAspectRatio4_3]; break;
        case 2: [self.cameraView setPhotoCaptureTypeWithAspectRatio:SBCameraAspectRatio1_1]; break;
        default: break;
    }
    [self.cameraView.recordButton setBorderColor:page == 0 ? [UIColor redColor] : [UIColor fc_stageblocBlueColor]];
}

-(void)switchCamera {
    self.cameraView.stateToolbar.backgroundColor = [UIColor clearColor];
    self.cameraView.stateToolbar.hidden = NO;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        AVCaptureFlashMode prevFlashMode = self.captureManager.currentManager.flashMode;
//        if (self.captureManager.currentManager.currentCamera == self.captureManager.photoManager.rearCamera) {
//            if ([self.captureManager.currentManager hasAvailableCameraType:SCCameraTypeFrontFacing]) {
//                self.captureManager.currentManager.cameraType = SCCameraTypeFrontFacing;
//            }
//        } else {
//            if ([self.captureManager.currentManager hasAvailableCameraType:SCCameraTypeRear]) {
//                self.captureManager.currentManager.cameraType = SCCameraTypeRear;
//            }
//        }
    });
    [self showBlur];
}

#pragma mark - Blur State
- (void) showBlur {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(removeBlur) object:nil];
    [self performSelector:@selector(removeBlur) withObject:nil afterDelay:1.f];
}

-(void)removeBlur {
    self.cameraView.stateToolbar.backgroundColor = [UIColor blackColor];
    self.cameraView.stateToolbar.hidden = YES;
}

#pragma mark - Status bar states
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - Actions
-(void)chooseExistingButtonPressed:(id)sender
{
    __weak typeof(self) weakSelf = self;
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:nil cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Last Taken", @"All Photos", nil];
    actionSheet.delegate = (id<UIActionSheetDelegate>)actionSheet;
    [[actionSheet rac_signalForSelector:@selector(actionSheet:didDismissWithButtonIndex:) fromProtocol:@protocol(UIActionSheetDelegate)] subscribeNext:^(RACTuple *t) {
        UIActionSheet *a = t.first;
        NSInteger index = [t.second integerValue];
        if (index != a.cancelButtonIndex) {
            if (index == 0) {
                [[[[SCAssetsManager sharedInstance] fetchLastPhoto] deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(UIImage *image) {
                    SCReviewController *vc = [[SCReviewController alloc] initWithImage:image];
                    vc.delegate = weakSelf;
                    [weakSelf.navigationController pushViewController:vc animated:YES];
                } error:^(NSError *error) {
                    NSLog(@"ERROR: %@", error);
                }];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    SCImagePickerController *picker = [[SCImagePickerController alloc] init];
                    picker.completionBlock = ^(UIImage *image, NSDictionary *info) {
                        if (image) {
                            SCReviewController *vc = [[SCReviewController alloc] initWithImage:image];
                            vc.delegate = weakSelf;
                            [weakSelf.navigationController pushViewController:vc animated:NO];
                        }
                        [weakSelf dismissViewControllerAnimated:YES completion:nil];
                    };
                    [weakSelf presentViewController:picker animated:YES completion:nil];
                });
            }
        }
    }];
    [actionSheet showInView:self.view];
}


-(void)flashModeButtonPressed:(UIButton *)sender {
//    AVCaptureFlashMode mode = [self.cameraView cycleFlashMode];
//    [self updateFlashMode:mode];
}
-(void)cameraToggleButtonPressed:(UIButton *)sender {
    [self switchCamera];
}

-(void)handleDoubleTap:(UITapGestureRecognizer *)tapRecognizer {
//    [self switchCamera];
}
-(void)handleSingleTap:(UITapGestureRecognizer *)tapRecognizer {
    //focus here
}
- (void) handleSwipeLeftGesture:(UISwipeGestureRecognizer*) swipeGesture {
    if (self.cameraView.progressBar.timeElapsed > 0) return;
    if (self.cameraView.pageView.index + 1 <= self.cameraView.pageView.labels.count-1)
        self.cameraView.pageView.index++;
}

- (void) handleSwipeRightGesture:(UISwipeGestureRecognizer*)swipeGesture {
    if (self.cameraView.progressBar.timeElapsed > 0) return;
    if (self.cameraView.pageView.index - 1 >= 0)
        self.cameraView.pageView.index--;
}

-(void)closeButtonPressed:(id)sender {
    if ([self.delegate respondsToSelector:@selector(cameraViewControllerDidFinish:)]) {
        [self.delegate cameraViewControllerDidFinish:self];
    }
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (touch.view == self.cameraView.recordButton)
        return NO;
    return YES;
}

#pragma mark - SCProgressBarDelegate

- (void) progressBarDidStart:(SCProgressBar*)progressBar {
}

- (void) progressBarDidPause:(SCProgressBar*)progressBar {
    
}

- (void) progressBarDidStop:(SCProgressBar*)progressBar withTime:(NSTimeInterval)time {
    [self stopRecording];
}

#pragma mark - SCRecordButtonDelegate
- (void) recordButtonStartedHolding:(SCRecordButton *)button {
    //only accept video mode for this logic
    if (self.captureManager.captureType != SBCaptureTypeVideo)
        return;
    
    [self startRecording];
}

- (void) recordButtonStoppedHolding:(SCRecordButton *)button {
    if (self.captureManager.captureType == SBCaptureTypePhoto) {
        [self capturePhoto];
    } else {
        [self pauseRecording];
    }
}

- (void) recordButtonTapped:(SCRecordButton *)button {
    //only accept photo mode for this logic
    if (self.captureManager.captureType != SBCaptureTypePhoto)
        return;
    
    [self capturePhoto];
}

#pragma mark - SCReviewControllerDelegate
- (void) reviewController:(SCReviewController *)controller acceptedImage:(UIImage *)image title:(NSString *)title description:(NSString *)description {
    NSDictionary *info = @{@"title" : title, @"description" : description};
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Image.png"];
    [UIImagePNGRepresentation(image) writeToFile:filePath atomically:YES];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"SHOULD Override Image Saved to Device" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
    
}

- (void) reviewController:(SCReviewController *)controller rejectedImage:(UIImage *)image {
    [self.navigationController popViewControllerAnimated:YES];

}

@end
