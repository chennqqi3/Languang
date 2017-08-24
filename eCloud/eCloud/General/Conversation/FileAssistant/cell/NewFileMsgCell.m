
//  NewFileMsgCell.m
//  eCloud
//
//  Created by Pain on 14-11-24.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import "NewFileMsgCell.h"
#import "NormalTextMsgCell.h"

@implementation NewFileMsgCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [super addCommonView:self];
        UIView *contentView = (UIView *)[self.contentView viewWithTag:body_tag];
        
        //文件类型消息背景
        UIView *fileView = [[UIView alloc]initWithFrame:CGRectZero];
        fileView.tag = file_tag;
        fileView.layer.cornerRadius = 4.0;
        fileView.backgroundColor =  [UIColor whiteColor];
        [contentView addSubview:fileView];
        [fileView release];
        
//        在fileView里添加一个子view，把本来添加到fileview的view都加到这个子view里
        UIView *fileSubView = [[[UIView alloc]initWithFrame:CGRectZero]autorelease];
        fileSubView.tag = file_sub_view_tag;
        fileSubView.userInteractionEnabled = NO;
        [fileView addSubview:fileSubView];
        
        //文件对应的图片
        UIImageView *filePicView = [[UIImageView alloc]initWithFrame:CGRectZero];
        filePicView.contentMode=UIViewContentModeScaleAspectFit;
        filePicView.tag = file_pic_tag;
        [fileSubView addSubview:filePicView];
        [filePicView release];

        //文件名称
        UILabel *fileNameLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        fileNameLabel.lineBreakMode = UILineBreakModeTailTruncation;
        fileNameLabel.numberOfLines = 0;
        fileNameLabel.font = [UIFont systemFontOfSize:FILE_MSG_FILENAME_FONTSIZE];
        fileNameLabel.textColor = [StringUtil colorWithHexString:FILE_MSG_FILENAME_FONTCOLOR];
        if ([UIAdapterUtil isGOMEApp]) {
            fileNameLabel.textColor = [UIColor colorWithRed:0x33/255 green:0x33/255 blue:0x33/255 alpha:1.0];
        }
        fileNameLabel.textAlignment = UITextAlignmentLeft;
        fileNameLabel.backgroundColor = [UIColor clearColor];
        fileNameLabel.tag = file_name_tag;
        [fileSubView addSubview:fileNameLabel];
        [fileNameLabel release];
        
        //文件大小
        UILabel *fileSizeLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        fileSizeLabel.lineBreakMode = UILineBreakModeMiddleTruncation;
        fileSizeLabel.font = [UIFont systemFontOfSize:FILE_MSG_FILESIZE_FONTSIZE];
        fileSizeLabel.textColor = [StringUtil colorWithHexString:FILE_MSG_FILESIZE_FONTCOLOR];
        fileSizeLabel.textAlignment = UITextAlignmentLeft;
        fileSizeLabel.tag = file_size_tag;
        [fileSubView addSubview:fileSizeLabel];
        [fileSizeLabel release];
        
        //文件下载状态
        UILabel *fileStateLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        fileStateLabel.lineBreakMode = UILineBreakModeMiddleTruncation;
        fileStateLabel.font = [UIFont systemFontOfSize:FILE_MSG_FILESIZE_FONTSIZE];
        fileStateLabel.textColor = [StringUtil colorWithHexString:FILE_MSG_FILESTATUS_FONTCOLOR];
        fileStateLabel.textAlignment = NSTextAlignmentRight;
        fileStateLabel.tag = file_download_state_tag;
        [fileSubView addSubview:fileStateLabel];
        [fileStateLabel release];
        
        //进度显示
        UIProgressView *_progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        _progressView.progress = 0.0;
        _progressView.tag = file_progressview_tag;
        _progressView.progressTintColor = [UIColor colorWithRed:26.0/255 green:199.0/255 blue:6.0/255 alpha:1.0];
        _progressView.trackTintColor = [UIColor colorWithRed:193.0/255 green:193.0/255 blue:193.0/255 alpha:1.0];
        [fileSubView addSubview:_progressView];
        [_progressView release];
        
        //取消按钮
//        UIImageView *downloadCancelBtn = [[UIImageView alloc] initWithFrame:CGRectZero];
//        downloadCancelBtn.userInteractionEnabled = YES;
//        downloadCancelBtn.tag = file_download_cancel_tag;
//        [downloadCancelBtn setImage:[StringUtil getImageByResName:@"file_stop.png"]];
//        [self.contentView addSubview:downloadCancelBtn];
//        [downloadCancelBtn release];
    }
    
    return self;
}

+ (void)configureCell:(UITableViewCell *)cell andRecord:(ConvRecord*)_convRecord
{
    float contentWidth = _convRecord.msgSize.width;
    float contentHeight = _convRecord.msgSize.height;

    UIView *fileView = (UIView*)[cell.contentView viewWithTag:file_tag];
    fileView.frame = CGRectMake(0.0,0.0, contentWidth, contentHeight);
    fileView.hidden = NO;

    UIView *fileSubView = (UIView*)[cell.contentView viewWithTag:file_sub_view_tag];
    fileSubView.frame = CGRectMake(0.0,0.0, contentWidth, contentHeight);
    fileSubView.hidden = NO;

    UIImageView *filePicView = (UIImageView*)[cell.contentView viewWithTag:file_pic_tag];
    //    filePicView.image = _convRecord.imageDisplay;
    filePicView.image = [StringUtil getImageByResName:@"chat_files_default@2x.png"];
    filePicView.frame = CGRectMake(FILE_MSG_IMAGE_SPACE, FILE_MSG_IMAGE_SPACE, FILE_MSG_IMAGE_MAX_WIDTH, FILE_MSG_IMAGE_MAX_HEIGHT);
    filePicView.hidden = NO;

    //文件名字
    UILabel *fileNameLabel = (UILabel*)[cell.contentView viewWithTag:file_name_tag];
    fileNameLabel.text = _convRecord.file_name;
    CGSize fileNameSize = [fileNameLabel.text sizeWithFont:[UIFont systemFontOfSize:FILE_MSG_FILENAME_FONTSIZE]];
    fileNameLabel.frame = CGRectMake(CGRectGetMaxX(filePicView.frame)+FILE_MSG_FILENAME_SPACE,FILE_MSG_FILENAME_SPACE, FILE_MSG_FILENAME_MAX_WIDTH, fileNameSize.height);
    fileNameLabel.hidden = NO;

    //文件大小
    UILabel *fileSizeLabel = (UILabel*)[cell.contentView viewWithTag:file_size_tag];
    NSInteger fileSize = [[NSString stringWithFormat:@"%@",_convRecord.file_size] intValue];
    NSString *fileSizeStr = [StringUtil getDisplayFileSize:fileSize];

    fileSizeLabel.text = fileSizeStr;
    CGSize fileSizeSize = [fileSizeStr sizeWithFont:[UIFont systemFontOfSize:FILE_MSG_FILESIZE_FONTSIZE]];
    fileSizeLabel.frame = CGRectMake(CGRectGetMaxX(filePicView.frame)+FILE_MSG_FILESIZE_SPACE,FILE_MSG_FILESIZE_SPACE_TOP, fileSizeSize.width, fileSizeSize.height);
    fileSizeLabel.hidden = NO;

    //文件状态  文件不存在
    CGSize fileStatusSize = [@"文件不存在" sizeWithFont:[UIFont systemFontOfSize:FILE_MSG_FILESIZE_FONTSIZE]];
    CGFloat fileStatusX = FILE_MSG_WIDTH - FILE_MSG_FILESTATUS_SPACE - fileStatusSize.width;
    
    UILabel *fileDownloadSateLabel = (UILabel*)[cell.contentView viewWithTag:file_download_state_tag];
    fileDownloadSateLabel.frame = CGRectMake(fileStatusX, FILE_MSG_FILESTATUS_SPACE_TOP, fileStatusSize.width, fileStatusSize.height);
    fileDownloadSateLabel.hidden = NO;

    //下载进度
    CGFloat progressWidth = FILE_MSG_WIDTH - (2 * FILE_MSG_PROGRESS_SPACE);
    CGFloat progressY     = CGRectGetMaxY(filePicView.frame) + 4;
    UIProgressView *_progressView = (UIProgressView*)[cell.contentView viewWithTag:file_progressview_tag];
    _progressView.frame = CGRectMake(FILE_MSG_PROGRESS_SPACE, progressY, progressWidth, 20.0);

    // 设置消息体的位置
    [self configureCommonView:cell andRecord:_convRecord];
}

//调整共用的view的布局
+ (void)configureCommonView:(UITableViewCell *)cell andRecord:(ConvRecord *)_convRecord
{
    UIView *contentView = (UIView *)[cell.contentView viewWithTag:body_tag];
    contentView.hidden = NO;
    
    float contentWidth = _convRecord.msgSize.width;
    float contentHeight = _convRecord.msgSize.height;
    
    UIImageView *headImageView = (UIImageView *)[cell.contentView viewWithTag:head_tag];
    
    //    收到的消息
    float contentX = 0;
    float contentY = 0;
    
    //    发送出去的消息
    if (_convRecord.msg_flag == send_msg) {
        contentX = headImageView.frame.origin.x - logo_horizontal_space - contentWidth;
        contentY = headImageView.frame.origin.y + send_msg_body_to_header_top;
    }else{
        contentX = headImageView.frame.origin.x + headImageView.frame.size.width + logo_horizontal_space;
        contentY = headImageView.frame.origin.y + rcv_msg_body_to_header_top;
    }
    
    contentView.frame = CGRectMake(contentX, contentY, contentWidth, contentHeight);
    
//    [[super class] setbubbleImageViewFrameByCell:cell andRecord:_convRecord];
    
    [ParentMsgCell configureStatusView:cell andRecord:_convRecord];
}

//返回高度
+ (float)getMsgHeight:(ConvRecord *)_convRecord
{
    //	时间所占高度 已经增加了时间与消息直接的分隔
    float dateBgHeight = [talkSessionUtil getTimeHeight:_convRecord];
    
    CGSize _size = CGSizeMake(FILE_MSG_WIDTH, FILE_MSG_HEIGHT);
    _convRecord.msgSize = _size;
    
    //   头像和内容一起的高度
    float tempH;
    
    if (_convRecord.msg_flag == send_msg) {
        // 头像与消息体顶端对齐
        tempH = _convRecord.msgSize.height + send_msg_body_to_header_top;
    }else{
        // 多了一个头像的差值
        tempH =_convRecord.msgSize.height + rcv_msg_body_to_header_top;
    }
    
    return dateBgHeight + tempH;
}


/** 激活文件类型消息 */
+ (void)activeCell:(UITableViewCell *)cell andConvRecord:(ConvRecord *)_convRecord{
    UIView *fileView = [cell.contentView viewWithTag:file_tag];
    fileView.tag = file_tag;
    fileView.backgroundColor = rcv_msg_active_bg_color;
}
/** 文件消息回复正常状态 */
+ (void)deactiveCell:(UITableViewCell *)cell andConvRecord:(ConvRecord *)_convRecord{
    UIView *fileView = [cell.contentView viewWithTag:file_tag];
    fileView.tag = file_tag;
    fileView.backgroundColor = [UIColor whiteColor];
}

@end
