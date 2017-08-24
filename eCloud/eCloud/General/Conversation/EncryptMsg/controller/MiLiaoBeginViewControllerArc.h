//
//  MiLiaoConvListViewControllerArc.h
//  miliao
//
//  Created by Alex-L on 2017/6/14.
//  Copyright © 2017年 Alex-L. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MiLiaoBeginVCProtocol <NSObject>

/** 开始密聊 */
- (void)startMiLiao;

@end

@interface MiLiaoBeginViewControllerArc : UIViewController

@property (nonatomic,assign) id<MiLiaoBeginVCProtocol> delegate;

@end
