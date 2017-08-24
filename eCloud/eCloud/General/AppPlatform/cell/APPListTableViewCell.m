//
//  APPListTableViewCell.m
//  eCloud
//
//  Created by Pain on 14-6-16.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

//图片大小
#define logo_size 40
//文字字体大小
#define font_size 16
//行高度
#define row_height 55

#import "APPListTableViewCell.h"
#import <QuartzCore/QuartzCore.h>
#import "APPPlatformDOA.h"
#import "APPListModel.h"
#import "APPUtil.h"
#import "NewMsgNumberUtil.h"
#import "NewAPPTagUtil.h"
#import "NewAppTagView.h"

#import "eCloudDefine.h"

@implementation APPListTableViewCell

@synthesize logoView;
@synthesize logoCoverView;
@synthesize appName;
@synthesize appNewTag;
@synthesize detailButton;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.contentView.backgroundColor = [UIColor clearColor];
        
        UILabel *lineBreak = [[UILabel alloc]initWithFrame:CGRectMake(4.0,0.0,312.0,1.0)];
        lineBreak.backgroundColor = [UIColor colorWithRed:193.0/255 green:193.0/255 blue:193.0/255 alpha:1.0];
        [self.contentView addSubview:lineBreak];
        [lineBreak release];
        
        
        CGRect rect = CGRectMake(10,(row_height - logo_size)/2,logo_size,logo_size);
        
        //应用图标
        self.logoView = [[UIImageView alloc]initWithFrame:rect];
		[self.contentView addSubview:self.logoView];
        
        self.logoCoverView = [[UIImageView alloc]initWithFrame:CGRectMake(0.0, 0.0, rect.size.width,  rect.size.height)];
        self.logoCoverView.backgroundColor = [UIColor colorWithRed:144.0/255 green:144.0/255 blue:144.0/255 alpha:0.4];
        self.logoCoverView.hidden = YES;
		[self.logoView addSubview:self.logoCoverView];
        
        //name
		self.appName = [[UILabel alloc]initWithFrame:CGRectMake(10+logo_size + 10,0,200,row_height)];
		self.appName .font = [UIFont systemFontOfSize:font_size];
        self.appName.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:self.appName ];
		
        self.appNewTag = [[NewAppTagView alloc]initWithFrame:CGRectMake(320.0-logo_size-220.0,0,40.0,row_height)];
        self.appNewTag.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:self.appNewTag ];
        
        //详细资料按钮
		self.detailButton=[[UIButton alloc]initWithFrame:CGRectMake(266.0, 4.0, 48.0, 48.0)];
        self.detailButton.backgroundColor = [UIColor clearColor];
//		[self.detailButton setImage:detailImage forState:UIControlStateNormal];
//		[self.detailButton setImage:detailImageClick forState:UIControlStateHighlighted];
//		[self.detailButton setImage:detailImageClick forState:UIControlStateSelected];
        [self.contentView addSubview:self.detailButton];
        
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

}

- (void)dealloc{
    self.logoView = nil;
    self.logoCoverView = nil;
    self.appName = nil;
    self.appNewTag = nil;
    self.detailButton = nil;
    
    [super dealloc];
}

#pragma mark - 配置Cell属性
- (void)configureCellWith:(APPListModel *)appModel{
    self.logoView.image = [APPUtil getAPPLogo:appModel];
        
    if (appModel.appShowFlag > 0) {
        //添加到我的页面
        [NewMsgNumberUtil addNewMsgNumberView:self.logoView];
        [NewMsgNumberUtil displayNewMsgNumber:self.logoView andNewMsgNumber:0];
        
        [self.detailButton setImage:[StringUtil getImageByResName:@"app_remove_btn.png"] forState:UIControlStateNormal];
        
//        self.logoCoverView.hidden = NO;
        self.appName.text = [NSString stringWithFormat:@"%@",appModel.appname];
        self.appName.textColor = [UIColor colorWithRed:144.0/255 green:144.0/255 blue:144.0/255 alpha:1.0];
        
        float newNumberWidth = [self.appName.text sizeWithFont:[UIFont systemFontOfSize:font_size]].width;
        if (newNumberWidth > 200.0) {
            newNumberWidth = 200.0;
        }
        
        CGRect rect = self.appName.frame;
        rect.size.width = newNumberWidth;
        [self.appName setFrame:rect];
        self.appNewTag.hidden = YES;
    }
    else{
        //未添加的应用列表
        int unred = [[APPPlatformDOA getDatabase] getAllNewPushNotiCountWithAppid:appModel.appid];
        [NewMsgNumberUtil addNewMsgNumberView:self.logoView];
        [NewMsgNumberUtil displayNewMsgNumber:self.logoView andNewMsgNumber:unred];
        
        [self.detailButton setImage:[StringUtil getImageByResName:@"app_add_btn.png"] forState:UIControlStateNormal];
        
//        self.logoCoverView.hidden = YES;
        self.appName.text = [NSString stringWithFormat:@"%@",appModel.appname];
        self.appName.textColor = [UIColor blackColor];
        float newNumberWidth = [self.appName.text sizeWithFont:[UIFont systemFontOfSize:font_size]].width;
        if (newNumberWidth > 170.0) {
            newNumberWidth = 170.0;
        }
        
        CGRect rect = self.appName.frame;
        CGRect rect1 = self.appNewTag.frame;
        rect.size.width = newNumberWidth;
        
        rect1.origin.x  = newNumberWidth+rect.origin.x;
        [self.appName setFrame:rect];
        [self.appNewTag setFrame:rect1];
        
        if (appModel.isnew > 0) {
            self.appNewTag.hidden = NO;
        }
        else{
            self.appNewTag.hidden = YES;
        }
    }
}


@end
