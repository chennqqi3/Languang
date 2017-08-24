//
//  MenuView.h
//  DropUpMenu
//
//  Created by 王刚 on 11/17/14.
//  Copyright (c) 2014 ccidnet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MenuViewDelegate;

@interface IM_MenuView : UIView

//custom methods

@property (nonatomic, weak) id<MenuViewDelegate> delegate;

//主菜单数据
@property (nonatomic, strong) NSArray *bottomItems;
//显示视图
@property (nonatomic, strong) UIView *displayView;
//选中button索引
@property (nonatomic, assign) NSInteger selectedBottomIndex;

//隐藏滑出菜单
- (void)hiddenItemTable;

// 清空子菜单
- (void)removeSubMenuViews;

//底部菜单只显示文字，不显示图片
- (void)setBottomItems:(NSArray *)bottomItems andLeftImageName:(NSString *)imageName;

@end


@protocol MenuViewDelegate <NSObject>

- (void)clickOrKeyAction:(NSInteger)ksel;

- (NSArray *)upMenuItemsAtBottomIndex:(NSInteger)index;

- (void)selectedUpMenuItemAtIndex:(NSInteger)upItemIndex bottomIndex:(NSInteger)bottomIndex;

@end
