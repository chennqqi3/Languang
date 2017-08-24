//
//  LGAppMsgViewControllerARC.h
//  eCloud
//
//  Created by Ji on 17/6/13.
//  Copyright © 2017年 网信. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Conversation;
@interface LGAppMsgViewControllerARC : UIViewController

/** 会话  */
@property (nonatomic, strong) Conversation *conv;

@end
