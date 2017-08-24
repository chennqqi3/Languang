//
//  ReceiptMsgRecordCell.h
//  eCloud
//
//  Created by Alex L on 15/11/5.
//  Copyright © 2015年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReceiptMsgRecordCell : UITableViewCell

@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *unreadCounts;
@property (nonatomic, strong) UILabel *durationLabel;
@property (nonatomic, strong) UIButton *playOrPauseBtn;

@end
