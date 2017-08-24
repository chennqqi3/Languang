//
//  AppListImageView.m
//  AppList
//
//  Created by Pain on 14-6-25.
//  Copyright (c) 2014年 fengying. All rights reserved.
//

#import "AppListImageView.h"
#import "AppListBtnModel.h"
#import "APPUtil.h"
#import "UIAdapterUtil.h"
#import "StringUtil.h"

@implementation AppListImageView

@synthesize iconbutton;
@synthesize nameLabel;
@synthesize deletebutton;
@synthesize appBtnModel;
@synthesize parent;

- (void)dealloc{
    self.iconbutton = nil;
    self.nameLabel = nil;
    self.deletebutton = nil;
    self.appBtnModel = nil;
    
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.userInteractionEnabled=YES;
        //self.image=[StringUtil getImageByResName:@"myitem2.png"];
        self.image=nil;
        CGFloat screenW = [UIAdapterUtil getDeviceMainScreenWidth];
        iconbutton=[[UIButton alloc]initWithFrame:CGRectMake((screenW/3-50)/2.0,(100-50)/2.0,50,50)];
        iconbutton.backgroundColor=[UIColor clearColor];
        //[iconbutton setImage:[StringUtil getImageByResName:@"yihuwanying.png"] forState:UIControlStateNormal];
		[iconbutton addTarget:self action:@selector(iconbuttonAction:)  forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:iconbutton];
        
        nameLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 50, 50, 20)];
        nameLabel.backgroundColor=[UIColor clearColor];
        nameLabel.font=[UIFont systemFontOfSize:12];
        //nameLabel.text = @"一呼万应";
        nameLabel.textAlignment=NSTextAlignmentCenter;
        [iconbutton addSubview:nameLabel];
        
        deletebutton=[[UIButton alloc]initWithFrame:CGRectMake(-7,-7,26.0,26.0)];
        deletebutton.hidden = YES;
        [deletebutton setImage:[StringUtil getImageByResName:@"red_delete.png"] forState:UIControlStateNormal];
        [deletebutton addTarget:self action:@selector(deleteGroupMemberAction:) forControlEvents:UIControlEventTouchUpInside];
        [iconbutton  addSubview:deletebutton];
    }
    return self;
}


- (void)iconbuttonAction:(UIButton *)sender{
    if ([parent respondsToSelector:@selector(iconbuttonAction:)]){
        [parent performSelector:@selector(iconbuttonAction:) withObject:self];
    }
}

- (void)deleteGroupMemberAction:(UIButton *)sender{
    if ([parent respondsToSelector:@selector(deleteGroupMemberAction:)]){
        [parent performSelector:@selector(deleteGroupMemberAction:) withObject:self];
    }
}

#pragma mark - 配置按钮
- (void)configureListImageView{
    if (self.appBtnModel.apptype == 10) {
        //第三方应用
        [iconbutton setImage:[APPUtil getAPPLogo:self.appBtnModel.appModel] forState:UIControlStateNormal];
        nameLabel.text = self.appBtnModel.appname;
        self.deletebutton.hidden = !self.appBtnModel.start_Delete;
    }
    else {
        //系统应用
        [iconbutton setImage:[StringUtil getImageByResName:[NSString stringWithFormat:@"%@",self.appBtnModel.appicon]] forState:UIControlStateNormal];
        nameLabel.text = self.appBtnModel.appname;
    }
}

#pragma mark - 隐藏所有按钮
- (void)hideAllBtn{
    iconbutton.hidden = YES;
    nameLabel.hidden = YES;
    self.deletebutton.hidden = YES;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
