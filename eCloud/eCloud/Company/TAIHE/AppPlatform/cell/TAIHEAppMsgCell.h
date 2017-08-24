//
//  TAIHEAppMsgCell.h
//  eCloud
//
//  Created by yanlei on 2017/2/22.
//  Copyright © 2017年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TAIHEAppMsgCellDelegate.h"

@class TAIHEAppMsgModel;

@interface TAIHEAppMsgCell : UITableViewCell

/** 推送的消息model实体 */
@property (nonatomic,strong) TAIHEAppMsgModel *appMsgModel;

@property (nonatomic, assign) id<TAIHEAppMsgCellDelegate> delegate;

@end
