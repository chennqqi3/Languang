//
//  FileAssistantUtil.m
//  eCloud
//
//  Created by 风影 on 15/1/12.
//  Copyright (c) 2015年  lyong. All rights reserved.
//

#import "FileAssistantUtil.h"
#import "ASIHTTPRequest.h"
#import "ConvRecord.h"
#import "FileAssistantListCell.h"
#import "ChooseFileListCell.h"
#import "eCloudDefine.h"
#import "DownloadFileModel.h"
#import "StringUtil.h"
#import "FileAlertView.h"

@implementation FileAssistantUtil

#pragma mark - 设置下载提示
+(void)configureFileResumeDownOrUpLoadSateLabelCell:(UITableViewCell *)cell convRecord:(ConvRecord*)_convRecord editState:(BOOL)editing{
    UILabel *fileTimeLab = (UILabel *)[cell.contentView viewWithTag:file_time_tag];
    UILabel *sourceLabel = (UILabel *)[cell.contentView viewWithTag:file_source_tag];
    UILabel *validityLabel = (UILabel *)[cell.contentView viewWithTag:file_validity_tag];
    validityLabel.hidden = YES;
    
    UIProgressView *_progressView = (UIProgressView *)[cell.contentView viewWithTag:file_list_progressview_tag];
    UIButton * downloadBtn = (UIButton *)[cell.contentView viewWithTag:file_download_button_tag];

    if (_convRecord.msg_flag == send_msg) {
        if (_convRecord.conv_type == singleType) {
            sourceLabel.text =  [NSString stringWithFormat:[StringUtil getLocalizableString:@"file_source_single_send" ],_convRecord.conv_title];
        }
        else{
            sourceLabel.text =  [NSString stringWithFormat:[StringUtil getLocalizableString:@"file_source_group_send" ],_convRecord.conv_title];
        }
        
        //发送文件
        switch (_convRecord.send_flag) {
            case send_uploading:
            {
                //正在上传
                fileTimeLab.hidden = YES;
                sourceLabel.hidden = YES;
                [self displayProgressView:_progressView];
            }
                break;
            case sending:
            {
                //正在发送
            }
                break;
            case send_success:
            {
                //发送成功
                fileTimeLab.hidden = NO;
                sourceLabel.hidden = NO;
                [self hideProgressView:_progressView];
            }
                break;
            case send_upload_fail:
            {
                //发送失败
            }
                break;
            case send_upload_stop:
            {
                //发送暂停
                fileTimeLab.hidden = NO;
                sourceLabel.hidden = NO;
                [self hideProgressView:_progressView];
            }
                break;
            case send_upload_nonexistent:
            {
                //文件已过期
                validityLabel.text = [StringUtil getLocalizableString:@"file_has_expired"];
                validityLabel.hidden = NO;
                fileTimeLab.hidden = NO;
                sourceLabel.hidden = NO;
                downloadBtn.hidden = YES;
                [self hideProgressView:_progressView];
            }
                break;
                
            default:
                break;
        }
    }
    else{
        //接收文件
        if (_convRecord.conv_type == singleType) {
            sourceLabel.text =  [NSString stringWithFormat:[StringUtil getLocalizableString:@"file_source_single_rec" ],_convRecord.conv_title];
        }
        else{
            sourceLabel.text =  [NSString stringWithFormat:[StringUtil getLocalizableString:@"file_source_group_rec" ],_convRecord.conv_title];
        }
    }
    
    //不管是发送的文件还是接收的文件,在文件助手列表里面都要判断本地有没有
    switch (_convRecord.download_flag) {
        case state_download_unknow:
        {
            //文件未点击下载
            fileTimeLab.hidden = NO;
            sourceLabel.hidden = NO;
            [self hideProgressView:_progressView];
            [downloadBtn setTitle:[StringUtil  getLocalizableString:@"download"] forState:UIControlStateNormal];
        }
            break;
        case state_download_success:
        {
            //文件下载成功
            fileTimeLab.hidden = NO;
            sourceLabel.hidden = NO;
            [self hideProgressView:_progressView];
            [downloadBtn setTitle:[StringUtil  getLocalizableString:@"file_browse"] forState:UIControlStateNormal];
        }
            break;
        case state_downloading:
        {
            //正在下载
            fileTimeLab.hidden = YES;
            sourceLabel.hidden = YES;
            [self displayProgressView:_progressView];
            _convRecord.downloadRequest.downloadProgressDelegate = _progressView;
            [downloadBtn setTitle:[StringUtil  getLocalizableString:@"file_stop"] forState:UIControlStateNormal];
        }
            break;
        case state_download_failure:
        {
            //下载失败
            fileTimeLab.hidden = NO;
            sourceLabel.hidden = NO;
            [self hideProgressView:_progressView];
            [downloadBtn setTitle:[StringUtil  getLocalizableString:@"download"] forState:UIControlStateNormal];
        }
            break;
        case state_download_stop:
        {
            //文件下载暂停
            fileTimeLab.hidden = NO;
            sourceLabel.hidden = NO;
            [self hideProgressView:_progressView];
            [downloadBtn setTitle:[StringUtil  getLocalizableString:@"download"] forState:UIControlStateNormal];
        }
            break;
        case state_download_nonexistent:
        {
            //文件已过期
            validityLabel.text = [StringUtil getLocalizableString:@"file_has_expired"];
            validityLabel.hidden = NO;
            fileTimeLab.hidden = NO;
            sourceLabel.hidden = NO;
            downloadBtn.hidden = YES;
            [self hideProgressView:_progressView];
        }
            break;
        default:
        {
            
        }
            break;
    }
    
    //编辑状态下不显示下载按钮和进度条
    if (editing) {
        downloadBtn.hidden = YES;
        fileTimeLab.hidden = NO;
        sourceLabel.hidden = NO;
        [self hideProgressView:_progressView];
    }
    else{
        if (_convRecord.download_flag != state_download_nonexistent) {
            downloadBtn.hidden = NO;
        }
    }
}

+(void)configureChooseFileResumeDownOrUpLoadSateLabelCell:(UITableViewCell *)cell convRecord:(ConvRecord*)_convRecord{
    UILabel *fileTimeLab = (UILabel *)[cell.contentView viewWithTag:file_time_tag];
    UILabel *sourceLabel = (UILabel *)[cell.contentView viewWithTag:file_source_tag];
    UILabel *validityLabel = (UILabel *)[cell.contentView viewWithTag:file_validity_tag];
    validityLabel.hidden = YES;
    
    UIProgressView *_progressView = (UIProgressView *)[cell.contentView viewWithTag:file_list_progressview_tag];
    UIImageView * downloadFlag = (UIImageView *)[cell.contentView viewWithTag:file_download_flag_tag];
    UIButton * downloadBtn = (UIButton *)[cell.contentView viewWithTag:file_download_button_tag];
    downloadBtn.hidden = NO;
    downloadFlag.hidden = NO;
    
    if (_convRecord.msg_flag == send_msg) {
        if (_convRecord.conv_type == singleType) {
            sourceLabel.text =  [NSString stringWithFormat:[StringUtil getLocalizableString:@"file_source_single_send" ],_convRecord.conv_title];
        }
        else{
            sourceLabel.text =  [NSString stringWithFormat:[StringUtil getLocalizableString:@"file_source_group_send" ],_convRecord.conv_title];
        }
        
        //发送文件
        switch (_convRecord.send_flag) {
            case send_uploading:
            {
                //正在上传
                fileTimeLab.hidden = YES;
                sourceLabel.hidden = YES;
                [self displayProgressView:_progressView];
            }
                break;
            case sending:
            {
                //正在发送
            }
                break;
            case send_success:
            {
                //发送成功
                fileTimeLab.hidden = NO;
                sourceLabel.hidden = NO;
                [self hideProgressView:_progressView];
            }
                break;
            case send_upload_fail:
            {
                //发送失败
            }
                break;
            case send_upload_stop:
            {
                //发送暂停
                fileTimeLab.hidden = NO;
                sourceLabel.hidden = NO;
                [self hideProgressView:_progressView];
            }
                break;
            case send_upload_nonexistent:
            {
                //文件已过期
                validityLabel.text = [StringUtil getLocalizableString:@"file_has_expired"];
                validityLabel.hidden = NO;
                fileTimeLab.hidden = NO;
                sourceLabel.hidden = NO;
                downloadBtn.hidden = YES;
                downloadFlag.hidden = YES;
                [self hideProgressView:_progressView];
            }
                break;
                
            default:
                break;
        }
    }
    else{
        //接收文件
        if (_convRecord.conv_type == singleType) {
            sourceLabel.text =  [NSString stringWithFormat:[StringUtil getLocalizableString:@"file_source_single_rec" ],_convRecord.conv_title];
        }
        else{
            sourceLabel.text =  [NSString stringWithFormat:[StringUtil getLocalizableString:@"file_source_group_rec" ],_convRecord.conv_title];
        }
    }
    
    //不管是发送的文件还是接收的文件,在文件助手列表里面都要判断本地有没有
    switch (_convRecord.download_flag) {
        case state_download_unknow:
        {
            //文件未点击下载
            fileTimeLab.hidden = NO;
            sourceLabel.hidden = NO;
            [self hideProgressView:_progressView];
            [downloadFlag setImage:[StringUtil getImageByResName:@"file_download.png"]];
        }
            break;
        case state_download_success:
        {
            //文件下载成功
            fileTimeLab.hidden = NO;
            sourceLabel.hidden = NO;
            [self hideProgressView:_progressView];
            
            [downloadFlag setImage:[StringUtil getImageByResName:@"view_file.png"]];
        }
            break;
        case state_downloading:
        {
            //正在下载
            fileTimeLab.hidden = YES;
            sourceLabel.hidden = YES;
            [self displayProgressView:_progressView];
            _convRecord.downloadRequest.downloadProgressDelegate = _progressView;
            [downloadFlag setImage:[StringUtil getImageByResName:@"file_stop_btn.png"]];
        }
            break;
        case state_download_failure:
        {
            //下载失败
            fileTimeLab.hidden = NO;
            sourceLabel.hidden = NO;
            [self hideProgressView:_progressView];
            [downloadFlag setImage:[StringUtil getImageByResName:@"file_download.png"]];
        }
            break;
        case state_download_stop:
        {
            //文件下载暂停
            fileTimeLab.hidden = NO;
            sourceLabel.hidden = NO;
            [self hideProgressView:_progressView];
            [downloadFlag setImage:[StringUtil getImageByResName:@"re_download_btn.png"]];
        }
            break;
        case state_download_nonexistent:
        {
            //文件已过期
            validityLabel.text = [StringUtil getLocalizableString:@"file_has_expired"];
            validityLabel.hidden = NO;
            fileTimeLab.hidden = NO;
            sourceLabel.hidden = NO;
            downloadBtn.hidden = YES;
            downloadFlag.hidden = YES;
            [self hideProgressView:_progressView];
        }
            break;
        default:
        {
            
        }
            break;
    }
    
}

+(void)hideProgressView:(UIProgressView*)progressView{
    //设置进度条为透明
    progressView.alpha = 0;
}

+(void)displayProgressView:(UIProgressView*)progressView{
    //显示进度条
    progressView.alpha = 1;
}


#pragma mark - 提示文件过期
+ (void)showFileNonexistViewInView:(UIView *)_view inTalkSession:(BOOL)talkSession{
    float windownHeight = [[UIApplication sharedApplication] keyWindow].frame.size.height;
    float viewHeight = _view.frame.size.height;
    float viewY = _view.frame.origin.y;

    CGRect _frame = CGRectMake(20.0, 120.0, 280.0, 44.0);
    //如果当前View的高度低于整个windown的高度，需要调整self的坐标
    if (viewHeight < windownHeight) {
        _frame.origin.y -= viewY;
        if (talkSession) {
            _frame.origin.y -= 44.0;
        }
    }
    
    FileAlertView *alertView = [[FileAlertView alloc] initWithFrame:_frame title:[StringUtil getLocalizableString:@"file_has_expired_tips"]];
    [alertView showFileAlertViewInView:_view];
    [alertView release];
}

@end
