//
//  AgentDetailViewController.h
//  eCloud
//
//  Created by yanlei on 15/8/19.
//  Copyright (c) 2015年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AgentDetailViewController : UIViewController<UIWebViewDelegate>

@property(nonatomic,retain) NSString *urlstr;
@property(nonatomic,retain)	NSString *curUrlStr;
@property(nonatomic,assign) int navigationType;

@end
