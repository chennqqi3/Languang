//
//  ViewController.m
//  iOS7_BarcodeScanner
//
//  Created by Jake Widmer on 11/16/13.
//  Copyright (c) 2013 Jake Widmer. All rights reserved.
//


#import "ScannerViewController.h"
#import "NotificationUtil.h"
#import "UIAdapterUtil.h"

#import "NewMyViewControllerOfCustomTableview.h"

#import "SettingsViewController.h"
#import "Barcode.h"
#import <AVFoundation/AVFoundation.h>
#import "JSONKit.h"
#import "IOSSystemDefine.h"
#import "StringUtil.h"
#import "conn.h"
#import "UserDefaults.h"
#import "ASIFormDataRequest.h"

#ifdef _LANGUANG_FLAG_
#import "LGMettingUtilARC.h"
#import "LGMettingDefine.h"
#import "LGMettingDetailViewControllerArc.h"
#endif

#ifdef _XIANGYUAN_FLAG_
#import "XIANGYUANOfficeLoginViewControllerARC.h"
#import "XIANGYUANAppViewControllerARC.h"
#endif
@interface ScannerViewController ()
{
//    加载提示
    UIActivityIndicatorView *indicatorView;
    UILabel *_label;
    
//
    float centerViewSize;
    float spacing;

    UIImageView *centerView;
    UIImageView *line;
    UILabel *msg;
    
    
}
@property (strong, nonatomic) NSMutableArray * foundBarcodes;
@property (strong, nonatomic) UIView *previewView;

@property (strong, nonatomic) SettingsViewController * settingsVC;


@end

@implementation ScannerViewController{
    /* Here’s a quick rundown of the instance variables (via 'iOS 7 By Tutorials'):
     
     1. _captureSession – AVCaptureSession is the core media handling class in AVFoundation. It talks to the hardware to retrieve, process, and output video. A capture session wires together inputs and outputs, and controls the format and resolution of the output frames.
     
     2. _videoDevice – AVCaptureDevice encapsulates the physical camera on a device. Modern iPhones have both front and rear cameras, while other devices may only have a single camera.
     
     3. _videoInput – To add an AVCaptureDevice to a session, wrap it in an AVCaptureDeviceInput. A capture session can have multiple inputs and multiple outputs.
     
     4. _previewLayer – AVCaptureVideoPreviewLayer provides a mechanism for displaying the current frames flowing through a capture session; it allows you to display the camera output in your UI.
     5. _running – This holds the state of the session; either the session is running or it’s not.
     6. _metadataOutput - AVCaptureMetadataOutput provides a callback to the application when metadata is detected in a video frame. AV Foundation supports two types of metadata: machine readable codes and face detection.
     7. _backgroundQueue - Used for showing alert using a separate thread.
     */
    AVCaptureSession *_captureSession;
    AVCaptureDevice *_videoDevice;
    AVCaptureDeviceInput *_videoInput;
    AVCaptureVideoPreviewLayer *_previewLayer;
    BOOL _running;
    AVCaptureMetadataOutput *_metadataOutput;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [UIAdapterUtil hideTabBar:self];
    
    [UIAdapterUtil setLeftButtonItemWithTitle:nil andTarget:self andSelector:@selector(backButtonPressed:)];
    self.title = @"二维码";
    
    [self setupCaptureSession];
    
    [self.view setBackgroundColor:[UIColor blackColor]];
    
    _previewView = [[UIView alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:_previewView];
    
    _previewLayer.frame = _previewView.bounds;
    [_previewView.layer addSublayer:_previewLayer];
    self.foundBarcodes = [[NSMutableArray alloc] init];
    
    // listen for going into the background and stop the session
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(applicationWillEnterForeground:)
     name:UIApplicationWillEnterForegroundNotification
     object:nil];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(applicationDidEnterBackground:)
     name:UIApplicationDidEnterBackgroundNotification
     object:nil];
    
    // set default allowed barcode types, remove types via setings menu if you don't want them to be able to be scanned
    self.allowedBarcodeTypes = [NSMutableArray new];
    [self.allowedBarcodeTypes addObject:@"org.iso.QRCode"];
    [self.allowedBarcodeTypes addObject:@"org.iso.PDF417"];
    [self.allowedBarcodeTypes addObject:@"org.gs1.UPC-E"];
    [self.allowedBarcodeTypes addObject:@"org.iso.Aztec"];
    [self.allowedBarcodeTypes addObject:@"org.iso.Code39"];
    [self.allowedBarcodeTypes addObject:@"org.iso.Code39Mod43"];
    [self.allowedBarcodeTypes addObject:@"org.gs1.EAN-13"];
    [self.allowedBarcodeTypes addObject:@"org.gs1.EAN-8"];
    [self.allowedBarcodeTypes addObject:@"com.intermec.Code93"];
    [self.allowedBarcodeTypes addObject:@"org.iso.Code128"];
    
    indicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    indicatorView.center = CGPointMake(self.view.frame.size.width * 0.5, self.view.frame.size.height * 0.5);
    [self.view addSubview:indicatorView];
    [indicatorView startAnimating];
    
    _label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 20)];
    _label.textColor = [UIColor whiteColor];
    _label.font = [UIFont systemFontOfSize:16.0];
    _label.text = @"正在加载...";
    _label.textAlignment = NSTextAlignmentCenter;
    _label.center = CGPointMake(indicatorView.center.x,indicatorView.center.y + 40);

    [self.view addSubview:_label];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(_previewView.frame.size.width / 2 -20, _previewView.frame.size.height- 120, 40, 30);
    [button setTitle:@"取消" forState:UIControlStateNormal];
//    [button.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [button addTarget:self action:@selector(cancle) forControlEvents:UIControlEventTouchUpInside];
    [_previewView addSubview:button];
//    增加动画
    [self setOverlayPickerView];

}

- (void)cancle{
    
    [self.navigationController popViewControllerAnimated:YES];
    
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self startRunning];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopRunning];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - AV capture methods

- (void)setupCaptureSession {
    // 1
    if (_captureSession) return;
    // 2
    _videoDevice = [AVCaptureDevice
                    defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (!_videoDevice) {
        NSLog(@"No video camera on this device!");
        return;
    }
    // 3
    _captureSession = [[AVCaptureSession alloc] init];
    // 4
    _videoInput = [[AVCaptureDeviceInput alloc]
                   initWithDevice:_videoDevice error:nil];
    // 5
    if ([_captureSession canAddInput:_videoInput]) {
        [_captureSession addInput:_videoInput];
    }
    // 6
    _previewLayer = [[AVCaptureVideoPreviewLayer alloc]
                     initWithSession:_captureSession];
    _previewLayer.videoGravity =
    AVLayerVideoGravityResizeAspectFill;
    
    
    // capture and process the metadata
    _metadataOutput = [[AVCaptureMetadataOutput alloc] init];
    dispatch_queue_t metadataQueue =
    dispatch_queue_create("com.1337labz.featurebuild.metadata", 0);
    [_metadataOutput setMetadataObjectsDelegate:self
                                          queue:metadataQueue];
    if ([_captureSession canAddOutput:_metadataOutput]) {
        [_captureSession addOutput:_metadataOutput];
    }
    
    [_captureSession addObserver:self forKeyPath:@"running" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)startRunning {
    if (_running) return;
    [_captureSession startRunning];
    _metadataOutput.metadataObjectTypes =
    _metadataOutput.availableMetadataObjectTypes;
    _running = YES;
    
    [indicatorView stopAnimating];
    [_label setHidden:YES];
}
- (void)stopRunning {
    if (!_running) return;
    [_captureSession stopRunning];
    _running = NO;
}

//  handle going foreground/background
- (void)applicationWillEnterForeground:(NSNotification*)note {
    [self startRunning];
}
- (void)applicationDidEnterBackground:(NSNotification*)note {
    [self stopRunning];
}

#pragma mark - Button action functions
- (IBAction)settingsButtonPressed:(id)sender {
    [self performSegueWithIdentifier:@"toSettings" sender:self];
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"toSettings"]) {
        self.settingsVC = (SettingsViewController *)[self.storyboard instantiateViewControllerWithIdentifier: @"SettingsViewController"];
        self.settingsVC = segue.destinationViewController;
        self.settingsVC.delegate = self;
    }
}


#pragma mark - Delegate functions

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputMetadataObjects:(NSArray *)metadataObjects
       fromConnection:(AVCaptureConnection *)connection
{
//    [metadataObjects
//     enumerateObjectsUsingBlock:^(AVMetadataObject *obj,
//                                  NSUInteger idx,
//                                  BOOL *stop)
//     {
//         if ([obj isKindOfClass:
//              [AVMetadataMachineReadableCodeObject class]])
//         {
//             // 3
//             AVMetadataMachineReadableCodeObject *code =
//             (AVMetadataMachineReadableCodeObject*)
//             [_previewLayer transformedMetadataObjectForMetadataObject:obj];
//             // 4
//             Barcode * barcode = [Barcode processMetadataObject:code];
//             
//             for(NSString * str in self.allowedBarcodeTypes){
//                if([barcode.getBarcodeType isEqualToString:str]){
//                    [self validBarcodeFound:barcode];
//                    return;
//                }
//            }
//         }
//     }];
    
    for (AVMetadataObject *obj in metadataObjects) {
        
        if ([obj isKindOfClass:[AVMetadataMachineReadableCodeObject class]]) {
            
            AVMetadataMachineReadableCodeObject *code = (AVMetadataMachineReadableCodeObject*)
            [_previewLayer transformedMetadataObjectForMetadataObject:obj];
            
            Barcode * barcode = [Barcode processMetadataObject:code];
            
            for(NSString * str in self.allowedBarcodeTypes){
                if([barcode.getBarcodeType isEqualToString:str]){
                    [self validBarcodeFound:barcode];
                    return;
                }
            }
        }
    }
}
- (void) validBarcodeFound:(Barcode *)barcode{
    [self stopRunning];
    [self.foundBarcodes addObject:barcode];
    
    [self performSelectorOnMainThread:@selector(openScannerResult) withObject:nil waitUntilDone:NO];

    //    [self showBarcodeAlert:barcode];
}

- (void)openScannerResult
{
    if (self.foundBarcodes.count) {
        Barcode *_barCode = self.foundBarcodes.lastObject;
        if ([_barCode.getBarcodeType isEqualToString:@"org.iso.QRCode"]) {
            
            if (_captureSession) {
                [_captureSession removeObserver:self forKeyPath:@"running" context:nil];
                _captureSession = nil;
            }
            
            NSString *url = _barCode.getBarcodeData;
            
            if (self.processType == scanQRCode_open_result) {
                if ([self.navigationController.topViewController isKindOfClass:[ScannerViewController class]]){
#ifdef _XIANGYUAN_FLAG_
                    
                    NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:url options:0];
                    NSString *decodedString = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
                    //                {
                    //                "uid": "7ec84611-be8f-49eb-9214-9f8d6bf0e1c1",
                    //                "sid": "66EAA7F623B85B53D4AB70FBD756F72E",
                    //                "app": "isso"
                    //                }
                    NSData* jsonData = [decodedString dataUsingEncoding:NSUTF8StringEncoding];
                    NSDictionary *dic = [jsonData objectFromJSONData];
                    
                    XIANGYUANOfficeLoginViewControllerARC *office = [[XIANGYUANOfficeLoginViewControllerARC alloc]init];
                    office.dict = dic;
                    [self.navigationController pushViewController:office animated:YES];
#else
                    
                    [NewMyViewControllerOfCustomTableview openLongHuHtml5:url withController:self];
#endif
                    
                }
                
            }else{
                
#ifdef _LANGUANG_FLAG_
      
                [self meetingIn:url];
                
#else
                
                if (self.delegate && [self.delegate respondsToSelector:@selector(barcodeFound:andBarcode:)]) {
                    [self.delegate barcodeFound:self andBarcode:url];
                }
                [self.navigationController popViewControllerAnimated:YES];
                
#endif
                

                
            }
        }
    }
}

- (void) showBarcodeAlert:(Barcode *)barcode{
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Code to do in background processing
        NSString * alertMessage = @"You found a barcode with type ";
        alertMessage = [alertMessage stringByAppendingString:[barcode getBarcodeType]];
//        alertMessage = [alertMessage stringByAppendingString:@" and data "];
//        alertMessage = [alertMessage stringByAppendingString:[barcode getBarcodeData]];
        alertMessage = [alertMessage stringByAppendingString:@"\n\nBarcode added to array of "];
        alertMessage = [alertMessage stringByAppendingString:[NSString stringWithFormat:@"%lu",(unsigned long)[self.foundBarcodes count]-1]];
        alertMessage = [alertMessage stringByAppendingString:@" previously found barcodes."];
        
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Barcode Found!"
                                                          message:alertMessage
                                                         delegate:self
                                                cancelButtonTitle:@"Done"
                                                otherButtonTitles:@"Scan again",nil];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // Code to update the UI/send notifications based on the results of the background processing
            [message show];

        });
    });
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (alertView.tag == 1001) {
        
        UIViewController *target = nil;
        for (UIViewController * controller in self.navigationController.viewControllers) {
            
#ifdef _LANGUANG_FLAG_
            
            if ([controller isKindOfClass:[LGMettingDetailViewControllerArc class]]){
                target = controller;
            }
            
#endif
            
        }
        if (target) {
            [self.navigationController popToViewController:target animated:YES];
        }
        
    }else{
        
        if(buttonIndex == 0){
            //Code for Done button
            // TODO: Create a finished view
        }
        if(buttonIndex == 1){
            //Code for Scan more button
            [self startRunning];
        }
    }
}

- (void) settingsChanged:(NSMutableArray *)allowedTypes{
    for(NSObject * obj in allowedTypes){
        NSLog(@"%@",obj);
    }
    if(allowedTypes){
        self.allowedBarcodeTypes = [NSMutableArray arrayWithArray:allowedTypes];
    }
}

#pragma mark ======动画=========

- (void)setOverlayPickerView
{
    centerViewSize = SCREEN_WIDTH * 0.70;
    
    centerView = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - centerViewSize) * 0.5, (SCREEN_HEIGHT - centerViewSize) * 0.5 - 20, centerViewSize, centerViewSize)];
//    centerView.center = self.view.center;
    centerView.image = [UIImage imageNamed:@"扫描框.png"];
    centerView.contentMode = UIViewContentModeScaleAspectFit;
    centerView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:centerView];
    centerView.hidden = YES;
    
    spacing = 10;
    float lineImageWidth = centerViewSize - spacing;
    line = [[UIImageView alloc] initWithFrame:CGRectMake(spacing * 0.5, spacing * 0.5 , lineImageWidth, 2)];
    line.image = [UIImage imageNamed:@"扫描线.png"];
    line.contentMode = UIViewContentModeScaleAspectFill;
    line.backgroundColor = [UIColor clearColor];
    [centerView addSubview:line];
    
    msg = [[UILabel alloc] initWithFrame:CGRectMake(centerView.frame.origin.x, centerView.frame.origin.y +  centerViewSize + 20, centerViewSize, 20)];
    msg.backgroundColor = [UIColor clearColor];
    msg.textColor = [UIColor whiteColor];
    msg.textAlignment = NSTextAlignmentCenter;
    [msg setAdjustsFontSizeToFitWidth:YES];
//    msg.font = [UIFont systemFontOfSize:16];
    msg.text = @"将二维码放入框内,即可自动扫描";
    [self.view addSubview:msg];
    msg.hidden = YES;

}


/**
 *  @author Whde
 *
 *  监听扫码状态-修改扫描动画
 *
 *  @param keyPath
 *  @param object
 *  @param change
 *  @param context
 */
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context{
    if ([object isKindOfClass:[AVCaptureSession class]]) {
        BOOL isRunning = ((AVCaptureSession *)object).isRunning;
        if (isRunning) {
            [self addAnimation];
        }else{
            [self removeAnimation];
        }
    }
}


/**
 *  @author Whde
 *
 *  添加扫码动画
 */
- (void)addAnimation{
    centerView.hidden = NO;
    msg.hidden = NO;
    line.hidden = NO;
    CABasicAnimation *animation = [[self class] moveYTime:2 fromY:[NSNumber numberWithFloat:10] toY:[NSNumber numberWithFloat:centerViewSize - spacing - 2] rep:OPEN_MAX];
    [line.layer addAnimation:animation forKey:@"LineAnimation"];
}

+ (CABasicAnimation *)moveYTime:(float)time fromY:(NSNumber *)fromY toY:(NSNumber *)toY rep:(int)rep
{
    CABasicAnimation *animationMove = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    [animationMove setFromValue:fromY];
    [animationMove setToValue:toY];
    animationMove.duration = time;
    animationMove.delegate = self;
    animationMove.repeatCount  = rep;
    animationMove.fillMode = kCAFillModeForwards;
    animationMove.removedOnCompletion = NO;
    animationMove.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    return animationMove;
}

/**
 *  @author Whde
 *
 *  去除扫码动画
 */
- (void)removeAnimation{
    [line.layer removeAnimationForKey:@"LineAnimation"];
    line.hidden = YES;
    centerView.hidden = YES;
    msg.hidden = YES;
}

//
//
///**
// *  @author Whde
// *
// *  从父视图中移出
// */
//- (void)selfRemoveFromSuperview{
//    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
//        self.view.alpha = 0;
//    } completion:^(BOOL finished) {
//        [self.view removeFromSuperview];
//        [self removeFromParentViewController];
//    }];
////    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
//}
//
///**
// *  @author Whde
// *
// *  扫码取消button方法
// *
// *  @return
// */
//- (void)dismissOverlayView:(id)sender{
//    [self selfRemoveFromSuperview];
//}


//返回 按钮
-(void) backButtonPressed:(id) sender{
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc{
    if (_captureSession) {
        [_captureSession removeObserver:self forKeyPath:@"running"];
        _captureSession = nil;
    }
}

- (void)meetingIn:(NSString *)mettingId{

#ifdef _LANGUANG_FLAG_
    Emp *emp = [conn getConn].curUser;
    NSString *curTime = [[conn getConn] getSCurrentTime];
    NSString *empID = [NSString stringWithFormat:@"%@",emp.empCode];

    
    NSString *md5Str = [StringUtil getMD5Str:[NSString stringWithFormat:@"%@%@%@",empID,curTime,LGmd5_password]];
    

    NSString *oaToken = [UserDefaults getLoginToken];
    NSString *type;
    NSDictionary *dict = [UserDefaults getLanGuangMeetingSign:mettingId];
    if (dict == nil) {
        
        type = @"0";
        
    }else{
        
        if([dict[@"meetingID"] isEqualToString:mettingId]){
            
            type = dict[@"data"];
            
        }else{
            
            type = @"0";
        }
    }
    
    
    //http://im.brc.com.cn/middleware/conference/meetingSign?access_token=1b5e8731e5ff44928991b3098fe52464&id=2825475087&timestamp=1496735269537&md5key=9702414DB7B35552B1D6360AF22C2A19&account=lhai
    
    NSString *urlString = [NSString stringWithFormat:@"%@/middleware/conference/meetingSign?",[LGMettingUtilARC get9013Url]];
   
    NSString *url = [NSString stringWithFormat:@"%@account=%@&md5key=%@&timeStamp%@&access_token=%@&type=%@&id=%@",urlString,empID,md5Str,curTime,oaToken,type,mettingId];
    
    //        NSString *urlString = [NSString stringWithFormat:@"http://dev.brc.com.cn:8085/api/meeting/list?access_token=1b5e8731e5ff44928991b3098fe52464&type=%ld&showrows=10&page=%ld",(long)type,(long)page];
    ASIFormDataRequest *requestForm = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:url]];
    
    [requestForm startSynchronous];
    
    
    //输入返回的信息
    [LogUtil debug:[NSString stringWithFormat:@"%s 获取签到返回信息 %@",__FUNCTION__,[requestForm responseString]]];
    //{"type":"会议签到与签退接口","status":100,"result":"操作成功","data":0,"contentType":"application/json"}
    NSString *jsonString = [requestForm responseString];
    NSData* jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *resultDict = [jsonData objectFromJSONData];
    if ([resultDict[@"status"] intValue] ==100) {
        
        NSString *message;
        NSString *data;
        if ([resultDict[@"data"] intValue] == 0) {
            
            message = @"签到成功";
            data = @"1";
            [self addAlert:message tag:1001];
            
        }else if ([resultDict[@"data"] intValue] == 1){
            
            message = @"签退成功";
            data = @"0";
            [self addAlert:message tag:1001];
        }
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        //[dict setObject:mettingId forKey:@"meetingID"];
        [dict setObject:data forKey:@"data"];
        
        [UserDefaults setLanGuangMeetingSign:mettingId dict:dict];
        
                                                        
    }else{
        
        [self addAlert:@"扫描二维码失败，请重新扫描" tag:1001];
    }
#endif
    
}

- (void)addAlert:(NSString *)message tag:(int)tag{
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[StringUtil getAlertTitle] message:message delegate:self cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"] otherButtonTitles:nil];
    alert.tag = tag;
    [alert show];
}

@end


