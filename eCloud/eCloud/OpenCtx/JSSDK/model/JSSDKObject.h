//
//  JSSDKObject.h
//  eCloud
//
//  Created by shisuping on 16/7/21.
//  Copyright © 2016年  lyong. All rights reserved.
//  js与原生交互工具类

#import <Foundation/Foundation.h>

@class WebViewJavascriptBridge;

@interface JSSDKObject : NSObject

/** 第三方 js与原生桥接对象 */
@property (nonatomic,retain) WebViewJavascriptBridge *bridge;
/** 当前操作的控制器对象 */
@property (nonatomic,retain) UIViewController *curVC;

/**
 注册绑定js触发的功能方法
 */
- (void)initSDK;

@end
