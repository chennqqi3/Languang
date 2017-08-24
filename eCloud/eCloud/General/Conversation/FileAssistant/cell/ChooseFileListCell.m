//
//  FileListCell.m
//  eCloud
//
//  Created by 风影 on 15/1/30.
//  Copyright (c) 2015年  lyong. All rights reserved.
//

#import "ChooseFileListCell.h"
#import "FileAssistantListCell.h"
#import "ConvRecord.h"
#import "StringUtil.h"
#import "UIAdapterUtil.h"
#import "IOSSystemDefine.h"

@implementation ChooseFileListCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIView *parentView = [[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height)]autorelease];
        parentView.tag = file_parent_view_tag;
//        parentView.backgroundColor = [UIColor redColor];
        [self.contentView addSubview:parentView];
        //复选框
        CGRect frame = CGRectMake(0.0,9.0,30.0,30.0);
        
        //文件类型
        frame.origin.x += 9.0;
        UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(frame.origin.x,frame.origin.y, 46.0, 46.0)];
        iconView.backgroundColor = [UIColor clearColor];
        iconView.tag = file_icon_tag;
        iconView.userInteractionEnabled = YES;
        [parentView addSubview:iconView];
        [iconView release];
        
        CGFloat screenW = [UIAdapterUtil getDeviceMainScreenWidth];

        //文件名
        frame.origin.x += 55.0;
        
        UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(frame.origin.x,frame.origin.y, 190.0, 20.0)];
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.tag = file_name_tag;
        nameLabel.textColor=[UIColor blackColor];
        nameLabel.font=[UIFont systemFontOfSize:17.0];
        nameLabel.textAlignment = UITextAlignmentLeft;
        [parentView addSubview:nameLabel];
        [nameLabel release];
        
        //文件大小
        frame.origin.y += 20.0;
        UILabel *sizeLabel = [[UILabel alloc]initWithFrame:CGRectMake(frame.origin.x,frame.origin.y, 80.0, 16.0)];
        sizeLabel.backgroundColor = [UIColor clearColor];
        sizeLabel.tag = file_size_tag;
        sizeLabel.textColor=[UIColor grayColor];
        sizeLabel.font=[UIFont systemFontOfSize:13.0];
        sizeLabel.textAlignment = UITextAlignmentLeft;
        [parentView addSubview:sizeLabel];
        [sizeLabel release];
        
        //文件是否有效提示
        frame.origin.x += 90.0;
        UILabel *validityLabel = [[UILabel alloc]initWithFrame:CGRectMake(frame.origin.x,frame.origin.y, 100.0, 16.0)];
        validityLabel.backgroundColor = [UIColor clearColor];
        validityLabel.tag = file_validity_tag;
        validityLabel.textColor=[UIColor grayColor];
        validityLabel.font=[UIFont systemFontOfSize:10.0];
        validityLabel.textAlignment = UITextAlignmentLeft;
        [parentView addSubview:validityLabel];
        [validityLabel release];
        
        //文件时间
        frame.origin.x -= 90.0;
        frame.origin.y += 16.0;
        UILabel *timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(frame.origin.x,frame.origin.y, 100.0, 20.0)];
        timeLabel.backgroundColor = [UIColor clearColor];
        timeLabel.tag = file_time_tag;
        timeLabel.textColor=[UIColor grayColor];
        timeLabel.font=[UIFont systemFontOfSize:13.0];
        timeLabel.contentMode = UIViewContentModeTop;
        timeLabel.textAlignment = UITextAlignmentRight;
        timeLabel.numberOfLines = 0;
        [parentView addSubview:timeLabel];
        [timeLabel release];
        
        //进度显示
//        UIProgressView *_progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(frame.origin.x, frame.origin.y+8.0, 186.0, 30.0)];
//        _progressView.progressViewStyle = UIProgressViewStyleDefault;
//        _progressView.progress = 0.0;
//        _progressView.tag = file_list_progressview_tag;
//        _progressView.progressTintColor = [UIColor colorWithRed:26.0/255 green:199.0/255 blue:6.0/255 alpha:1.0];
//        _progressView.trackTintColor = [UIColor colorWithRed:193.0/255 green:193.0/255 blue:193.0/255 alpha:1.0];
//        [self.contentView  addSubview:_progressView];
//        [_progressView release];
        
        //文件来源
//        frame.origin.x += 90.0;
//        UILabel *sourceLabel = [[UILabel alloc]initWithFrame:CGRectMake(frame.origin.x,frame.origin.y, 100.0, 20.0)];
//        sourceLabel.backgroundColor = [UIColor clearColor];
//        sourceLabel.tag = file_source_tag;
//        sourceLabel.textColor=[UIColor grayColor];
//        sourceLabel.font=[UIFont systemFontOfSize:10.0];
//        sourceLabel.contentMode = UIViewContentModeTop;
//        sourceLabel.textAlignment = UITextAlignmentLeft;
//        sourceLabel.numberOfLines = 2;
//        [parentView addSubview:sourceLabel];
//        [sourceLabel release];
        
        //显示下载或者浏览
//        UIImageView *downloadFlag =[[UIImageView alloc] initWithFrame:CGRectMake(iconView.frame.origin.x+30.0,iconView.frame.origin.y+30.0,16.0,16.0)];
//        downloadFlag.backgroundColor = [UIColor clearColor];
//        downloadFlag.tag = file_download_flag_tag;
//        [parentView addSubview:downloadFlag];
//        [downloadFlag release];
        
        //下载按钮
//        UIButton *downloadBtn =[[UIButton alloc] initWithFrame:iconView.frame];
//        downloadBtn.backgroundColor = [UIColor clearColor];
//        downloadBtn.tag = file_download_button_tag;
//        [parentView addSubview:downloadBtn];
//        [downloadBtn release];
//        
//        UILabel *downloadBtnLab = [[UILabel alloc]initWithFrame:CGRectMake(0.0,0.0, 40.0, 20.0)];
//        downloadBtnLab.backgroundColor = [UIColor clearColor];
//        downloadBtnLab.hidden = YES;
//        downloadBtnLab.tag = file_download_button_lab_tag;
//        [downloadBtn addSubview:downloadBtnLab];
//        [downloadBtnLab release];
        
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
    
    UIImageView *fileIconView = (UIImageView *)[cell.contentView viewWithTag:file_icon_tag];
    fileIconView.image = [StringUtil getImageByResName:@"ic_chat_file"];
    
    UILabel *fileNameLab = (UILabel *)[cell.contentView viewWithTag:file_name_tag];
    fileNameLab.text = _fileName;
    
    UILabel *fileSizeLab = (UILabel *)[cell.contentView viewWithTag:file_size_tag];
    NSInteger fileSize = [_convRecord.file_size intValue];
    NSString *fileSizeStr = [StringUtil getDisplayFileSize:fileSize];
    fileSizeLab.text = fileSizeStr;
    
    UILabel *fileTimeLab = (UILabel *)[cell.contentView viewWithTag:file_time_tag];
    fileTimeLab.text =  _convRecord.msgTimeDisplay;
    
    UIButton * isSelectBtn = (UIButton *)[cell.contentView viewWithTag:file_edit_button_tag];
    if (_convRecord.isChosen) {
        [isSelectBtn setImage:[StringUtil getImageByResName:@"photo_Selection_ok.png"] forState:UIControlStateNormal];
    }
    else{
        [isSelectBtn setImage:[StringUtil getImageByResName:@"Selection_01"] forState:UIControlStateNormal];
    }
}

- (void)configureCell:(UITableViewCell *)cell editState:(BOOL)editing{
    UIImageView *fileIconView = (UIImageView *)[cell.contentView viewWithTag:file_icon_tag];
    UILabel *nameLabel = (UILabel *)[cell.contentView viewWithTag:file_name_tag];
    UILabel *sizeLabel = (UILabel *)[cell.contentView viewWithTag:file_size_tag];
    UILabel *validityLabel = (UILabel *)[cell.contentView viewWithTag:file_validity_tag];
    UILabel *timeLabel = (UILabel *)[cell.contentView viewWithTag:file_time_tag];
    UIProgressView *_progressView = (UIProgressView *)[cell.contentView viewWithTag:file_list_progressview_tag];
    UILabel *sourceLabel = (UILabel *)[cell.contentView viewWithTag:file_source_tag];
    UIImageView * downloadFlag = (UIImageView *)[cell.contentView viewWithTag:file_download_flag_tag];
    UIImageView * downloadBtn = (UIImageView *)[cell.contentView viewWithTag:file_download_button_tag];
    UIButton * isSelectBtn = (UIButton *)[cell.contentView viewWithTag:file_edit_button_tag];
    if (editing) {
        CGRect frame = CGRectMake(44,12,30.0,30.0);
        
        frame.origin.x += 9.0;
        [fileIconView setFrame:CGRectMake(frame.origin.x,frame.origin.y, 45, 45)];
        
        frame.origin.x += 57;
        [nameLabel setFrame:CGRectMake(frame.origin.x,frame.origin.y, SCREEN_WIDTH - 12, 21)];
        
        frame.origin.y += 30.0;

        [sizeLabel setFrame:CGRectMake(frame.origin.x,frame.origin.y, 60.0, 16.0)];
        
        
//        frame.origin.x += 60.0;
//        [validityLabel setFrame:CGRectMake(frame.origin.x,frame.origin.y, 80.0, 16.0)];
        
//        frame.origin.x -= 60.0;
//        frame.origin.y += 16.0;
        [timeLabel setFrame:CGRectMake(SCREEN_WIDTH-200-12,frame.origin.y, 200, 21)];
        
        [_progressView setFrame:CGRectMake(frame.origin.x, frame.origin.y+8.0, 186.0, 30.0)];
        
//        frame.origin.x += 90.0;
//        [sourceLabel setFrame:CGRectMake(frame.origin.x,frame.origin.y, 100.0, 20.0)];
//        
//        
//        [downloadFlag setFrame:CGRectMake(fileIconView.frame.origin.x+30.0,fileIconView.frame.origin.y+30.0,18.0,18.0)];
//        [downloadBtn setFrame:fileIconView.frame];
//        
//        downloadFlag.hidden = NO;
//        downloadBtn.hidden = NO;
        isSelectBtn.hidden = NO;
    }
    else {
        CGRect frame = CGRectMake(0.0,9.0,30.0,30.0);
        
        frame.origin.x += 9.0;
        [fileIconView setFrame:CGRectMake(frame.origin.x,frame.origin.y, 46.0, 46.0)];
        
        frame.origin.x += 55.0;
        [nameLabel setFrame:CGRectMake(frame.origin.x,frame.origin.y, 190.0, 20.0)];
        
        frame.origin.y += 20.0;
        [sizeLabel setFrame:CGRectMake(frame.origin.x,frame.origin.y, 80.0, 16.0)];
        
        frame.origin.x += 90.0;
        [validityLabel setFrame:CGRectMake(frame.origin.x,frame.origin.y, 100.0, 16.0)];
        
        frame.origin.x -= 90.0;
        frame.origin.y += 16.0;
        [timeLabel setFrame:CGRectMake(frame.origin.x,frame.origin.y, 90.0, 20.0)];
        
        [_progressView setFrame:CGRectMake(frame.origin.x, frame.origin.y+8.0, 186.0, 30.0)];
        
        frame.origin.x += 90.0;
        [sourceLabel setFrame:CGRectMake(frame.origin.x,frame.origin.y, 100.0, 20.0)];
        [downloadBtn setFrame:fileIconView.frame];
        
        downloadFlag.hidden = NO;
        downloadBtn.hidden = NO;
        isSelectBtn.hidden = YES;
    }
}

- (void)layoutSubviews{
    
    [super layoutSubviews];
    
    NSLog(@"contentView frame is %@",NSStringFromCGRect(self.contentView.frame));
    
    CGRect _frame = self.contentView.frame;
    _frame.origin = CGPointZero;
    
    if ([UIAdapterUtil isGOMEApp]) {
        _frame.origin = CGPointMake(0, 5);
        _frame.size = CGSizeMake(_frame.size.width, _frame.size.height - 10);
    }
    
//    UIView *fileParentView = [self.contentView viewWithTag:file_parent_view_tag];
//    fileParentView.frame = _frame;
//    
//    CGFloat nameLabelX = 55.0 + 9.0 + 46.0 + 15.0; // 复选按钮,间距,文件图标,间距
//    CGRect frame = CGRectMake(nameLabelX,9.0,30.0,30.0);
//    UILabel *nameLabel = (UILabel *)[self.contentView viewWithTag:file_name_tag];
//    [nameLabel setFrame:CGRectMake(frame.origin.x,frame.origin.y, self.frame.size.width-nameLabelX-10-5, 20.0)];// -5是觉得太靠右
//    
//    CGFloat sourceLabelX = 55.0 + 9.0 + 46.0 + 15.0 + 90.0; // + 时间label
//    CGRect sFrame = CGRectMake(sourceLabelX,9.0 + 20.0 + 16.0,30.0,30.0);
//    UILabel *sourceLabel = (UILabel *)[self.contentView viewWithTag:file_source_tag];
//    sourceLabel.textAlignment = NSTextAlignmentRight;
//    [sourceLabel setFrame:CGRectMake(sFrame.origin.x,sFrame.origin.y, self.frame.size.width-sourceLabelX-10-15, 20.0)];// -15 是觉得太靠右
    
}

@end
