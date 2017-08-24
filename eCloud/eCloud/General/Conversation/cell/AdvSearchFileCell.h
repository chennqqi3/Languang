//
//  AdvSearchFileCell.h
//  eCloud
//  在会话列表界面 展示文件搜索结果 cell
//  Created by shisuping on 17/6/29.
//  Copyright © 2017年 网信. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ConvRecord;

@interface AdvSearchFileCell : UITableViewCell

/** 下载进度 */
@property (nonatomic,retain) UIProgressView *progressView;


/** 显示 查询结果 文件  */
- (void)configCellWithConvRecord:(ConvRecord *)_convRecord;

@end
