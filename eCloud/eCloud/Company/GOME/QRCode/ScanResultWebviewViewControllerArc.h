//
//  ScanResultWebviewViewControllerArc
//  eCloud
//  扫描结果 webview 代码来自 新华网 打开 创客课堂功能
//  Created by Alex-L on 2017/5/27.
//  Copyright © 2017年 网信. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScanResultWebviewViewControllerArc : UIViewController

@property (nonatomic, strong) NSString *urlstr;

@property (nonatomic, assign) BOOL isAutoLogin;

/** url 是否来自扫描结果 */
@property (nonatomic,assign) BOOL urlIsFromScanResult;

@end
