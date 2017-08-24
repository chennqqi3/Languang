//
//  UILabel+SetStatus.h
//  GomeSubApplication
//
//  Created by 房潇 on 2016/12/3.
//  Copyright © 2016年 Gome. All rights reserved.
//

#import "GSAHeader.h"

typedef NS_ENUM(NSInteger, GSALabelBorder) {
    GSALabelBlueBorder = 0,
    GSALabelClearBorder
};

@interface UILabel (SetStatus)
/**
 添加颜色为028be6的边框

 @param border 加边框还是去掉边框
 */
- (void)setBorder:(GSALabelBorder)border;
/**
 label多行显示 以Word折行
 */
- (void)setMultiline;

/**
 设置label两端对齐
 */
- (void)setAlignmentRightandLeft;
@end
