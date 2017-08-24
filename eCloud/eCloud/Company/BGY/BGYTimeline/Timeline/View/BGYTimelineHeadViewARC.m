//
//  BGYTimelineHeadView.m
//  eCloud
//
//  Created by Alex-L on 2017/7/5.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "BGYTimelineHeadViewARC.h"
#import "StringUtil.h"
#import "UIAdapterUtil.h"

#define ICON_VIEW_WIDTH 81
#define ICON_VIEW_HIEGHT ICON_VIEW_WIDTH
#define ICON_VIEW_X (frame.size.width-106)
#define ICON_VIEW_Y (frame.size.height-(ICON_VIEW_WIDTH*(3.0/4.0)))

#define ICON_WIDTH 75
#define ICON_HEIGHT ICON_WIDTH
#define ICON_X ((ICON_VIEW_WIDTH-ICON_WIDTH)/2)
#define ICON_Y ICON_X

#define LABEL_WIDTH 100
#define LABEL_HEIGHT 27

@interface BGYTimelineHeadViewARC ()

@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIImageView *icon;
@property (nonatomic, strong) UILabel *nameLabel;

@end

@implementation BGYTimelineHeadViewARC

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.backgroundImageView = [[UIImageView alloc] initWithFrame:frame];
        self.backgroundImageView.image = [StringUtil getImageByResName:@"headImage"];
        [self addSubview:self.backgroundImageView];
        
        
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(ICON_VIEW_X-LABEL_WIDTH+15, ICON_VIEW_Y+((ICON_VIEW_HIEGHT-LABEL_HEIGHT)/2.0), LABEL_WIDTH, LABEL_HEIGHT)];
        self.nameLabel.text = @"   碧桂园";
        self.nameLabel.textColor = [UIColor whiteColor];
        self.nameLabel.backgroundColor = [[UIAdapterUtil getDominantColor] colorWithAlphaComponent:0.5];
        [self addSubview:self.nameLabel];
        // 设置圆角
        self.nameLabel.layer.cornerRadius = LABEL_HEIGHT/2.0;
        self.nameLabel.clipsToBounds = YES;
        
        
        UIView *iconView = [[UIView alloc] initWithFrame:CGRectMake(ICON_VIEW_X, ICON_VIEW_Y, ICON_VIEW_WIDTH, ICON_VIEW_HIEGHT)];
        iconView.backgroundColor = [UIAdapterUtil getDominantColor];
        [self addSubview:iconView];
        // 设置圆角
        iconView.layer.cornerRadius = ICON_VIEW_WIDTH/2.0;
        iconView.clipsToBounds = YES;
        
        
        self.icon = [[UIImageView alloc] initWithFrame:CGRectMake(ICON_X, ICON_Y, ICON_WIDTH, ICON_WIDTH)];
        self.icon.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
        [iconView addSubview:self.icon];
        // 设置圆角
        self.icon.layer.cornerRadius = ICON_WIDTH/2.0;
        self.icon.clipsToBounds = YES;
    }
    
    return self;
}

@end
