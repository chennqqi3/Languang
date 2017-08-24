//
//  LGEmpCollectionCellArc.m
//  eCloud
//
//  Created by Alex-L on 2017/1/3.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "LGEmpCollectionCellArc.h"
#import "eCloudConfig.h"

#define CELL_SIZE (self.frame.size)

#define ICON_X 5
#define ICON_Y 0

#define USER_STATUS_WIDTH 16
#define USER_STATUS_HEIGHT 16

#define USER_NAME_X 0
#define USER_NAME_HEIGHT 20

#define USERNAME_FONT 12

@implementation LGEmpCollectionCellArc

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.icon = [[UIImageView alloc] initWithFrame:CGRectMake(ICON_X, ICON_Y, CELL_SIZE.width - ICON_X*2, CELL_SIZE.width - ICON_X*2)];
        self.icon.layer.cornerRadius = 3;
        self.icon.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
        self.icon.clipsToBounds = YES;
        
        self.userStatus = [[UIImageView alloc] initWithFrame:CGRectMake(CELL_SIZE.width - 10 - USER_STATUS_WIDTH, CELL_SIZE.height - 17 - USER_STATUS_HEIGHT, USER_STATUS_WIDTH, USER_STATUS_HEIGHT)];
        self.userName = [[UILabel alloc] initWithFrame:CGRectMake(USER_NAME_X, CELL_SIZE.height - USER_NAME_HEIGHT, CELL_SIZE.width, USER_NAME_HEIGHT)];
        [self.userName setFont:[UIFont systemFontOfSize:USERNAME_FONT]];
        self.userName.textAlignment = NSTextAlignmentCenter;
        
        [self addSubview:self.icon];
        if ([eCloudConfig getConfig].needDisplayUserStatus) {
            [self addSubview:self.userStatus];
        }
        [self addSubview:self.userName];
    }
    return self;
}


@end
