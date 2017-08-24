//
//  MenuView.m
//  DropUpMenu
//
//  Created by 王刚 on 11/17/14.
//  Copyright (c) 2014 ccidnet. All rights reserved.
//

#import "IM_MenuView.h"
#import "eCloudDefine.h"
#import "IM_GWDropUpCell.h"

//static NSUInteger const defaultHeight = 44;
#define BTN_TAG_BASE_NUM 5678
#define DEFAULT_COLOR [UIColor colorWithRed:250.0/255.0 green:250.0/255.0 blue:250.0/255.0 alpha:1.0]
#define DEFAULT_BG_COLOR [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0]

static CGFloat const CellHeight = 40;

@interface IM_MenuView() <UITableViewDelegate, UITableViewDataSource>

//滑出菜单数据
@property (nonatomic, strong) NSArray *upTableItems;
//滑出列表
@property (nonatomic, strong) UITableView *itemTableView;

//滑出菜单是否隐藏
@property (nonatomic, assign) BOOL itemTableViewHidden;
// 子菜单弹出的框
@property (nonatomic, strong) UIImageView *backgroundImageView;
// 子菜单弹出的背景view
@property (nonatomic, strong) UIView *subItemBackGroundView;

@end

@implementation IM_MenuView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = DEFAULT_BG_COLOR;
        self.selectedBottomIndex = -1;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = frame;
        self.backgroundColor = DEFAULT_BG_COLOR;
        self.selectedBottomIndex = -1;
        
    }
    return self;
}

- (void)setBottomItems:(NSArray *)bottomItems {
    [self setBottomItems:bottomItems andLeftImageName:@"Mode_textmenuicon.png"];
//    _bottomItems = bottomItems;
//    //移除
//    for (UIView *view in self.subviews) {
//        [view removeFromSuperview];
//    }
//    //添加
//    CGFloat btnwidth = (self.frame.size.width - (bottomItems.count-1)*0.5)/bottomItems.count;
//    for (int i = 0; i < bottomItems.count; i++) {
//        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake((btnwidth + 0.5) * i, 0.5, 1, CGRectGetHeight(self.frame)-0.5)];
//        imageView.backgroundColor = [UIColor colorWithRed:202/255.0f green:202/255.0f blue:202/255.0f alpha:1.0f];
//        [self addSubview:imageView];
//        UIButton *btn = [self btnWithTitle:bottomItems[i] leftImageName:@"Mode_textmenuicon"];//bottom_btn
//        btn.frame = CGRectMake((btnwidth + 0.5) * i, 0.5, btnwidth, CGRectGetHeight(self.frame)-0.5);
//        btn.titleLabel.font = [UIFont systemFontOfSize:13];
//        btn.backgroundColor = [UIColor clearColor];
//        btn.tag = BTN_TAG_BASE_NUM + i;
//        [self addSubview:btn];
//    }
}

//底部菜单只显示文字，不显示图片
- (void)setBottomItems:(NSArray *)bottomItems andLeftImageName:(NSString *)imageName
{
    _bottomItems = bottomItems;
    //移除
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    //添加
    CGFloat btnwidth = (self.frame.size.width - (bottomItems.count-1)*0.5)/bottomItems.count;
    for (int i = 0; i < bottomItems.count; i++) {
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake((btnwidth + 0.5) * i, 0.5, 1, CGRectGetHeight(self.frame)-0.5)];
        imageView.backgroundColor = [UIColor colorWithRed:202/255.0f green:202/255.0f blue:202/255.0f alpha:1.0f];
        [self addSubview:imageView];
        UIButton *btn = [self btnWithTitle:bottomItems[i] leftImageName:imageName];//bottom_btn
        if (imageName) {
            [btn setImage:nil forState:UIControlStateNormal];
        }
        btn.frame = CGRectMake((btnwidth + 0.5) * i, 0.5, btnwidth, CGRectGetHeight(self.frame)-0.5);
        btn.titleLabel.font = [UIFont systemFontOfSize:13];
        btn.backgroundColor = [UIColor clearColor];
        btn.tag = BTN_TAG_BASE_NUM + i;
        
        // 设置点击效果
        UIView *backGroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 60)];
        backGroundView.backgroundColor = [UIColor lightGrayColor];
        
        [btn setBackgroundImage:[self convertViewToImage:backGroundView] forState:UIControlStateHighlighted];
        
        [self addSubview:btn];
    }
}
// UIView转UIImage
-(UIImage*)convertViewToImage:(UIView*)view
{
    UIGraphicsBeginImageContext(view.bounds.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage*image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}


- (UIButton *)btnWithTitle:(NSString *)title leftImageName:(NSString *)imageName {
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom]; // UIButtonTypeInfoLight
    btn.titleLabel.font = [UIFont systemFontOfSize:15];
    [btn setTintColor:[UIColor lightGrayColor]];
    if (IOS7_OR_LATER) {
        [btn setTintAdjustmentMode:UIViewTintAdjustmentModeAutomatic];
    }
    [btn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    
    btn.backgroundColor = DEFAULT_COLOR;
    
    [btn addTarget:self action:@selector(btnHandler:) forControlEvents:UIControlEventTouchUpInside];
    
    return btn;
}

- (void)btnHandler:(UIButton *)sender {
    
    NSInteger ksel = sender.tag - BTN_TAG_BASE_NUM;
    
    if (self.selectedBottomIndex == ksel) {
        self.itemTableViewHidden = !self.itemTableViewHidden;
        // 无子菜单
        if (self.upTableItems == nil || self.upTableItems.count == 0)
        {
            [self.delegate clickOrKeyAction:ksel];
        }
        self.selectedBottomIndex = -1;
    } else {
        self.upTableItems = [self.delegate upMenuItemsAtBottomIndex:ksel];
        // 无子菜单
        if (self.upTableItems == nil || self.upTableItems.count == 0) {
            [self hiddenItemTable];
            self.selectedBottomIndex = ksel;
            [self.delegate clickOrKeyAction:ksel];
        }else{
            [self.itemTableView reloadData];
            [self showItemTableAtIndex:ksel];
        }
    }
}


- (void)setItemTableViewHidden:(BOOL)itemTableViewHidden {
    itemTableViewHidden ? [self hiddenItemTable] :  [self showItemTableAtIndex:self.selectedBottomIndex];
}

//打开
- (void)showItemTableAtIndex:(NSInteger)index {
    if (self.upTableItems.count == 0) {
        return;
    }
    
    CGFloat tableWidth = (self.frame.size.width - (self.bottomItems.count+1))/self.bottomItems.count;// self.segmentedControl.frame.size.width/self.menuItems.count;
    CGRect tableFrame = CGRectMake(tableWidth * index + index + 1+40, self.displayView.frame.size.height-80/* - self.frame.size.height*/, tableWidth, CellHeight * self.upTableItems.count);
    
    // 取出底部工具栏的view
    for (id subView in self.displayView.subviews) {
        if ([subView isKindOfClass:[UIView class]]) {
            
            UIView *viewTmp = subView;
            if (viewTmp.frame.size.height == 50 || viewTmp.frame.size.height == 310) {
                // 将底部工具栏放在控制器视图的最前面
                [self.displayView bringSubviewToFront:viewTmp];
            }
        }
    }
    
//    self.backgroundImageView.frame = tableFrame;
//    self.itemTableView.frame = tableFrame;
    
    // 设置_subItemBackGroundView的frame
    self.subItemBackGroundView.frame = CGRectMake(tableFrame.origin.x, tableFrame.origin.y, tableFrame.size.width, tableFrame.size.height+10);
    
    // 在_subItemBackGroundView中设置itemTableView的frame
    self.itemTableView.frame = CGRectMake(0, 0, self.subItemBackGroundView.bounds.size.width, self.subItemBackGroundView.bounds.size.height-10);
    
    // 在_subItemBackGroundView中设置backgroundImageView的frame
    CGSize imageSize = self.backgroundImageView.image.size;
    self.backgroundImageView.frame = CGRectMake(tableFrame.size.width/2-imageSize.width/2, CGRectGetMaxY(self.itemTableView.frame)-0.5, imageSize.width, imageSize.height);
    
    tableFrame.origin.y = self.displayView.frame.size.height - self.frame.size.height - CellHeight * self.upTableItems.count - 70 + 64/*(displayViewTable.contentOffset.y + 64)*/;
    
    [UIView animateWithDuration:0.3f animations:^{
//        self.itemTableView.frame = tableFrame;
        self.subItemBackGroundView.frame = CGRectMake(tableFrame.origin.x, tableFrame.origin.y, tableFrame.size.width, tableFrame.size.height+10);
        
//        self.backgroundImageView.frame = CGRectMake(tableFrame.origin.x, tableFrame.origin.y, tableFrame.size.width, tableFrame.size.height+8);
        
    } completion:^(BOOL finished) {
        self.selectedBottomIndex = index;
        _itemTableViewHidden = NO;
    }];
}

//隐藏
- (void)hiddenItemTable {
    self.selectedBottomIndex = -1;
    CGRect tframe = self.subItemBackGroundView.frame;
    tframe.origin.y = self.displayView.frame.size.height;// - self.frame.size.height;
    [UIView animateWithDuration:0.2 animations:^{
//        self.itemTableView.frame = tframe;
//        CGSize imageSize = self.backgroundImageView.image.size;
//        self.backgroundImageView.frame = CGRectMake(tframe.origin.x+46-imageSize.width/2, CGRectGetMaxY(tframe)-2, imageSize.width, imageSize.height);
        self.subItemBackGroundView.frame = tframe;
    } completion:^(BOOL finished) {
        _itemTableViewHidden = YES;
    }];
}




#pragma up tableView
- (UITableView *)itemTableView {
    if (!_itemTableView) {
        _itemTableView = [[UITableView alloc]init];
        [_itemTableView registerClass:[IM_GWDropUpCell class] forCellReuseIdentifier:NSStringFromClass([IM_GWDropUpCell class])];
        _itemTableView.dataSource = self;
        _itemTableView.delegate = self;
        // 去掉弹出的子菜单的上下滑动的弹簧效果
        _itemTableView.bounces = NO;
        
        _itemTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        _itemTableView.layer.cornerRadius = 6;
        _itemTableView.layer.borderWidth = 0.5;
        _itemTableView.layer.borderColor = DEFAULT_BG_COLOR.CGColor;
        _itemTableView.backgroundColor = [UIColor colorWithRed:239/255.0f green:243/255.0f blue:237/255.0f alpha:1.0f];
        
//        if (IOS7_OR_LATER)
//        {
//            // 将cell的分割线的右端距离右边距15px
//            _itemTableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 15);
//        }
        
        
        if (self.displayView) {
//            [self.displayView addSubview:_itemTableView];
//            [_itemTableView sendSubviewToBack:self.displayView];
            
            // 创建二级子菜单的背景视图
            _subItemBackGroundView = [[UIView alloc]init];
            _subItemBackGroundView.backgroundColor = [UIColor clearColor];
            [_subItemBackGroundView addSubview:_itemTableView];
            [self.displayView addSubview:_subItemBackGroundView];
            // 添加二级菜单下的小箭头
            [self backgroundImageView];
        }
    }
    return _itemTableView;
}

- (UIImageView *)backgroundImageView{
    if (!_backgroundImageView) {
        _backgroundImageView = [[UIImageView alloc]init];
        _backgroundImageView.image = [UIImage imageNamed:@"EmoRelateword"];
        
//        _backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
        
        // 像素保护先去掉，后面重新作图，将新图放置在tableview的底部
//        UIImage *image = self.backgroundImageView.image;
//        self.backgroundImageView.image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(5,5,20,5)];
        
//        [self.displayView addSubview:_backgroundImageView];
        [self.subItemBackGroundView addSubview:_backgroundImageView];
        
//        _backgroundImageView.hidden = YES;
    }
    return _backgroundImageView;
}
#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.upTableItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    IM_GWDropUpCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([IM_GWDropUpCell class]) forIndexPath:indexPath];
    // frame适配
    CGRect cellFrame = cell.frame;
    cellFrame.size.width = self.subItemBackGroundView.frame.size.width;
    cell.frame = cellFrame;
    
    [UIAdapterUtil customSelectBackgroundOfCell:cell];
    cell.backgroundColor = [UIColor clearColor];
    cell.nameLabel.text = self.upTableItems[indexPath.row];
    if (indexPath.row == self.upTableItems.count-1) {
        cell.lineImageView.hidden = YES;
    }else{
        cell.lineImageView.hidden = NO;
    }
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.delegate selectedUpMenuItemAtIndex:indexPath.row bottomIndex:self.selectedBottomIndex];
    [self hiddenItemTable];
}
// 清空子菜单
- (void)removeSubMenuViews{
    [_itemTableView removeFromSuperview];
}
@end
