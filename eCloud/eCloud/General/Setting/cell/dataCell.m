//
//  dataCell.m
//  eCloud
//
//  Created by SH on 14-8-4.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import "dataCell.h"
#import "StringUtil.h"
#import "UIAdapterUtil.h"

@implementation dataCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [UIAdapterUtil customSelectBackgroundOfCell:self];
        
        self.typeLable = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, 120, 51)];
        self.typeLable.backgroundColor = [UIColor clearColor];
        self.typeLable.textColor=[UIAdapterUtil isGOMEApp] ? GOME_NAME_COLOR : [UIColor blackColor];
        self.typeLable.font=[UIFont systemFontOfSize:17];
        self.typeLable.textAlignment = UITextAlignmentLeft;
		[self.contentView addSubview:self.typeLable];
        
        self.sizeLable = [[UILabel alloc]initWithFrame:CGRectMake(85, 0, 80,51)];
        self.sizeLable.backgroundColor = [UIColor clearColor];
		self.sizeLable.textColor=[UIColor grayColor];
        self.sizeLable.font=[UIFont systemFontOfSize:16.0];
        self.sizeLable.textAlignment = UITextAlignmentLeft;
		[self.contentView addSubview:self.sizeLable];
        
        CGFloat screenW = [UIAdapterUtil getDeviceMainScreenWidth];
        self.clearButton = [[UIButton alloc]initWithFrame:CGRectMake(screenW - 40-15, 5, 40, 40)];
        self.clearButton.backgroundColor = [UIColor clearColor];
        self.clearButton.titleLabel.textAlignment = NSTextAlignmentRight;
    
        [self.clearButton setTitleColor:[UIColor colorWithRed:36/255.0 green:129/255.0 blue:252/255.0 alpha:1/1.0] forState:UIControlStateNormal];

        [self.clearButton setTitle:[StringUtil getLocalizableString:@"clearData_clear"] forState:UIControlStateNormal];
        [self addSubview:self.clearButton];
    }
    return self;
}

-(void)dealloc
{
    self.typeLable = nil;
    self.sizeLable = nil;
    self.clearButton = nil;
    [super dealloc];
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
@end
