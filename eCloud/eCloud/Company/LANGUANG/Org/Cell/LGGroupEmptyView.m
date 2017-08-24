//
//  LGGroupEmptyView.m
//  eCloud
//
//  Created by lidianchao on 2017/8/15.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "LGGroupEmptyView.h"
#import "StringUtil.h"

@implementation LGGroupEmptyView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        self.backgroundColor = [UIColor whiteColor];
        [self configUI];
    }
    return self;
}
- (void)configUI
{
    CGFloat imageWidth = 90;
    CGFloat imageHeight = 110;
    CGFloat imageX = (kScreenWidth - imageWidth) * 1.0 / 2;
    CGFloat imageY = 60;
    UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(imageX, imageY, imageWidth, imageHeight)];
    iconImageView.image = [StringUtil getImageByResName:@"img_meeting_nothing"];
    [self addSubview:iconImageView];
    
    CGFloat labelWidth = 100;
    CGFloat labelHeight = 21;
    CGFloat labelX = (kScreenWidth - labelWidth) * 1.0 / 2;
    CGFloat labelY = CGRectGetMaxY(iconImageView.frame)+10;
    UILabel *msgLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelX, labelY, labelWidth, labelHeight)];
    msgLabel.font = [UIFont systemFontOfSize:12];
    msgLabel.textAlignment = NSTextAlignmentCenter;
    msgLabel.text = @"居然没有群!";
    msgLabel.textColor = [UIColor grayColor];
    [self addSubview:msgLabel];
    
    CGFloat btnWidth = 150;
    CGFloat btnHeight = 40;
    CGFloat btnX = (kScreenWidth - btnWidth) * 1.0 / 2;
    CGFloat btnY = CGRectGetMaxY(msgLabel.frame)+20;
    UIButton *startGroupChatBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    startGroupChatBtn.frame = CGRectMake(btnX, btnY, btnWidth, btnHeight);
    startGroupChatBtn.layer.cornerRadius = 3;
    startGroupChatBtn.clipsToBounds = YES;
    [startGroupChatBtn setBackgroundColor:[UIColor blueColor]];
    startGroupChatBtn.backgroundColor = [UIColor colorWithRed:88/255.0 green:159/255.0 blue:253/255.0 alpha:1];
    [startGroupChatBtn setTitle:@"发起群聊" forState:UIControlStateNormal];
    startGroupChatBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [startGroupChatBtn addTarget:self action:@selector(startGroupChatClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:startGroupChatBtn];
}
- (void)startGroupChatClicked:(UIButton *)sender
{
    if(self.startGroupChatCallback)
    {
       self.startGroupChatCallback();
    }
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
