//
//  APPPushListTableViewCell.h
//  eCloud
//
//  Created by Pain on 14-6-23.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>
//行高度
#define row_height (120.0)

@class APPPushNotification;

@interface APPPushListTableViewCell : UITableViewCell

@property(nonatomic,retain) UILabel *lineBreak;
@property(nonatomic,retain) UILabel *title;
@property(nonatomic,retain) UILabel *sender; //发送人
@property(nonatomic,retain) UILabel *notitime;
@property(nonatomic,retain) UILabel *summary;

//设置Cell的值
- (void)configureCellWith:(APPPushNotification *)appNotif;
@end
