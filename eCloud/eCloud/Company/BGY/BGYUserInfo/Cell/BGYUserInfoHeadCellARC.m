//
//  BGYUserInfoHeadCellARC.m
//  eCloud
//
//  Created by Alex-L on 2017/7/17.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "BGYUserInfoHeadCellARC.h"

@implementation BGYUserInfoHeadCellARC

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.userLogo.layer.cornerRadius = 40;
    self.userLogo.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
