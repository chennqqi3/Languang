//
//  GOMEAPPCell.m
//  GOME_DEMO
//
//  Created by Alex L on 16/11/29.
//  Copyright © 2016年 Alex L. All rights reserved.
//

#import "GOMEAPPCell.h"
#import "GOMEAppViewController.h"
#import "CustomMyCell.h"
#import "UIAdapterUtil.h"
#import "StringUtil.h"
#import "APPUtil.h"
#import "NewMsgNumberUtil.h"
#import "UserDefaults.h"

#ifdef _GOME_FLAG_
#import "GMShoppingDayGo.h"
#endif

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

#define IPHONE_5S (SCREEN_HEIGHT == 568)
#define IPHONE_6  (SCREEN_HEIGHT == 667)
#define IPHONE_6P (SCREEN_HEIGHT == 736)

/** 间距 */
#define SEPARATION (IPHONE_6P ? 35 : (IPHONE_6 ?  32 : 35))

@interface GOMEAPPCell ()

@property (nonatomic, strong) UIImageView *icon;
@property (nonatomic, strong) UILabel *appName;
@property (nonatomic, strong) UIImageView *deleteBtn;

@end

@implementation GOMEAPPCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        CGFloat imageViewWidth, imageViewHeight;
        imageViewWidth = imageViewHeight = frame.size.width-2*SEPARATION;
        self.icon = [[UIImageView alloc] initWithFrame:CGRectMake(SEPARATION, 10, imageViewWidth, imageViewHeight)];
        self.icon.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:self.icon];
        
        self.deleteBtn = [[UIImageView alloc] initWithImage:[StringUtil getImageByResName:@"app_delete"]];
        self.deleteBtn.frame = CGRectMake(CGRectGetWidth(self.frame)-30, 0, 15, 15);
        self.deleteBtn.hidden = YES;
        [self.contentView addSubview:self.deleteBtn];
        
        self.appName = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.size.height-25-SEPARATION+10, frame.size.width, 21)];
        [self.appName setFont:[UIFont systemFontOfSize:IPHONE_6 ? 15 : 16]];
        self.appName.textAlignment = NSTextAlignmentCenter;
        self.appName.textColor = GOME_NAME_COLOR;
        [self.contentView addSubview:self.appName];
        
        // 添加显示未读数的小红点
        [NewMsgNumberUtil addNewMsgNumberView:self.icon];
    }
    
    return self;
}

- (void)setModel:(APPListModel *)model
{
    _model = model;
    
    self.deleteBtn.hidden = self.isEditing ? NO : YES;
    
    if ([APPUtil isDefaultApp:_model])
    {
        self.deleteBtn.hidden = YES;
    }
    
    NSLog(@"logopath %@ appname %@",_model.logopath,_model.appname);
    UIImage *image = [CustomMyCell getAppLogo:_model];
    self.icon.image = image;
    self.appName.text = _model.appname;
    
    if (model.appid == GOME_PURCHASE_APP_ID) {
        [NewMsgNumberUtil displayNewMsgNumber:self.icon andNewMsgNumber:_model.unread];
        [NewMsgNumberUtil setUnreadViewFrame:self.icon];
    }else{
        [NewMsgNumberUtil displayNewMsgNumber:self.icon andNewMsgNumber:0];
    }
}

@end
