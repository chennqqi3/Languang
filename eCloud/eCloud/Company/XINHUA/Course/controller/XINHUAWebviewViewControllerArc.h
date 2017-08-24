//
//  XINHUAWebviewViewControllerArc.h
//  eCloud
//
//  Created by Alex-L on 2017/5/27.
//  Copyright © 2017年 网信. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XINHUAWebviewViewControllerArc : UIViewController

@property (nonatomic, strong) NSString *urlstr;

@property (nonatomic, assign) CGFloat viewHeight;

@property (nonatomic, assign) BOOL isAutoLogin;

/** url 是否来自扫描结果 */
@property (nonatomic,assign) BOOL urlIsFromScanResult;

@end
