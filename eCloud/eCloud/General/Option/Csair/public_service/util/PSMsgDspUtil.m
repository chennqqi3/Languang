//
//  PSMsgDspUtil.m
//  eCloud
//
//  Created by shisuping on 15-6-26.
//  Copyright (c) 2015年  lyong. All rights reserved.
//

#import "PSMsgDspUtil.h"
#import "EncryptFileManege.h"
#import "ServiceModel.h"
#import "ServiceMessage.h"
#import "ServiceMessageDetail.h"


#import "UIImageOfCrop.h"

#import "UITableViewCell+getCellContentWidth.h"

#import "NewOrgViewController.h"

#import "LinkTextMsgCell.h"
#import "FaceTextMsgCell.h"
#import "NormalTextMsgCell.h"
#import "PicMsgCell.h"

#import "InputTextView.h"
#import "openWebViewController.h"
#import "NewMsgNotice.h"

#import "userInfoViewController.h"
#import "conn.h"

#import "eCloudDAO.h"
#import "PSUtil.h"

#import "StringUtil.h"

#import "talkSessionViewController.h"

#import "PublicServiceDAO.h"
#import "ServiceMenuModel.h"
#import "PSDetailViewController.h"
#import "ConvRecord.h"
#import "ServiceMessage.h"
#import "ServiceMessageDetail.h"

#import "talkSessionUtil.h"

#import "PSMsgUtil.h"

static NSString *chatCellId = @"ChatCell";

static NSString *MsgCellId = @"MsgCell";
static NSString *SingleMsgCellId = @"SingleMsgCell";

//消息时间
static NSString *headerCellId = @"headerView";


static PSMsgDspUtil *psMsgDspUtil;

@implementation PSMsgDspUtil
{
    PublicServiceDAO *_psDAO;
}

+ (PSMsgDspUtil *)getUtil
{
    if (!psMsgDspUtil) {
        psMsgDspUtil = [[PSMsgDspUtil alloc]init];
    }
    return psMsgDspUtil;
}

- (id)init
{
    self = [super init];
    if (self) {
        _psDAO = [PublicServiceDAO getDatabase];
    }
    return self;
}

//如果此公众号 有未读消息，那么把未读消息设置为已读
- (void)makeReadIfExistUnread
{
    int unreadMsgCount = [_psDAO getUnreadMsgCountOfPS:[talkSessionViewController getTalkSession].serviceModel.serviceId];
    if(unreadMsgCount > 0)
    {
        //	把此服务号所有的未读消息设置为已读
        [_psDAO updateReadFlagOfPSMsg:[talkSessionViewController getTalkSession].serviceModel.serviceId];
    }
}

//查看某个公众号的详细资料
-(void)viewServiceInfo:(UIViewController *)curController andServiceModel:(ServiceModel *)serviceModel
{
    PSDetailViewController *_controller = [[PSDetailViewController alloc]init];
    _controller.serviceId = serviceModel.serviceId;
    [curController.navigationController pushViewController:_controller animated:YES];
    [_controller release];
}

#pragma mark =====公众号消息展示=====
//获取tableView一共有几个section
- (NSInteger)getNumberOfSection
{
    return [talkSessionViewController getTalkSession].convRecordArray.count + 1;
}

//获取每一个section有几行
- (int)getRowCountOfSection:(NSInteger)section
{
    if(section == 0)
        return 1;
    
    int rows = 0;
    
    id _id = [[talkSessionViewController getTalkSession].convRecordArray objectAtIndex:section - 1];
    
    if([_id isKindOfClass:[ConvRecord class]])
    {
        rows = 1;
    }
    else
    {
        ServiceMessage *message = (ServiceMessage*)_id;
        if(message.msgType == ps_msg_type_news && message.detail)
        {
            rows = message.detail.count;
        }
    }
    
    //	[LogUtil debug:[NSString stringWithFormat:@"%s ,rows is %d",__FUNCTION__,rows]];
    
    return rows;
}

//获取每一行的高度
- (CGFloat)getHeightOfIndexPath:(NSIndexPath *)indexPath
{
    //	加载提示
    if(indexPath.section == 0)
    {
        if ([[talkSessionViewController getTalkSession]getOffset] == 0) {
            return 1;
        }
        return 40;
    }
    float height = 0;
    
    int section = indexPath.section;
    int row = indexPath.row;
    
    id _id = [[talkSessionViewController getTalkSession].convRecordArray objectAtIndex:section - 1];
    if([_id isKindOfClass:[ConvRecord class]])
    {
        height = [talkSessionUtil getMsgBodyHeight:(ConvRecord*)_id];
    }
    else
    {
        ServiceMessage *message = (ServiceMessage*)_id;
        int msgType = message.msgType;
        if(msgType == ps_msg_type_news)
        {
            if(message.detail && message.detail.count > 0)
            {
                if(message.detail.count == 1)
                {
                    height = [PSMsgUtil getSinglePsMsgHeight:message];
                }
                else
                {
                    if(row == 0)
                    {
                        height = [PSMsgUtil getPSMsgRow0Height];
                    }
                    else
                    {
                        height = ps_msg_row1_height;
                    }
                }
            }
        }
    }
    return height;
}

//cellwilldisplay时的处理
- (void)processWhenCellWillDisplay:(UITableView *)tableView andCell:(UITableViewCell *)cell andIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
    {
        [UIAdapterUtil removeBackground:cell];
        return;
    }
    
    int section = indexPath.section;
    id _id = [[talkSessionViewController getTalkSession].convRecordArray objectAtIndex:section-1];
    if([_id isKindOfClass:[ConvRecord class]])
    {
        [UIAdapterUtil removeBackground:cell];
    }
    else
    {
        if (IOS7_OR_LATER)
        {
            [UIAdapterUtil removeBackground:cell];
            [UIAdapterUtil customCellBackground:tableView andCell:cell andIndexPath:indexPath];
        }
    }
}

- (UITableViewCell *)getCellOfTableView:(UITableView *)tableView andConvRecord:(ConvRecord *)_convRecord
{
    UITableViewCell *cell = nil;
    
    if (_convRecord.msg_type == type_text) {
        
        if (_convRecord.isLinkText) {
            static NSString *linkTextCellID = @"linkTextCellIDPS";
            cell = [tableView dequeueReusableCellWithIdentifier:linkTextCellID];
            if (cell == nil) {
                cell = [[[LinkTextMsgCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:linkTextCellID]autorelease];
                [self processHeadImage:cell andConvRecord:_convRecord];
            }
        }
        else if(_convRecord.isTextPic)
        {
            static NSString *faceTextCellID = @"faceTextCellIDPS";
            cell = [tableView dequeueReusableCellWithIdentifier:faceTextCellID];
            if (cell == nil) {
                cell = [[[FaceTextMsgCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:faceTextCellID]autorelease];
                [self processHeadImage:cell andConvRecord:_convRecord];
            }
        }
        else
        {
            static NSString *normalTextCellID = @"normalTextCellIDPS";
            cell = [tableView dequeueReusableCellWithIdentifier:normalTextCellID];
            if (cell == nil) {
                cell = [[[NormalTextMsgCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:normalTextCellID]autorelease];
                
                [self processHeadImage:cell andConvRecord:_convRecord];
            }
        }
    }
    else if (_convRecord.msg_type == type_pic)
    {
//        图片类型的公众号消息 应该判断图片是否存在，如果不存在，那么就提示正在下载，并且去下载，下载完毕后进行展示
        static NSString *picMsgCellID = @"picMsgCellIDPS";
        cell = [tableView dequeueReusableCellWithIdentifier:picMsgCellID];
        if (cell == nil) {
            cell = [[[PicMsgCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:picMsgCellID]autorelease];
            [self processHeadImage:cell andConvRecord:_convRecord];

            //                增加图片消息点击事件
            [[talkSessionViewController getTalkSession] addSingleTapToPicViewOfCell:cell];
        }
    }
    
    if (cell) {
        [talkSessionUtil configureCell:cell andConvRecord:_convRecord];
        [self configHead:cell andConvRecord:_convRecord];
        
        UIActivityIndicatorView *spinner = (UIActivityIndicatorView*)[cell.contentView viewWithTag:status_spinner_tag];
        
        [spinner stopAnimating];
        
        //	状态按钮
        if (_convRecord.msg_type == type_pic) {
            if (_convRecord.msg_flag == send_msg) {
//                如果是发送的图片消息，那么按照普通消息处理即可
//                [[talkSessionViewController getTalkSession]autoDownloadSmallPic:cell andConvRecord:_convRecord];
            }else{
                if (!_convRecord.isBigPicExist) {
                    if(!_convRecord.isDownLoading)
                    {
                        [spinner startAnimating];
                        _convRecord.isDownLoading = true;
                        
                        [self autoDownloadPSPicMsgImageWithCell:cell andConvRecord:_convRecord];
                    }else{
                        [spinner startAnimating];
                    }
                }
            }
        }
        
    }
    return cell;
}

//自动下载公众号图片
- (void)autoDownloadPSPicMsgImageWithCell:(UITableViewCell *)cell andConvRecord:(ConvRecord *)recordObject
{
    UIActivityIndicatorView *activity = (UIActivityIndicatorView*)[cell.contentView viewWithTag:status_spinner_tag];
    [activity startAnimating];
    
    dispatch_queue_t queue;
    queue = dispatch_queue_create("download ps pic msg image", NULL);
    dispatch_async(queue, ^{
        NSURL *url = [NSURL URLWithString:recordObject.msg_body];
        
        [LogUtil debug:[NSString stringWithFormat:@"%s url is %@",__FUNCTION__,url]];
        
        NSData *imageData = [NSData dataWithContentsOfURL:url];
        UIImage *image = [UIImage imageWithData:imageData];
        recordObject.isDownLoading = false;
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (image!=nil)
            {
                [activity stopAnimating];
                
                NSString *imagePath = [PSMsgUtil getPSPicMsgImagePath:recordObject];
                
                BOOL success = [EncryptFileManege saveFileWithPath:imagePath withData:imageData];
//                [imageData writeToFile:imagePath atomically:YES];
                if(!success)
                {
                    [LogUtil debug:@"公众号图片消息保存失败"];
                }
                else
                {
                    //                                    怎么更新呢
                    int _index = [[talkSessionViewController getTalkSession] getArrayIndexByMsgId:recordObject.msgId];
                    if(_index >=0)
                    {
                        [[talkSessionViewController getTalkSession] reloadRow:_index+1];
                    }
                }
            }
            else
            {
                [activity stopAnimating];
                
            }
        });
    });
    dispatch_release(queue);
}

//获取cell
- (UITableViewCell *)getCellOfTableView:(UITableView *)tableView andIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
    {
        UITableViewCell *cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil]autorelease];
        [cell addSubview:[[talkSessionViewController getTalkSession]getIndicatorView]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    
    int section = indexPath.section;
    int row = indexPath.row;
    
    
    id _id = [[talkSessionViewController getTalkSession].convRecordArray objectAtIndex:indexPath.section-1];
    if([_id isKindOfClass:[ConvRecord class]])
    {
//        目前支持文本和图片类型的公众号消息
        
        UITableViewCell *chatCell = [self getCellOfTableView:tableView andConvRecord:(ConvRecord *)_id];
        
        return chatCell;
    }
    else
    {
        UITableViewCell *msgCell;
        
        ServiceMessage *message = (ServiceMessage*)_id;
        ServiceMessageDetail *detailMsg = [message.detail objectAtIndex:row];
        
        if(message.detail.count == 1)
        {
            msgCell = [tableView dequeueReusableCellWithIdentifier:SingleMsgCellId];
            
            if(msgCell == nil)
            {
                msgCell = [PSMsgUtil singlePsMsgTableViewCellWithReuseIdentifier:SingleMsgCellId];
            }
            [PSMsgUtil  configureSinglePsMsgCell:msgCell andPSMsg:message];
        }
        else
        {
            msgCell = [tableView dequeueReusableCellWithIdentifier:MsgCellId];
            
            if(msgCell == nil)
            {
                msgCell = [PSMsgUtil multiPsMsgTableViewCellWithReuseIdentifier:MsgCellId];
            }
            
            [PSMsgUtil configureMultiPsMsgCell:msgCell andPSMsgDtl:detailMsg];
        }
        
        UIActivityIndicatorView *spinner = (UIActivityIndicatorView*)[msgCell.contentView viewWithTag:ps_spinner_tag];
        
        if(!detailMsg.isPicExists)
        {
            //			异步下载图片
            if(!detailMsg.isPicDownloading)
            {
                detailMsg.isPicDownloading = YES;
                [self autoDownloadPic:msgCell andDetailMsg:detailMsg];
            }
            else
            {
                [spinner startAnimating];				
            }
        }
        else
        {
            [spinner stopAnimating];
        }
        
        return msgCell;
    }
}


#pragma mark 点击头像查看用户资料
-(void)processHeadImage:(UITableViewCell*)cell andConvRecord:(ConvRecord*)_convRecord
{
    UIImageView *headView = (UIImageView*)[cell.contentView viewWithTag:head_tag];
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(viewUserInfo:)];
    [headView addGestureRecognizer:singleTap];
    [singleTap release];
}

//设置头像和名字 主要是显示收到的公众号的消息，发送的不在这里处理
- (void)configHead:(UITableViewCell*)cell andConvRecord:(ConvRecord*)_convRecord
{
    conn *_conn = [conn getConn];
    int msgFlag = _convRecord.msg_flag;
    int serviceId = _convRecord.conv_id.intValue;
    
    if(msgFlag == rcv_msg)
    {
        UIImage *image = [PSUtil getServiceLogo:[talkSessionViewController getTalkSession].serviceModel];
        UIImageView *headView = (UIImageView*)[cell.contentView viewWithTag:head_tag];
        headView.image = image;

        UILabel *nameLabel = (UILabel*)[cell.contentView viewWithTag:head_empName_tag];
        nameLabel.text = [talkSessionViewController getTalkSession].serviceModel.serviceName;
    }
}

#pragma mark 查看用户资料
-(void)viewUserInfo:(UITapGestureRecognizer *)gesture
{
    CGPoint p = [gesture locationInView:[talkSessionViewController getTalkSession].chatTableView];
    NSIndexPath *indexPath = [[talkSessionViewController getTalkSession].chatTableView indexPathForRowAtPoint:p];
    ConvRecord *_convRecord = [[talkSessionViewController getTalkSession].convRecordArray objectAtIndex:indexPath.section-1];
    if(_convRecord.msg_flag == send_msg)
    {
        [NewOrgViewController openUserInfoById:[conn getConn].userId andCurController:[talkSessionViewController getTalkSession]];
    }
    else
    {
        [self viewServiceInfo:[talkSessionViewController getTalkSession] andServiceModel:[talkSessionViewController getTalkSession].serviceModel];
    }
}

-(void)autoDownloadPic:(UITableViewCell *)cell andDetailMsg:(ServiceMessageDetail*)detailMsg
{
    UIActivityIndicatorView *spinner = (UIActivityIndicatorView*)[cell.contentView viewWithTag:ps_spinner_tag];
    [spinner startAnimating];
    dispatch_queue_t queue;
    queue = dispatch_queue_create("download ps detail msg pic", NULL);
    dispatch_async(queue, ^{
        NSURL *url = [NSURL URLWithString:[StringUtil trimString:detailMsg.msgUrl]];
        NSData *imageData = [NSData dataWithContentsOfURL:url];
        UIImage *image = [UIImage imageWithData:imageData];
        if(detailMsg.row == 0)
        {//大图尺寸裁剪
            image = [image imageByScalingAndCroppingForSize:CGSizeMake([PSMsgUtil getMaxContentWidth], [PSMsgUtil getPSBigPicHeight])];
        }
        else
        {//按照正方形裁剪
            image = [image imageByScalingAndCroppingForSize:CGSizeMake(100, 100)];
        }
        
        
        if (UIImagePNGRepresentation(image) == nil)
        {
            imageData = UIImageJPEGRepresentation(image, 1);
        } else
        {
            imageData = UIImagePNGRepresentation(image);
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [spinner stopAnimating];
            detailMsg.isPicDownloading = NO;
            if (image!=nil)
            {
                NSString *picpath = [PSMsgUtil getDtlImgPath:detailMsg];
                BOOL success=[EncryptFileManege saveFileWithPath:picpath withData:imageData];
//                [imageData writeToFile:picpath atomically:YES];
                if(!success)
                {
                    NSLog(@"推送消息明细对应图片保存失败");
                }
                else
                {
                    for(int i = [talkSessionViewController getTalkSession].convRecordArray.count-1;i>=0;i--)
                    {
                        id _id = [[talkSessionViewController getTalkSession].convRecordArray objectAtIndex:i];
                        if([_id isKindOfClass:[ServiceMessage class]])
                        {
                            ServiceMessage *message = (ServiceMessage*)_id;
                            if(message.msgId == detailMsg.serviceMsgId)
                            {
                                //								[LogUtil debug:[NSString stringWithFormat:@"%s,download ok row is %d,section is %d",__FUNCTION__,detailMsg.row,i]];
                                
                                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:detailMsg.row inSection:i+1];
                                [[talkSessionViewController getTalkSession].chatTableView beginUpdates];
                                [[talkSessionViewController getTalkSession].chatTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
                                [[talkSessionViewController getTalkSession].chatTableView endUpdates];
                            }
                        }
                    }
                }
            }
        });
    });
}

//获取section header 高度
- (CGFloat)getHeaderHeightOfSection:(NSInteger)section
{
    if(section == 0)
        return 0;
    
    id _id = [[talkSessionViewController getTalkSession].convRecordArray objectAtIndex:section-1];
    if([_id isKindOfClass:[ServiceMessage class]])
    {
        return 30;
    }
    return 0;
}

//获取section view
- (UIView *)getHeaderViewOfSection:(NSInteger)section
{
    if(section == 0)
        return nil;
    
    id _id = [[talkSessionViewController getTalkSession].convRecordArray objectAtIndex:section-1];
    if([_id isKindOfClass:[ServiceMessage class]])
    {
        UITableViewCell *headerCell;
        //		如果是
        if (IOS_VERSION_BEFORE_6)
        {
            headerCell = [PSMsgUtil headerViewWithReuseIdentifier:headerCellId];
        }
        else
        {
            headerCell = [[talkSessionViewController getTalkSession].chatTableView dequeueReusableHeaderFooterViewWithIdentifier:headerCellId];
            if(headerCell == nil)
            {
                headerCell = [PSMsgUtil headerViewWithReuseIdentifier:headerCellId];
            }
        }
        
        [PSMsgUtil configureHeaderView:headerCell andPSMsg:(ServiceMessage*)_id];
        return headerCell.contentView;
    }
    return nil;
}

//点击了表格的某一行
- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int section = indexPath.section;
    int row = indexPath.row;
    if(section > 0)
    {
        id _id = [[talkSessionViewController getTalkSession].convRecordArray objectAtIndex:section-1];
        if([_id isKindOfClass:[ServiceMessage class]])
        {
            ServiceMessage *message = (ServiceMessage*)_id;
            ServiceMessageDetail *dtlMessage = [message.detail objectAtIndex:row];
            if(dtlMessage.msgLink && dtlMessage.msgLink.length > 0)
            {
                [self openWebUrl:[StringUtil trimString:dtlMessage.msgLink]];
            }
        }
    }
}

#pragma mark 打开超链接
-(void)openWebUrl:(NSString *)urlStr
{
    openWebViewController *openweb=[[openWebViewController alloc]init];
    openweb.customTitle = [talkSessionViewController getTalkSession].serviceModel.serviceName;
    openweb.urlstr=urlStr;
    openweb.fromtype=1;
    openweb.needUserInfo = YES;
    [[talkSessionViewController getTalkSession].navigationController pushViewController:openweb animated:YES];
    [openweb release];
}

#pragma mark ======接收公众号消息======
//收到公众号的消息后，可以展示在界面上

- (void)displayRcvPsMsg:(NewMsgNotice *)_notice
{
    if ([talkSessionViewController getTalkSession].talkType == publicServiceMsgDtlConvType) {
        int serviceId = _notice.serviceId;
        if(serviceId == [talkSessionViewController getTalkSession].serviceModel.serviceId)
        {
            PublicServiceDAO *_psDAO = [PublicServiceDAO getDatabase];
            int serviceMsgId = _notice.serviceMsgId;
            ServiceMessage *message = [_psDAO getMessageByServiceMsgId:serviceMsgId];
            if(message.msgType == ps_msg_type_news)
            {
                [[talkSessionViewController getTalkSession].convRecordArray addObject:message];
            }
            else
            {
                ConvRecord *_convRecord = [[ConvRecord alloc]init];
                [_psDAO convertServiceMessage:message toConvRecord:_convRecord];
                [talkSessionUtil setPropertyOfConvRecord:_convRecord];

                [[talkSessionViewController getTalkSession].convRecordArray addObject:_convRecord];
                
                [self setTimeDisplay:_convRecord andIndex:[talkSessionViewController getTalkSession].convRecordArray.count - 1];

                [_convRecord release];
            }
            
            [_psDAO updateReadFlagByServiceMsgId:serviceMsgId];
            [[talkSessionViewController getTalkSession].chatTableView reloadData];
            
            [self scrollToEnd];
            //     [self showNoReadNum];
        }
    }
}

#pragma mark 滑动到最底部
-(void)scrollToEnd
{
    int section = [[talkSessionViewController getTalkSession].convRecordArray count];
    int row = 0;
    int count = [[talkSessionViewController getTalkSession].convRecordArray count] ;
    if(count > 0)
    {
        id _id = [[talkSessionViewController getTalkSession].convRecordArray objectAtIndex:count-1];
        if([_id isKindOfClass:[ServiceMessage class]])
        {
            ServiceMessage *message = (ServiceMessage*)_id;
           
            if(message.detail)
            {
                row = message.detail.count - 1;
            }
        }
        if (row >= 0) {
            [[talkSessionViewController getTalkSession].chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]
                                                                            atScrollPosition: UITableViewScrollPositionBottom
                                                                                animated:NO];
        }
    }
}

#pragma mark =====长按菜单处理=======
//显示 长按 菜单
- (void)showMenu:(id)dic
{
//    tableBackGroudButton.hidden = NO;
    
    UITableViewCell *longClickCell =  (UITableViewCell*)[(NSDictionary *)dic objectForKey:@"LONG_CLICK_CELL"];
    //	显示菜单前，设置长按效果
    
    if([talkSessionViewController getTalkSession].editIndexPath)
    {
        int section = [talkSessionViewController getTalkSession].editIndexPath.section;
        
        id _id = [[talkSessionViewController getTalkSession].convRecordArray objectAtIndex:section - 1];
        
        UIMenuController * menu = [UIMenuController sharedMenuController];
        [UIAdapterUtil dismissMenu];

        if([_id isKindOfClass:[ConvRecord class]])
        {
            ConvRecord *editRecord = (ConvRecord*)_id;
            UIImageView *bubbleView = (UIImageView*)[longClickCell.contentView viewWithTag:bubble_send_tag];
            if(bubbleView.hidden)
            {
                bubbleView = (UIImageView*)[longClickCell.contentView viewWithTag:bubble_rcv_tag];
            }
            
            NSString *pointY=[(NSDictionary*)dic objectForKey:@"pointY"];
            float copyX;
            if(editRecord.msg_flag == rcv_msg)
            {
                copyX = bubbleView.frame.origin.x + bubbleView.frame.size.width / 2 + 5;
            }
            else
            {
                copyX = bubbleView.frame.origin.x + bubbleView.frame.size.width/2 - 5;
            }
            
            int copyY=[pointY intValue]-longClickCell.frame.origin.y;
            [menu setTargetRect: CGRectMake(copyX , copyY, 1, 1) inView: longClickCell];
        }
        else
        {
            float r = 233/255.0;
            UIColor *_color = [UIColor colorWithRed:r green:r blue:r alpha:1];
            longClickCell.backgroundColor = _color;
            
            ServiceMessage *_serviceMessage = [[talkSessionViewController getTalkSession].convRecordArray objectAtIndex:section-1];
            for(int row = 0;row < _serviceMessage.detail.count;row++)
            {
                NSIndexPath *_indexPath = [NSIndexPath indexPathForRow:row inSection:section];
                if(row != [talkSessionViewController getTalkSession].editIndexPath.row)
                {
                    [[[talkSessionViewController getTalkSession].chatTableView cellForRowAtIndexPath:_indexPath] setBackgroundColor:_color];
                }
            }
            float menuX = [longClickCell getCellContentWidth] / 2;
            
            NSString *pointY=[(NSDictionary*)dic objectForKey:@"pointY"];
            int menuY=[pointY intValue]-longClickCell.frame.origin.y;
            
            [menu setTargetRect: CGRectMake(menuX , menuY, 1, 1) inView: longClickCell];
        }
        UIMenuItem *menuItem = [[UIMenuItem alloc] initWithTitle:[StringUtil getLocalizableString:@"copy"] action:@selector(copyAction:)];
        UIMenuItem *menuItem2 = [[UIMenuItem alloc] initWithTitle:[StringUtil getLocalizableString:@"delete"] action:@selector(deleteAction:)];
        [menu setMenuItems:[NSArray arrayWithObjects:menuItem,menuItem2, nil]];
        [menu setMenuVisible: YES animated: YES];

    }
}

//图文消息支持删除，其它消息支持复制
-(BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    BOOL retValue = NO;
    if([talkSessionViewController getTalkSession].editIndexPath)
    {
        //	是否允许copy
        BOOL canCopy = NO;
        id _id = [[talkSessionViewController getTalkSession].convRecordArray objectAtIndex:[talkSessionViewController getTalkSession].editIndexPath.section-1];
        if([_id isKindOfClass:[ConvRecord class]])
        {
            ConvRecord *_convRecord = (ConvRecord *)_id;
            if (_convRecord.msg_type == type_text) {
                canCopy = YES;
            }
        }
        if(action == @selector(deleteAction:))
        {
            retValue = YES;
        }
        else if(action == @selector(copyAction:))
        {
            retValue = canCopy;
        }
    }
    
    return retValue;
}

-(void)menuDisplay
{
    if([talkSessionViewController getTalkSession].editIndexPath)
    {
        id _id = [[talkSessionViewController getTalkSession].convRecordArray objectAtIndex:[talkSessionViewController getTalkSession].editIndexPath.section-1];
        if([_id isKindOfClass:[ConvRecord class]])
        {
            UITableViewCell *cell = [[talkSessionViewController getTalkSession].chatTableView cellForRowAtIndexPath:[talkSessionViewController getTalkSession].editIndexPath];
            UIImageView *bubbleView = (UIImageView*)[cell.contentView viewWithTag:bubble_send_tag];
            if(bubbleView.hidden)
            {
                bubbleView = (UIImageView*)[cell.contentView viewWithTag:bubble_rcv_tag];
            }
            bubbleView.highlighted = YES;
        }
    }
}
-(void)menuHide
{
    if([talkSessionViewController getTalkSession].editIndexPath)
    {
        id _id = [[talkSessionViewController getTalkSession].convRecordArray objectAtIndex:[talkSessionViewController getTalkSession].editIndexPath.section - 1];
        if([_id isKindOfClass:[ConvRecord class]])
        {
            UITableViewCell *cell = [[talkSessionViewController getTalkSession].chatTableView cellForRowAtIndexPath:[talkSessionViewController getTalkSession].editIndexPath];
            UIImageView *bubbleView = (UIImageView*)[cell.contentView viewWithTag:bubble_send_tag];
            if(bubbleView.hidden)
            {
                bubbleView = (UIImageView*)[cell.contentView viewWithTag:bubble_rcv_tag];
            }
            bubbleView.highlighted = NO;
        }
        else
        {
            //		弹出菜单隐藏的时候，设置cell background color 为 clearcolor
            UITableViewCell *cell = [[talkSessionViewController getTalkSession].chatTableView cellForRowAtIndexPath:[talkSessionViewController getTalkSession].editIndexPath];
            float r = 247/255.0;
            UIColor *_color = [UIColor colorWithRed:r green:r blue:r alpha:1];
            cell.backgroundColor = _color;
            
            int section = [talkSessionViewController getTalkSession].editIndexPath.section;
            ServiceMessage *_serviceMessage = [[talkSessionViewController getTalkSession].convRecordArray objectAtIndex:section - 1];
            
            for(int row = 0;row < _serviceMessage.detail.count;row++)
            {
                NSIndexPath *_indexPath = [NSIndexPath indexPathForRow:row inSection:section];
                if(row != [talkSessionViewController getTalkSession].editIndexPath.row)
                {
                    [[[talkSessionViewController getTalkSession].chatTableView cellForRowAtIndexPath:_indexPath] setBackgroundColor:_color];
                }
            }
        }
        
        [talkSessionViewController getTalkSession].editIndexPath = nil;
    }
}

-(void)delete:(id)sender
{
    PublicServiceDAO *_psDAO = [PublicServiceDAO getDatabase];
    if([talkSessionViewController getTalkSession].editIndexPath)
    {
        id _id = [[talkSessionViewController getTalkSession].convRecordArray objectAtIndex:[talkSessionViewController getTalkSession].editIndexPath.section - 1];
        if([_id isKindOfClass:[ConvRecord class]])
        {
            ServiceMessage *serviceMessage = [[[ServiceMessage alloc]init]autorelease];
            ConvRecord *_convRecord = (ConvRecord *)_id;
            if (_convRecord.msg_type == type_pic) {
                serviceMessage.msgType = ps_msg_type_pic;
            }
            else
            {
                serviceMessage.msgType = ps_msg_type_text;
            }
            serviceMessage.msgId = ((ConvRecord*)_id).msgId;
            serviceMessage.serviceId = _convRecord.conv_id.intValue;
            [_psDAO deleteServiceMessage:serviceMessage];
        }
        else
        {
            ServiceMessage *serviceMessage = [[talkSessionViewController getTalkSession].convRecordArray objectAtIndex:([talkSessionViewController getTalkSession].editIndexPath.section - 1)];
            [_psDAO deleteServiceMessage:serviceMessage];
        }
        
        [[talkSessionViewController getTalkSession].convRecordArray removeObjectAtIndex:([talkSessionViewController getTalkSession].editIndexPath.section - 1)];
        [[talkSessionViewController getTalkSession].chatTableView beginUpdates];
        [[talkSessionViewController getTalkSession].chatTableView deleteSections:[NSIndexSet indexSetWithIndex:[talkSessionViewController getTalkSession].editIndexPath.section] withRowAnimation:UITableViewRowAnimationNone];
        [[talkSessionViewController getTalkSession].chatTableView endUpdates];
        [talkSessionViewController getTalkSession].editIndexPath = nil;
    }
}
- (void)copy:(id)sender
{
    if([talkSessionViewController getTalkSession].editIndexPath)
    {
        ConvRecord *_convRecord = [[talkSessionViewController getTalkSession].convRecordArray objectAtIndex:[talkSessionViewController getTalkSession].editIndexPath.section - 1];
        if(_convRecord.msg_type == ps_msg_type_text)
        {
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            [pasteboard setString:_convRecord.msg_body];
        }
    }
}

#pragma mark ===发送消息===
-(void)sendPSMessage
{
    conn *_conn = [conn getConn];
    PublicServiceDAO *_psDAO = [PublicServiceDAO getDatabase];
    
    NSCharacterSet *whitespace = [NSCharacterSet  whitespaceAndNewlineCharacterSet];
    NSString *inputMsg = [talkSessionViewController getTalkSession].messageTextField.text;
    inputMsg = [inputMsg stringByTrimmingCharactersInSet:whitespace];
    if(inputMsg.length == 0 )
        return;

    ServiceMessage *message = [[ServiceMessage alloc]init];
    message.msgBody = inputMsg;
    message.msgFlag = send_msg;
    message.msgTime = [_conn getCurrentTime];
    message.msgType = ps_msg_type_text;
    message.serviceId = [talkSessionViewController getTalkSession].serviceModel.serviceId;
    message.sendFlag = sending;
    
    bool result = [_psDAO saveServiceMessage:message];
    if(result)
    {
        //		[LogUtil debug:[NSString stringWithFormat:@"%s,%d",__FUNCTION__,message.msgId]];
        ConvRecord *_convRecord = [[ConvRecord alloc]init];
        [_psDAO convertServiceMessage:message toConvRecord:_convRecord];
        [[talkSessionViewController getTalkSession].convRecordArray addObject:_convRecord];
        [talkSessionUtil setPropertyOfConvRecord:_convRecord];
        [self setTimeDisplay:_convRecord andIndex:[talkSessionViewController getTalkSession].convRecordArray.count - 1];
        [[talkSessionViewController getTalkSession].chatTableView reloadData];
        [self scrollToEnd];
        
        //消息修改发送状态
        BOOL sendResult = [_conn sendPSMsg:message];
        
        if (sendResult) {
            _convRecord.send_flag = send_success;
            message.sendFlag = send_success;
        }
        else{
            _convRecord.send_flag = send_upload_fail;
            message.sendFlag = send_upload_fail;
        }
        
        [_psDAO updateSendFlagOfServiceMessage:message];
        
        [_convRecord release];
        
        [talkSessionViewController getTalkSession].messageTextField.text = @" ";
    }
    
    
    [message release];
}

#pragma mark 确定本条记录是否显示时间
-(void)setTimeDisplay:(ConvRecord*)record  andIndex:(int)_index
{
    if(_index == 0)
    {
        record.isTimeDisplay = true;
        return;
    }
    
    bool isDisplay = true;
    
    int lastDisplayMsgIndex = [self getLastDisplayTimeMsg:_index];
    
    id _id = [[talkSessionViewController getTalkSession].convRecordArray objectAtIndex:lastDisplayMsgIndex];
    
    if([_id isKindOfClass:[ServiceMessage class]])
    {
        record.isTimeDisplay = true;
        return;
    }
    
    //			如果当前的时间和第一条的时间在3分钟之内，那么就不用显示,有两种情况，一个是小于msg_time_sec,一个是小于0，防止下面消息的显示时间比上面消息的显示时间早的情况 fabs(
    NSTimeInterval _diff = record.msg_time.intValue - ((ConvRecord*)_id).msg_time.intValue;
    
    if(_diff < 0 || (_diff >= 0 && _diff <= msg_time_sec))
    {
        isDisplay = false;
    }
    record.isTimeDisplay = isDisplay;
}

#pragma mark 找到最近的一条显示时间的消息，从_index开始向前找
-(int)getLastDisplayTimeMsg:(int)_index
{
    for(int i= _index;i>=0;i--)
    {
        id _id = [[talkSessionViewController getTalkSession].convRecordArray objectAtIndex:i];
        if([_id isKindOfClass:[ServiceMessage class]])
        {
            return i;
        }
        else
        {
            if(((ConvRecord*)_id).isTimeDisplay)
            {
                return i;
            }
        }
    }
    return 0;
}

//保存录音和图片类型的消息到数据库
-(BOOL)saveMediaPsMsg:(int)iMsgType message:(NSString *)messageStr filesize:(int)fsize filename:(NSString *)fname
{
    return NO;
    
    int msgType = 0;
    if (iMsgType == type_record) {
        msgType = ps_msg_type_record;
    }
    else if (iMsgType == type_pic)
    {
        msgType = ps_msg_type_pic;
    }else{
        return NO;
    }
    
    conn *_conn = [conn getConn];
    PublicServiceDAO *_psDAO = [PublicServiceDAO getDatabase];
    
    ServiceMessage *message = [[ServiceMessage alloc]init];
    message.msgBody = messageStr;
    message.msgFlag = send_msg;
    message.msgTime = [_conn getCurrentTime];
    message.msgType = msgType;
    message.serviceId = [talkSessionViewController getTalkSession].serviceModel.serviceId;
    message.sendFlag = send_success;// send_uploading;
    message.fileSize = fsize;
//    把文件名字 保存到msgurl列中
    message.msgUrl = fname;
    
    bool result = [_psDAO saveServiceMessage:message];
    if(result)
    {
        //		[LogUtil debug:[NSString stringWithFormat:@"%s,%d",__FUNCTION__,message.msgId]];
        ConvRecord *_convRecord = [[ConvRecord alloc]init];
        [_psDAO convertServiceMessage:message toConvRecord:_convRecord];
        [[talkSessionViewController getTalkSession].convRecordArray addObject:_convRecord];
        [self setTimeDisplay:_convRecord andIndex:[talkSessionViewController getTalkSession].convRecordArray.count - 1];
        [[talkSessionViewController getTalkSession].chatTableView reloadData];
        [self scrollToEnd];
//        [[talkSessionViewController getTalkSession]prepareUploadFileWithFileRecord:_convRecord];
        
//        //消息修改发送状态
//        BOOL sendResult = [_conn sendPSMsg:message];
//        
//        if (sendResult) {
//            _convRecord.send_flag = send_success;
//            message.sendFlag = send_success;
//        }
//        else{
//            _convRecord.send_flag = send_upload_fail;
//            message.sendFlag = send_upload_fail;
//        }
//        
//        [_psDAO updateSendFlagOfServiceMessage:message];
        
        [_convRecord release];
    }
    [message release];
    return YES;
}

//实现在会话列表界面 可以点击小图 查看大图功能
- (NSString *)getPSMsgImageUrl:(ConvRecord *)convRecord
{
    NSMutableString *mStr = [[NSMutableString alloc]init];
    [mStr appendString:public_service_message_flag];
    [mStr appendString:[NSString stringWithFormat:@"|%@",convRecord.conv_id]];
    [mStr appendString:[NSString stringWithFormat:@"|%d",convRecord.msgId]];
    [mStr appendString:[NSString stringWithFormat:@"|%@",convRecord.msg_body]];
     return [mStr autorelease];
}

//根据url，得到对应的serviceid msgid url等，方便下载
- (ConvRecord *)getConvRecordFromPSMsgImgUrl:(NSString *)imageUrl
{
    if (imageUrl && imageUrl.length > 0) {
        NSArray *strArray = [imageUrl componentsSeparatedByString:@"|"];
        if (strArray.count == 4) {
            ConvRecord *_convRecord = [[[ConvRecord alloc]init]autorelease];
            _convRecord.conv_id = strArray[1];
            _convRecord.msgId = [strArray[2] intValue];
            _convRecord.msg_body = strArray[3];
            return _convRecord;
        }
    }
    return nil;
}

#pragma mark ====上传图片语音时msgid要特殊处理，否则无法区分是否为 服务号 上传====
- (NSString *)getRealMsgIdByMsgId:(NSString *)msgId
{
    NSArray *temp = [msgId componentsSeparatedByString:@"_"];
    if (temp.count == 3) {
        NSString *msgId = temp[2];
        return msgId;
    }
    return nil;
}

- (NSString *)getServiceIdByMsgId:(NSString *)msgId
{
    NSArray *temp = [msgId componentsSeparatedByString:@"_"];
    if (temp.count == 3) {
        NSString *serviceId = temp[1];
        return serviceId;
    }
    return nil;
}

- (NSString *)createCustomMsgId:(ConvRecord *)_convRecord
{
    NSString *customMsgId = [NSString stringWithFormat:@"%@_%@_%d",public_service_message_flag,_convRecord.conv_id,_convRecord.msgId];
    return customMsgId;
}

#pragma mark =====文件上传成功========

#pragma mark =====文件上传失败=======

@end
