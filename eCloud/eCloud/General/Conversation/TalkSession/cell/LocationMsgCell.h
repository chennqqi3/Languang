//
//  LocationMsgCell.h
//  eCloud
//
//  Created by Alex L on 16/5/20.
//  Copyright © 2016年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParentMsgCell.h"

//	最大宽度、高度
#define MSG_MAX_LOCATION_WIDTH (224)
#define MSG_MAX_LOCATION_HEIGHT (163)

// 地址控件的一些属性  高度、字体颜色、字体大小
#define MSG_ADDRESS_SPACE (8.5)
#define MSG_ADDRESS_HEIGHT (37)
#define MSG_ADDRESS_FONTSIZE (17)
#define MSG_ADDRESS_FONTCOLOR @"#000000"

// 图片控件的一些属性  高度
#define LOCATION_PIC_WIDTH (224)
#define LOCATION_PIC_HEIGHT (126)

@interface LocationMsgCell : ParentMsgCell

//显示图片文本消息，包括布局
+ (void)configureCell:(UITableViewCell *)cell andRecord:(ConvRecord*)_convRecord;

//调整共用的view的布局
+ (void)configureCommonView:(UITableViewCell *)cell andRecord:(ConvRecord *)_convRecord;

//普通图片消息的总高度
+ (float)getMsgHeight:(ConvRecord *)_convRecord;

@end
