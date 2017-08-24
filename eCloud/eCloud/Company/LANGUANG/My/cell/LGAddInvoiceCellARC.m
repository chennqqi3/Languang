//
//  LGAddInvoiceCellARC.m
//  eCloud
//
//  Created by Ji on 17/7/11.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "LGAddInvoiceCellARC.h"
#import "IOSSystemDefine.h"
#import "StringUtil.h"

@implementation LGAddInvoiceCellARC

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 100, 60)];
        self.nameLabel.font = [UIFont systemFontOfSize:15];
        
        [self.contentView addSubview:self.nameLabel];
        
        self.valueTextView = [[UITextView alloc] initWithFrame:CGRectMake(120, 0, SCREEN_WIDTH - 120, 60)];
        self.valueTextView.font = [UIFont systemFontOfSize:15];
        self.valueTextView.textColor = [UIColor colorWithRed:161/255.0 green:161/255.0 blue:161/255.0 alpha:1];
        [self.contentView addSubview:self.valueTextView];
          
        self.invoiceImage = [[UIImageView alloc] initWithFrame:CGRectMake(120, 5, 50, 50)];
        [self.contentView addSubview:self.invoiceImage];
        self.invoiceImage.hidden = YES;
        self.invoiceImage.userInteractionEnabled = YES;
        
//        self.imageS = [[UIImageView alloc] initWithFrame:CGRectMake(180, 5, 90, 120)];
//        [self.contentView addSubview:self.imageS];
//        self.imageS.hidden = YES;
//        self.imageS.userInteractionEnabled = YES;
        
        self.delImage = [[UIImageView alloc] initWithFrame:CGRectMake(230, 100, 20, 20)];
        [self.contentView addSubview:self.delImage];
        self.delImage.image = [StringUtil getImageByResName:@"delete_invoice.png"];
        self.delImage.hidden = YES;
        self.delImage.userInteractionEnabled = YES;
        
    }
    
    return self;
}


@end
