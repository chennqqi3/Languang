//
//  ReceiptMsgFileCell.h
//  eCloud
//
//  Created by Alex L on 15/11/5.
//  Copyright © 2015年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReceiptMsgFileCell : UITableViewCell

@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel * unreadCounts;

@property (nonatomic, strong) UIImageView *fileImgView;
@property (nonatomic, strong) UILabel *fileName;
@property (nonatomic, strong) UILabel *fileSize;

@end
