//
//  TAIHEAppMsgCell.h
//  eCloud
//
//  Created by yanlei on 2017/2/22.
//  Copyright © 2017年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LANGUANGAppMsgCellARCDelegate.h"

@class LANGUANGAppMsgModelARC;

@interface LANGUANGAppMsgCellARC : UITableViewCell

/** 推送的消息model实体 */
@property (nonatomic,strong) LANGUANGAppMsgModelARC *LGAppMsgModel;

@property (nonatomic, assign) id<LANGUANGAppMsgCellARCDelegate> delegate;

@end
