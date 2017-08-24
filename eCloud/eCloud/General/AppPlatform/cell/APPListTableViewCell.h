//
//  APPListTableViewCell.h
//  eCloud
//
//  Created by Pain on 14-6-16.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>
@class NewAppTagView;
@class APPListModel;
@interface APPListTableViewCell : UITableViewCell

@property(nonatomic,retain) UIImageView *logoView;
@property(nonatomic,retain) UIImageView *logoCoverView;
@property(nonatomic,retain) UILabel *appName;
@property(nonatomic,retain) NewAppTagView *appNewTag;
@property(nonatomic,retain) UIButton *detailButton;

//设置Cell的值
- (void)configureCellWith:(APPListModel *)appModel;

@end
