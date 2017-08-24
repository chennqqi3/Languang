//
//  ScanQRCodeViewController.m
//  mettingDetail
//
//  Created by Alex-L on 2017/6/19.
//  Copyright © 2017年 Alex-L. All rights reserved.
//

#import "ScanQRCodeViewControllerArc.h"
#import <AVFoundation/AVFoundation.h>
#import "StringUtil.h"
#import "UIAdapterUtil.h"
#import "eCloudDefine.h"
#import "ScanResultWebviewViewControllerArc.h"

#define SCAN_VIEW_WIDTH (IS_IPHONE_6 ? 230 : (IS_IPHONE_6P ? 250 : 220))

@interface ScanQRCodeViewControllerArc ()<AVCaptureMetadataOutputObjectsDelegate>
{
    NSTimer *_timer;
    CGFloat _scanCursorY;
}
@property (weak, nonatomic) IBOutlet UIImageView *scanImage1;
@property (weak, nonatomic) IBOutlet UIImageView *scanImage2;
@property (weak, nonatomic) IBOutlet UIImageView *scanImage3;
@property (weak, nonatomic) IBOutlet UIImageView *scanImage4;

@property (retain, nonatomic) IBOutlet UILabel *descriptionLabel;


@property (weak, nonatomic) IBOutlet UIView *scanView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scanViewWidth;

@property (strong, nonatomic) UIImageView *scanCursor;
@property (strong, nonatomic) UIView *backgroundView;

// 原生扫描用到的类
@property (strong,nonatomic)AVCaptureDevice * device;
@property (strong,nonatomic)AVCaptureDeviceInput * input;
@property (strong,nonatomic)AVCaptureMetadataOutput * output;
@property (strong,nonatomic)AVCaptureSession * session;
@property (strong,nonatomic)AVCaptureVideoPreviewLayer * preview;

@end

@implementation ScanQRCodeViewControllerArc

- (void)dealloc
{
    NSLog(@"%s", __func__);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [UIAdapterUtil hideTabBar:self];
    
    if (self.session)
    {
        [self startScan];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self stopScan];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"扫一扫";
    
    self.view.frame = [UIScreen mainScreen].bounds;
    self.view.clipsToBounds = YES;
    
    self.scanViewWidth.constant = SCAN_VIEW_WIDTH;
    
    self.descriptionLabel.text = @"将二维码/条形码放入框内,即可自动扫描";
    
    self.scanImage1.image = [StringUtil getImageByResName:@"icon_scan1"];
    self.scanImage2.image = [StringUtil getImageByResName:@"icon_scan2"];
    self.scanImage3.image = [StringUtil getImageByResName:@"icon_scan3"];
    self.scanImage4.image = [StringUtil getImageByResName:@"icon_scan4"];
    
    self.backgroundView = [[UIView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-SCREEN_HEIGHT)/2.0, -35-32, SCREEN_HEIGHT, SCREEN_HEIGHT)];
    self.backgroundView.layer.borderColor = [UIColor colorWithWhite:0 alpha:0.5].CGColor;
    self.backgroundView.layer.borderWidth = (SCREEN_HEIGHT-SCAN_VIEW_WIDTH)/2.0;
    [self.view insertSubview:self.backgroundView atIndex:0];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-35, SCREEN_WIDTH, 60)];
    view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    [self.view addSubview:view];
    
    
    self.scanCursor = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, SCAN_VIEW_WIDTH-10*2, 8)];
    self.scanCursor.image = [StringUtil getImageByResName:@"icon_cursor"];
    [self.scanView addSubview:self.scanCursor];
    
    
    
    // Device
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Input
    _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    
    // Output
    _output = [[AVCaptureMetadataOutput alloc]init];
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    // Session
    _session = [[AVCaptureSession alloc]init];
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    
    // 连接输入和输出
    if ([_session canAddInput:self.input])
    {
        [_session addInput:self.input];
    }
    
    if ([_session canAddOutput:self.output])
    {
        [_session addOutput:self.output];
    }
    
    _output.metadataObjectTypes =@[AVMetadataObjectTypeQRCode];
    
    
    _preview =[AVCaptureVideoPreviewLayer layerWithSession:_session];
    _preview.videoGravity =AVLayerVideoGravityResizeAspectFill;
    _preview.frame =self.view.layer.bounds;
    [self.view.layer insertSublayer:_preview atIndex:0];
    
    //设置扫描区域
    CGFloat top = self.scanView.frame.origin.y/SCREEN_HEIGHT;
    CGFloat left = self.scanView.frame.origin.x/SCREEN_WIDTH;
    CGFloat width = SCAN_VIEW_WIDTH/SCREEN_WIDTH;
    CGFloat height = SCAN_VIEW_WIDTH/SCREEN_HEIGHT;
    ///top 与 left 互换  width 与 height 互换
    [_output setRectOfInterest:CGRectMake(top,left, height, width)];
    
    // 开始扫描
    [self startScan];
}

#pragma mark - <AVCaptureMetadataOutputObjectsDelegate>
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    NSString *stringValue;
    if ([metadataObjects count] >0)
    {
        //停止扫描
        [self stopScan];
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex:0];
        stringValue = metadataObject.stringValue;
        NSLog(@"%@", stringValue);
        
        ScanResultWebviewViewControllerArc *webviewVC = [[ScanResultWebviewViewControllerArc alloc] init];
        webviewVC.urlstr = stringValue;
        webviewVC.urlIsFromScanResult = YES;
        [self.navigationController pushViewController:webviewVC animated:YES];
    }
    else
    {
        NSLog(@"无扫描信息 重新开始扫描");
        [_session startRunning];
    }
}

- (void)startScan
{
    [_session startRunning];
    
    _timer = [NSTimer timerWithTimeInterval:.015f target:self selector:@selector(timerScan)userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop]addTimer:_timer forMode:NSDefaultRunLoopMode];
}

- (void)timerScan
{
    _scanCursorY += 1;
    if (_scanCursorY > (SCAN_VIEW_WIDTH-5)) {
        _scanCursorY = 0;
    }
    
    CGRect rect = self.scanCursor.frame;
    rect.origin.y = _scanCursorY;
    self.scanCursor.frame = rect;
}

- (void)stopScan
{
    [_session stopRunning];
    
    
    [_timer invalidate];
    _timer = nil;
}

@end
