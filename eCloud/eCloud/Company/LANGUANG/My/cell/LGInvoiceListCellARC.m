//
//  LGInvoiceListCellARC.m
//  eCloud
//
//  Created by Ji on 17/7/11.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "LGInvoiceListCellARC.h"

@implementation LGInvoiceListCellARC

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        self.icon = [[UIImageView alloc] initWithFrame:CGRectMake(12, 8, 24, 24)];
        [self.contentView addSubview:self.icon];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(48, 8.5, 160, 22.5)];
        self.titleLabel.font = [UIFont systemFontOfSize:16];
        [self.contentView addSubview:self.titleLabel];
        
    }
    
    return self;
}

@end
