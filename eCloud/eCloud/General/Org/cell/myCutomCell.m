//
//  myCutomCell.m
//  eCloud
//
//  Created by yanlei on 15/11/25.
//  Copyright © 2015年  lyong. All rights reserved.
//

#import "myCutomCell.h"
#import "StringUtil.h"
#import "UserDisplayUtil.h"
#import "eCloudDefine.h"
#import "MessageView.h"

// 头像的宽度
#define iconViewWidth 54
// 员工名称的x值
#define nameX (iconViewWidth+23)
// 员工名称控件的最大宽度
#define nameMaxWidth SCREEN_WIDTH-90
// 员工名称控件的tag值
#define nameLable_tag 103

@implementation myCutomCell
@synthesize iconView;
@synthesize nameLable;
@synthesize newButton;

- (void)dealloc
{
    self.iconView = nil;
    self.nameLable = nil;
    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // 设置cell选中后的样式
        [UIAdapterUtil customSelectBackgroundOfCell:self];
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        CGSize _size = [UserDisplayUtil getDefaultUserLogoSize];
        float height = (iconViewWidth * _size.height) / _size.width;
        
        self.iconView = [[UIImageView alloc]initWithFrame:CGRectMake(10, (myCellHeight-height)*0.5, iconViewWidth, height)];
        
#ifdef _BGY_FLAG_
        
        self.iconView.frame = CGRectMake(20, 25, 70, 70);
        [self.iconView.layer setMasksToBounds:YES];
        [self.iconView.layer setCornerRadius:5];
#endif
        
        [self.contentView addSubview:self.iconView];

        self.nameLable = [[VerticallyAlignedLabel alloc] initWithFrame:CGRectMake(nameX, height/2-5, nameMaxWidth, 30)];
        
#ifdef _BGY_FLAG_
        
        self.nameLable.frame = CGRectMake(60+45, 45, nameMaxWidth, 30);

#endif
        
        self.nameLable.backgroundColor = [UIColor clearColor];
        self.nameLable.textColor=[UIColor blackColor];
        self.nameLable.font=[UIFont boldSystemFontOfSize:18.0];
        self.nameLable.textAlignment = UITextAlignmentLeft;
        self.nameLable.verticalAlignment = VerticalAlignmentMiddle;
        self.nameLable.tag = nameLable_tag;
        [self.contentView addSubview:self.nameLable];
        
        if ([UIAdapterUtil isHongHuApp]){
            CGSize size = [self.textLabel.text sizeWithFont:self.textLabel.font];
            // 新版本按钮初始化
            self.newButton=[[UIButton alloc]initWithFrame:CGRectMake(size.width + 30,(45 - 20) / 2, 100, 20)];
            
            //        [newButton addTarget:self action:@selector(openAbout) forControlEvents:UIControlEventTouchUpInside];
            
            UIEdgeInsets capInsets = UIEdgeInsetsMake(9,9,9,9);
            MessageView *messageView = [MessageView getMessageView];
            UIImage *newMsgImage = [UIImage imageWithContentsOfFile:[StringUtil getResPath:@"app_new_push" andType:@"png"]];
            newMsgImage = [messageView resizeImageWithCapInsets:capInsets andImage:newMsgImage];
            
            [self.newButton setBackgroundImage:newMsgImage forState:UIControlStateNormal];
            self.newButton.backgroundColor=[UIColor clearColor];
            [self.newButton setTitle:@"NEW VERSION" forState:UIControlStateNormal];
            self.newButton.font=[UIFont boldSystemFontOfSize:12];
            [self.contentView addSubview:self.newButton];
            [self.newButton release];
        }
    }
    return self;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
