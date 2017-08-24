//
//  LGMettingTipCell.h
//  eCloud
//
//  Created by Ji on 17/6/15.
//  Copyright © 2017年 网信. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LANGUANGAppMsgModelARC.h"
#import "LANGUANGAppMsgCellARCDelegate.h"

@interface LGMettingTipCellARC : UITableViewCell


@property (retain, nonatomic) UIView *whiteView;
@property (retain, nonatomic) UILabel *tipLabel;

/** 推送的消息model实体 */
@property (nonatomic,strong) LANGUANGAppMsgModelARC *LGAppMsgModel;

- (void)configCellWithDataModel:(LANGUANGAppMsgModelARC*)model;


@property (nonatomic, assign) id<LANGUANGAppMsgCellARCDelegate> delegate;

@end
