//
//  LGGroupEmptyView.h
//  eCloud
//
//  Created by lidianchao on 2017/8/15.
//  Copyright © 2017年 网信. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define kScreenRect [UIScreen mainScreen].bounds
typedef void(^StartGroupChatCallback)(void);
@interface LGGroupEmptyView : UIView
@property(nonatomic, copy) StartGroupChatCallback startGroupChatCallback;
@end
