//
//  LGNewsCellARC.h
//  eCloud
//
//  Created by Ji on 17/6/17.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "ParentMsgCell.h"
#import "LGNewsMdelARC.h"

@interface LGNewsCellARC : ParentMsgCell

@property(nonatomic,strong)UILabel *titleLabel;
@property(nonatomic,strong)UILabel *urlLabel;

+ (void)configCellWithDataModel:(LGNewsMdelARC*)model andCell:(UITableViewCell *)cell andRecord:(ConvRecord *)_convRecord;

-(void)showView:(UIView *)parentView convRecord:(ConvRecord*)_convRecord;

+ (float)getMsgHeight:(ConvRecord *)_convRecord;
@end
