//
//  chatRecordCell.m
//  eCloud
//
//  Created by shinehey on 15/1/5.
//  Copyright (c) 2015年  lyong. All rights reserved.
//
#define text_Width 200.0
#define row_height 64.0

#import "chatRecordCell.h"
#import "convRecord.h"
#import "StringUtil.h"
#import "VerticallyAlignedLabel.h"
#import "LastRecordView.h"
#import "UserDisplayUtil.h"
#import "UIRoundedRectImage.h"
#import "Emp.h"
#import "PermissionModel.h"

#import "IOSSystemDefine.h"

@implementation chatRecordCell
{
    CGSize tempTextSize;
    
    CGFloat iconX;
    CGFloat iconY;
    CGFloat iconWidth;
    CGFloat iconHeight;

}


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)
reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        iconX = 3;
        iconY = 8;
//        iconWidth = 50;
//        iconHeight = 48;
        
//        UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(iconX, iconY, iconWidth, iconHeight)];
        
        UIImageView *icon = [UserDisplayUtil getUserLogoView];
        
        iconWidth = icon.frame.size.width;
        iconHeight = icon.frame.size.height;

        icon.tag = icon_tag;
        [self.contentView addSubview:icon];
        
        
        VerticallyAlignedLabel *nameLabel = [[VerticallyAlignedLabel alloc] init];
        CGFloat nameX = iconX+iconWidth+4;
        CGFloat nameY = iconY+3;
#ifdef _LANGUANG_FLAG_
        nameX = iconX+iconWidth+12;
#endif
        CGFloat nameWidth = text_Width;
        nameLabel.frame = CGRectMake(nameX, nameY, nameWidth, 20);
        nameLabel.font = [UIFont systemFontOfSize:17];
        nameLabel.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
        nameLabel.tag = name_tag;
        [self.contentView addSubview:nameLabel];
        [nameLabel release];
        
        
        LastRecordView *textLabel = [[LastRecordView alloc] initWithFrame:CGRectMake(nameX, nameY+CGRectGetHeight(nameLabel.frame)+5, nameWidth, text_height)];
//        textLabel.VerticalAlignment = VerticalAlignmentMiddle;
//        textLabel.font = [UIFont systemFontOfSize:15.0];
//        textLabel.textColor = [UIColor colorWithRed:155/255.0 green:155/255.0 blue:155/255.0 alpha:1];
//        textLabel.numberOfLines = 0;
        textLabel.tag = text_tag;
        [self.contentView addSubview:textLabel];
        [textLabel release];
        
        VerticallyAlignedLabel *timeLabel = [[VerticallyAlignedLabel alloc] init];
        CGFloat timeX = nameX +nameWidth;
        CGFloat timeY = nameY;
//        CGFloat timeWidth = CGRectGetWidth(self.frame) - (nameX+nameWidth) -10;
        CGFloat timeWidth = SCREEN_WIDTH - (nameX+nameWidth) -10;
        CGFloat timeHeight = 24;
        
        timeLabel.frame = CGRectMake(timeX, timeY, timeWidth, timeHeight);
        timeLabel.textAlignment = UITextAlignmentRight;
        timeLabel.font = [UIFont systemFontOfSize:12.0];
        timeLabel.textColor=[UIColor colorWithRed:178/255.0 green:178/255.0 blue:178/255.0 alpha:1];
        timeLabel.tag = time_tag;
        [self.contentView addSubview:timeLabel];
        [timeLabel release];
    }
    return self;
}

-(void)configCellWithConvRecord:(NSDictionary *)dic
{
    UIImageView *icon = (UIImageView *)[self viewWithTag:icon_tag];
    
    Emp *emp = [[Emp alloc]init];
    emp.emp_id = [[dic valueForKey:@"emp_id"] intValue];
    emp.emp_status = [[dic valueForKey:@"emp_status"] intValue];
    emp.loginType = [[dic valueForKey:@"emp_login_type"] intValue];
    emp.emp_sex = [[dic valueForKey:@"emp_sex"]intValue];
    emp.emp_logo = default_emp_logo;
    [UserDisplayUtil setUserLogoView:icon andEmp:emp andDisplayCurUserStatus:YES];
    [emp release];
    
//    
//    NSString *picPath = [StringUtil getLogoFilePathBy:[StringUtil getStringValue:[[dic valueForKey:@"emp_id"] intValue]] andLogo:@"0"];
//    UIImage *iconImage = [UIImage imageWithContentsOfFile:picPath];
//    
//    [UserDisplayUtil setUserLogoView:icon andEmpPermission:[dic valueForKey:@"permission"]];
//    
//    if (iconImage ==nil) {
//        int sex= [[dic valueForKey:@"emp_sex"] intValue];
//        if (sex == 0) {
//            iconImage = [UIImage imageNamed:@"female.png"];
//        }else
//        {
//            iconImage = [UIImage imageNamed:@"male.png"];
//        }
//    }else
//    {
//        iconImage = [UIImage createRoundedRectImage:iconImage size:CGSizeZero];
//    }
//    
//    
//    icon.image = iconImage;
    icon.frame = CGRectMake(iconX, iconY, iconWidth, iconHeight);
    
    
    UILabel *nameLabel = (UILabel *)[self viewWithTag:name_tag];
    nameLabel.text = [dic valueForKey:@"emp_name"];
    
    LastRecordView *textLabel = (LastRecordView *)[self viewWithTag:text_tag];
    /*
    textLabel.text = [dic valueForKey:@"msg_body"];
    CGSize tempSize = [self configTextSize:textLabel.text];
    CGRect _frame = textLabel.frame;
    _frame.size.height = tempSize.height +3;
    textLabel.frame = _frame;
//    textLabel.VerticalAlignment = VerticalAlignmentTop;
     */
    UIColor *greenColor = [UIColor colorWithRed:63.0/255.0 green:180.8/255.0 blue:8.0/255.0 alpha:1];
    textLabel.specialColor = greenColor;// [UIColor greenColor];
#ifdef _LANGUANG_FLAG_
    textLabel.specialColor =  [UIColor colorWithRed:36/255.0 green:129/255.0 blue:252/255.0 alpha:1/1.0];
#endif
    textLabel.msgBody = [dic valueForKey:@"msg_body"];
    textLabel.maxWidth = 230;
    textLabel.textFont = [UIFont systemFontOfSize:14.0f];
    textLabel.textColor = [UIColor darkGrayColor];
    [textLabel display];

    
    UILabel *timeLabel = (UILabel *)[self viewWithTag:time_tag];
    timeLabel.text = [StringUtil getLastMessageDisplayTime:[dic valueForKey:@"msg_time"]];
    
}

/*
-(CGSize)configTextSize:(NSString*)contentStr
{
    if (contentStr.length > 0) {
        tempTextSize = [contentStr sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(text_Width,MAXFLOAT)lineBreakMode:UILineBreakModeWordWrap];
        if (tempTextSize.height < text_height) {
            tempTextSize.height = text_height;
        }
        else
        {
            tempTextSize.height = tempTextSize.height;
        }
    }
    else
    {
        tempTextSize = CGSizeMake(text_Width, text_height);
    }
    return tempTextSize;
}
*/
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
