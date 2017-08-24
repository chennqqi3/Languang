//
//  CustomMyCell.h
//  eCloud
//  办公界面上  轻应用相关的显示cell
//  Created by shisuping on 15-9-6.
//  Copyright (c) 2015年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>

// 行高
#define ROW_HEIGHT (55.0)

@class APPListModel;

@interface CustomMyCell : UITableViewCell

/**
 根据model对cell上的组件进行赋值及布局调整

 @param model 轻应用实体
 */
- (void)configCellWithDataModel:(APPListModel*)model;

/**
 获取app的logo

 @param appModel 指定轻应用model

 @return logo图片
 */
+ (UIImage *)getAppLogo:(APPListModel *)appModel;

@end
