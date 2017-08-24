//
//  TAIHEAppMsgCell.m
//  eCloud
//
//  Created by yanlei on 2017/2/22.
//  Copyright © 2017年  lyong. All rights reserved.
//

#import "LANGUANGAppMsgCellARC.h"
#import "StringUtil.h"
#import "LANGUANGAppMsgModelARC.h"
#import "IOSSystemDefine.h"
#import "LGMettingDetailViewControllerArc.h"

@interface LANGUANGAppMsgCellARC ()
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
@property (retain, nonatomic) IBOutlet UIView *lineView;
@property(strong,nonatomic)UILabel *placeLabel;
@property(strong,nonatomic)UILabel *approach;
@property(strong,nonatomic)UIImageView *endImage;
@end

@implementation LANGUANGAppMsgCellARC
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
    self.viewDetailView.hidden = YES;
    self.lineView.hidden = YES;
    
    self.placeLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.msgTitleLabel.frame.size.width + self.msgTitleLabel.frame.origin.x + 50, self.msgTitleLabel.frame.origin.y, self.whiteView.frame.size.width - self.msgTitleLabel.frame.size.width - self.msgTitleLabel.frame.origin.x, self.msgTitleLabel.frame.size.height)];
    self.placeLabel.textColor = [UIColor lightGrayColor];
    self.placeLabel.font = [UIFont systemFontOfSize:14];
//    self.placeLabel.text = @"地点：会议室1005大的撒大所多撒";
//    self.placeLabel.backgroundColor = [UIColor yellowColor];
    [self.whiteView addSubview:self.placeLabel];

    self.approach = [[UILabel alloc]initWithFrame:CGRectMake(self.msgSubTypeLabel.frame.size.width + self.msgSubTypeLabel.frame.origin.x + 40, self.msgSubTypeLabel.frame.origin.y, self.whiteView.frame.size.width - self.msgSubTypeLabel.frame.size.width - self.msgSubTypeLabel.frame.origin.x, self.msgSubTypeLabel.frame.size.height)];
    self.approach.textColor = [UIColor orangeColor];
    self.approach.font = [UIFont systemFontOfSize:14];
//    self.approach.backgroundColor = [UIColor yellowColor];
    [self.whiteView addSubview:self.approach];
    
    self.endImage = [[UIImageView alloc]initWithFrame:CGRectMake(self.whiteView.frame.size.width / 2 - 50, 10, 135, 120)];
//    self.endImage.backgroundColor = [UIColor redColor];
    self.endImage.image = [StringUtil getImageByResName:@"end2.png"];
    [self.whiteView addSubview:self.endImage];
    self.endImage.hidden = YES;
    
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

- (void)setLGAppMsgModel:(LANGUANGAppMsgModelARC *)appMsgModel{
    _LGAppMsgModel = appMsgModel;

//    // 为控件赋值
    //NSString *string;
    UIColor *_color;
    //UIColor *_color = [UIColor colorWithPatternImage:[StringUtil getImageByResName:@"rootDeptBtn1.png"]];
    if ([appMsgModel.importance isEqualToString:@"非正式"]) {
        //string = @"一般";
        _color = [UIColor blueColor];
        
    }else{
        //string = @"重要";
        _color = [UIColor redColor];
        
    }
    NSMutableAttributedString *AttributedStr = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"[%@]%@",appMsgModel.importance,appMsgModel.title]];
    
    [AttributedStr addAttribute:NSForegroundColorAttributeName
     
                          value:_color
     
                          range:NSMakeRange(1, appMsgModel.importance.length)];
    
    //_titleLabel.attributedText = AttributedStr;
    self.msgSubTypeLabel.attributedText = AttributedStr;
    self.msgTitleLabel.text = appMsgModel.host;
    self.msgContentLabel.text = [NSString stringWithFormat:@"%@   %@",appMsgModel.startTime,appMsgModel.duration];
    
    if (appMsgModel.summary.length == 0) {
        
        self.msgTimeLabel.text = @"  ";
        
    }else{
        
        self.msgTimeLabel.text = appMsgModel.summary;
    }

    if (appMsgModel.place.length) {
        
        self.placeLabel.text = [NSString stringWithFormat:@"地点：%@",appMsgModel.place];
        
    }
    self.msgRecTimeLabel.text = [StringUtil getDisplayTime_day:appMsgModel.msgtime];
    self.approach.text = appMsgModel.approach;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *endTime = [dateFormatter dateFromString:appMsgModel.endTime];
    
    NSDate *time = [[LGMettingDetailViewControllerArc getLGMettingDetailViewControllerArc] getCurrentTime];
    
    BOOL isEnd = [[LGMettingDetailViewControllerArc getLGMettingDetailViewControllerArc] compareOneDay:time withAnotherDay:endTime];
    
    if (isEnd) {
        self.endImage.hidden = NO;
    }
    
}

- (void)dealloc
{
   
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIMenuControllerWillHideMenuNotification object:nil];
}
@end
