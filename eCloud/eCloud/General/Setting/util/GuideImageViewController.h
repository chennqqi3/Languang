//
//  GuideImageViewController.h
//  eCloud
//
//  Created by yanlei on 15/11/26.
//  Copyright © 2015年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GuideImageViewController : UIViewController
/** 用来展示gif动图 */
@property(nonatomic,retain)UIWebView *webView;
/** 广告图 */
@property (nonatomic,retain) UIImageView *guideImageView;
/** 没用到 */
@property (nonatomic,retain) NSString *landscapeString;
/** 没用到 */
@property (nonatomic,retain) NSString *VerticalString;
/** 没用到 */
@property (nonatomic,assign) NSInteger num;
/** 用来放广告图 */
@property(nonatomic,retain)UIScrollView *imageScrollView;

@end
