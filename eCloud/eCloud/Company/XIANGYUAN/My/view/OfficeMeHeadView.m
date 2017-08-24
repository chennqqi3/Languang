//
//  OfficeMeHeadView.m
//  WanDaOA
//
//  Created by hfchenc on 14-6-26.
//  Copyright (c) 2014年 李文龙. All rights reserved.
//

#import "OfficeMeHeadView.h"
//#import "UIImage+UIImageExt.h"
#import "StringUtil.h"
#import "IOSSystemDefine.h"

@implementation OfficeMeHeadView

+ (OfficeMeHeadView *)loadFromXib
{
    return [[[NSBundle mainBundle] loadNibNamed:@"OfficeMeHeadView" owner:self options:nil] objectAtIndex:0];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
- (IBAction)tapHeadView:(id)sender {
    if (self.tapHeadViewBlock) {
        self.tapHeadViewBlock();
    }
}

- (IBAction)personInformationClick:(id)sender
{
    if (self.personInfomationBlock) {
        self.personInfomationBlock();
    }
}

- (void)loadViewWithHeadImage:(NSString *)imageUrl name:(NSString *)name position:(NSString *)position apartment:(NSString *)apartment loginName:(NSString *)longName
{
    [self.headImageView.layer setMasksToBounds:YES];
    [self.headImageView.layer setCornerRadius:60/2];
    self.backImage.image = [StringUtil getImageByResName:@"aboutMe_background_image"];
    self.arrowImage.image = [StringUtil getImageByResName:@"aboutMe_white_arrow_image"];
    CGRect _frame = self.arrowImage.frame;
    _frame.origin.x = SCREEN_WIDTH - self.arrowImage.frame.size.width - 10;
    self.arrowImage.frame = _frame;
    
    self.loginNameLabel.text = longName;
    self.nameLabel.text = name;
    self.nameLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:18];
    
    NSArray *tempArr=[position componentsSeparatedByString:@":"];
    if (tempArr) {
        
        self.positionLabel.text = tempArr[0];
    }
    _frame = self.positionLabel.frame;
    _frame.size.width = SCREEN_WIDTH - self.positionLabel.frame.origin.x - 10;
    self.positionLabel.frame = _frame;
    self.positionLabel.lineBreakMode = UILineBreakModeWordWrap | UILineBreakModeTailTruncation;
    
    self.addressLabel.text = apartment;
    CGSize nameLabelSize = [name sizeWithFont:[UIFont systemFontOfSize:18] constrainedToSize:CGSizeMake(320, 21)];
    CGRect loginNameLabelframe = CGRectMake(nameLabelSize.width + self.nameLabel.frame.origin.x+5,self.loginNameLabel.frame.origin.y , self.loginNameLabel.frame.size.width, self.loginNameLabel.frame.size.height);
    self.loginNameLabel.frame = loginNameLabelframe;
    self.loginNameLabel.hidden = YES;
    
    if (iPhone5) {
        
        CGRect _frame = self.headImageView.frame;
        _frame.origin.x = _frame.origin.x - 10;
        self.headImageView.frame = _frame;
        _frame = self.loginNameLabel.frame;
        _frame.origin.x = _frame.origin.x - 30;
        self.loginNameLabel.frame = _frame;
        _frame = self.nameLabel.frame;
        _frame.origin.x = _frame.origin.x - 30;
        self.nameLabel.frame = _frame;
        _frame = self.positionLabel.frame;
        _frame.origin.x = _frame.origin.x - 30;
        self.positionLabel.frame = _frame;
        _frame = self.addressLabel.frame;
        _frame.origin.x = _frame.origin.x - 30;
        _frame.size.width = SCREEN_WIDTH - self.addressLabel.frame.origin.x - 10;
        self.addressLabel.frame = _frame;
        
    }
}
- (void)dealloc {
    [_backImage release];
    [_arrowImage release];
    [super dealloc];
}
@end
