//
//  TAIHEWXWorkView.m
//  eCloud
//
//  Created by yanlei on 2017/1/17.
//  Copyright © 2017年  lyong. All rights reserved.
//

#import "TAIHEWXWorkView.h"
#import "APPListModel.h"
#import "CustomMyCell.h"
#import "IOSSystemDefine.h"

@interface TAIHEWXWorkView ()

/** 第三方图标控件 */
@property (nonatomic, strong) UIImageView *iconView;
/** 第三方应用名字控件 */
@property (nonatomic, strong) UILabel *nameLabel;

@end
@implementation TAIHEWXWorkView
+ (instancetype)workView
{
    return [[self alloc] init];
}

- (UIImageView *)iconView
{
    if (_iconView == nil) {
        UIImageView *iconView = [[UIImageView alloc] init];
        iconView.backgroundColor = [UIColor clearColor];
        [self addSubview:iconView];
        _iconView = iconView;
    }
    return _iconView;
}

- (UILabel *)nameLabel
{
    if (_nameLabel == nil) {
        UILabel *nameLabel = [[UILabel alloc] init];
        if(IS_IPHONE_6P){
            nameLabel.font = [UIFont systemFontOfSize:15];
        }else if (IS_IPAD){
            nameLabel.font = [UIFont systemFontOfSize:18];
        }else{
            nameLabel.font = [UIFont systemFontOfSize:14];
        }
        nameLabel.textAlignment = NSTextAlignmentCenter;
        nameLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:nameLabel];
        _nameLabel = nameLabel;
    }
    return _nameLabel;
}
- (void)layoutSubviews{
    [super layoutSubviews];
    
    CGFloat workW = self.frame.size.width;
    CGFloat workH = self.frame.size.height;
    if (IS_IPHONE_5) {
        self.iconView.frame = CGRectMake(10, 10, workW-20, workW-20);
    }else if(IS_IPHONE_6P){
        self.iconView.frame = CGRectMake(10, 5, workW-20, workW-20);
    }else{
        self.iconView.frame = CGRectMake(2.5, 2.5, workW-5, workW-5);
    }
    
    if (IS_IPHONE_6P) {
        
        self.nameLabel.frame = CGRectMake(0, CGRectGetMaxY(self.iconView.frame)+10, workW, workH - workW);
        
    }else if(IS_IPAD){
        
        self.nameLabel.frame = CGRectMake(0, workW, workW, 40);
        
    }else{
        
        self.nameLabel.frame = CGRectMake(0, workW, workW, workH - workW);
    }
}

- (void)setAppModel:(APPListModel *)appModel
{
    _appModel = appModel;
    
    UIImage *image = [CustomMyCell getAppLogo:appModel];
    
    self.nameLabel.text = appModel.appname;
    self.iconView.image = [CustomMyCell getAppLogo:appModel];;
}

@end
