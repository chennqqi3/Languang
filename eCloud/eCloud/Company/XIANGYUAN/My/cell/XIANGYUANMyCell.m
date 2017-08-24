//
//  XIANGYUANMyCell.m
//  eCloud
//
//  Created by Ji on 17/5/24.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "XIANGYUANMyCell.h"

@implementation XIANGYUANMyCell


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self=[super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        

        self.homeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 15, 70, 70)];
        
        [self.contentView addSubview:self.homeImageView];
        self.homeImageView.userInteractionEnabled=YES;
        [self.homeImageView.layer setMasksToBounds:YES];
        [self.homeImageView.layer setCornerRadius:5];
        
        self.homeDay = [[UILabel alloc]initWithFrame:CGRectMake(self.homeImageView.frame.origin.x + self.homeImageView.frame.size.width + 20 , self.homeImageView.frame.origin.y , self.homeImageView.frame.size.width + 100 , self.homeImageView.frame.size.height)];
        self.homeDay.backgroundColor = [UIColor clearColor];
        self.homeDay.textColor=[UIColor blackColor];
        self.homeDay.font=[UIFont boldSystemFontOfSize:18.0];
        self.homeDay.textAlignment = UITextAlignmentLeft;
        [self.contentView addSubview:self.homeDay];
        
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
