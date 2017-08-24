//
//  MeInfoCell.h
//  WanDaOA
//
//  Created by hfchenc on 14-6-26.
//  Copyright (c) 2014年 李文龙. All rights reserved.
//


@interface OfficeMeInfoCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel        *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel        *subTitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView    *accessory;
@property (strong, nonatomic) UIImageView           *lineImageView;
+ (id)loadFromXib;

@end
