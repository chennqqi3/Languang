//
//  mCell.h
//  eCloud
//
//  Created by SH on 14-9-16.
//  Copyright (c) 2014年  lyong. All rights reserved.
//
#define myCellHeight 140
#define iconViewWidth 54
#define iconViewHeight 72
#define deptX (iconViewWidth+23)
#define nameX (iconViewWidth+23)
#define nameY 18
#define deptY 51
#define deptMAXWidth SCREEN_WIDTH-90
#define nameMaxWidth SCREEN_WIDTH-90

#import <UIKit/UIKit.h>
#import "VerticallyAlignedLabel.h"

@interface myCell : UITableViewCell

@property(nonatomic,retain)VerticallyAlignedLabel *nameLable;
@property(nonatomic,retain)VerticallyAlignedLabel *deptLable;
@property(nonatomic,retain)UIImageView *iconView;
@property(nonatomic,retain)UIImageView *sexView;
@property(nonatomic,retain)UIImageView *ModifyView;
@end
