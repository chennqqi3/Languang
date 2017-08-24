//
//  LGMettingTipCell.m
//  eCloud
//
//  Created by Ji on 17/6/15.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "LGMettingTipCellARC.h"
#import "IOSSystemDefine.h"

@implementation LGMettingTipCellARC

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    LGMettingTipCellARC *cell = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (cell) {

        cell.backgroundColor = [UIColor clearColor];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.whiteView = [[UIView alloc]initWithFrame:CGRectMake(30, 0, SCREEN_WIDTH - 60, 140)];
        self.whiteView.layer.borderColor = [[UIColor colorWithWhite:0.92 alpha:1]CGColor];
        self.whiteView.backgroundColor = [UIColor whiteColor];
        self.whiteView.layer.borderWidth = 1;
        self.whiteView.layer.cornerRadius = 5;
        self.whiteView.clipsToBounds = YES;
        [cell.contentView addSubview:self.whiteView];
        
        self.tipLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 5, self.whiteView.frame.size.width -5, 100)];
        self.tipLabel.font = [UIFont systemFontOfSize:15];
        self.tipLabel.numberOfLines = 0;
        
        [self.whiteView addSubview:self.tipLabel];

    }
    
    return cell;
}

- (void)configCellWithDataModel:(LANGUANGAppMsgModelARC*)model{
    
    
    NSString *str;
    if ([model.meetingMsgType isEqualToString:@"5"]) {
        
        str = [NSString stringWithFormat:@"[结束]\"%@%@\"会议还有%@结束,结束之后会议室将会关闭",model.startTime,model.title,model.duration];
    }else if ([model.meetingMsgType isEqualToString:@"2"]){
        
        //[取消]“2017.05.23 09:00 需求沟通”会议已取消
        str = [NSString stringWithFormat:@"[取消]\"%@%@\"会议已取消",model.startTime,model.title];
    }
//        NSMutableParagraphStyle *paraStyle01 = [[NSMutableParagraphStyle alloc] init];
//        paraStyle01.lineHeightMultiple = 1.5;
//        
//        NSDictionary *attrDict01 = @{ NSParagraphStyleAttributeName: paraStyle01,
//                                      NSFontAttributeName: [UIFont systemFontOfSize: 15] };
//        
//        self.tipLabel.attributedText = [[NSAttributedString alloc] initWithString: str attributes: attrDict01];

        NSMutableAttributedString *AttributedStr = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@", str]];
        
        [AttributedStr addAttribute:NSForegroundColorAttributeName
         
                              value:[UIColor redColor]
         
                              range:NSMakeRange(1, 2)];
        
        
        self.tipLabel.attributedText = AttributedStr;
        
   
    CGSize size = [self.tipLabel.text sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(self.whiteView.frame.size.width -5, MAXFLOAT) lineBreakMode:UILineBreakModeWordWrap];
    CGRect _frame = self.whiteView.frame;
    _frame.size.height = size.height + 10;
    self.whiteView.frame = _frame;
    _frame = self.tipLabel.frame;
    _frame.size.height = size.height;
    self.tipLabel.frame = _frame;
    
}

#pragma mark - 跳转到推送信息详情
- (void)viewDetailToTip
{
    if (_delegate && [_delegate respondsToSelector:@selector(viewDetail:)])
    {
        [_delegate viewDetail:self];
    }
}

@end
