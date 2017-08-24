//
//  LocalFileListCell.m
//  QuickLookDemo
//
//  Created by Pain on 14-4-9.
//  Copyright (c) 2014年 yangjw . All rights reserved.
//

#import "LocalFileListCell.h"

@implementation LocalFileListCell

@synthesize isSelectBtn;
@synthesize isSelectBtnView;
@synthesize fileIconView;
@synthesize fileNameLabel;
@synthesize fileSizeLabel;
@synthesize fileCreateDateLabel;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleGray;
        
        //复选框
        CGRect frame = CGRectMake(6.0,6.0,30.0,30.0);
        
        //文件预览小图
        frame.origin.x += frame.size.width;
		self.fileIconView = [[UIImageView alloc] initWithFrame:CGRectMake(frame.origin.x,2.0, 40.0, 40.0)];
        self.fileIconView.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:self.fileIconView];
        
        //文件名
        frame.origin.x += 42.0;
		self.fileNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(frame.origin.x,1.0, 190.0, 20.0)];
		self.fileNameLabel.backgroundColor = [UIColor clearColor];
		self.fileNameLabel.textColor=[UIColor blackColor];
        self.fileNameLabel.font=[UIFont systemFontOfSize:14.0];
        self.fileNameLabel.textAlignment = UITextAlignmentLeft;
		[self.contentView addSubview:self.fileNameLabel];
		
        //文件大小
		self.fileSizeLabel = [[UILabel alloc]initWithFrame:CGRectMake(frame.origin.x,20.0, 180.0, 20.0)];
		self.fileSizeLabel.backgroundColor = [UIColor clearColor];
		self.fileSizeLabel.textColor=[UIColor grayColor];
        self.fileSizeLabel.font=[UIFont systemFontOfSize:12.0];
        self.fileSizeLabel.textAlignment = UITextAlignmentLeft;
		[self.contentView addSubview:self.fileSizeLabel];
        
        //文件修改时间
        frame.origin.x += 180.0;
		self.fileCreateDateLabel = [[UILabel alloc]initWithFrame:CGRectMake(frame.origin.x+16.0,8.0, 46.0, 30.0)];
		self.fileCreateDateLabel.backgroundColor = [UIColor clearColor];
		self.fileCreateDateLabel.textColor=[UIColor grayColor];
        self.fileCreateDateLabel.font=[UIFont systemFontOfSize:8.0];
		self.fileCreateDateLabel.contentMode = UIViewContentModeTop;
        self.fileCreateDateLabel.textAlignment = UITextAlignmentLeft;
        self.fileCreateDateLabel.numberOfLines = 2;
		[self.contentView addSubview:self.fileCreateDateLabel];
        
        self.isSelectBtnView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0,0.0, 70.0, 44.0)];
        self.isSelectBtnView .userInteractionEnabled = YES;
        self.isSelectBtnView.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:self.isSelectBtnView];
        
        self.isSelectBtn =[[UIButton alloc] initWithFrame:CGRectMake(-5.0,0.0,44.0,44.0)];
        self.isSelectBtn.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:self.isSelectBtn];
    }
    return self;
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
