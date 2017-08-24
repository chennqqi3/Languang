//  以前做的应用的界面 deprecated
//  AppListImageView.h
//  AppList
//
//  Created by Pain on 14-6-25.
//  Copyright (c) 2014年 fengying. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AppListBtnModel;
@interface AppListImageView : UIImageView{
    id parent;
}
@property(nonatomic,retain) UIButton *iconbutton;
@property(nonatomic,retain) UILabel *nameLabel;
@property(nonatomic,retain) UIButton *deletebutton;
@property(nonatomic,retain) AppListBtnModel *appBtnModel;

@property (nonatomic, assign) id parent;

- (void)configureListImageView;//配置按钮
- (void)hideAllBtn;//隐藏所有按钮
@end
