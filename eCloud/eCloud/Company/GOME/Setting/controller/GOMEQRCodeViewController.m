//
//  GOMEQRCodeViewController.m
//  eCloud
//
//  Created by Alex L on 17/3/16.
//  Copyright © 2017年  lyong. All rights reserved.
//

#import "GOMEQRCodeViewController.h"
#import "StringUtil.h"
#import "eCloudDefine.h"

@interface GOMEQRCodeViewController ()

@property (retain, nonatomic) IBOutlet UIImageView *gomeLogo;
@property (retain, nonatomic) IBOutlet UIImageView *QRCodeView;


- (IBAction)gotoDownloadWebView:(UITapGestureRecognizer *)sender;

@property (retain, nonatomic) IBOutlet NSLayoutConstraint *qrCodeConstraintsLeft;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *qrCodeConstraintsRight;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *logoTopConstraints;


@end

@implementation GOMEQRCodeViewController

- (void)dealloc {
    
    [_qrCodeConstraintsLeft release];
    [_qrCodeConstraintsRight release];
    [_gomeLogo release];
    [_QRCodeView release];
    [_logoTopConstraints release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.gomeLogo.image = [StringUtil getImageByResName:@"settings_logo"];
    self.QRCodeView.image = [StringUtil getImageByResName:@"setting_download_qrcode"];
    
    self.title = [StringUtil getLocalizableString:@"settings_download_website"];
    
    if (IS_IPHONE_6)
    {
        CGFloat width = 70;
        self.qrCodeConstraintsLeft.constant  = width;
        self.qrCodeConstraintsRight.constant = width;
        
        self.logoTopConstraints.constant = 50;
    }
    else if (IS_IPHONE_6P)
    {
        CGFloat width = 80;
        self.qrCodeConstraintsLeft.constant  = width;
        self.qrCodeConstraintsRight.constant = width;
        
        self.logoTopConstraints.constant = 70;
    }
    else
    {
        CGFloat width = 65;
        self.qrCodeConstraintsLeft.constant  = width;
        self.qrCodeConstraintsRight.constant = width;
        
        self.logoTopConstraints.constant = 40;
    }
}

- (IBAction)gotoDownloadWebView:(UITapGestureRecognizer *)sender
{
    NSURL *url = [[NSURL alloc] initWithString:@"http://imweb.corp.gome.com.cn/" ];
    [[UIApplication sharedApplication] openURL:url];
    NSLog(@"用Safari打开下载地址");
}

@end
