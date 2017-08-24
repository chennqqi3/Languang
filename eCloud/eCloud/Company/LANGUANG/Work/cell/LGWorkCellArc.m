//
//  LGWorkCellArc.m
//  eCloud
//
//  Created by Ji on 17/7/20.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "LGWorkCellArc.h"
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
#define SEPARATION (IPHONE_6P ? 27 : (IPHONE_6 ?  25 : 27))

@interface LGWorkCellArc ()

@property (nonatomic, strong) UIImageView *icon;
@property (nonatomic, strong) UILabel *appName;
@property (nonatomic, strong) UIImageView *deleteBtn;

@end

@implementation LGWorkCellArc

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        CGFloat imageViewWidth, imageViewHeight;
        imageViewWidth = imageViewHeight = frame.size.width-2*SEPARATION;
        self.icon = [[UIImageView alloc] initWithFrame:CGRectMake(SEPARATION, 12, imageViewWidth, imageViewHeight)];
        self.icon.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:self.icon];
        
        self.deleteBtn = [[UIImageView alloc] initWithImage:[StringUtil getImageByResName:@"app_delete"]];
        self.deleteBtn.frame = CGRectMake(CGRectGetWidth(self.frame)-30, 0, 15, 15);
        self.deleteBtn.hidden = YES;
        [self.contentView addSubview:self.deleteBtn];
        
        self.appName = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.size.height-15-SEPARATION+10, frame.size.width, 21)];
        [self.appName setFont:[UIFont systemFontOfSize:13]];
        self.appName.textAlignment = NSTextAlignmentCenter;
        self.appName.textColor = [UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1];
        [self.contentView addSubview:self.appName];
        
        
        self.contentView.backgroundColor = [UIColor whiteColor];
        
        // 添加显示未读数的小红点
        [NewMsgNumberUtil addNewMsgNumberView:self.icon];
    }
    
    return self;
}

- (void)setModel:(APPListModel *)model
{
    _model = model;
    
    if ([APPUtil isDefaultApp:_model])
    {
        self.deleteBtn.hidden = YES;
    }
    
    NSLog(@"logopath %@ appname %@",_model.logopath,_model.appname);
    //    UIImage *image = [CustomMyCell getAppLogo:_model];
    //self.icon.image = [StringUtil getImageByResName:_model.logopath];
    //    优先显示根据服务器配置下载下来的图片
    UIImage *_image = [APPUtil getMyAPPLogo:model];
    
    //如果不存在 显示默认的和此应用对应的本地的图片
    if (!_image) {
        if(model.appicon){
            // 若后台没有给logopath，加载初始化图片
            _image = [StringUtil getImageByResName:model.appicon];
        }
    }
    //否则显示默认的轻应用的图片
    if (!_image) {
        _image = [StringUtil getImageByResName:@"app_default_icon_html5.png"];
    }
    
    self.icon.image = _image;
    
    self.appName.text = _model.appname;
}


@end
