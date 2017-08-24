//
//  ImgtxtMsgCell.m
//  eCloud
//
//  Created by yanlei on 15/11/6.
//  Copyright © 2015年  lyong. All rights reserved.
//

#import "ImgtxtMsgCell.h"
#import "DisplayImgtxtTableView.h"
#import "ImgtxtMsgSubCell.h"

@implementation ImgtxtMsgCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [super addCommonView:self];
        
#pragma mark --不带超链接一般文本消息--
        UIView *contentView = (UIView *)[self.contentView viewWithTag:body_tag];
        
        
//        self.imgtxtTable = [[DisplayImgtxtTableView alloc]initWithFrame:contentView.bounds style:UITableViewStylePlain];
//        self.imgtxtTable.tag = imgtxt_table_tag;
//        self.imgtxtTable.delegate = self;
//        self.imgtxtTable.dataSource = self;
//        [contentView addSubview:self.imgtxtTable];
//        [self.imgtxtTable release];
        
//        UILabel *normalTextView = [[UILabel alloc]initWithFrame:CGRectZero];
//        normalTextView.font = [UIFont systemFontOfSize:message_font];
//        normalTextView.numberOfLines = 0;
//        normalTextView.backgroundColor = [UIColor clearColor];
//        normalTextView.tag = normal_text_tag;
//        normalTextView.textColor = [UIColor colorWithRed:53/255 green:53/255 blue:53/255 alpha:1.0];
//        [contentView addSubview:normalTextView];
//        [normalTextView release];
    }
    return self;
}

- (void)configureCell:(ConvRecord*)_convRecord;
{
    [super configureCell:_convRecord];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"imgtxtsubcellId";
    ImgtxtMsgSubCell *subCell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    
    if (!subCell) {
        subCell = [[ImgtxtMsgSubCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        subCell.backgroundColor = [UIColor blackColor];
    }
    subCell.textLabel.text = @"我是图文cell";
    
    return subCell;
}

@end
