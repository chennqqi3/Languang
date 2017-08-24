//
//  APPPushListTableViewCell.m
//  eCloud
//
//  Created by Pain on 14-6-23.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import "APPPushListTableViewCell.h"
#import <QuartzCore/QuartzCore.h>
#import "APPPushNotification.h"
#import "eCloudDefine.h"

//图片大小
#define not_backgroung_size (300.0)
//文字字体大小
#define font_size (16.0)

@implementation APPPushListTableViewCell

@synthesize lineBreak;
@synthesize title;
@synthesize sender;
@synthesize notitime;
@synthesize summary;

- (void)dealloc{
    self.lineBreak = nil;
    self.title = nil;
    self.sender = nil;
    self.notitime = nil;
    self.summary = nil;
    
    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code

        self.contentView.backgroundColor = [UIColor clearColor];//[UIColor colorWithRed:244.0/255 green:244.0/255 blue:244.0/255 alpha:1.0];
        
        float x;
        float y;
        float w;
        float h;
        
        if (IOS7_OR_LATER)
        {
            x = 10;
            y = 0;
            w = 300;
            h = row_height - 2 * y;
        }
        else
        {
            x = 0;
            y = 0;
            w = 300;
            h = row_height - 2 * y;
        }
        CGRect rect = CGRectMake(x,y,w,h);
        
        float kheight = 4;
        
        //推送消息背景
        UIImageView *notBgView = [[UIImageView alloc]initWithFrame:rect];
        notBgView.layer.cornerRadius = 4.0;
        notBgView.layer.masksToBounds = YES;
        notBgView.layer.backgroundColor = [[UIColor whiteColor] CGColor];
        notBgView.layer.borderWidth = 1.0;
        notBgView.layer.borderColor = [[UIColor colorWithRed:193.0/255 green:193.0/255 blue:193.0/255 alpha:1.0] CGColor];
		[self.contentView addSubview:notBgView];
        [notBgView release];
        
        lineBreak = [[UILabel alloc]initWithFrame:CGRectMake(-2,0.0,312.0,4.0)];
        lineBreak.backgroundColor = [UIColor colorWithRed:39.0/255 green:39.0/255 blue:39.0/255 alpha:1.0];
        [notBgView addSubview:lineBreak];
        
        //推送标题
        self.title = [[UILabel alloc]initWithFrame:CGRectMake(6.0,0.0+ kheight,278.0,30.0)];
		self.title.font = [UIFont boldSystemFontOfSize:font_size];
        self.title.backgroundColor = [UIColor clearColor];
        self.title.textColor = [UIColor blackColor];
//        self.title.text = @"推送推送1";
		[notBgView addSubview:self.title];
        
        //发送人
        self.sender = [[UILabel alloc]initWithFrame:CGRectMake(6.0,24.0 + kheight,130.0,30.0)];
		self.sender.font = [UIFont systemFontOfSize:font_size-2];
        self.sender.backgroundColor = [UIColor clearColor];
        self.sender.textColor = [UIColor colorWithRed:83.0/255 green:83.0/255 blue:83.0/255 alpha:1.0];
        self.sender.textAlignment = NSTextAlignmentLeft;
        [notBgView addSubview:self.sender];
        
        //推送时间
        self.notitime = [[UILabel alloc]initWithFrame:CGRectMake(138.0,24.0 + kheight,156.0,30.0)];
		self.notitime.font = [UIFont systemFontOfSize:font_size-2];
        self.notitime.backgroundColor = [UIColor clearColor];
        self.notitime.textColor = [UIColor colorWithRed:83.0/255 green:83.0/255 blue:83.0/255 alpha:1.0];
        self.notitime.textAlignment = NSTextAlignmentRight;
//        self.notitime.text = @"9:30";
		[notBgView addSubview:self.notitime];
        
        //概要
		self.summary = [[UILabel alloc]initWithFrame:CGRectMake(6.0,50.0 + kheight,278.0,40.0)];
		self.summary .font = [UIFont systemFontOfSize:font_size-2];
        self.summary.backgroundColor = [UIColor clearColor];
        self.summary.textColor = [UIColor colorWithRed:83.0/255 green:83.0/255 blue:83.0/255 alpha:1.0];
        self.summary.numberOfLines = 2;
        self.summary.lineBreakMode = UILineBreakModeTailTruncation;
//        self.summary.text = @"概要概要概要概要概要概要概要概要概要概要概要概要概要概要概要概要概要概要概要概要概要概要概要概要概要概要概要概要概要概要概要概要概要概要概要概要概要概要概要概要概要概要概要概要概要概要概要概要概要概要概要概要概要概要概要概要概要概要概要概要概要概要概要概要概要概要概要概要概要概要概要概要概要概要概要概要概要概要概要概要概要概要概要概要概要概要概要概要概要概要概要概要概要概要概要概要概要概要概要概要概要概要概要概要";
		[notBgView addSubview:self.summary];
        
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

    // Configure the view for the selected state
}

#pragma mark - 配置Cell属性
- (void)configureCellWith:(APPPushNotification *)appNotif{
    if (appNotif.read_flag < 1) {
        //未读消息
        lineBreak.backgroundColor = [UIColor redColor];
    }
    else{
        lineBreak.backgroundColor = [UIColor colorWithRed:39.0/255 green:39.0/255 blue:39.0/255 alpha:1.0];
    }
    self.title.text = appNotif.title;
    self.sender.text = appNotif.src;
    self.notitime.text = appNotif.notiTimeDisplay;
    self.summary.text = appNotif.summary;
}

@end
