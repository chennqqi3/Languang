//
//  LGInvoiceMsgCellARC.m
//  eCloud
//
//  Created by Ji on 17/7/19.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "LGInvoiceMsgCellARC.h"
#import "IOSSystemDefine.h"

@implementation LGInvoiceMsgCellARC

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 100, 60)];
        self.nameLabel.font = [UIFont systemFontOfSize:15];
        
        [self.contentView addSubview:self.nameLabel];
        
        self.valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(130, 0, SCREEN_WIDTH - 140, 60)];
        self.valueLabel.font = [UIFont systemFontOfSize:15];
        self.valueLabel.textColor = [UIColor colorWithRed:161/255.0 green:161/255.0 blue:161/255.0 alpha:1];
        self.valueLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        self.valueLabel.numberOfLines = 1;
        [self.contentView addSubview:self.valueLabel];
        
        self.invoiceImage = [[UIImageView alloc] initWithFrame:CGRectMake(130, 5, 50, 50)];
        [self.contentView addSubview:self.invoiceImage];
        self.invoiceImage.hidden = YES;
        self.invoiceImage.userInteractionEnabled = YES;
        
        
    }
    
    return self;
}

@end
