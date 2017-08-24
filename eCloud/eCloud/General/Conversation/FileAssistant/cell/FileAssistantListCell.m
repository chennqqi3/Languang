//
//  FileAssistantListCell.m
//  eCloud
//
//  Created by 风影 on 15/1/11.
//  Copyright (c) 2015年  lyong. All rights reserved.
//


#import "FileAssistantListCell.h"
#import "ConvRecord.h"
#import "StringUtil.h"
#import "UIAdapterUtil.h"
#import "UserInterfaceUtil.h"
@implementation FileAssistantListCell
{
    UILabel *_nameLabel;
    CGRect _iconRect;
    CGRect _nameLabelRect;
    CGRect _sizeRect;
    CGRect _validityLabelRect;
    CGRect _timeRect;
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [UIAdapterUtil customSelectBackgroundOfCell:self];

        UIView *parentView = [[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height)]autorelease];
        parentView.tag = file_parent_view_tag;
        //        parentView.backgroundColor = [UIColor redColor];
        [self.contentView addSubview:parentView];

        //复选框
        CGRect frame = CGRectMake(0.0,9.0,30.0,30.0);
        
        //文件类型
        frame.origin.x += 9.0;
        _iconRect = CGRectMake(12, 12, 45, 45);
        UIImageView *iconView = [[UIImageView alloc] initWithFrame:_iconRect];
        iconView.image = [StringUtil getImageByResName:@"ic_chat_file.png"];
        iconView.backgroundColor = [UIColor clearColor];
        iconView.tag = file_icon_tag;
        [parentView addSubview:iconView];
        [iconView release];
        
        //文件名 0810适配
        CGFloat screenW = [UIAdapterUtil getDeviceMainScreenWidth];
        frame.origin.x += 55.0;
        CGFloat nameLabelW = screenW - CGRectGetMaxX(iconView.frame) - 30 - 48 ; // 48 按钮宽度
//        NSLog(@"screenW===%g",screenW);
//        NSLog(@"nameLabelW===%g",nameLabelW);
        _nameLabelRect = CGRectMake(67, 15, nameLabelW, 21);
        _nameLabel = [[UILabel alloc]initWithFrame:_nameLabelRect];
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.tag = file_name_tag;
        _nameLabel.textColor = UIColorFromRGB(0x000000);;
        _nameLabel.font=[UIFont systemFontOfSize:17];
        [_nameLabel.text sizeWithFont:_nameLabel.font];
        _nameLabel.textAlignment = UITextAlignmentLeft;
        [parentView addSubview:_nameLabel];
        [_nameLabel release];
        
        //文件大小
        frame.origin.y += 20.0;
        _sizeRect = CGRectMake(67, 42, 55, 14);
        UILabel *sizeLabel = [[UILabel alloc]initWithFrame:_sizeRect];
        sizeLabel.backgroundColor = [UIColor clearColor];
        sizeLabel.tag = file_size_tag;
        sizeLabel.textColor = UIColorFromRGB(0xA3A3A3);
        sizeLabel.font=[UIFont systemFontOfSize:13];
        sizeLabel.textAlignment = UITextAlignmentLeft;
        [parentView addSubview:sizeLabel];
        [sizeLabel release];
        
        //文件是否有效提示
        frame.origin.x += 90.0;
        _validityLabelRect = CGRectMake(174, 42, 100, 14);
        UILabel *validityLabel = [[UILabel alloc]initWithFrame:_validityLabelRect];
        validityLabel.backgroundColor = [UIColor clearColor];
        validityLabel.tag = file_validity_tag;
        validityLabel.textColor=UIColorFromRGB(0xA3A3A3);;
        validityLabel.font=[UIFont systemFontOfSize:10.0];
        validityLabel.textAlignment = UITextAlignmentLeft;
        [parentView addSubview:validityLabel];
        [validityLabel release];
        
        //文件时间
        frame.origin.x -= 90.0;
        frame.origin.y += 16.0;
        CGFloat width = [UIScreen mainScreen].bounds.size.width/2 - 38;
        _timeRect = CGRectMake([UIScreen mainScreen].bounds.size.width/2 - 50, 42, width, 14);
        UILabel *timeLabel = [[UILabel alloc]initWithFrame:_timeRect];
        timeLabel.backgroundColor = [UIColor clearColor];
        timeLabel.tag = file_time_tag;
        timeLabel.textColor=UIColorFromRGB(0xA3A3A3);;
        timeLabel.font=[UIFont systemFontOfSize:13];
        timeLabel.contentMode = UIViewContentModeTop;
        timeLabel.textAlignment = NSTextAlignmentRight;
        timeLabel.numberOfLines = 2;
        [parentView addSubview:timeLabel];
        [timeLabel release];
     
        //进度显示
        //UIProgressView *_progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(frame.origin.x, frame.origin.y+8.0, 186.0, 30.0)];
        UIProgressView *_progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(frame.origin.x, 55, 186.0, 30.0)];
        _progressView.progressViewStyle = UIProgressViewStyleDefault;
        _progressView.progress = 0.0;
        _progressView.tag = file_list_progressview_tag;
        _progressView.progressTintColor = [UIColor colorWithRed:26.0/255 green:199.0/255 blue:6.0/255 alpha:1.0];
        _progressView.trackTintColor = [UIColor colorWithRed:193.0/255 green:193.0/255 blue:193.0/255 alpha:1.0];
        [self.contentView  addSubview:_progressView];
        [_progressView release];
        
        //文件来源
        frame.origin.x += 90.0;
        UILabel *sourceLabel = [[UILabel alloc]initWithFrame:CGRectMake(frame.origin.x,frame.origin.y, 100.0, 20.0)];
        sourceLabel.backgroundColor = [UIColor clearColor];
        sourceLabel.tag = file_source_tag;
        sourceLabel.textColor=[UIColor grayColor];
        sourceLabel.font=[UIFont systemFontOfSize:10.0];
        sourceLabel.contentMode = UIViewContentModeTop;
        sourceLabel.textAlignment = UITextAlignmentLeft;
        sourceLabel.numberOfLines = 2;
        //[parentView addSubview:sourceLabel];
        [sourceLabel release];
        
        //下载按钮
        UIButton *downloadBtn =[[UIButton alloc] initWithFrame:CGRectMake(screenW-76,20.5,64,28.0)];
        downloadBtn.backgroundColor = [UIColor clearColor];
        downloadBtn.tag = file_download_button_tag;
        [downloadBtn setBackgroundImage:[StringUtil getImageByResName:@"file_download_btn.png"] forState:UIControlStateNormal];
        [downloadBtn setTitleColor:FILE_ASSISTANT_DOWNLOAD_BTN_TEXT_COLOR forState:UIControlStateNormal];
        downloadBtn.titleLabel.font =[UIFont boldSystemFontOfSize:12.0];
        downloadBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
        [downloadBtn.titleLabel setTextAlignment:NSTextAlignmentCenter];
        downloadBtn.titleLabel.minimumFontSize = 9.0;
        [parentView addSubview:downloadBtn];
        [downloadBtn release];
        
        UILabel *downloadBtnLab = [[UILabel alloc]initWithFrame:CGRectMake(0.0,0.0, 40.0, 20.0)];
        downloadBtnLab.backgroundColor = [UIColor clearColor];
        downloadBtnLab.hidden = YES;
        downloadBtnLab.tag = file_download_button_lab_tag;
        [downloadBtn addSubview:downloadBtnLab];
        [downloadBtnLab release];
        
        //选择按钮
        UIButton *isSelectBtn = [[UIButton alloc] initWithFrame:CGRectMake(12,22,25,25)];
        isSelectBtn.backgroundColor = [UIColor clearColor];
        isSelectBtn.tag = file_edit_button_tag;
        [parentView addSubview:isSelectBtn];
        [isSelectBtn release];
    }
    return self;
}

- (void)configureCell:(UITableViewCell *)cell andConvRecord:(ConvRecord*)_convRecord{
    
    NSString *_fileName = [NSString stringWithFormat:@"%@",_convRecord.file_name];

    UILabel *fileNameLab = (UILabel *)[cell.contentView viewWithTag:file_name_tag];
    fileNameLab.text = _fileName;
//    NSLog(@"fileNameLab------%@",NSStringFromCGRect(fileNameLab.frame));
    
    UILabel *fileSizeLab = (UILabel *)[cell.contentView viewWithTag:file_size_tag];
    NSInteger fileSize = [_convRecord.file_size intValue];
    NSString *fileSizeStr = [StringUtil getDisplayFileSize:fileSize];
    fileSizeLab.text = fileSizeStr;
    
    UILabel *fileTimeLab = (UILabel *)[cell.contentView viewWithTag:file_time_tag];
    fileTimeLab.text =  _convRecord.msgTimeDisplay;
//    fileTimeLab.text =  @"2017-08-04 11:32";
    
    UIButton * isSelectBtn = (UIButton *)[cell.contentView viewWithTag:file_edit_button_tag];
    if (_convRecord.isChosen) {
       [isSelectBtn setImage:[StringUtil getImageByResName:@"photo_Selection_ok.png"] forState:UIControlStateNormal];
    }
    else{
        [isSelectBtn setImage:[StringUtil getImageByResName:@"Selection_01.png"] forState:UIControlStateNormal];
    }
}

- (void)configureCell:(UITableViewCell *)cell editState:(BOOL)editing{
    UIImageView *fileIconView = (UIImageView *)[cell.contentView viewWithTag:file_icon_tag];
    UILabel *nameLabel = (UILabel *)[cell.contentView viewWithTag:file_name_tag];
//    NSLog(@"nameLabel2222------%@",NSStringFromCGRect(nameLabel.frame));
    UILabel *sizeLabel = (UILabel *)[cell.contentView viewWithTag:file_size_tag];
    UILabel *validityLabel = (UILabel *)[cell.contentView viewWithTag:file_validity_tag];
    UILabel *timeLabel = (UILabel *)[cell.contentView viewWithTag:file_time_tag];
    UIProgressView *_progressView = (UIProgressView *)[cell.contentView viewWithTag:file_list_progressview_tag];
    UILabel *sourceLabel = (UILabel *)[cell.contentView viewWithTag:file_source_tag];
    UIButton * downloadBtn = (UIButton *)[cell.contentView viewWithTag:file_download_button_tag];
    UIButton * isSelectBtn = (UIButton *)[cell.contentView viewWithTag:file_edit_button_tag];
    if (editing) {
        CGRect frame = CGRectMake(60.0,9.0,30.0,30.0);
        
        frame.origin.x += 9.0;
        [fileIconView setFrame:CGRectMake(44,12, 45.0, 45.0)];
        
        frame.origin.x += 55.0;
        
        
        [nameLabel setFrame:CGRectMake(99,12, 264, 21)];
        
        frame.origin.y += 20.0;
        [sizeLabel setFrame:CGRectMake(99,42, 55, 14)];
        
        
        frame.origin.x += 60.0;
        [validityLabel setFrame:CGRectMake(204,42, 80.0, 14)];
        
        frame.origin.x -= 60.0;
        frame.origin.y += 16.0;
        CGFloat width = [UIScreen mainScreen].bounds.size.width/2 + 38;
        [timeLabel setFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2 - 50,42, width, 14)];
        
        [_progressView setFrame:CGRectMake(frame.origin.x, 55, 186.0, 30.0)];
        
        frame.origin.x += 90.0;
        [sourceLabel setFrame:CGRectMake(frame.origin.x,frame.origin.y, 100.0, 20.0)];
        
        
        downloadBtn.hidden = YES;
        isSelectBtn.hidden = NO;
    }
    else {
        CGRect frame = CGRectMake(0.0,9.0,30.0,30.0);
        
        frame.origin.x += 9.0;
        [fileIconView setFrame:_iconRect];
        
        frame.origin.x += 55.0;
        [nameLabel setFrame:_nameLabelRect];
        
        frame.origin.y += 20.0;
        [sizeLabel setFrame:_sizeRect];
        
        frame.origin.x += 90.0;
        [validityLabel setFrame:_validityLabelRect];
        
        frame.origin.x -= 90.0;
        frame.origin.y += 16.0;
        [timeLabel setFrame:_timeRect];
        
        [_progressView setFrame:CGRectMake(frame.origin.x, 55, 186.0, 30.0)];
        
        frame.origin.x += 90.0;
        [sourceLabel setFrame:CGRectMake(frame.origin.x,frame.origin.y, 100.0, 20.0)];
        
        downloadBtn.hidden = NO;
        isSelectBtn.hidden = YES;
    }
}

// 0810-0813
-(void)layoutSubviews{
    [super layoutSubviews];

    CGRect _frame = self.contentView.frame;
    _frame.origin = CGPointZero;
    
    if ([UIAdapterUtil isGOMEApp]) {
        _frame.origin = CGPointMake(0, 5);
        _frame.size = CGSizeMake(_frame.size.width, _frame.size.height - 10);
    }
    
    UIView *fileParentView = [self.contentView viewWithTag:file_parent_view_tag];
    fileParentView.frame = _frame;
    
    CGFloat nameLabW = self.frame.size.width - 64 - 48 - 40;
    [_nameLabel setFrame:CGRectMake(_nameLabel.frame.origin.x, -15, nameLabW, self.frame.size.height)];
    CGFloat sourceLabelW = self.frame.size.width - 9 - 46 - 9 - 48 - 9 - 90 - 20;//20为向左调整
    UILabel *sourceLabel = (UILabel *)[self.contentView viewWithTag:file_source_tag];
    sourceLabel.textAlignment = NSTextAlignmentRight;
    
    // 9 为左边间距, 46 为icon宽度, 90为timeLabel宽度, 5为向右调整
    CGFloat sourceLabelX = 9 + 46 + 9 + 90 + 5;
    CGFloat screenW = [UIAdapterUtil getDeviceMainScreenWidth];
    // 判断是否为编辑状态 55/414.0 相对6p的移动
    if (sourceLabel.frame.origin.x > sourceLabelX ) {
        [sourceLabel setFrame:CGRectMake(sourceLabelX + 55/414.0*screenW, 22, sourceLabelW, self.frame.size.height)];
    }else{
        [sourceLabel setFrame:CGRectMake(sourceLabelX , 22, sourceLabelW, self.frame.size.height)];
    }
}

@end
