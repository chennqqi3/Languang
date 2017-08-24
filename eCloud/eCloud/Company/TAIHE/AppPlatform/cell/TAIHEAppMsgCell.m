//
//  TAIHEAppMsgCell.m
//  eCloud
//
//  Created by yanlei on 2017/2/22.
//  Copyright © 2017年  lyong. All rights reserved.
//

#import "TAIHEAppMsgCell.h"
#import "StringUtil.h"
#import "TAIHEAppMsgModel.h"

@interface TAIHEAppMsgCell ()
@property (retain, nonatomic) IBOutlet UILabel *sendPersonLabel;
@property (retain, nonatomic) IBOutlet UIView *whiteView;
@property (retain, nonatomic) IBOutlet UIView *timeBackgroupView;
@property (retain, nonatomic) IBOutlet UIImageView *arrowImage;
@property (retain, nonatomic) IBOutlet UIView *viewDetailView;
@property (retain, nonatomic) IBOutlet UILabel *msgRecTimeLabel;

@property (retain, nonatomic) IBOutlet UILabel *msgTitleLabel;
@property (retain, nonatomic) IBOutlet UILabel *msgContentLabel;
@property (retain, nonatomic) IBOutlet UILabel *msgTimeLabel;
@property (retain, nonatomic) IBOutlet UILabel *msgSubTypeLabel;

@end

@implementation TAIHEAppMsgCell
- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.msgTitleLabel.numberOfLines = 1;
    self.msgContentLabel.numberOfLines = 1;
    self.msgTimeLabel.numberOfLines = 1;
    
    self.whiteView.layer.cornerRadius = 5;
    self.whiteView.clipsToBounds = YES;
    self.whiteView.layer.borderColor = [[UIColor colorWithWhite:0.92 alpha:1]CGColor];
    self.whiteView.layer.borderWidth = 1;
    
    self.timeBackgroupView.layer.cornerRadius = 11;
    self.timeBackgroupView.clipsToBounds = YES;
    self.arrowImage.image = [StringUtil getImageByResName:@"conf_arrow_right"];
    
    //查看详情
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewDetails)];
    self.viewDetailView.userInteractionEnabled = YES;
    [self.viewDetailView addGestureRecognizer:tap1];
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
    self.msgSubTypeLabel.text = appMsgModel.subtype == nil ? @"待办" : appMsgModel.subtype;
    self.msgTitleLabel.text = appMsgModel.sender;
    self.msgContentLabel.text = appMsgModel.title;
    self.msgTimeLabel.text = [StringUtil getDisplayTime:[NSString stringWithFormat:@"%lld",appMsgModel.sendtime]];
    
    self.msgRecTimeLabel.text = [StringUtil getDisplayTime_day:appMsgModel.msgtime];
}

- (void)dealloc
{
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIMenuControllerWillHideMenuNotification object:nil];
}
@end
