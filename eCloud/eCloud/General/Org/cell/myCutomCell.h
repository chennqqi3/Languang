//
//  myCutomCell.h
//  eCloud
//
//  Created by yanlei on 15/11/25.
//  Copyright © 2015年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VerticallyAlignedLabel.h"

// 自定义cell的高度
#define myCellHeight 86

@interface myCutomCell : UITableViewCell
/** 员工名称 */
@property(nonatomic,retain)VerticallyAlignedLabel *nameLable;
/** 用户头像 */
@property(nonatomic,retain)UIImageView *iconView;
/** 新版本标识按钮 */
@property(nonatomic,retain)UIButton *newButton;

@end
