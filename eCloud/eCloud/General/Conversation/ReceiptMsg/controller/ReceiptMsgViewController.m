//
//  ReceiptMsgViewController.m
//  eCloud
//
//  Created by Alex L on 15/11/4.
//  Copyright © 2015年  lyong. All rights reserved.
//

#import "ReceiptMsgViewController.h"

#import "ReceiptMsgDetailViewController.h"

#import "ReceiptMsgTextCell.h"
#import "ReceiptMsgPicCell.h"
#import "ReceiptMsgRecordCell.h"
#import "ReceiptMsgFileCell.h"

#import "ReceiptDAO.h"
#import "CollectionUtil.h"
#import "ConvRecord.h"

#import "eCloudDefine.h"

#define KSCREEN_BOUNDS ([UIScreen mainScreen].bounds)

static NSString *fileCellIdentify    = @"fileCellIdentify";
static NSString *videoCellIdentify   = @"videoCellIdentify";
static NSString *recordCellIdentify   = @"recordCellIdentify";
static NSString *textMsgCellIdentify = @"textMsgCellIdentify";
static NSString *pictureCellIdentify = @"pictureCellIdentify";
static NSString *longTextMsgCellIdentify = @"longTextMsgCellIdentify";

@interface ReceiptMsgViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *receiptMsgData;

@end

@implementation ReceiptMsgViewController

- (NSArray *)receiptMsgData
{
    if (_receiptMsgData == nil)
    {
        ReceiptDAO *receiptDAO = [ReceiptDAO getDataBase];
        _receiptMsgData = [receiptDAO getReceiptMsgByconvID:self.convID];
    }
    return _receiptMsgData;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置标题
//    UILabel *titltLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 20)];
//    [titltLabel setFont:[UIFont systemFontOfSize:17]];
//    titltLabel.text = [StringUtil getLocalizableString:@"chatmessage_receipt_msg_list"];
//    [titltLabel setTextColor:[UIColor whiteColor]];
//    self.navigationItem.titleView = titltLabel;
    self.title = [StringUtil getLocalizableString:@"chatmessage_receipt_msg_list"];
    
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    tableView.dataSource = self;
    tableView.delegate = self;
    
    // 让分割线左边置顶
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        
        [tableView setSeparatorInset:UIEdgeInsetsZero];
        
    }
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        
        [tableView setLayoutMargins:UIEdgeInsetsZero];
        
    }
    
    // 把多余的分割线去掉
    [tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    
    [self.view addSubview:tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.receiptMsgData.count;
}

#pragma mark - tableview数据源方法
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ConvRecord *convRecord = self.receiptMsgData[indexPath.row];
    if (convRecord.msg_type == type_text)
    {
        ReceiptMsgTextCell *textCell = (ReceiptMsgTextCell *)[tableView dequeueReusableCellWithIdentifier:textMsgCellIdentify];
        if (textCell == nil)
        {
            textCell = [[ReceiptMsgTextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:textMsgCellIdentify];
        }
        
        textCell.timeLabel.text = [self getTime:convRecord.msg_time];
        textCell.textMsgLabel.text = convRecord.msg_body;
        textCell.unreadCounts.text = [NSString stringWithFormat:@"%@",convRecord.receiptTips];
        NSArray *array = [convRecord.receiptTips componentsSeparatedByString:@" "];
        NSInteger unreadCounts = [array[0] integerValue];
        if (unreadCounts == 0)
        {
            textCell.unreadCounts.text = [StringUtil getLocalizableString:@"receipt_msg_read"];
        }
        
        return textCell;
    }
    else if (convRecord.msg_type == type_pic)
    {
        ReceiptMsgPicCell *picCell = (ReceiptMsgPicCell *)[tableView dequeueReusableCellWithIdentifier:pictureCellIdentify];
        if (picCell == nil)
        {
            picCell = [[ReceiptMsgPicCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:pictureCellIdentify];
        }
        
        picCell.timeLabel.text = [self getTime:convRecord.msg_time];
        picCell.unreadCounts.text = [NSString stringWithFormat:@"%@",convRecord.receiptTips];
        NSArray *array = [convRecord.receiptTips componentsSeparatedByString:@" "];
        NSInteger unreadCounts = [array[0] integerValue];
        if (unreadCounts == 0)
        {
            picCell.unreadCounts.text = [StringUtil getLocalizableString:@"receipt_msg_read"];;
        }
        
        NSString *messageStr = convRecord.msg_body;
        NSString *picname=[NSString stringWithFormat:@"%@.png",messageStr];
        NSString *picpath = [[CollectionUtil newRcvFilePath] stringByAppendingPathComponent:picname];
        UIImage *originImg = [UIImage imageWithContentsOfFile:picpath];
        
        NSString *smallpicname=[NSString stringWithFormat:@"small%@.png",messageStr];
        NSString *smallpicpath = [[CollectionUtil newRcvFilePath] stringByAppendingPathComponent:smallpicname];
        UIImage *smallimg =  [UIImage imageWithContentsOfFile:smallpicpath];
        
        picCell.picture.image = originImg ? originImg : smallimg;
        
        return picCell;
    }
    else if (convRecord.msg_type == type_record)
    {
        ReceiptMsgRecordCell *recordCell = (ReceiptMsgRecordCell *)[tableView dequeueReusableCellWithIdentifier:recordCellIdentify];
        if (recordCell == nil)
        {
            recordCell = [[ReceiptMsgRecordCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:recordCellIdentify];
        }
        
        recordCell.timeLabel.text = [self getTime:convRecord.msg_time];
        recordCell.unreadCounts.text = [NSString stringWithFormat:@"%@",convRecord.receiptTips];
        NSArray *array = [convRecord.receiptTips componentsSeparatedByString:@" "];
        NSInteger unreadCounts = [array[0] integerValue];
        if (unreadCounts == 0)
        {
            recordCell.unreadCounts.text = [StringUtil getLocalizableString:@"receipt_msg_read"];;
        }
        
        recordCell.durationLabel.text = convRecord.file_size;
        
        return recordCell;
    }
    else if (convRecord.msg_type == type_file)
    {
        ReceiptMsgFileCell *fileCell = (ReceiptMsgFileCell *)[tableView dequeueReusableCellWithIdentifier:fileCellIdentify];
        if (fileCell == nil)
        {
            fileCell = [[ReceiptMsgFileCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:fileCellIdentify];
        }
        
        fileCell.timeLabel.text = [self getTime:convRecord.msg_time];
        fileCell.unreadCounts.text = [NSString stringWithFormat:@"%@",convRecord.receiptTips];
        NSArray *array = [convRecord.receiptTips componentsSeparatedByString:@" "];
        NSInteger unreadCounts = [array[0] integerValue];
        if (unreadCounts == 0)
        {
            fileCell.unreadCounts.text = [StringUtil getLocalizableString:@"receipt_msg_read"];;
        }
        
        fileCell.fileName.text = convRecord.msg_body;
        fileCell.fileImgView.image = [StringUtil getFileDefaultImage:convRecord.msg_body];
        fileCell.fileSize.text = convRecord.file_size;
        
        return fileCell;
    }
    
    return nil;
}

- (NSString *)getTime:(NSString *)sendTime
{
    // 计算什么时候发送的
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger zoneTime = [zone secondsFromGMT];
    NSInteger timeFromYesterday = (([sendTime integerValue] + zoneTime)/ 3600) % 24;
    
    NSInteger _timeNow = [[NSDate date] timeIntervalSince1970];
    NSInteger time = _timeNow - [sendTime integerValue];
    NSInteger hours = time/(60*60) + timeFromYesterday;
    NSInteger days = hours / 24;
    
    
    NSDate *detaildate = [NSDate dateWithTimeIntervalSince1970:[sendTime integerValue]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    if (days == 0)
    {
        [dateFormatter setDateFormat:@"HH:MM"];
        NSString *date = [dateFormatter stringFromDate:detaildate];
        
        return date;
    }
    else if (days >= 1 && days < 20)
    {
        [dateFormatter setDateFormat:@"MM/dd HH:MM"];
        NSString *date = [dateFormatter stringFromDate:detaildate];
        
        return date;
    }
    else
    {
        [dateFormatter setDateFormat:@"yy/MM/dd"];
        NSString *date = [dateFormatter stringFromDate:detaildate];
        
        return date;
    }
}

#pragma mark - tableview代理方法
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ConvRecord *convRecord = self.receiptMsgData[indexPath.row];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ReceiptMsgDetailViewController *detailViewCtl = [[ReceiptMsgDetailViewController alloc] init];
    detailViewCtl.msgId = convRecord.msgId;
    [self.navigationController pushViewController:detailViewCtl animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ConvRecord *convRecord = self.receiptMsgData[indexPath.row];
    
    if (convRecord.msg_type == type_text)
    {
        return 80;
    }
    else if (convRecord.msg_type == type_pic)
    {
        return 150;
    }
    else if (convRecord.msg_type == type_record)
    {
        return 80;
    }
    
    return 80;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 让分割线左边置顶
    if ([cell respondsToSelector:@selector(setSeparatorInset:)])
    {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)])
    {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
