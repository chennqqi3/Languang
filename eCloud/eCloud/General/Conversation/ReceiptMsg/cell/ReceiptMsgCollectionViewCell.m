//
//  ReceiptMsgCollectionViewCell.m
//  eCloud
//
//  Created by Alex L on 15/11/5.
//  Copyright © 2015年  lyong. All rights reserved.
//

#import "ReceiptMsgCollectionViewCell.h"
#import "eCloudConfig.h"
#import "UIAdapterUtil.h"
#import "UserDisplayUtil.h"

#define CELL_SIZE (self.frame.size)

#define ICON_X 5
#define ICON_Y 0


#if defined(_HUAXIA_FLAG_) || defined(_ZHENGRONG_FLAG_)
#define USER_STATUS_WIDTH 10
#define USER_STATUS_HEIGHT 10
#else
#define USER_STATUS_WIDTH 16
#define USER_STATUS_HEIGHT 16
#endif

#define USER_NAME_X 0
#define USER_NAME_HEIGHT 20

#define USERNAME_FONT 12

@implementation ReceiptMsgCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        CGSize size = [UserDisplayUtil getDefaultUserLogoSize];
        CGFloat iconHeight = 45;// CELL_SIZE.height - USER_NAME_HEIGHT;
        CGFloat iconWidth = iconHeight * (size.width/size.height);
        
        CGFloat iconX = CELL_SIZE.width/2.0 - iconWidth/2.0;
        
        CGFloat iconY = (CELL_SIZE.height - (iconHeight + USER_NAME_HEIGHT)) * 0.5;
        self.icon = [[UIImageView alloc] initWithFrame:CGRectMake(iconX, iconY, iconWidth, iconHeight)];
        
        [UserDisplayUtil addLogoTextLabelToLogoView:self.icon];
        
        [UIAdapterUtil setCornerPropertyOfView:self.icon];
        
        CGFloat statusX = CELL_SIZE.width/2.0 + iconWidth/2.0 - USER_STATUS_WIDTH/2.0;
        self.userStatus = [[UIImageView alloc] initWithFrame:CGRectMake(statusX, CELL_SIZE.height - 17 - USER_STATUS_HEIGHT, USER_STATUS_WIDTH, USER_STATUS_HEIGHT)];
        
        CGFloat userNameY = iconY + iconHeight;
        
        self.userName = [[UILabel alloc] initWithFrame:CGRectMake(USER_NAME_X, userNameY, CELL_SIZE.width, USER_NAME_HEIGHT)];
        
        
        [self.userName setFont:[UIFont systemFontOfSize:USERNAME_FONT]];
        self.userName.textAlignment = NSTextAlignmentCenter;
        
        [self addSubview:self.icon];
        
#if defined(_HUAXIA_FLAG_) || defined(_ZHENGRONG_FLAG_)
        [self addSubview:self.userStatus];
#else
        if ([eCloudConfig getConfig].needDisplayUserStatus) {
            [self addSubview:self.userStatus];
        }
#endif
        [self addSubview:self.userName];
    }
    return self;
}

@end
