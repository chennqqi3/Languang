//
//  TAIHEEmailAppMsgCell.m
//  eCloud
//
//  Created by yanlei on 2017/2/23.
//  Copyright © 2017年  lyong. All rights reserved.
//

#import "TAIHEEmailAppMsgCell.h"
#import "TAIHEAppMsgViewController.h"
#import "TAIHEAppMsgModel.h"
#import "StringUtil.h"

@interface TAIHEEmailAppMsgCell ()
/** 服务器下发下来的时间组件 */
@property (retain, nonatomic) IBOutlet UILabel *msgRecTimeLabel;
/** 时间背景组件 */
@property (retain, nonatomic) IBOutlet UIView *timeBackgroupView;
/** 内容背景组件 */
@property (retain, nonatomic) IBOutlet UIView *whiteView;
/** 邮件发送人组件组件 */
@property (retain, nonatomic) IBOutlet UILabel *msgSenderLabel;
/** 邮件标题组件 */
@property (retain, nonatomic) IBOutlet UILabel *msgTitleLabel;
/** 邮件摘要组件 */
@property (retain, nonatomic) IBOutlet UILabel *msgContentLabel;
/** 触摸组件 */
//@property (retain, nonatomic) IBOutlet UIView *touchView;
//@property (retain, nonatomic) IBOutlet NSLayoutConstraint *whiteViewLayoutConstraint;

@end

@implementation TAIHEEmailAppMsgCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.msgSenderLabel.numberOfLines = 1;
    self.msgTitleLabel.numberOfLines = 1;
    
    self.whiteView.layer.cornerRadius = 5;
    self.whiteView.clipsToBounds = YES;
    self.whiteView.layer.borderColor = [[UIColor colorWithWhite:0.92 alpha:1]CGColor];
    self.whiteView.layer.borderWidth = 1;
    
    self.timeBackgroupView.layer.cornerRadius = 11;
    self.timeBackgroupView.clipsToBounds = YES;
    
    // 查看详情
//    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewDetails)];
//    self.touchView.userInteractionEnabled = YES;
//    [self.touchView addGestureRecognizer:tap1];
}

#pragma mark - 跳转到推送信息详情
- (void)viewDetails
{
    if (_delegate && [_delegate respondsToSelector:@selector(viewDetail:)])
    {
        [_delegate viewDetail:self];
    }
}

- (void)setAppMsgModel:(TAIHEAppMsgModel *)appMsgModel{
    _appMsgModel = appMsgModel;
    
    // 为控件赋值
//    如果是会议类型消息，则如下显示 add by shisp
    if (appMsgModel.apptype == app_conf_flag) {
        self.msgSenderLabel.text = appMsgModel.title;
        self.msgTitleLabel.text = [NSString stringWithFormat:@"开始时间：%@",[StringUtil getDisplayTime:[StringUtil getStringValue:appMsgModel.starttime]]];
        self.msgContentLabel.text = appMsgModel.location;
    }else{
        self.msgSenderLabel.text = appMsgModel.sender;
        self.msgTitleLabel.text = appMsgModel.title;
        self.msgContentLabel.text = appMsgModel.content;
    }
    
    
    self.msgRecTimeLabel.text = [StringUtil getDisplayTime_day:appMsgModel.msgtime];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
//    self.whiteViewLayoutConstraint.constant = self.bounds.size.height - 70;
    [self layoutIfNeeded];
}

- (void)dealloc
{
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIMenuControllerWillHideMenuNotification object:nil];
    [super dealloc];
}

@end
