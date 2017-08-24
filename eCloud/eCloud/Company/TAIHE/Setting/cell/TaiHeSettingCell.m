//
//  TaiHeSettingCell.m
//  eCloud
//
//  Created by Ji on 17/1/17.
//  Copyright © 2017年  lyong. All rights reserved.
//

#import "TaiHeSettingCell.h"
#import "TAIHEAppViewController.h"
@implementation TaiHeSettingCell


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self=[super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
      
        self.homeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 20, 80, 80)];
        
        [self.contentView addSubview:self.homeImageView];
        self.homeImageView.userInteractionEnabled=YES;
        self.homeImageView.image = [[TAIHEAppViewController getTaiHeAppViewController]headTangential];
        self.homeImageView.layer.masksToBounds =YES;
        self.homeImageView.layer.cornerRadius = 40;
        [self.homeImageView.layer setBorderWidth:1];
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        
        CGColorRef colorref = CGColorCreate(colorSpace,(CGFloat[]){ 86,192,88,1});
        [self.homeImageView.layer setBorderColor:colorref];//边框颜色
        
        self.homeDay = [[UILabel alloc]initWithFrame:CGRectMake(self.homeImageView.frame.origin.x + self.homeImageView.frame.size.width + 20 , self.homeImageView.frame.origin.y , self.homeImageView.frame.size.width + 100 , self.homeImageView.frame.size.height)];
        self.homeDay.backgroundColor = [UIColor clearColor];
        self.homeDay.textColor=[UIColor blackColor];
        self.homeDay.font=[UIFont boldSystemFontOfSize:18.0];
        self.homeDay.textAlignment = UITextAlignmentLeft;
        [self.contentView addSubview:self.homeDay];
        
//        self.homeMonth = [[UILabel alloc]initWithFrame:CGRectMake(self.homeDay.frame.origin.x, self.homeDay.frame.origin.y + self.homeDay.frame.size.height + 10, self.homeDay.frame.size.height, 20)];
//        self.homeMonth.text = @"天";
//        self.homeMonth.font = [UIFont systemFontOfSize:13];
//        self.homeMonth.textAlignment = NSTextAlignmentRight;
//        [self.contentView addSubview:self.homeMonth];
        
        
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
