//
//  RedpacketMessageCell.h
//  LeanChat
//
//  Created by YANG HONGBO on 2016-5-7.
//  Copyright © 2016年 云帐户. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "RedpacketMessageModel.h"
#import "ParentMsgCell.h"
#import "ConvRecord.h"

/** 演示用Cell页面*/
@interface RedpacketMessageCell : ParentMsgCell

@property (nonatomic, strong)   UIImageView *headerImageView;
@property (nonatomic, strong)   UILabel     *userNickNameLabel;

- (void)configWithRedpacketMessageModel:(RedpacketMessageModel *)model
                        andRedpacketDic:(NSDictionary *)redpacketDic;

+ (CGFloat)heightForRedpacketMessageCell:(RedpacketMessageModel *)model;

+ (void)showRedpacketMsgView:(RedpacketMessageCell *)cell andConvRecord:(ConvRecord *)_convRecord;

@end
