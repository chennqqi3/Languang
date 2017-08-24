//
//  QueryResultHeaderCell.m
//  eCloud
//
//  Created by shisuping on 14-5-23.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import "QueryResultHeaderCell.h"

#define cell_name_tag 101

@implementation QueryResultHeaderCell

- (void)dealloc
{
//    NSLog(@"%s",__FUNCTION__);
    [super dealloc];
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = [UIColor colorWithRed:235/255.0 green:240/255.0 blue:244/255.0 alpha:1];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        CGRect _frame = CGRectMake(10, 15, self.frame.size.width, 20);
        UILabel *cellNameLabel = [[UILabel alloc]initWithFrame:_frame];
        cellNameLabel.tag = cell_name_tag;
        cellNameLabel.textColor = [UIColor darkGrayColor];
        cellNameLabel.font = [UIFont systemFontOfSize:15];
        cellNameLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:cellNameLabel];
        [cellNameLabel release];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configCell:(NSString *)cellName
{
    UILabel *cellNameLabel = (UILabel *)[self.contentView viewWithTag:cell_name_tag];
    cellNameLabel.text = cellName;
}

@end
