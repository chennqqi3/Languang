//
//  LANGUANGMeetingCellARC.h
//  eCloud
//
//  Created by Ji on 17/5/26.
//  Copyright © 2017年 网信. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LANGUANGMeetingModelARC.h"

@interface LANGUANGMeetingCellARC : UITableViewCell

@property(nonatomic,strong)UILabel *titleLabel;
@property(nonatomic,strong)UILabel *dayLabel;

- (void)configCellWithDataModel:(LANGUANGMeetingModelARC*)model;

@end
