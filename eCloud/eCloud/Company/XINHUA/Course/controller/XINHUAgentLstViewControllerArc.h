//
//  XINHUAgentLstViewControllerArc.h
//  eCloud
//
//  Created by Ji on 17/4/28.
//  Copyright © 2017年 网信. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMYWebView.h"

@interface XINHUAgentLstViewControllerArc : UIViewController<IMYWebViewDelegate>
{
    IMYWebView *webview;
}
@property(nonatomic,retain)  NSString *urlstr;
@end
