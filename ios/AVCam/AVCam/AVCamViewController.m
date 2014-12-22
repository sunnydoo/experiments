/*
     File: AVCamViewController.m
 Abstract: View controller for camera interface.
  Version: 3.1
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 
 */

#import "AVCamViewController.h"

#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "AVCamPreviewView.h"
#import "MovieRecorder.h"

//typedef NS_ENUM( NSInteger, VideoSnakeRecordingStatus ) {
//    VideoSnakeRecordingStatusIdle = 0,
//    VideoSnakeRecordingStatusStartingRecording,
//    VideoSnakeRecordingStatusRecording,
//    VideoSnakeRecordingStatusStoppingRecording,
//}; // internal state machine

static void * CapturingStillImageContext = &CapturingStillImageContext;
static void * RecordingContext = &RecordingContext;
static void * SessionRunningAndDeviceAuthorizedContext = &SessionRunningAndDeviceAuthorizedContext;

@interface AVCamViewController () <AVCaptureVideoDataOutputSampleBufferDelegate, MovieRecorderDelegate>

// For use in the storyboards.
@property (nonatomic, weak) IBOutlet AVCamPreviewView *previewView;
@property (nonatomic, weak) IBOutlet UIButton *cameraButton;
@property (weak, nonatomic) IBOutlet UIButton *fastmoButton;
@property (weak, nonatomic) IBOutlet UIButton *slowmoButton;


- (IBAction)toggleFastmoRecording:(id)sender;
- (IBAction)toggleSlowmoRecording:(id)sender;
- (IBAction)changeCamera:(id)sender;
- (IBAction)focusAndExposeTap:(UIGestureRecognizer *)gestureRecognizer;

//- (void)toggleMovieRecording;

// Session management.
@property (nonatomic) dispatch_queue_t sessionQueue; // Communicate with the session and other session objects on this queue.
@property (nonatomic) AVCaptureSession *session;
@property (nonatomic) AVCaptureDeviceInput *videoDeviceInput;
@property (nonatomic) AVCaptureDevice *videoDevice;
//@property (nonatomic) AVCaptureMovieFileOutput *movieFileOutput;

@property (nonatomic) dispatch_queue_t videoDataOutputQueue;
@property (nonatomic) AVCaptureVideoDataOutput *videoDataOutput;
@property (nonatomic) MovieRecorder *recorder;
@property (nonatomic) NSURL* recordingURL;


// Utilities.
@property (nonatomic) UIBackgroundTaskIdentifier backgroundRecordingID;
@property (nonatomic, getter = isDeviceAuthorized) BOOL deviceAuthorized;
@property (nonatomic, readonly, getter = isSessionRunningAndDeviceAuthorized) BOOL sessionRunningAndDeviceAuthorized;
@property (nonatomic) BOOL lockInterfaceRotation;
@property (nonatomic) id runtimeErrorHandlingObserver;
@property (nonatomic) NSString* captureMode;
@property (nonatomic) CMFormatDescriptionRef videoFormat;
@property (nonatomic) AVCaptureVideoOrientation videoOrientation;
//@property (nonatomic) VideoSnakeRecordingStatus recordingStatus;


@end

@implementation AVCamViewController

- (BOOL)isSessionRunningAndDeviceAuthorized
{
	return [[self session] isRunning] && [self isDeviceAuthorized];
}

+ (NSSet *)keyPathsForValuesAffectingSessionRunningAndDeviceAuthorized
{
	return [NSSet setWithObjects:@"session.running", @"deviceAuthorized", nil];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	// Create the AVCaptureSession
	AVCaptureSession *session = [[AVCaptureSession alloc] init];
	[self setSession:session];
	
	// Setup the preview view
	[[self previewView] setSession:session];
	
	// Check for device authorization
	[self checkDeviceAuthorizationStatus];
	
	// In general it is not safe to mutate an AVCaptureSession or any of its inputs, outputs, or connections from multiple threads at the same time.
	// Why not do all of this on the main queue?
	// -[AVCaptureSession startRunning] is a blocking call which can take a long time. We dispatch session setup to the sessionQueue so that the main queue isn't blocked (which keeps the UI responsive).
	
	dispatch_queue_t sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL);
	[self setSessionQueue:sessionQueue];
	
	dispatch_async(sessionQueue, ^{
		[self setBackgroundRecordingID:UIBackgroundTaskInvalid];
		
		NSError *error = nil;
		
		AVCaptureDevice *videoDevice = [AVCamViewController deviceWithMediaType:AVMediaTypeVideo preferringPosition:AVCaptureDevicePositionBack];
		AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
        self.videoDevice = videoDevice;
		
		if (error)
		{
			NSLog(@"%@", error);
		}
		
		if ([session canAddInput:videoDeviceInput])
		{
			[session addInput:videoDeviceInput];
			[self setVideoDeviceInput:videoDeviceInput];

			dispatch_async(dispatch_get_main_queue(), ^{
				// Why are we dispatching this to the main queue?
				// Because AVCaptureVideoPreviewLayer is the backing layer for AVCamPreviewView and UIView can only be manipulated on main thread.
				// Note: As an exception to the above rule, it is not necessary to serialize video orientation changes on the AVCaptureVideoPreviewLayer’s connection with other session manipulation.
  
				[[(AVCaptureVideoPreviewLayer *)[[self previewView] layer] connection] setVideoOrientation:(AVCaptureVideoOrientation)[self interfaceOrientation]];
			});
		}
		
		AVCaptureDevice *audioDevice = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] firstObject];
		AVCaptureDeviceInput *audioDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:&error];
		
		if (error)
		{
			NSLog(@"%@", error);
		}
		
		if ([session canAddInput:audioDeviceInput])
		{
			[session addInput:audioDeviceInput];
		}
		
//		AVCaptureMovieFileOutput *movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
//		if ([session canAddOutput:movieFileOutput])
//		{
//			[session addOutput:movieFileOutput];
//			AVCaptureConnection *connection = [movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
//			if ([connection isVideoStabilizationSupported])
//				[connection setEnablesVideoStabilizationWhenAvailable:YES];
//			[self setMovieFileOutput:movieFileOutput];
//		}
        
        self.videoDataOutputQueue = dispatch_queue_create( "com.apple.sample.sessionmanager.video", DISPATCH_QUEUE_SERIAL );
        dispatch_set_target_queue( self.videoDataOutputQueue, dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0) );
        
        self.videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
        [self.videoDataOutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
        [self.videoDataOutput setSampleBufferDelegate:self queue:_videoDataOutputQueue];
        
        [self.videoDataOutput setAlwaysDiscardsLateVideoFrames:YES];
        
        if( [ session canAddOutput: self.videoDataOutput])
        {
            [session addOutput: self.videoDataOutput];
        }
        
        [self switchFormatWithDesiredFPS: 120.0 forDevice: videoDevice ];
        
	});
}

- (void)viewWillAppear:(BOOL)animated
{
	dispatch_async([self sessionQueue], ^{
		[self addObserver:self forKeyPath:@"sessionRunningAndDeviceAuthorized" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:SessionRunningAndDeviceAuthorizedContext];
//		[self addObserver:self forKeyPath:@"movieFileOutput.recording" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:RecordingContext];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:[[self videoDeviceInput] device]];
		
		__weak AVCamViewController *weakSelf = self;
		[self setRuntimeErrorHandlingObserver:[[NSNotificationCenter defaultCenter] addObserverForName:AVCaptureSessionRuntimeErrorNotification object:[self session] queue:nil usingBlock:^(NSNotification *note) {
			AVCamViewController *strongSelf = weakSelf;
			dispatch_async([strongSelf sessionQueue], ^{
				// Manually restarting the session since it must have been stopped due to an error.
				[[strongSelf session] startRunning];
				[[strongSelf fastmoButton] setTitle:NSLocalizedString(@"FASTMO", @"FASTMO Recording button record title") forState:UIControlStateNormal];
                [[strongSelf slowmoButton] setTitle:NSLocalizedString(@"SLOWMO", @"FASTMO Recording button record title") forState:UIControlStateNormal];
			});
		}]];
		[[self session] startRunning];
	});
}

- (void)viewDidDisappear:(BOOL)animated
{
	dispatch_async([self sessionQueue], ^{
		[[self session] stopRunning];
		
		[[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:[[self videoDeviceInput] device]];
		[[NSNotificationCenter defaultCenter] removeObserver:[self runtimeErrorHandlingObserver]];
		
		[self removeObserver:self forKeyPath:@"sessionRunningAndDeviceAuthorized" context:SessionRunningAndDeviceAuthorizedContext];
		//[self removeObserver:self forKeyPath:@"movieFileOutput.recording" context:RecordingContext];
	});
}

- (BOOL)prefersStatusBarHidden
{
	return YES;
}

- (BOOL)shouldAutorotate
{
	// Disable autorotation of the interface when recording is in progress.
	return ![self lockInterfaceRotation];
}

- (NSUInteger)supportedInterfaceOrientations
{
	return UIInterfaceOrientationMaskAll;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[[(AVCaptureVideoPreviewLayer *)[[self previewView] layer] connection] setVideoOrientation:(AVCaptureVideoOrientation)toInterfaceOrientation];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{

    if (context == RecordingContext)
	{
		BOOL isRecording = [change[NSKeyValueChangeNewKey] boolValue];
		
		dispatch_async(dispatch_get_main_queue(), ^{
            if ( [[self captureMode] isEqualToString: @"fastmo" ]) {
                if (isRecording)
                {
                    [[self cameraButton] setEnabled:NO];
                    [[self fastmoButton] setTitle:NSLocalizedString(@"STOP", @"FASTMO Recording button stop title") forState:UIControlStateNormal];
                    [[self fastmoButton] setEnabled:YES];
                    
                }
                else
                {
                    [[self cameraButton] setEnabled:YES];
                    [[self fastmoButton] setTitle:NSLocalizedString(@"FASTMO", @"FASTMO Recording button record title") forState:UIControlStateNormal];
                    [[self fastmoButton] setEnabled:YES];
                }
            }
            else if( [[self captureMode] isEqualToString: @"slowmo" ]) {
                if (isRecording)
                {
                    [[self cameraButton] setEnabled:NO];
                    [[self slowmoButton] setTitle:NSLocalizedString(@"STOP", @"SLOWMO Recording button stop title") forState:UIControlStateNormal];
                    [[self slowmoButton] setEnabled:YES];
                    
                }
                else
                {
                    [[self cameraButton] setEnabled:YES];
                    [[self slowmoButton] setTitle:NSLocalizedString(@"SLOWMO", @"SLOWMO Recording button record title") forState:UIControlStateNormal];
                    [[self slowmoButton] setEnabled:YES];
                }
            }
		});
	}
	else if (context == SessionRunningAndDeviceAuthorizedContext)
	{
		BOOL isRunning = [change[NSKeyValueChangeNewKey] boolValue];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			if (isRunning)
			{
				[[self cameraButton] setEnabled:YES];
				[[self fastmoButton] setEnabled:YES];
				[[self slowmoButton] setEnabled:YES];
			}
			else
			{
				[[self cameraButton] setEnabled:NO];
				[[self fastmoButton] setEnabled:NO];
				[[self slowmoButton] setEnabled:NO];
			}
		});
	}
	else
	{
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

#pragma mark Actions

- (void)switchFormatWithDesiredFPS: (CGFloat) desiredFPS forDevice: (AVCaptureDevice *)videoDevice
{
    AVCaptureDeviceFormat *selectedFormat = nil;
    int32_t maxWidth = 0;
    AVFrameRateRange *frameRateRange = nil;
    
    for (AVCaptureDeviceFormat *format in [videoDevice formats]) {
        
        for (AVFrameRateRange *range in format.videoSupportedFrameRateRanges) {
            
            CMFormatDescriptionRef desc = format.formatDescription;
            CMVideoDimensions dimensions = CMVideoFormatDescriptionGetDimensions(desc);
            int32_t width = dimensions.width;
            
            if (range.minFrameRate <= desiredFPS && desiredFPS <= range.maxFrameRate && width >= maxWidth) {
                
                selectedFormat = format;
                frameRateRange = range;
                maxWidth = width;
            }
        }
    }
    
    if (selectedFormat) {
        
        if ([videoDevice lockForConfiguration:nil]) {
            
            NSLog(@"selected format:%@", selectedFormat);
            videoDevice.activeFormat = selectedFormat;
            videoDevice.activeVideoMinFrameDuration = CMTimeMake(1, (int32_t)desiredFPS);
            videoDevice.activeVideoMaxFrameDuration = CMTimeMake(1, (int32_t)desiredFPS);
            [videoDevice unlockForConfiguration];
        }
    }
}


- (void) setupRecording
{
    if ( ! self.recorder) {
        NSString *outputFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[@"movie" stringByAppendingPathExtension:@"mov"]];
        self.recordingURL = [[NSURL alloc] initFileURLWithPath: outputFilePath];
        self.recorder = [[MovieRecorder alloc] initWithURL: self.recordingURL];
        dispatch_queue_t callbackQueue = dispatch_queue_create( "com.apple.sample.sessionmanager.recordercallback", DISPATCH_QUEUE_SERIAL ); // guarantee ordering of callbacks with a serial queue
        [self.recorder setDelegate:self callbackQueue:callbackQueue];
    }
}

static CGFloat angleOffsetFromPortraitOrientationToOrientation(AVCaptureVideoOrientation orientation)
{
    CGFloat angle = 0.0;
    
    switch (orientation) {
        case AVCaptureVideoOrientationPortrait:
            angle = 0.0;
            break;
        case AVCaptureVideoOrientationPortraitUpsideDown:
            angle = M_PI;
            break;
        case AVCaptureVideoOrientationLandscapeRight:
            angle = -M_PI_2;
            break;
        case AVCaptureVideoOrientationLandscapeLeft:
            angle = M_PI_2;
            break;
        default:
            break;
    }
    
    return angle;
}

- (CGAffineTransform)transformFromVideoBufferOrientationToOrientation:(AVCaptureVideoOrientation)orientation withAutoMirroring:(BOOL)mirror
{
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    // Calculate offsets from an arbitrary reference orientation (portrait)
    CGFloat orientationAngleOffset = angleOffsetFromPortraitOrientationToOrientation( orientation );
    CGFloat videoOrientationAngleOffset = angleOffsetFromPortraitOrientationToOrientation( self.videoOrientation );
    
    // Find the difference in angle between the desired orientation and the video orientation
    CGFloat angleOffset = orientationAngleOffset - videoOrientationAngleOffset;
    transform = CGAffineTransformMakeRotation(angleOffset);
    
    if ( self.videoDevice.position == AVCaptureDevicePositionFront ) {
        if ( mirror ) {
            transform = CGAffineTransformScale(transform, -1, 1);
        }
        else {
            if ( UIInterfaceOrientationIsPortrait(orientation) ) {
                transform = CGAffineTransformRotate(transform, M_PI);
            }
        }
    }
    
    return transform;
}

- (IBAction)toggleFastmoRecording:(id)sender {
//    [self setCaptureMode: @"fastmo"];
//    [[self fastmoButton] setEnabled:NO];
//    [self toggleMovieRecording ];
    
    if ( ! self.recorder.isRecording ) {
        
        [self setupRecording];

        // Disable the idle timer while recording
        [UIApplication sharedApplication].idleTimerDisabled = YES;
        
        // Make sure we have time to finish saving the movie if the app is backgrounded during recording
        if ( [[UIDevice currentDevice] isMultitaskingSupported] )
            self.backgroundRecordingID = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{}];
       
        CGAffineTransform videoTransform = [self transformFromVideoBufferOrientationToOrientation:(AVCaptureVideoOrientation)UIDeviceOrientationPortrait  withAutoMirroring:NO];
        
        [self.recorder addVideoTrackWithSourceFormatDescription:self.videoFormat transform:videoTransform];
        
        [self.recorder prepareToRecord];
    }
    else
    {
        [self.recorder finishRecording];
    }
    
}

- (IBAction)toggleSlowmoRecording:(id)sender {
//    
//    [self setCaptureMode: @"slowmo"];
//    [[self slowmoButton] setEnabled:NO];
//    [self toggleMovieRecording ];
        
    if ( ! self.recorder.isRecording ) {
        [self setupRecording];
        
        // Disable the idle timer while recording
        [UIApplication sharedApplication].idleTimerDisabled = YES;
        
        // Make sure we have time to finish saving the movie if the app is backgrounded during recording
        if ( [[UIDevice currentDevice] isMultitaskingSupported] )
            self.backgroundRecordingID = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{}];
        
        CGAffineTransform videoTransform = [self transformFromVideoBufferOrientationToOrientation:(AVCaptureVideoOrientation)UIDeviceOrientationPortrait  withAutoMirroring:NO];
        
        [self.recorder addVideoTrackWithSourceFormatDescription:self.videoFormat transform:videoTransform];
        
        [self.recorder prepareToRecord];
    }
    else
    {
        [self.recorder finishRecording];
    }
}

//- (void)toggleMovieRecording
//{
//	dispatch_async([self sessionQueue], ^{
//		if (![[self movieFileOutput] isRecording])
//		{
//			[self setLockInterfaceRotation:YES];
//			
//			if ([[UIDevice currentDevice] isMultitaskingSupported])
//			{
//				// Setup background task. This is needed because the captureOutput:didFinishRecordingToOutputFileAtURL: callback is not received until AVCam returns to the foreground unless you request background execution time. This also ensures that there will be time to write the file to the assets library when AVCam is backgrounded. To conclude this background execution, -endBackgroundTask is called in -recorder:recordingDidFinishToOutputFileURL:error: after the recorded file has been saved.
//				[self setBackgroundRecordingID:[[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil]];
//			}
//			
//			// Update the orientation on the movie file output video connection before starting recording.
//			[[[self movieFileOutput] connectionWithMediaType:AVMediaTypeVideo] setVideoOrientation:[[(AVCaptureVideoPreviewLayer *)[[self previewView] layer] connection] videoOrientation]];
//			
//			// Turning OFF flash for video recording
//			[AVCamViewController setFlashMode:AVCaptureFlashModeOff forDevice:[[self videoDeviceInput] device]];
//			
//			// Start recording to a temporary file.
//			NSString *outputFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[@"movie" stringByAppendingPathExtension:@"mov"]];
//			[[self movieFileOutput] startRecordingToOutputFileURL:[NSURL fileURLWithPath:outputFilePath] recordingDelegate:self];
//		}
//		else
//		{
//			[[self movieFileOutput] stopRecording];
//		}
//	});
//}

- (IBAction)changeCamera:(id)sender
{
	[[self cameraButton] setEnabled:NO];
	[[self fastmoButton] setEnabled:NO];
	[[self slowmoButton] setEnabled:NO];
	
	dispatch_async([self sessionQueue], ^{
		AVCaptureDevice *currentVideoDevice = [[self videoDeviceInput] device];
		AVCaptureDevicePosition preferredPosition = AVCaptureDevicePositionUnspecified;
		AVCaptureDevicePosition currentPosition = [currentVideoDevice position];
		
		switch (currentPosition)
		{
			case AVCaptureDevicePositionUnspecified:
				preferredPosition = AVCaptureDevicePositionBack;
				break;
			case AVCaptureDevicePositionBack:
				preferredPosition = AVCaptureDevicePositionFront;
				break;
			case AVCaptureDevicePositionFront:
				preferredPosition = AVCaptureDevicePositionBack;
				break;
		}
		
		AVCaptureDevice *videoDevice = [AVCamViewController deviceWithMediaType:AVMediaTypeVideo preferringPosition:preferredPosition];
		AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:nil];
		
		[[self session] beginConfiguration];
		
		[[self session] removeInput:[self videoDeviceInput]];
		if ([[self session] canAddInput:videoDeviceInput])
		{
			[[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:currentVideoDevice];
			
			[AVCamViewController setFlashMode:AVCaptureFlashModeAuto forDevice:videoDevice];
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:videoDevice];
			
			[[self session] addInput:videoDeviceInput];
			[self setVideoDeviceInput:videoDeviceInput];
		}
		else
		{
			[[self session] addInput:[self videoDeviceInput]];
		}
		
		[[self session] commitConfiguration];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			[[self cameraButton] setEnabled:YES];
			[[self fastmoButton] setEnabled:YES];
			[[self slowmoButton] setEnabled:YES];
		});
	});
}

//- (IBAction)snapStillImage:(id)sender
//{
//	dispatch_async([self sessionQueue], ^{
//		// Update the orientation on the still image output video connection before capturing.
//		[[[self stillImageOutput] connectionWithMediaType:AVMediaTypeVideo] setVideoOrientation:[[(AVCaptureVideoPreviewLayer *)[[self previewView] layer] connection] videoOrientation]];
//		
//		// Flash set to Auto for Still Capture
//		[AVCamViewController setFlashMode:AVCaptureFlashModeAuto forDevice:[[self videoDeviceInput] device]];
//		
//		// Capture a still image.
//		[[self stillImageOutput] captureStillImageAsynchronouslyFromConnection:[[self stillImageOutput] connectionWithMediaType:AVMediaTypeVideo] completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
//			
//			if (imageDataSampleBuffer)
//			{
//				NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
//				UIImage *image = [[UIImage alloc] initWithData:imageData];
//				[[[ALAssetsLibrary alloc] init] writeImageToSavedPhotosAlbum:[image CGImage] orientation:(ALAssetOrientation)[image imageOrientation] completionBlock:nil];
//			}
//		}];
//	});
//}

- (IBAction)focusAndExposeTap:(UIGestureRecognizer *)gestureRecognizer
{
	CGPoint devicePoint = [(AVCaptureVideoPreviewLayer *)[[self previewView] layer] captureDevicePointOfInterestForPoint:[gestureRecognizer locationInView:[gestureRecognizer view]]];
	[self focusWithMode:AVCaptureFocusModeAutoFocus exposeWithMode:AVCaptureExposureModeAutoExpose atDevicePoint:devicePoint monitorSubjectAreaChange:YES];
}

- (void)subjectAreaDidChange:(NSNotification *)notification
{
	CGPoint devicePoint = CGPointMake(.5, .5);
	[self focusWithMode:AVCaptureFocusModeContinuousAutoFocus exposeWithMode:AVCaptureExposureModeContinuousAutoExposure atDevicePoint:devicePoint monitorSubjectAreaChange:NO];
}

#pragma Utilities Methods
- (void) saveVideoFileToPhotos: (NSURL*) fileURL
{
    [[[ALAssetsLibrary alloc] init] writeVideoAtPathToSavedPhotosAlbum:fileURL completionBlock:^(NSURL *assetURL, NSError *error) {
        if (error)
            NSLog(@"%@", error);
        
        [[NSFileManager defaultManager] removeItemAtURL:fileURL error:nil];
        
        UIBackgroundTaskIdentifier backgroundRecordingID = [self backgroundRecordingID];
        [self setBackgroundRecordingID:UIBackgroundTaskInvalid];
        
        if (backgroundRecordingID != UIBackgroundTaskInvalid)
            [[UIApplication sharedApplication] endBackgroundTask:backgroundRecordingID];
    }];
}

- (void) processFastmoVideo : (NSURL *) videoFileURL
{
    // Create Asset
    NSDictionary *options = @{ AVURLAssetPreferPreciseDurationAndTimingKey : @YES };
    AVURLAsset *videoAsset = [[AVURLAsset alloc] initWithURL:videoFileURL options:options];
    
    //Get Video Track from Video
    AVAssetTrack *videoAssetTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];

    //Add video track to composition.
    AVMutableComposition *mutableComposition = [AVMutableComposition composition];
    AVMutableCompositionTrack *mutableCompositionVideoTrack = [mutableComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    
    [mutableCompositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero,videoAssetTrack.timeRange.duration) ofTrack:videoAssetTrack atTime:kCMTimeZero error:nil];
    
    double videoScaleFactor = 0.5;
    CMTime videoDuration = videoAsset.duration;
    CMTime newVideoDuration = CMTimeMake(videoDuration.value*videoScaleFactor, videoDuration.timescale);
    
    [mutableCompositionVideoTrack scaleTimeRange: CMTimeRangeMake( kCMTimeZero, videoDuration)
                                      toDuration: newVideoDuration ];
    
    //Video Orientation Is Wrong, correct it.
    [mutableCompositionVideoTrack setPreferredTransform: videoAssetTrack.preferredTransform ];
    
    //Add background audio
    NSString* audioPath = [[NSBundle mainBundle] pathForResource: @"fast" ofType:@"mp3"];
    NSURL* audioURL = [NSURL fileURLWithPath:audioPath];

    AVAsset *backgdAudioAsset = [AVURLAsset URLAssetWithURL:audioURL options:nil];
    AVAssetTrack *backgdAudioTrack = [[backgdAudioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];

    AVMutableCompositionTrack *mutableCompositionAudioTrack = [mutableComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];

    [mutableCompositionAudioTrack insertTimeRange: CMTimeRangeMake( kCMTimeZero, newVideoDuration) ofTrack:backgdAudioTrack atTime: kCMTimeZero error: nil] ;
    
    AVAssetExportSession* assetExport = [[AVAssetExportSession alloc] initWithAsset: mutableComposition presetName:AVAssetExportPresetMediumQuality];
    
    NSString *newVideoFile = [NSTemporaryDirectory() stringByAppendingPathComponent:[@"movie6" stringByAppendingPathExtension:@"mov"]];
    NSURL* newVideoURL = [NSURL fileURLWithPath: newVideoFile];
    assetExport.outputURL = newVideoURL;
    assetExport.outputFileType = AVFileTypeQuickTimeMovie;
    
    [assetExport exportAsynchronouslyWithCompletionHandler:^{
        
        switch ([assetExport status]) {
            case AVAssetExportSessionStatusFailed:
                NSLog(@"Export failed: %@", [[assetExport error] localizedDescription]);
                break;
            case AVAssetExportSessionStatusCancelled:
                NSLog(@"Export canceled");
                break;
            default:
                [[NSFileManager defaultManager] removeItemAtURL:videoFileURL error:nil];
                [self saveVideoFileToPhotos: newVideoURL ];
                break;
        }
    }];
}

#pragma mark File Output Delegate

//- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
//{
//	if (error)
//		NSLog(@"%@", error);
//	
//	[self setLockInterfaceRotation:NO];
//	
//	// Note the backgroundRecordingID for use in the ALAssetsLibrary completion handler to end the background task associated with this recording. This allows a new recording to be started, associated with a new UIBackgroundTaskIdentifier, once the movie file output's -isRecording is back to NO — which happens sometime after this method returns.
//	
//    if ( [[self captureMode] isEqualToString: @"fastmo"] ) {
//        [self processFastmoVideo: outputFileURL ];
//    }
//    else {
//        [ self saveVideoFileToPhotos: outputFileURL];
//    }
//}


- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
     self.videoFormat = CMSampleBufferGetFormatDescription(sampleBuffer);
    
    [self.recorder appendVideoSampleBuffer: sampleBuffer];
}

//#pragma mark Recording State Machine
//
//// call under @synchonized( self )
//- (void)transitionToRecordingStatus:(VideoSnakeRecordingStatus)newStatus error:(NSError*)error
//{
//    SEL delegateSelector = NULL;
//    VideoSnakeRecordingStatus oldStatus = _recordingStatus;
//    _recordingStatus = newStatus;
//    
//#if LOG_STATUS_TRANSITIONS
//    NSLog( @"VideoSnakeSessionManager recording state transition: %@->%@", [self stringForRecordingStatus:oldStatus], [self stringForRecordingStatus:newStatus] );
//#endif
//    
//    if ( newStatus != oldStatus ) {
//        if ( error && ( newStatus == VideoSnakeRecordingStatusIdle ) ) {
//            delegateSelector = @selector(recordingDidFailWithError:);
//        }
//        else {
//            error = nil; // only the above delegate method takes an error
//            if ( ( oldStatus == VideoSnakeRecordingStatusStartingRecording ) && ( newStatus == VideoSnakeRecordingStatusRecording ) )
//                delegateSelector = @selector(sessionManagerRecordingDidStart:);
//            else if ( ( oldStatus == VideoSnakeRecordingStatusRecording ) && ( newStatus == VideoSnakeRecordingStatusStoppingRecording ) )
//                delegateSelector = @selector(sessionManagerRecordingWillStop:);
//            else if ( ( oldStatus == VideoSnakeRecordingStatusStoppingRecording ) && ( newStatus == VideoSnakeRecordingStatusIdle ) )
//                delegateSelector = @selector(sessionManagerRecordingDidStop:);
//        }
//    }
//    
//    if ( delegateSelector && [self delegate] ) {
//        dispatch_async( _delegateCallbackQueue, ^{
//            @autoreleasepool {
//                if ( error )
//                    [[self delegate] performSelector:delegateSelector withObject:self withObject:error];
//                else
//                    [[self delegate] performSelector:delegateSelector withObject:self];
//            }
//        });
//    }
//}


- (void)movieRecorderDidFinishPreparing:(MovieRecorder *)recorder
{
//    @synchronized( self ) {
//        if ( _recordingStatus != VideoSnakeRecordingStatusStartingRecording ) {
//            @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Expected to be in StartingRecording state" userInfo:nil];
//            return;
//        }
//        
//        [self transitionToRecordingStatus:VideoSnakeRecordingStatusRecording error:nil];
//    }
}

- (void)movieRecorder:(MovieRecorder *)recorder didFailWithError:(NSError *)error
{
//    @synchronized( self ) {
//        self.recorder = nil;
//        [self transitionToRecordingStatus:VideoSnakeRecordingStatusIdle error:error];
//    }
}

- (void)movieRecorderDidFinishRecording:(MovieRecorder *)recorder
{

    self.recorder = nil;
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library writeVideoAtPathToSavedPhotosAlbum:self.recordingURL completionBlock:^(NSURL *assetURL, NSError *error) {
        
        [[NSFileManager defaultManager] removeItemAtURL:self.recordingURL error:NULL];
    }];
}

#pragma mark Device Configuration

- (void)focusWithMode:(AVCaptureFocusMode)focusMode exposeWithMode:(AVCaptureExposureMode)exposureMode atDevicePoint:(CGPoint)point monitorSubjectAreaChange:(BOOL)monitorSubjectAreaChange
{
	dispatch_async([self sessionQueue], ^{
		AVCaptureDevice *device = [[self videoDeviceInput] device];
		NSError *error = nil;
		if ([device lockForConfiguration:&error])
		{
			if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:focusMode])
			{
				[device setFocusMode:focusMode];
				[device setFocusPointOfInterest:point];
			}
			if ([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:exposureMode])
			{
				[device setExposureMode:exposureMode];
				[device setExposurePointOfInterest:point];
			}
			[device setSubjectAreaChangeMonitoringEnabled:monitorSubjectAreaChange];
			[device unlockForConfiguration];
		}
		else
		{
			NSLog(@"%@", error);
		}
	});
}

+ (void)setFlashMode:(AVCaptureFlashMode)flashMode forDevice:(AVCaptureDevice *)device
{
	if ([device hasFlash] && [device isFlashModeSupported:flashMode])
	{
		NSError *error = nil;
		if ([device lockForConfiguration:&error])
		{
			[device setFlashMode:flashMode];
			[device unlockForConfiguration];
		}
		else
		{
			NSLog(@"%@", error);
		}
	}
}

+ (AVCaptureDevice *)deviceWithMediaType:(NSString *)mediaType preferringPosition:(AVCaptureDevicePosition)position
{
	NSArray *devices = [AVCaptureDevice devicesWithMediaType:mediaType];
	AVCaptureDevice *captureDevice = [devices firstObject];
	
	for (AVCaptureDevice *device in devices)
	{
		if ([device position] == position)
		{
			captureDevice = device;
			break;
		}
	}
	
	return captureDevice;
}

#pragma mark UI

- (void)runStillImageCaptureAnimation
{
	dispatch_async(dispatch_get_main_queue(), ^{
		[[[self previewView] layer] setOpacity:0.0];
		[UIView animateWithDuration:.25 animations:^{
			[[[self previewView] layer] setOpacity:1.0];
		}];
	});
}

- (void)checkDeviceAuthorizationStatus
{
	NSString *mediaType = AVMediaTypeVideo;
	
	[AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
		if (granted)
		{
			//Granted access to mediaType
			[self setDeviceAuthorized:YES];
		}
		else
		{
			//Not granted access to mediaType
			dispatch_async(dispatch_get_main_queue(), ^{
				[[[UIAlertView alloc] initWithTitle:@"AVCam!"
											message:@"AVCam doesn't have permission to use Camera, please change privacy settings"
										   delegate:self
								  cancelButtonTitle:@"OK"
								  otherButtonTitles:nil] show];
				[self setDeviceAuthorized:NO];
			});
		}
	}];
}

@end
