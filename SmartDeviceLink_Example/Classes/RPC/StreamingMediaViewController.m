//
//  StreamingMediaViewController.m
//  SmartDeviceLink-iOS
//
//  Created by WuLeilei on 17/3/7.
//  Copyright © 2017年 smartdevicelink. All rights reserved.
//

#import "StreamingMediaViewController.h"
#import <AVFoundation/AVFoundation.h>

#import "SDLStreamingMediaManager.h"
#import "SDLDisplayCapabilities.h"
#import "SDLDisplayType.h"
#import "SDLNames.h"
#import "SDLMediaClockFormat.h"
#import "SDLProxy.h"
#import "SDLProtocol.h"
#import "SDLManager.h"

@interface StreamingMediaViewController () <AVCaptureVideoDataOutputSampleBufferDelegate>
{
    SDLStreamingMediaManager *_streamingMediaManager;
    
    UISegmentedControl *_segmentedControl;
    
    AVCaptureSession *_captureSession;
}
@end

@implementation StreamingMediaViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Submit" style:UIBarButtonItemStylePlain target:self action:@selector(submitRPC:)];
    
    // video quality
    UILabel *segLabel = [[UILabel alloc] init];
    segLabel.text = @"视频质量：";
    [_contentView addSubview:segLabel];
    [segLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@(64 + 20));
        make.left.equalTo(@20);
        make.right.equalTo(@-20);
        make.height.equalTo(@30);
    }];
    
    _segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"低", @"中", @"高"]];
    _segmentedControl.selectedSegmentIndex = 0;
    [_contentView addSubview:_segmentedControl];
    [_segmentedControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(segLabel.mas_bottom);
        make.left.right.equalTo(segLabel);
        make.height.equalTo(@30);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_streamingMediaManager stopVideoSession];
    [_streamingMediaManager stopAudioSession];
    _streamingMediaManager = nil;
}

- (void)submitRPC:(UIBarButtonItem *)item {
    item.enabled = NO;
    
    NSMutableDictionary* dict = [@{NAMES_displayType:[SDLDisplayType GEN2_6_DMA],
                                   NAMES_textFields:[@[@"hello"] mutableCopy],
                                   NAMES_imageFields:[@[@"123"] mutableCopy],
                                   NAMES_mediaClockFormats:[@[[SDLMediaClockFormat CLOCKTEXT1], [SDLMediaClockFormat CLOCK3], [SDLMediaClockFormat CLOCKTEXT3]] copy],
                                   NAMES_graphicSupported:@YES,
                                   NAMES_templatesAvailable:[@[@"String", @"String", @"String"] mutableCopy],
//                                   NAMES_screenParams:screenParams,
                                   NAMES_numCustomPresetsAvailable:@43} mutableCopy];
    SDLDisplayCapabilities* displayCapabilities = [[SDLDisplayCapabilities alloc] initWithDictionary:dict];
    
    __weak typeof(self) weakSelf = self;
//    _streamingMediaManager = [ProxyManager sharedManager].sdlManager.proxy.streamingMediaManager;
    _streamingMediaManager = [[SDLStreamingMediaManager alloc] initWithProtocol:[ProxyManager sharedManager].sdlManager.proxy.protocol displayCapabilities:displayCapabilities];
    [[ProxyManager sharedManager].sdlManager.proxy.protocol.protocolDelegateTable addObject:_streamingMediaManager];
    [_streamingMediaManager startVideoSessionWithStartBlock:^(BOOL success, NSError * _Nullable error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowLogNotification" object:[NSString stringWithFormat:@"startVideoSession %@ %@", @(success), error]];
        if (success) {
            [weakSelf setupCaptureSession];
        } else {
            NSLog(@"%@", error);
        }
    }];
}

- (void)setupCaptureSession {
    NSError *error = nil;
    
    // Create the session
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    
    // Configure the session to produce lower resolution video frames, if your
    // processing algorithm can cope. We'll specify medium quality for the
    // chosen device.
    NSString *sessionPreset;
    switch (_segmentedControl.selectedSegmentIndex) {
        case 0:
            sessionPreset = AVCaptureSessionPresetLow;
            break;
            
        case 1:
            sessionPreset = AVCaptureSessionPresetMedium;
            break;
            
        case 2:
            sessionPreset = AVCaptureSessionPresetHigh;
            break;
            
        default:
            sessionPreset = AVCaptureSessionPresetLow;
            break;
    }
    session.sessionPreset = sessionPreset;
    
    // Find a suitable AVCaptureDevice
    AVCaptureDevice *device = [AVCaptureDevice
                               defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Create a device input with the device and add it to the session.
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device
                                                                        error:&error];
    if (!input) {
        // Handling the error appropriately.
    }
    [session addInput:input];
    
    // Create a VideoDataOutput and add it to the session
    AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
    [session addOutput:output];
    
    // Configure your output.
    dispatch_queue_t queue = dispatch_queue_create("myQueue", NULL);
    [output setSampleBufferDelegate:self queue:queue];
    // Specify the pixel format
    output.videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSNumber numberWithInt:kCVPixelFormatType_32BGRA], kCVPixelBufferPixelFormatTypeKey,
                            [NSNumber numberWithInt: 400], (id)kCVPixelBufferWidthKey,
                            [NSNumber numberWithInt: 240], (id)kCVPixelBufferHeightKey,
                            nil];
    
    // setup video connection
    AVCaptureConnection *videoConnection = [output connectionWithMediaType:AVMediaTypeVideo];
    videoConnection.videoOrientation = AVCaptureVideoOrientationPortrait;
    
    AVCaptureVideoPreviewLayer *preLayer = [AVCaptureVideoPreviewLayer layerWithSession: session];
    preLayer.frame = CGRectMake(20, 64 + 100, 300, 240);
    preLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:preLayer];
    [preLayer setNeedsDisplay];
    
    // Start the session running to start the flow of data
    [session startRunning];
}

// Delegate routine that is called when a sample buffer was written
- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection {
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    [_streamingMediaManager sendVideoData:imageBuffer];
}

@end
