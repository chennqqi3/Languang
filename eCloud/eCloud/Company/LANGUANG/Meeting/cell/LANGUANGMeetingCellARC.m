//
//  LANGUANGMeetingCellARC.m
//  eCloud
//
//  Created by Ji on 17/5/26.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "LANGUANGMeetingCellARC.h"
#import "StringUtil.h"
#import "IOSSystemDefine.h"

@implementation LANGUANGMeetingCellARC

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    LANGUANGMeetingCellARC *cell = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (cell) {
        
        //cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;

        //        图片
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 21, 8, 8)];
        imageView.image = [StringUtil getImageByResName:@"yuanhong.png"];
        [cell.contentView addSubview:imageView];
        
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(30, 0, SCREEN_WIDTH - 90, 50)];
        [cell.contentView addSubview:_titleLabel];

        _dayLabel = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH -50, 0, 50, 50)];
        [_dayLabel setFont:[UIFont boldSystemFontOfSize:14.0]];
        [_dayLabel setTextColor:[UIColor colorWithRed:188/255.0f green:188/255.0f blue:188/255.0f alpha:1.0f]];
        [cell.contentView addSubview:_dayLabel];
    }
    
    return cell;
}

- (void)configCellWithDataModel:(LANGUANGMeetingModelARC*)appModel
{

    //NSString *string;
    UIColor *_color;
    if ([appModel.type isEqualToString:@"非正式"]) {
        //string = @"一般";
        _color = [UIColor blueColor];
    }else{
        //string = @"重要";
        _color = [UIColor redColor];
    }
    NSString *tmpStr = [appModel.startTime substringWithRange:NSMakeRange(5,5)];
    NSMutableAttributedString *AttributedStr = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"[%@]%@ %@",appModel.type,appModel.confName,tmpStr]];
    
    [AttributedStr addAttribute:NSForegroundColorAttributeName
     
                          value:_color
     
                          range:NSMakeRange(1, appModel.type.length)];
    
    _titleLabel.attributedText = AttributedStr;
    
    //starttime 2017-02-20 09:30:00
    if (appModel.startTime.length >16) {
        
        NSString *string;
        string = [appModel.startTime substringToIndex:16];
        _dayLabel.text = [string substringFromIndex:11];
        
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
