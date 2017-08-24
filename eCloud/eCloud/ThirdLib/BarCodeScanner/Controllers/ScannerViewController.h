//
//  ViewController.h
//  iOS7_BarcodeScanner
//
//  Created by Jake Widmer on 11/16/13.
//  Copyright (c) 2013 Jake Widmer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingsViewController.h"

typedef enum
{
    scanQRCode_open_result = 0,
    scanQRCode_return_result =1
}scanQRCodeResultDef;

@interface ScannerViewController : UIViewController<UIAlertViewDelegate, SettingsDelegate>
@property (strong, nonatomic) NSMutableArray * allowedBarcodeTypes;

//扫描结果处理方式
@property (assign,nonatomic) int processType;
@property (assign,nonatomic) id delegate;
@end


@protocol ScannerViewDelegate <NSObject>

- (void)barcodeFound:(ScannerViewController *)scanner andBarcode:(NSString *)barCode;

@end

