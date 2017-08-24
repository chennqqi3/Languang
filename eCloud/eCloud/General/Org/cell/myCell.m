//
//  mCell.m
//  eCloud
//
//  Created by SH on 14-9-16.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import "myCell.h"
#import "StringUtil.h"
#import "UserDisplayUtil.h"
#import "eCloudDefine.h"
#import "UIAdapterUtil.h"

#define fuctionBtn1_tag 101
#define fuctionBtn2_tag 102
#define nameLable_tag 103

@implementation myCell
@synthesize iconView;
@synthesize nameLable;
@synthesize deptLable;

- (void)dealloc
{
    self.iconView = nil;
    self.nameLable = nil;
    self.deptLable = nil;
    //[super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [UIAdapterUtil customSelectBackgroundOfCell:self];
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
//        高度 通过宽度计算出来 不再写死
//        CGSize _size = [UserDisplayUtil getDefaultUserLogoSize];
//        float height = (iconViewWidth * _size.height) / _size.width;
        
        self.iconView = [[[UIImageView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH/2-32, 28, 64, 64)]autorelease];
        if ([UIAdapterUtil isTAIHEApp]) {
            self.iconView.frame = CGRectMake(10, 15, iconViewWidth, iconViewWidth);
            self.iconView.layer.masksToBounds =YES;
            self.iconView.layer.cornerRadius = iconViewWidth /2;
            [self.iconView.layer setBorderWidth:1];
            CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
            
            CGColorRef colorref = CGColorCreate(colorSpace,(CGFloat[]){ 86,192,88,1});
            [self.iconView.layer setBorderColor:colorref];
        }
        
#ifdef _XIANGYUAN_FLAG_

        self.iconView.frame = CGRectMake(10, 15, iconViewWidth, iconViewWidth);
        [self.iconView.layer setMasksToBounds:YES];
        [self.iconView.layer setCornerRadius:5];
#endif
        
        [UIAdapterUtil setCornerPropertyOfView:self.iconView];
        [UserDisplayUtil addLogoTextLabelToLogoView:self.iconView];
        
        [self.contentView addSubview:self.iconView];
        
        self.ModifyView = [[UIImageView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH/2+15, 29, 16, 16)];
        self.ModifyView.image = [StringUtil getImageByResName:@"btn_my_datum_photo_edit"];
        [self.contentView addSubview:self.ModifyView];
        
//        self.nameLable = [[[VerticallyAlignedLabel alloc] initWithFrame:CGRectMake(nameX, nameY, nameMaxWidth, 40)]autorelease];
        self.nameLable = [[[VerticallyAlignedLabel alloc] init]autorelease];
        self.nameLable.backgroundColor = [UIColor clearColor];
		self.nameLable.textColor=[UIColor blackColor];
        self.nameLable.font = [UIFont fontWithName:@"PingFangHK-Medium" size:17];
        self.nameLable.textAlignment = UITextAlignmentLeft;
        self.deptLable.verticalAlignment = VerticalAlignmentTop;
        self.nameLable.tag = nameLable_tag;
		[self.contentView addSubview:self.nameLable];
//        NSLog(@"%@",NSStringFromCGRect(self.nameLable.frame));
        
//        self.deptLable = [[[VerticallyAlignedLabel alloc]initWithFrame:CGRectMake(deptX, deptY, deptMAXWidth,30)]autorelease];
//        self.deptLable.backgroundColor = [UIColor clearColor];
//		self.deptLable.textColor=[UIColor grayColor];
//        self.deptLable.font=[UIFont systemFontOfSize:16.0];
//        self.deptLable.textAlignment = UITextAlignmentLeft;
//        self.deptLable.numberOfLines = 0;
//        self.deptLable.verticalAlignment = VerticalAlignmentTop;
//		[self.contentView addSubview:self.deptLable];
        self.sexView = [[[UIImageView alloc]init]autorelease];
        [self.contentView addSubview:self.sexView];
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

@end
