//
//  GOMENotificationCell.m
//  eCloud
//
//  Created by Alex L on 16/12/7.
//  Copyright © 2016年  lyong. All rights reserved.
//

#import "GOMENotificationCell.h"
#import "StringUtil.h"
#import "APPPlatformDOA.h"
#import "APPListModel.h"
#import "JSONKit.h"
#import "AppMsgModel.h"
#import "GOMEAppMsgModel.h"

@interface GOMENotificationCell ()

@property (retain, nonatomic) IBOutlet UIView *whiteView;
@property (retain, nonatomic) IBOutlet UILabel *timeLabel;
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UILabel *viewDetailLabel;

@property (retain, nonatomic) IBOutlet UIImageView *timeImage;
@property (retain, nonatomic) IBOutlet UIImageView *arrowImage;
@property (retain, nonatomic) IBOutlet UIView *imageTapView;


@property (nonatomic, strong) UIView *grayView;

@end

@implementation GOMENotificationCell

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIMenuControllerWillHideMenuNotification object:nil];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.whiteView.layer.cornerRadius = 5;
    self.whiteView.clipsToBounds = YES;
    self.whiteView.layer.borderColor = [[UIColor colorWithWhite:0.92 alpha:1]CGColor];
    self.whiteView.layer.borderWidth = 1;
    
    self.arrowImage.image = [StringUtil getImageByResName:@"blue_left_arrow"];
    self.timeImage.image = [StringUtil getImageByResName:@"imTime"];
    
    self.viewDetailLabel.text = @"查 看";
    
    //查看详情
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewDetails)];
    self.viewDetailLabel.userInteractionEnabled = YES;
    [self.viewDetailLabel addGestureRecognizer:tap1];
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewDetails)];
    self.imageTapView.userInteractionEnabled = YES;
    [self.imageTapView addGestureRecognizer:tap2];
    
    
    // 监听 menu 消失的通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(menuWillHide) name:UIMenuControllerWillHideMenuNotification object:nil];
    
    // 长按弹出删除按钮
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [self.contentView addGestureRecognizer:longPress];
}

-(BOOL)canBecomeFirstResponder
{
    return YES;
}

-(BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (action == @selector(deleteAction))
    {
        return YES;
    }
    return NO;
}

- (void)longPress:(UIGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        self.whiteView.backgroundColor = [UIColor colorWithWhite:0.87 alpha:1];
        
        self.grayView = [[UIView alloc] initWithFrame:self.whiteView.frame];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeGrayView)];
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(removeGrayView:)];
        [self.grayView addGestureRecognizer:pan];
        [self.grayView addGestureRecognizer:tap];
        [self.contentView addSubview:self.grayView];
        
        [self becomeFirstResponder];
        
        
        // 显示 "删除" 按钮
        UIMenuItem *deleteItem = [[UIMenuItem alloc] initWithTitle:[StringUtil getLocalizableString:@"delete"] action:@selector(deleteAction)];
        UIMenuController *menu = [UIMenuController sharedMenuController];
        [menu setMenuItems:[NSArray arrayWithObjects:deleteItem, nil]];
        [menu setTargetRect:self.whiteView.bounds inView:self.whiteView];
        [menu setMenuVisible:YES animated:YES];
    }
}

- (void)removeGrayView
{
    UIMenuController *menu = [UIMenuController sharedMenuController];
    [menu setMenuVisible:NO animated:YES];
}

- (void)removeGrayView:(UIGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        UIMenuController *menu = [UIMenuController sharedMenuController];
        [menu setMenuVisible:NO animated:YES];
    }
}

- (void)menuWillHide
{
    self.whiteView.backgroundColor = [UIColor whiteColor];
    [self.grayView removeFromSuperview];
    
    [self resignFirstResponder];
}

- (void)deleteAction
{
    if (_deleteDelegate && [_deleteDelegate respondsToSelector:@selector(deleteWithIndex:)])
    {
        [_deleteDelegate deleteWithIndex:self.tag];
    }
    
    NSLog(@"delete");
}

- (void)viewDetails
{
    NSLog(@"viewDetails");
    
    if (_deleteDelegate && [_deleteDelegate respondsToSelector:@selector(viewDetail:)])
    {
        [_deleteDelegate viewDetail:self];
    }
}

- (void)setAppMsgModel:(AppMsgModel *)model{
    _appMsgModel = model;
    self.titleLabel.text = model.appMsgTitle;
    self.messageLabel.text = model.gomeAppMsgModel.msgContent;
    
    self.timeLabel.text = [StringUtil getDisplayTime_day:[NSString stringWithFormat:@"%d",model.appMsgTime]];
}

@end
