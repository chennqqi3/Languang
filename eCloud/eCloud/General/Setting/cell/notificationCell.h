//
//  notificationCell.h
//  eCloud
//
//  Created by SH on 14-9-3.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface notificationCell : UITableViewCell
typedef void(^SwitchActionCallBack)(id sender);
/** 通知标题 */
@property(nonatomic,retain) UILabel *nameLable;
@property(nonatomic,retain) UILabel *inOpenLable;
@property(nonatomic, strong) UISwitch *switchBtn;
@property(nonatomic, copy) SwitchActionCallBack switchActionCallBack;
- (void)showSwitch;
- (void)showIsOpenLabel;
@end
