//
//  talkSessionUtil.m
//  eCloud
//
//  Created by Richard on 13-10-4.
//  Copyright (c) 2013年  lyong. All rights reserved.
//

#import "talkSessionUtil.h"
#import "RedpacketMessageCell.h"

#import "GroupInfoMsgCell.h"
#import "NormalTextMsgCell.h"
#import "FaceTextMsgCell.h"
#import "LinkTextMsgCell.h"
#import "AudioMsgCell.h"
#import "VideoMsgCell.h"
#import "LocationMsgCell.h"

#import "NotificationUtil.h"
#import "WXReplyToOneMsgCellTableViewCellArc.h"
#import "ReplyOneMsgModelArc.h"
#import "PicMsgCell.h"
#import "NewImgTxtMsgCell.h"
#import "RobotUtil.h"
#import "RobotFileUtil.h"
#import "ConvRecord.h"

#import "JSONKit.h"
#import "LocationModel.h"
#import "LocationMsgUtil.h"
#import "MiLiaoUtilArc.h"
#ifdef _XINHUA_FLAG_
#import "SystemMsgModelArc.h"
#endif

#import "UITableViewCell+getCellContentWidth.h"

#import "PSMsgUtil.h"
#import "EncryptFileManege.h"

#import "TextMessageView.h"
#import "MessageView.h"
#import "TextLinkView.h"
#import "OHAttributedLabelEx.h"
#import "eCloudDAO.h"
#import "UIProgressLabel.h"
#import "eCloudDefine.h"
#import "ReceiptDAO.h"
#import "UserDisplayUtil.h"

#import "FontSizeUtil.h"
#import "WXReplyOneMsgUtil.h"

#import "ParentMsgCell.h"
#import "IrregularView.h"

#import "ImageUtil.h"

#import "StringUtil.h"
#import "NewFileMsgCell.h"

#import "FileAssistantDOA.h"
#import "DownloadFileModel.h"
#import "UserDefaults.h"
#import "talkSessionUtil2.h"
#import "LanUtil.h"
#import "UIAdapterUtil.h"
#import "RobotDAO.h"
#import "DisplayImgtxtTableView.h"
#import "RobotResponseXmlParser.h"
#import "StringUtil.h"
#import "CloudFileModel.h"

#ifdef _LANGUANG_FLAG_
#import "RedPacketModelArc.h"
#import "RedpacketMessageCell.h"
#import "RedpacketConfig.h"
#import "RedpacketTakenMessageTipCell.h"
#import "LANGUANGAppMsgModelARC.h"
#import "LGNewsMdelARC.h"
#import "LGNewsCellARC.h"
#endif

#if defined(_HUAXIA_FLAG_)
#import "HuaXiaUserInterfaceDefine.h"
#endif

#ifdef _TAIHE_FLAG_
#import "TAIHEAppMsgModel.h"
#endif

@implementation talkSessionUtil
@synthesize custom_font_size;

#pragma mark -
#pragma mark --显示一条消息需要的所有的UI控件--
+ (UITableViewCell *)tableViewCellWithReuseIdentifier:(NSString *)identifier
{
	MessageView *messageView = [MessageView getMessageView];
	
	ParentMsgCell *cell = [[[ParentMsgCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	cell.opaque = YES;
	
#pragma mark --消息时间--
	UIEdgeInsets capInsets = UIEdgeInsetsMake(7,5,7,5);
	UIImageView *dateBg = [[UIImageView alloc] initWithImage:[messageView resizeImageWithCapInsets:capInsets andImage:[StringUtil getImageByResName:@"date_bg.png"]]];
	
	dateBg.tag = time_tag;
	
	UILabel *timelabel=[[UILabel alloc]initWithFrame:CGRectZero];
	timelabel.backgroundColor= [UIColor colorWithRed:204 green:204 blue:204 alpha:0];
	timelabel.font=[UIFont systemFontOfSize:time_font_size];
	timelabel.textAlignment = NSTextAlignmentCenter;
	timelabel.textColor = [UIColor whiteColor];
	timelabel.tag = time_text_tag;
	
	[dateBg addSubview:timelabel];
	[timelabel release];
	
	[cell.contentView addSubview:dateBg];
	[dateBg release];
	
#pragma mark --头像--
	//	用户头像
	UIImageView *headImageView =  [UserDisplayUtil getUserLogoView];//[[UIImageView alloc]initWithFrame:CGRectZero];
	headImageView.userInteractionEnabled = YES;
	headImageView.tag = head_tag;
	
	UILabel *namelabel=[[UILabel alloc]initWithFrame:CGRectMake(0, chat_user_logo_size, chat_user_logo_size, 20)];
	namelabel.hidden = YES;
	namelabel.tag = head_empName_tag;
	namelabel.backgroundColor=[UIColor colorWithRed:241 green:241 blue:239 alpha:0];
	namelabel.font=[UIFont boldSystemFontOfSize:12];
	namelabel.textAlignment=UITextAlignmentCenter;
	[headImageView addSubview:namelabel];
	[namelabel release];
	
	[cell.contentView addSubview:headImageView];
//	[headImageView release];
	
#pragma mark --状态--
	UIView *statusView = [[UIView alloc]initWithFrame:CGRectZero];
	statusView.tag = status_tag;
	
	// 消息发送失败的按钮
	UIButton *failView=[[UIButton alloc]init];
	[failView setImage:[StringUtil getImageByResName:@"send_msg_fail.png"] forState:UIControlStateNormal];
	[failView setImage:[StringUtil getImageByResName:@"send_msg_fail.png"] forState:UIControlStateSelected];
	[failView setImage:[StringUtil getImageByResName:@"send_msg_fail.png"] forState:UIControlStateHighlighted];
	failView.tag = status_failBtn_tag;
	failView.hidden = YES;
	[statusView addSubview:failView];
	[failView release];
	
	// 发送录音时需要一个view，提示用户正在上传录音
	//		现在是发送图片，录音和文字都需要上传提示
	
	UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	spinner.tag = status_spinner_tag;
	[statusView addSubview:spinner];
	[spinner release];
	
	//		在这里需要判断，如果是收到的录音消息，那么需要判断，是否显示未读标志
	UIImageView *redimage=[[UIImageView alloc]initWithFrame:CGRectMake(10, 16, 8, 8)];
	redimage.hidden=YES;
	redimage.tag=status_audio_tag;
	redimage.image=[StringUtil getImageByResName:@"new_msg_icon.png"];
	[statusView addSubview:redimage];
	[redimage release];
	
	[cell.contentView addSubview:statusView];
	[statusView release];
	
#pragma mark --发送消息气泡--
	UIImageView *bubbleImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
	bubbleImageView.tag=bubble_send_tag;
	bubbleImageView.userInteractionEnabled = YES;
	//	自己和联系人采用不同的气泡图片
	UIImage *bubble = [StringUtil getImageByResName:@"bubbleSelf.png"];
    UIImage *bubbleHighlighted = [StringUtil getImageByResName:@"bubbleSelfDown.png"];
	
	capInsets = UIEdgeInsetsMake(30,22,9,22);
	bubbleImageView.image = [messageView resizeImageWithCapInsets:capInsets andImage:bubble];
	bubbleImageView.highlightedImage = [messageView resizeImageWithCapInsets:capInsets andImage:bubbleHighlighted];
	
	[cell.contentView addSubview:bubbleImageView];
	
	[bubbleImageView release];
	
#pragma mark --接收消息气泡--
	bubbleImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
	bubbleImageView.tag=bubble_rcv_tag;
	bubbleImageView.userInteractionEnabled = YES;
	//	自己和联系人采用不同的气泡图片
	bubble = [StringUtil getImageByResName:@"bubble.png"];
    bubbleHighlighted = [StringUtil getImageByResName:@"bubbleDown.png"];
	
	capInsets = UIEdgeInsetsMake(30,22,9,22);
	bubbleImageView.image = [messageView resizeImageWithCapInsets:capInsets andImage:bubble];
	bubbleImageView.highlightedImage = [messageView resizeImageWithCapInsets:capInsets andImage:bubbleHighlighted];
	
	[cell.contentView addSubview:bubbleImageView];
	
	[bubbleImageView release];
	
#pragma mark --消息内容--
	UIView *contentView = [[UIView alloc]initWithFrame:CGRectZero];
	contentView.userInteractionEnabled = YES;
	contentView.tag = body_tag;

#pragma mark --文件类型消息--
	UIView *fileView = [[UIView alloc]initWithFrame:CGRectZero];
	fileView.tag = file_tag;
	
//	文件对应的图片
	UIImageView *filePicView = [[UIImageView alloc]initWithFrame:CGRectZero];
	filePicView.contentMode=UIViewContentModeScaleAspectFit;
	filePicView.tag = file_pic_tag;
	[fileView addSubview:filePicView];
	[filePicView release];

//	显示文件下载进度
	UILabel *progressLabel = [[UILabel alloc]initWithFrame:CGRectZero];
	progressLabel.backgroundColor = [UIColor clearColor];
//	progressLabel.textColor = [UIColor whiteColor];
	progressLabel.textAlignment = UITextAlignmentCenter;
	progressLabel.tag = file_progress_tag;
	progressLabel.font = [UIFont systemFontOfSize:message_font];
	[filePicView addSubview:progressLabel];
	[progressLabel release];
	

//	文件名称和大小，和分组通知的文字大小一致
	UILabel *fileNameLabel = [[UILabel alloc]initWithFrame:CGRectZero];
	fileNameLabel.lineBreakMode = UILineBreakModeMiddleTruncation;
	fileNameLabel.font = [UIFont systemFontOfSize:time_font_size];
	fileNameLabel.textColor = [UIColor whiteColor];
	fileNameLabel.textAlignment = UITextAlignmentCenter;
//	CGFloat R  = (CGFloat) 0/255.0;
//    CGFloat G = (CGFloat) 66/255.0;
//    CGFloat B = (CGFloat) 88/255.0;
//    CGFloat alpha = (CGFloat) 0.5;
	fileNameLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
	fileNameLabel.tag = file_name_tag;
	[fileView addSubview:fileNameLabel];
	[fileNameLabel release];
	
	[contentView addSubview:fileView];
	[fileView release];
	
#pragma mark --图片消息--
	IrregularView *showPicView=[[IrregularView alloc]initWithFrame:CGRectZero];
	showPicView.tag = pic_tag;
    showPicView.contentMode=UIViewContentModeScaleAspectFit;
	
	//	进度条View
    UIProgressView *progressCell=[[UIProgressView alloc]initWithFrame:CGRectZero];
	progressCell.progress=0;
    progressCell.tag=pic_progress_tag;
    [showPicView addSubview:progressCell];
    [progressCell release];
	
	[contentView addSubview:showPicView];
	
	[showPicView release];
	
#pragma mark --录音消息--
	UIButton *clickbutton=[[UIButton alloc]initWithFrame:CGRectZero];
    clickbutton.tag=audio_tag;

  	UIImageView *buttonimage=[[UIImageView alloc]initWithFrame:CGRectZero];
    buttonimage.tag=audio_playImageView_tag;
	
	UILabel *timeSecond = [[UILabel alloc]initWithFrame:CGRectZero];
	timeSecond.backgroundColor=[UIColor colorWithRed:178 green:225 blue:69 alpha:0];;
	timeSecond.font=[UIFont systemFontOfSize:16];
	timeSecond.tag = audio_second_tag;
    [clickbutton addSubview:buttonimage];
    [buttonimage release];
	
    [clickbutton addSubview:timeSecond];
    [timeSecond release];
	
	[contentView addSubview:clickbutton];
	[clickbutton release];
	
#pragma mark --不带超链接一般文本消息--
	UILabel *normalTextView = [[UILabel alloc]initWithFrame:CGRectZero];
	normalTextView.font = [UIFont systemFontOfSize:message_font];
	normalTextView.numberOfLines = 0;
	normalTextView.backgroundColor = [UIColor clearColor];
	normalTextView.tag = normal_text_tag;
	[contentView addSubview:normalTextView];
	[normalTextView release];

#pragma mark --不带超链接图文混合消息--
	TextMessageView *textPicView = [[TextMessageView alloc]initWithFrame:CGRectZero];
	textPicView.maxWidth = MAX_WIDTH;
	textPicView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	textPicView.tag = nolink_text_pic_tag;
	[contentView addSubview:textPicView];
	[textPicView release];
	
#pragma mark --带超链接的文本消息--
	TextLinkView *linkView=[[TextLinkView alloc]initWithFrame:CGRectZero];
	linkView.tag = link_text_tag;
	[contentView addSubview:linkView];
	[linkView release];
	
	[cell.contentView addSubview:contentView];
	[contentView release];
	
	
#pragma mark --群组变化通知--
	UIEdgeInsets _capInsets = UIEdgeInsetsMake(7,5,7,5);
	UIImageView *groupInfoBg = [[UIImageView alloc] initWithImage:[messageView resizeImageWithCapInsets:_capInsets andImage:[StringUtil getImageByResName:@"date_bg.png"]]];
	
	groupInfoBg.tag = groupinfo_tag;
	
	UILabel *groupInfolabel=[[UILabel alloc]initWithFrame:CGRectZero];
	groupInfolabel.numberOfLines =  0;
	groupInfolabel.lineBreakMode = NSLineBreakByWordWrapping;
	groupInfolabel.backgroundColor=[UIColor colorWithRed:204 green:204 blue:204 alpha:0];
	groupInfolabel.font=[UIFont systemFontOfSize:groupInfo_font_size];
	groupInfolabel.textColor = [UIColor whiteColor];
	groupInfolabel.tag = groupinfo_text_tag;
	[groupInfoBg addSubview:groupInfolabel];
	[groupInfolabel release];
	
	[cell.contentView addSubview:groupInfoBg];
	
	[groupInfoBg release];
	
#pragma mark --一呼百应消息--
	UIEdgeInsets receipt_capInsets = UIEdgeInsetsMake(7,5,7,5);
	UIImageView *receiptBg = [[UIImageView alloc] initWithImage:[messageView resizeImageWithCapInsets:receipt_capInsets andImage:[StringUtil getImageByResName:@"date_bg.png"]]];
	receiptBg.tag = receipt_tag;
	
	UILabel *receiptLabel=[[UILabel alloc]initWithFrame:CGRectZero];
	receiptLabel.textAlignment = NSTextAlignmentCenter;
	receiptLabel.backgroundColor = [UIColor clearColor];
	receiptLabel.font=[UIFont systemFontOfSize:time_font_size];
	receiptLabel.textColor = [UIColor whiteColor];
	receiptLabel.tag = receipt_text_tag;
	[receiptBg addSubview:receiptLabel];
	[receiptLabel release];
	
	[cell.contentView addSubview:receiptBg];
	
	[receiptBg release];
	
	return cell;
}

#pragma mark --一条消息所占的height--
+(float)getMsgBodyHeight:(ConvRecord*)_convRecord
{
    BOOL isNeedNewHeight = NO;
    CGFloat newHeight = 0;
    if (_convRecord.isTextMsg) {
        if (_convRecord.locationModel) {
            newHeight = [LocationMsgCell getMsgHeight:_convRecord];
            return newHeight;
        }else if (_convRecord.cloudFileModel){
            //                [self getclounfileMsgSize:_convRecord];
            //                return;
            
        }else if (_convRecord.isRobotImgTxtMsg){
        }else if (_convRecord.isRobotFileMsg){
        }else if(_convRecord.redPacketModel){   // 红包消息
            
            newHeight = [self getRedPicketMsgSize:_convRecord];
            isNeedNewHeight = YES;
            return newHeight;
            
        }else if (_convRecord.newsModel){
            
            newHeight = [LGNewsCellARC getMsgHeight:_convRecord];
            isNeedNewHeight = YES;
            return newHeight;
        }
        else if (_convRecord.replyOneMsgModel){
            isNeedNewHeight = YES;
            newHeight = [WXReplyToOneMsgCellTableViewCellArc getMsgHeight:_convRecord];
        }
        else{
            if(_convRecord.isLinkText)
            {
                newHeight = [LinkTextMsgCell getMsgHeight:_convRecord];
                isNeedNewHeight = YES;
            }
            else
            {
                if(_convRecord.isTextPic)
                {
                    newHeight = [FaceTextMsgCell getMsgHeight:_convRecord];
                    isNeedNewHeight = YES;
                }
                else
                {
                    newHeight = [NormalTextMsgCell getMsgHeight:_convRecord];
                    isNeedNewHeight = YES;
                }
            }
        }
    }else if (_convRecord.isLongMsg){
        newHeight = [NormalTextMsgCell getLongMsgHeight:_convRecord];
        isNeedNewHeight = YES;
    }else if (_convRecord.isPicMsg){
        newHeight = [PicMsgCell getMsgHeight:_convRecord];
        isNeedNewHeight = YES;
    }else if (_convRecord.isRecordMsg){
        newHeight = [AudioMsgCell getMsgHeight:_convRecord];
        isNeedNewHeight = YES;
    }else if (_convRecord.isVideoMsg){
        newHeight = [VideoMsgCell getMsgHeight:_convRecord];
        isNeedNewHeight = YES;
    }else if (_convRecord.isFileMsg){
        newHeight = [NewFileMsgCell getMsgHeight:_convRecord];
        isNeedNewHeight = YES;
    }
    
    // 是否为回执消息
    if (isNeedNewHeight) {
//        if (_convRecord.isHuizhiMsg) {
//            float receiptTipsHeight = [self getReceiptTipsHeight:_convRecord];
//            return dateBgHeight + bubbleHeight + 20 + receiptTipsHeight + MSG_TO_MSG;
//        }
        return newHeight;
    }
    
    //	内容
    int msgType = _convRecord.msg_type;
    
 	//	时间
	float dateBgHeight = [self getTimeHeight:_convRecord];
	
	switch (msgType) {
		case type_group_info:
		{
            return [GroupInfoMsgCell getGroupInfoSize:_convRecord];
//			[self getGroupInfoSize:_convRecord];
//            return dateBgHeight + _convRecord.msgSize.height;// + 25 + MSG_TO_MSG;
		}
			break;
		case type_text:
		{
#ifdef _LANGUANG_FLAG_
            if ([_convRecord.redPacketModel.type isEqualToString:@"redPacketAction"]) {
                
                return [RedpacketTakenMessageTipCell heightForRedpacketMessageTipCell];
            }
#endif
            [self getTextMsgSize:_convRecord];
		}
			break;
		case type_file:
		{
			[self getFileMsgSize:_convRecord];
		}
			break;
		case type_pic:
		{
			[self getPicMsgSize:_convRecord];
		}
			break;
        case type_video:
        {
            [self getVideoMsgSize:_convRecord];
        }
            break;
		case type_record:
		{
			[self getAudioMsgSize:_convRecord];
		}
			break;
		case type_long_msg:
		{
			[self getLongMsgSize:_convRecord];
		}
			break;
        case type_imgtxt:
        {
            [self getImgtxtMsgSize:_convRecord];
        }
            break;
        case type_wiki:
        {
            [self getWikiMsgSize:_convRecord];
        }
            break;
			
		default:
			break;
	}
	
	float bodyHeight = _convRecord.msgSize.height;
	
	float bubbleHeight = bodyHeight + 20;
	
	//	如果气泡的高度比头像的高度小
	if(bubbleHeight < min_height)
	{
		bubbleHeight = min_height;
	}

	if(msgType == type_record)
	{
		bubbleHeight = bodyHeight;
	}
	
    bool fromSelf = true;
    if(_convRecord.msg_flag == rcv_msg)
    {
        fromSelf = false;
    }
    
    //微调各类消息间距
    if(_convRecord.isFileMsg || _convRecord.cloudFileModel || _convRecord.isRobotFileMsg){
        if (fromSelf) {
            bubbleHeight -= 1.0;
        }
        else{
            bubbleHeight += 20.0;
        }
    }
    else if (_convRecord.isPicMsg || _convRecord.isRobotPicMsg){
        if (fromSelf) {
            bubbleHeight -= 11.0;
        }
        else{
            bubbleHeight += 6.0;
        }
    }
    else if (msgType == type_record){
        if (fromSelf) {
            bubbleHeight += 4.0;
        }
        else{
            bubbleHeight += 20.0;
        }
    }
    else if (msgType == type_text){
        if (!fromSelf) {
            bubbleHeight += 18.0;
        }
    }
    else if (msgType == type_long_msg){
        if (fromSelf) {
            bubbleHeight += 6.0;
        }
        else{
            bubbleHeight += 24.0;
        }
    }
    else if (msgType == type_imgtxt){
        if (!fromSelf) {
            bubbleHeight += 18.0;
        }
    }
    else if (msgType == type_wiki){
        if (!fromSelf) {
            bubbleHeight += 18.0;
        }
    }
    
	if(_convRecord.recordType == ps_conv_record_type)
	{
		return dateBgHeight + bubbleHeight + 10;
	}
	else
	{
		float receiptTipsHeight = [self getReceiptTipsHeight:_convRecord];
		return dateBgHeight + bubbleHeight + 20 + receiptTipsHeight + MSG_TO_MSG;
	}
}

#pragma mark --消息时间所占height--
+(float)getTimeHeight:(ConvRecord*)_convRecord
{
	//	时间
	float dateBgHeight = 0;
	if(_convRecord.isTimeDisplay)
	{
		NSString *msgTime = _convRecord.msg_time;
		CGSize size = [msgTime sizeWithFont:[UIFont systemFontOfSize:msg_time_font_size]];
		
		//	时间的宽度和高度
		float labelHeight = size.height;
		//		时间的背景与时间label之间有空隙，上下分别有3个像素
		dateBgHeight = labelHeight + msg_time_vertical_space * 2 + msg_time_to_msg_body_space;
	}
	return dateBgHeight;
}

#pragma mark --文本消息的size--
+(void)getTextMsgSize:(ConvRecord*)_convRecord
{
    if (_convRecord.locationModel) {
        [self getLocationMsgSize:_convRecord];
        return;
    }
    if (_convRecord.cloudFileModel) {
        [self getclounfileMsgSize:_convRecord];
        return;
    }
#ifdef _XINHUA_FLAG_
    if (_convRecord.systemMsgModel)
    {
        if ([_convRecord.systemMsgModel.msgType isEqual:TYPE_PIC]) {
            [self getRobotPicSize:_convRecord];
            return;
        }
        else if ([_convRecord.systemMsgModel.msgType isEqualToString:TYPE_NEWS])
        {
            CGSize size = [self getSizeOfTextMsg:_convRecord.systemMsgModel.title withFont:[UIFont systemFontOfSize:imgtxt_title_font_size] withMaxWidth:MAX_WIDTH];
            CGFloat height = (size.height > 21)?100:82;
            _convRecord.msgSize = CGSizeMake(MAX_WIDTH, height);
            return;
        }
        else if ([_convRecord.systemMsgModel.msgType isEqualToString:TYPE_VIDEO])
        {
            _convRecord.msgSize = CGSizeMake(133, 164);
            return;
        }
        else if ([_convRecord.systemMsgModel.msgType isEqualToString:TYPE_VOICE])
        {
            _convRecord.msgSize = CGSizeMake(60, 25);
            return;
        }
        else
        {
            [self getSystemMsgSize:_convRecord];
            return;
        }
    }
#endif
#ifdef _LANGUANG_FLAG_
    if (_convRecord.redPacketModel) {
        
        [self getRedPicketMsgSize:_convRecord];
        return;
    }
//    if (_convRecord.newsModel) {
//        
//        CGSize size;
//        size.width = 247;
//        size.height = 50;
//        _convRecord.msgSize = size;
//        return;
//    }
#endif
    if (_convRecord.replyOneMsgModel){
        [WXReplyToOneMsgCellTableViewCellArc getReplyToOneMsgSize:_convRecord];
        return;
    }
    if (_convRecord.isRobotImgTxtMsg) {
        _convRecord.msgSize = CGSizeMake(MAX_WIDTH, new_imgtxt_total_hegiht);
        return;
    }
    if (_convRecord.isRobotFileMsg) {
//        走文件cell的size计算方式
        [self getFileMsgSize:_convRecord];
        return;
    }
    if (_convRecord.isRobotPicMsg){
        [self getRobotPicSize:_convRecord];
        return;
    }
        

	float maxWidth = MAX_WIDTH;
	if(_convRecord.recordType == mass_conv_record_type)
	{
		maxWidth = [UIAdapterUtil getTableCellContentWidth] - 40;
	}
	MessageView *messageView = [MessageView getMessageView];
	//		消息内容，消息size
	NSString *messageStr = _convRecord.msg_body;
	if(_convRecord.isLinkText)
	{
        TextLinkView *linkView=[[TextLinkView alloc]initWithFrame:CGRectZero];
		linkView.textWidth=maxWidth;
        linkView.textstr=messageStr;
        _convRecord.msgSize=[linkView getViewSize];
        [linkView release];
//		_convRecord.msgSize = [OHAttributedLabelEx heightWithText:messageStr font:[UIFont systemFontOfSize:16] maxWidth:MAX_WIDTH];
//        NSLog(@"msgSize %f  %f",_convRecord.msgSize.width,_convRecord.msgSize.height);
	}
	else
	{
		if(_convRecord.isTextPic)
		{
//			NSMutableArray *data = [NSMutableArray array];
//			//	把文字和表情分开
//			[messageView getImageRange:messageStr:data];
//			//		计算size
//			CGSize messageViewSize = [messageView getTextMessageViewSize:data andMaxWidth:maxWidth];
            CGSize messageViewSize = [messageView getTextMessageViewSize:_convRecord.textMsgArray andMaxWidth:maxWidth];
			_convRecord.msgSize = messageViewSize;
			
		}
		else
		{
            _convRecord.msgSize = [self getSizeOfTextMsg:messageStr withFont:[UIFont systemFontOfSize:[FontSizeUtil getFontSize]] withMaxWidth:maxWidth];
		}
	}
    
//    if (_convRecord.isTextPic) {
//        NSLog(@"%s msgbody is %@ msgSize is %@",__FUNCTION__,messageStr,NSStringFromCGSize(_convRecord.msgSize));
//    }
}
#pragma mark --文件消息的size--
+(void)getFileMsgSize:(ConvRecord*)_convRecord
{
//把图片的尺寸和显示文本的尺寸进行比较，去比较大的
	UIImage *img;
//	if(_convRecord.isFileExists)
//	{
////		img = [UIImage imageWithContentsOfFile:[StringUtil getResPath:@"file_pic_exist" andType:@"png"]];
//        img = [StringUtil getFileDefaultImage:_convRecord.file_name];
//	}
//	else
//	{
//		img = [UIImage imageWithContentsOfFile:[StringUtil getResPath:@"file_pic_not_exist" andType:@"png"]];
//	}
    
    img = [StringUtil getFileDefaultImage:_convRecord.file_name];
    
	_convRecord.imageDisplay = img;
	
	CGSize labelSize = [_convRecord.fileNameAndSize sizeWithFont:[UIFont systemFontOfSize:time_font_size]];
	if(labelSize.width > MAX_WIDTH)
	{
		labelSize.width = MAX_WIDTH;
	}
	
    if (labelSize.width < 140.0) {
        //文件消息最小长度
        labelSize.width = 140.0;
    }
	float msgWidth;
    //    国美要求的文件图标和气泡之间的间隔大，上下多了10px
	float msgHeight = img.size.height + 2 * file_cell_space;
	
    /*
	if(labelSize.width + 10 <= img.size.width)
	{
		msgWidth = img.size.width;
	}
	else
	{
		msgWidth = labelSize.width + 10;
	}
	*/
    msgWidth = [UIAdapterUtil getTableCellContentWidth] - 120;
    if (IS_IPAD) {
        msgWidth = 300;
    }
    
	_convRecord.msgSize = CGSizeMake(msgWidth, msgHeight);
}

#pragma mark -- 视频消息的size --
+(void)getVideoMsgSize:(ConvRecord *)_convRecord
{
    if (_convRecord.recordType == normal_conv_record_type || _convRecord.recordType == mass_conv_record_type) {
        // 消息内容，消息size
//        NSString *messageStr = _convRecord.msg_body;
//        NSString *videoname=[NSString stringWithFormat:@"%@.mp4",messageStr];
        NSString *videoname = _convRecord.file_name;
        NSString *videopath = [[StringUtil newRcvFilePath] stringByAppendingPathComponent:videoname];
        
        // 直接展示播放
//        AVPlayer *player=[AVPlayer playerWithURL:[NSURL URLWithString:videopath]];
//        _convRecord.avplay = player;
        
        // 获取视频缩略图
//        _convRecord.imageDisplay = [self getVideoPreViewImage:[NSURL fileURLWithPath:videopath]];
        
        // 计算视频大小
        //        CGSize _size = [MessageView getImageDisplaySize:img];
        //        float defaultframeWidth = _size.width;
        //        float defaultframeHeight = _size.height;
        
        _convRecord.msgSize = CGSizeMake(video_display_width,video_display_height);
        if (IS_IPAD) {
            
        }
    }
    else if (_convRecord.recordType == ps_conv_record_type)
    {
        // 公众号的暂时先不处理
    }
}

#pragma mark --图片消息的size--
+(void)getPicMsgSize:(ConvRecord*)_convRecord
{
    if (_convRecord.recordType == normal_conv_record_type || _convRecord.recordType == mass_conv_record_type || (_convRecord.recordType == ps_conv_record_type && _convRecord.msg_flag == send_msg)) {
        //		消息内容，消息size
        NSString *messageStr = _convRecord.msg_body;
        
        NSString *picname=[NSString stringWithFormat:@"%@.png",messageStr];
        //  [[RobotDAO getDatabase]isRobotUser:_convRecord.conv_id.intValue]
        if ([[RobotDAO getDatabase]getRobotId] == _convRecord.conv_id.intValue || [_convRecord.msg_body rangeOfString:@"imgmsg"].length > 0) {
            picname = _convRecord.file_name;
        }
        NSString *picpath = [[StringUtil newRcvFilePath] stringByAppendingPathComponent:picname];
        
        UIImage *originImg = [UIImage imageWithData:[EncryptFileManege getDataWithPath:picpath]];
        
        NSString *smallpicname=[NSString stringWithFormat:@"small%@.png",messageStr];
        // [[RobotDAO getDatabase]isRobotUser:_convRecord.conv_id.intValue]
        if ([[RobotDAO getDatabase]getRobotId] == _convRecord.conv_id.intValue || [_convRecord.msg_body rangeOfString:@"imgmsg"].length > 0) {
            smallpicname = [NSString stringWithFormat:@"small%@",_convRecord.file_name];
        }
        NSString *smallpicpath = [[StringUtil newRcvFilePath] stringByAppendingPathComponent:smallpicname];
        
        UIImage *smallimg = [UIImage imageWithData:[EncryptFileManege getDataWithPath:smallpicpath]];
        
        UIImage *img = nil;
        
        if(originImg == nil)
        {
            if (smallimg==nil) {
                img=[StringUtil getImageByResName:@"default_pic.png"];//默认图片
            }
            else
            {
                img = smallimg;
            }
        }
        else
        {
            img = originImg;
            //		如果有原图，就显示原图，不再进行判断
            //		CGSize _size = [self getImageSizeAfterCrop:img];
            //
            //		if(_size.width > 0 && _size.height > 0)
            //		{
            //			if(smallimg)
            //			{
            //				img = smallimg;
            //			}
            //		}
        }
        _convRecord.imageDisplay = img;
        
        CGSize _size = [MessageView getImageDisplaySize:img];
        float defaultframeWidth = _size.width;
        float defaultframeHeight = _size.height;
        
        _convRecord.msgSize = CGSizeMake(defaultframeWidth,defaultframeHeight);
    }
    else if (_convRecord.recordType == ps_conv_record_type && _convRecord.msg_flag == rcv_msg)
    {
//        如果是公众号图片消息，怎么取高度呢 首先找 本地是否缓存，有读缓存 否则使用默认图片
        NSString *messageStr = _convRecord.msg_body;
        
        NSString *imagePath = [PSMsgUtil getPSPicMsgImagePath:_convRecord];
        
//        UIImage *img = [UIImage imageWithContentsOfFile:imagePath];
        UIImage *img = [UIImage imageWithData:[EncryptFileManege getDataWithPath:imagePath]];
        
        if (!img) {
            img=[StringUtil getImageByResName:@"default_pic.png"];//默认图片
        }
        
        _convRecord.imageDisplay = img;
        
        CGSize _size = [MessageView getImageDisplaySize:img];
        float defaultframeWidth = _size.width;
        float defaultframeHeight = _size.height;
        
        _convRecord.msgSize = CGSizeMake(defaultframeWidth,defaultframeHeight);
    }
}

#pragma mark ----红包消息的size----
+ (CGFloat)getRedPicketMsgSize:(ConvRecord *)_convRecord
{
#ifdef _LANGUANG_FLAG_
    NSData* jsonData = [_convRecord.msg_body dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *resultDict = [jsonData objectFromJSONData];
    CGFloat height =[[RedpacketConfig sharedConfig] heightForRedpacketMessageDict:resultDict];
    
    //	时间所占高度 已经增加了时间与消息直接的分隔
    float dateBgHeight = [talkSessionUtil getTimeHeight:_convRecord];
    
    _convRecord.msgSize = CGSizeMake(196, height);
    
    //   头像和内容一起的高度
    float tempH;
    
    if (_convRecord.msg_flag == send_msg) {
        // 头像与消息体顶端对齐
        tempH = _convRecord.msgSize.height + send_msg_body_to_header_top;
    }else{
        // 多了一个头像的差值
        tempH =_convRecord.msgSize.height + rcv_msg_body_to_header_top;
    }
    if ([_convRecord.redPacketModel.type isEqualToString:@"redPacketAction"]) {
        
        return [RedpacketTakenMessageTipCell heightForRedpacketMessageTipCell];
    }
    return dateBgHeight + tempH;
    
#endif
}

#pragma mark ----位置消息的size----
+ (void)getLocationMsgSize:(ConvRecord *)_convRecord
{
    if (_convRecord.imageDisplay == nil) {
        UIImage *image = [LocationMsgUtil getLocationImage:_convRecord.locationModel];
        if (image) {
            _convRecord.imageDisplay = image;
        }
    }
    
    _convRecord.msgSize = CGSizeMake(location_pic_width, location_pic_height);
}

#pragma mark ----云文件消息的size----
+ (void)getclounfileMsgSize:(ConvRecord *)_convRecord
{
    UIImage * img = [StringUtil getFileDefaultImage:_convRecord.cloudFileModel.fileName];
    
    _convRecord.imageDisplay = img;

    float msgHeight = img.size.height;
    
    float msgWidth = [UIAdapterUtil getTableCellContentWidth] - 120;
    if (IS_IPAD) {
        msgWidth = 300;
    }
    _convRecord.msgSize = CGSizeMake(msgWidth, msgHeight);

}

#pragma mark ----系统推送消息的size----
+ (void)getSystemMsgSize:(ConvRecord *)_convRecord
{
#ifdef _XINHUA_FLAG_
    CGSize size = [self getSizeOfTextMsg:_convRecord.systemMsgModel.msgBody withFont:[UIFont systemFontOfSize:[FontSizeUtil getFontSize]] withMaxWidth:MAX_WIDTH];
    _convRecord.msgSize = size;
#endif
}
#pragma mark --录音消息的size--
+(void)getAudioMsgSize:(ConvRecord*)_convRecord
{
	int timeint=[_convRecord.file_size intValue];
	float cwidth=MIN_AUDIO_WIDTH+PER_SECOND_WIDTH*timeint;
	
	if(cwidth > MAX_AUDIO_WIDTH)
	{
		cwidth = MAX_AUDIO_WIDTH;
	}
    
    float audioHeight = single_line_height + 20;
#ifdef _LANGAUANG_FLAG_
    audioHeight = 37;
#endif
	_convRecord.msgSize = CGSizeMake(cwidth,audioHeight);
}

#pragma mark --长消息的size--
+(void)getLongMsgSize:(ConvRecord*)_convRecord
{
	//		检查长消息是否下载，如果没有下载，那么就先去下载，然后展示
	//		如果已经下载，那么就直接展示
	NSString *fileName=[NSString stringWithFormat:@"%@.txt",_convRecord.msg_body];
	NSString *filePath = [[StringUtil newRcvFilePath] stringByAppendingPathComponent:fileName];
    NSData *longMsgData = [EncryptFileManege getDataWithPath:filePath];
    NSString *longMsg = [[NSString alloc] initWithData:longMsgData encoding:NSUTF8StringEncoding];
//	NSString *longMsg = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
	if(longMsg == nil || longMsg.length == 0)
	{
		longMsg = _convRecord.file_name;
	}
	
	float maxWidth = MAX_WIDTH;
	if(_convRecord.recordType == mass_conv_record_type)
	{
		maxWidth = [UIAdapterUtil getTableCellContentWidth] - 40;
	}

    _convRecord.msgSize = [self getSizeOfTextMsg:longMsg withFont:[UIFont systemFontOfSize:[FontSizeUtil getFontSize]] withMaxWidth:maxWidth];
//	_convRecord.msgSize = [longMsg sizeWithFont:[UIFont systemFontOfSize:[FontSizeUtil getFontSize]] constrainedToSize:CGSizeMake(maxWidth,10000.0f)lineBreakMode:UILineBreakModeWordWrap];
}

#pragma mark --groupinfo的size--
+(void)getGroupInfoSize:(ConvRecord*)_convRecord
{
	//	时间相对背景的起始位置
	float labelX = 7;
	
	//	如果信息较多，则需要显示多行，一行的最大宽度是320 - 20*2 - labeX * 2
	int maxWidth = SCREEN_WIDTH - 20*2 - labelX*2;
	
    if ([[MiLiaoUtilArc getUtil]isMiLiaoConv:_convRecord.conv_id])
    {
        maxWidth = 130;
    }
    
	NSString *msgBody = _convRecord.msg_body;
    _convRecord.msgSize = [self getSizeOfTextMsg:msgBody withFont:[UIFont systemFontOfSize:[FontSizeUtil getGroupInfoFontSize]] withMaxWidth:maxWidth];
//	_convRecord.msgSize = [msgBody sizeWithFont:[UIFont systemFontOfSize:[FontSizeUtil getGroupInfoFontSize]] constrainedToSize:CGSizeMake(maxWidth, 10000.0f) lineBreakMode:UILineBreakModeWordWrap];
    
//    NSLog(@"%s,width is %.0f,height is %.0f",__FUNCTION__,_convRecord.msgSize.width,_convRecord.msgSize.height);

}

#pragma mark --一呼百应提示所占height--
+(float)getReceiptTipsHeight:(ConvRecord*)_convRecord
{
	float receiptTipsHeight = 0;
	if(_convRecord.isReceiptMsg || _convRecord.isHuizhiMsg)
	{
        if (_convRecord.isMiLiaoMsg && _convRecord.isMiLiaoMsgOpen) {
            
        }else{
            NSString *receiptTips = _convRecord.receiptTips;
            CGSize size = [receiptTips sizeWithFont:[UIFont systemFontOfSize:groupInfo_font_size]];// time_font_size]];
            
            //	时间的宽度和高度
            float labelHeight = size.height;
            //		时间的背景与时间label之间有空隙，上下分别有3个像素
            receiptTipsHeight = labelHeight + 6;
        }
	}
	return receiptTipsHeight;
}

#pragma mark --填充消息内容--
+ (void)configureCell:(UITableViewCell *)cell andConvRecord:(ConvRecord*)_convRecord 
{
	//	首先隐藏所有的元素
	[self hideView:cell.contentView];
	
	//显示时间
	[self configureTime:cell convRecord:_convRecord];
	
	//	显示头像
	[self configureHead:cell convRecord:_convRecord];
	
	//	显示消息内容
	
#pragma mark --显示消息内容--
    [self configureMsgBody:cell convRecord:_convRecord];
	//	状态
	
//	[self configureStatus:cell convRecord:_convRecord];
}

#pragma mark --隐藏所有的控件--
+(void)hideView:(UIView *)uiView
{
	for(UIView *view in uiView.subviews)
	{
		if([view isKindOfClass:[UIActivityIndicatorView class]])
		{
			continue;
		}
		if(view.tag == audio_playImageView_tag)
		{
			continue;
		}
        if(view.tag == pic_progress_tag || view.tag == file_progressview_tag || view.tag == video_progress_tag)
		{
			UIProgressView *progressView = (UIProgressView*)view;
			[self hideProgressView:progressView];
			continue;
		}
		view.hidden = YES;
		[self hideView:view];
	}
}

#pragma mark ===========================各类消息显示配置===========================
#pragma mark --显示消息时间--
+(void)configureTime:(UITableViewCell *)cell convRecord:(ConvRecord*)_convRecord
{
	if(_convRecord.isTimeDisplay)
	{
		NSString *displayMsgTime = _convRecord.msgTimeDisplay;
		CGSize size = [displayMsgTime sizeWithFont:[UIFont systemFontOfSize:msg_time_font_size]];
		
		//	时间的宽度和高度
		float labelWidth = size.width;
		float labelHeight = size.height;
		
		//	时间相对背景的起始位置
		float labelX = msg_time_horizontal_space;
		float labelY = msg_time_vertical_space;
		
		//	背景的宽度和高度
		float bgWidth = labelWidth + 2*labelX;
		float bgHeight = labelHeight + 2*labelY;
		
		//	背景的起始位置
		float bgX = ([cell getCellContentWidth] - bgWidth) / 2;
		
		UIImageView *dateBg = (UIImageView*)[cell.contentView viewWithTag:time_tag];
		dateBg.frame = CGRectMake(bgX, 0.0f, bgWidth, bgHeight );
		dateBg.hidden = NO;
		
		
		//		增加消息时间
		UILabel *timelabel= (UILabel*)[cell.contentView viewWithTag:time_text_tag];
		timelabel.text = displayMsgTime;
		timelabel.frame = CGRectMake(0, 0,bgWidth, bgHeight);
		timelabel.hidden = NO;
//		
//		[LogUtil debug:[NSString stringWithFormat:@"displayMsgTime is %@,timeLabel is %@",displayMsgTime,timelabel]];
	}
}

#pragma mark --显示头像和名称--
+(void)configureHead:(UITableViewCell *)cell convRecord:(ConvRecord*)_convRecord
{
    UIImageView *headImageView = (UIImageView *)[cell.contentView viewWithTag:head_tag];
    float logoWidth = headImageView.frame.size.width;

	MessageView *messageView = [MessageView getMessageView];
	
	int msgType = _convRecord.msg_type;
	
	if(msgType == type_group_info)
	{
		return;
	}
	
	//	设置是发送的消息，还是接收的消息
	bool fromSelf = true;
	if(_convRecord.msg_flag == rcv_msg)
	{
		fromSelf = false;
	}
	
    //  设置选择按钮的位置
    UIButton *editBtn = (UIButton *)[headImageView viewWithTag:head_edit_button_tag];
    if (_convRecord.isEdit) {
        editBtn.hidden = NO;
    }

#pragma mark --显示用户头像--
	//	头像的x值
	float headX = logo_horizontal_space;
    
    CGFloat screenW = [UIAdapterUtil getDeviceMainScreenWidth];

	if(fromSelf)
	{
        headX = screenW - logo_horizontal_space - logoWidth ;//+ 5;
	}
    
    //    如果显示了编辑按钮，那么头像向右偏移
    if (!editBtn.hidden) {
        if (_convRecord.isSelect) {
            [editBtn setImage:[StringUtil getImageByResName:@"Selection_01_ok.png"] forState:UIControlStateNormal];
        }else{
            [editBtn setImage:[StringUtil getImageByResName:@"Selection_01.png"] forState:UIControlStateNormal];
        }

        CGRect _frame = editBtn.frame;

        if (fromSelf) {
            _frame.origin.x = -(screenW - check_box_horizontal_sapce * 2 - logoWidth);
        }else{
            headX = edit_button_size + check_box_horizontal_sapce * 2;
            _frame.origin.x = - (edit_button_size + check_box_horizontal_sapce);
        }
        editBtn.frame = _frame;
    }

    
//	if(_convRecord.recordType == ps_conv_record_type)
//	{
//		headX = 0;
//		if(fromSelf)
//		{
//			headX = 300 - chat_user_logo_size;
//		}
//	}
	
	//	头像的y值
	UIImageView *dateBg = (UIImageView*)[cell.contentView viewWithTag:time_tag];
	float headY = 0;
	if(!dateBg.hidden)
	{
		headY = msg_time_to_msg_body_space + dateBg.frame.size.height;
	}
	
    UILabel *namelabel= (UILabel*)[cell.contentView viewWithTag:head_empName_tag];
    if (_convRecord.isMiLiaoMsg) {
        namelabel.text = @"";
    }else{
        namelabel.text=_convRecord.emp_name;
    }
	
//    如果是普通的聊天信息 或者 公众号发送的消息 则设置头像
    if (_convRecord.recordType == normal_conv_record_type || (_convRecord.recordType == ps_conv_record_type && _convRecord.msg_flag == send_msg)) {
        UIImageView *logoView = [UserDisplayUtil getSubLogoFromLogoView:headImageView];
        logoView.image = [self getEmpLogo:_convRecord andHeadView:headImageView];
        if ([logoView.image isEqual:default_logo_image]) {
            Emp *_emp = [[[Emp alloc]init]autorelease];
            _emp.emp_name = _convRecord.emp_name;
            NSDictionary *mDic = [UserDisplayUtil getUserDefinedLogoDicOfEmp:_emp];
            [UserDisplayUtil setUserDefinedLogo:logoView andLogoDic:mDic];
        }else{
            [UserDisplayUtil hideLogoText:logoView];
        }
       
        logoView.hidden = NO;
    }
    headImageView.contentMode = UIViewContentModeScaleToFill;
    CGRect _frame = headImageView.frame;
    _frame.origin = CGPointMake(headX, headY);
	headImageView.frame = _frame;
	headImageView.hidden = NO;
	
//	[LogUtil debug:[NSString stringWithFormat:@"%s,%.0f",__FUNCTION__, headX]];

//
//    if([LanUtil isChinese]){
//        namelabel.text=_convRecord.emp_name;
//    }else
//    {
//        namelabel.text = _convRecord.emp_name_eng;
//    }
	
	if(fromSelf)
	{
		namelabel.hidden = YES;
	}
	else
	{
		namelabel.hidden = NO;
		[UserDisplayUtil setNameColor:namelabel andEmpStatus:_convRecord.empStatus];
	}
}

#pragma mark --群组通知消息--
+(void)configureGroupInfo:(UITableViewCell *)cell convRecord:(ConvRecord*)_convRecord
{
//    NSLog(@"%s,cell.contentView is %@",__FUNCTION__,cell.contentView);
    
    BOOL isSingleLine = YES;
    if((_convRecord.msgSize.height / [UIFont systemFontOfSize:[FontSizeUtil getGroupInfoFontSize]].lineHeight) > 1)
    {
//        NSLog(@"多行消息");
        isSingleLine = NO;
    }
    
    if(isSingleLine)
    {
//        背景的宽度，x值，y值，高度都需要计算
//        label的x值为0，y值0，宽度和高度同背景
        float labelX = 0;
        float labelY = 0;
        
        NSString *msgBody = _convRecord.msg_body;
        //	时间的宽度和高度
        float labelWidth = 0;
        float labelHeight = 0;
        
        //	背景的宽度和高度
        float bgWidth = _convRecord.msgSize.width + 20;
        float bgHeight = _convRecord.msgSize.height + 10;
        
        //	背景的起始位置
        float bgX = ([cell getCellContentWidth] -20 - bgWidth) / 2;
        if(_convRecord.recordType == mass_conv_record_type)
        {
            bgX = ([cell getCellContentWidth]-40 - bgWidth) / 2;
        }
        
        float bgY = 10;
        if(_convRecord.isTimeDisplay)
        {
            UIImageView *dateBg = (UIImageView*)[cell.contentView viewWithTag:time_tag];
            bgY = msg_time_to_msg_body_space + dateBg.frame.origin.y + dateBg.frame.size.height;
        }
        
        UIImageView *groupInfoBg = (UIImageView*)[cell.contentView viewWithTag:groupinfo_tag];
        groupInfoBg.frame = CGRectMake(bgX, bgY, bgWidth, bgHeight );
        groupInfoBg.hidden = NO;
        
        
        //增加消息时间
        UILabel *grpInfoText=(UILabel*)[cell.contentView viewWithTag:groupinfo_text_tag];
        grpInfoText.font = [UIFont systemFontOfSize:[FontSizeUtil getGroupInfoFontSize]];
        grpInfoText.frame = CGRectMake(labelX, labelY,bgWidth, bgHeight);
        grpInfoText.text = msgBody;
        grpInfoText.hidden = NO;
        grpInfoText.textAlignment = NSTextAlignmentCenter;
        
//        NSLog(@"%s,groupInfoBg is %@,grpInfoText is %@",__FUNCTION__,groupInfoBg,grpInfoText);
    }
    else
    {
//        背景的宽度 背景的x值都是固定的，背景的高度，背景的y值是变化的
//        label的宽度 label相对于背景的x值，y值都是固定的，label的高度是变化的
        
        float labelX = 7;
        float labelY = 3;
        
        NSString *msgBody = _convRecord.msg_body;
        //	时间的宽度和高度
        float labelWidth = [cell getCellContentWidth] - 32.0 * 2 - labelX * 2;
        float labelHeight = _convRecord.msgSize.height;
        
        //	背景的宽度和高度
        float bgWidth = [cell getCellContentWidth] - 32.0 * 2;
        float bgHeight = labelHeight + labelY * 2;
        
        //	背景的起始位置
        float bgX = 22.0;
        if(_convRecord.recordType == mass_conv_record_type)
        {
            bgX = 0;
        }
        
        float bgY = 12.0;
        if(_convRecord.isTimeDisplay)
        {
            UIImageView *dateBg = (UIImageView*)[cell.contentView viewWithTag:time_tag];
            bgY = msg_time_to_msg_body_space + dateBg.frame.origin.y + dateBg.frame.size.height;
        }
        
        if ([[MiLiaoUtilArc getUtil]isMiLiaoConv:_convRecord.conv_id])
        {
            bgX = (SCREEN_WIDTH-140)/2.0;
            bgWidth = 140;
        }
        UIImageView *groupInfoBg = (UIImageView*)[cell.contentView viewWithTag:groupinfo_tag];
        groupInfoBg.frame = CGRectMake(bgX, bgY, bgWidth, bgHeight );
        groupInfoBg.hidden = NO;
        
        
        //		增加消息
        if ([[MiLiaoUtilArc getUtil]isMiLiaoConv:_convRecord.conv_id])
        {
            labelX = 7;
            labelWidth = 130;
        }
        
        UILabel *grpInfoText=(UILabel*)[cell.contentView viewWithTag:groupinfo_text_tag];
        grpInfoText.font = [UIFont systemFontOfSize:[FontSizeUtil getGroupInfoFontSize]];
        grpInfoText.frame = CGRectMake(labelX, labelY,labelWidth, labelHeight);
        grpInfoText.text = msgBody;
        grpInfoText.hidden = NO;
        grpInfoText.textAlignment = UITextAlignmentLeft;
        
//        NSLog(@"%s,groupInfoBg is %@,grpInfoText is %@",__FUNCTION__,groupInfoBg,grpInfoText);
    }
    
	//	时间相对背景的起始位置

}

#pragma mark --显示文本消息--
+(void)configureTextMsg:(UITableViewCell *)cell convRecord:(ConvRecord*)_convRecord
{
	float maxWidth = MAX_WIDTH;
	if(_convRecord.recordType == mass_conv_record_type)
	{
		maxWidth = [cell getCellContentWidth]-40;
	}
	MessageView *messageView = [MessageView getMessageView];

	//		消息内容，消息size
    NSString *messageStr = _convRecord.msg_body;
	
	if(_convRecord.isLinkText)
	{
		TextLinkView *linkView = (TextLinkView*)[cell.contentView viewWithTag:link_text_tag];
		linkView.textWidth = maxWidth;
		linkView.textstr = messageStr;
        if (_convRecord.msg_flag == send_msg) {
            linkView.textColor = SEND_MSG_TEXT_COLOR;
            linkView.linkTextColor = SEND_LINK_MSG_TEXT_COLOR;
        }else{
            linkView.textColor = RCV_MSG_TEXT_COLOR;
            linkView.linkTextColor = RCV_LINK_MSG_TEXT_COLOR;
        }
        [linkView getViewSize];
		[linkView updateShowContent];
		linkView.hidden = NO;
	}
	else
	{
		if(_convRecord.isTextPic)
		{
//			NSMutableArray *data = [NSMutableArray array];
//			//	把文字和表情分开
//			[messageView getImageRange:messageStr:data];
			TextMessageView* textMessageView = (TextMessageView*)[cell.contentView viewWithTag:nolink_text_pic_tag];
			textMessageView.frame = CGRectMake(0,0,_convRecord.msgSize.width,_convRecord.msgSize.height);
			textMessageView.hidden = NO;
            if (_convRecord.msg_flag == send_msg) {
                textMessageView.textColor = SEND_MSG_TEXT_COLOR;
            }else{
                textMessageView.textColor = RCV_MSG_TEXT_COLOR;
            }
			[textMessageView setMessage:_convRecord.textMsgArray];
		}
		else
		{
			UILabel *normalTextView = (UILabel*)[cell.contentView viewWithTag:normal_text_tag];
            normalTextView.font = [UIFont systemFontOfSize:[FontSizeUtil getFontSize]];
			normalTextView.frame =  CGRectMake(0,0,_convRecord.msgSize.width,_convRecord.msgSize.height);
			normalTextView.text = messageStr;
			normalTextView.hidden = NO;
            [self setTextMsgColor:normalTextView andConvRecord:_convRecord];
		}
	}
}

#pragma mark --图文的size--
+(void)getImgtxtMsgSize:(ConvRecord*)_convRecord{
    _convRecord.msgSize = CGSizeMake(SCREEN_WIDTH-40-70, _convRecord.robotModel.imgtxtArray.count*80);
}

#pragma mark --显示图文消息--
+(void)configureImgtxtMsg:(UITableViewCell *)cell convRecord:(ConvRecord*)_convRecord{
    float maxWidth = MAX_WIDTH;
    if(_convRecord.recordType == mass_conv_record_type)
    {
        maxWidth = [cell getCellContentWidth]-40;
    }
    
    UIView *imgTxtView = (UIView *)[cell.contentView viewWithTag:body_tag];
    DisplayImgtxtTableView *imgTableView = (DisplayImgtxtTableView *)[imgTxtView viewWithTag:imgtxt_table_tag];

    if (imgTableView != nil) {
//        while ([imgTableView retainCount] > 0) {
//            [imgTableView release];
//        }
        [imgTableView removeFromSuperview];
        NSInteger count = [imgTableView retainCount];
        imgTableView = nil;
    }
    imgTableView = [[[DisplayImgtxtTableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain]autorelease];
    imgTableView.bounces = NO;
    imgTableView.frame = CGRectMake(12, 5, SCREEN_WIDTH-40-70, _convRecord.robotModel.imgtxtArray.count*90);
    imgTableView.tag = imgtxt_table_tag;
//    imgTableView.backgroundColor = [UIColor clearColor];
    imgTableView.dataArray = _convRecord.robotModel.imgtxtArray;
    [imgTableView reloadData];
    [imgTxtView addSubview:imgTableView];
//    [imgTableView release];
    
    
    }

#pragma mark --百科的size--
+(void)getWikiMsgSize:(ConvRecord*)_convRecord{
    _convRecord.msgSize = CGSizeMake(SCREEN_WIDTH-40-70, _convRecord.robotModel.imgtxtArray.count*80);
}

#pragma mark --显示百科消息--
+(void)configureWikiMsg:(UITableViewCell *)cell convRecord:(ConvRecord*)_convRecord{
    float maxWidth = MAX_WIDTH;
    if(_convRecord.recordType == mass_conv_record_type)
    {
        maxWidth = [cell getCellContentWidth]-40;
    }
    
    UIView *imgTxtView = (UIView *)[cell.contentView viewWithTag:body_tag];
    DisplayImgtxtTableView *imgTableView = (DisplayImgtxtTableView *)[imgTxtView viewWithTag:imgtxt_table_tag];
    
    if (imgTableView != nil) {
        [imgTableView removeFromSuperview];
        NSInteger count = [imgTableView retainCount];
        imgTableView = nil;
    }
    imgTableView = [[[DisplayImgtxtTableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain]autorelease];
    imgTableView.bounces = NO;
    imgTableView.frame = CGRectMake(12, 5, SCREEN_WIDTH-40-70, _convRecord.robotModel.imgtxtArray.count*90);
    imgTableView.tag = imgtxt_table_tag;
    imgTableView.backgroundColor = [UIColor clearColor];
    imgTableView.dataArray = _convRecord.robotModel.imgtxtArray;
    [imgTableView reloadData];
    [imgTxtView addSubview:imgTableView];
    NSString *messageStr = _convRecord.msg_body;
}

#pragma mark --显示文件消息--
+(void)configureFileMsg:(UITableViewCell *)cell convRecord:(ConvRecord*)_convRecord
{
	UIView *fileView = (UIView*)[cell.contentView viewWithTag:file_tag];
    float fileViewSizeWidth =  _convRecord.msgSize.width;
	fileView.frame = CGRectMake(5.0,0.0, fileViewSizeWidth, _convRecord.msgSize.height);
//	[LogUtil debug:[NSString stringWithFormat:@"fileView frame is %@",NSStringFromCGRect(fileView.frame)]] ;
	fileView.hidden = NO;
	
    UIView *fileSubView = (UIView*)[cell.contentView viewWithTag:file_sub_view_tag];
    fileSubView.hidden = NO;
    
	UIImageView *filePicView = (UIImageView*)[cell.contentView viewWithTag:file_pic_tag];
	filePicView.image = _convRecord.imageDisplay;
//	filePicView.frame = CGRectMake((_convRecord.msgSize.width - _convRecord.imageDisplay.size.width)/2, 0, _convRecord.imageDisplay.size.width, _convRecord.imageDisplay.size.height);
    filePicView.frame = CGRectMake(4.0, 4.0, _convRecord.imageDisplay.size.width, _convRecord.imageDisplay.size.height);
	filePicView.hidden = NO;
//	[LogUtil debug:[NSString stringWithFormat:@"filePicView frame is %@",NSStringFromCGRect(filePicView.frame)]] ;

    //文件名字
	UILabel *fileNameLabel = (UILabel*)[cell.contentView viewWithTag:file_name_tag];
//	fileNameLabel.text = _convRecord.fileNameAndSize;
    fileNameLabel.text = _convRecord.file_name;
//	fileNameLabel.frame = CGRectMake(0, _convRecord.msgSize.height - 20, _convRecord.msgSize.width, 20);
    fileNameLabel.frame = CGRectMake(_convRecord.imageDisplay.size.width+7.0,2.0, fileViewSizeWidth-_convRecord.imageDisplay.size.width, 30.0);
	fileNameLabel.hidden = NO;
//	[LogUtil debug:[NSString stringWithFormat:@"fileNameLabel frame is %@",NSStringFromCGRect(fileNameLabel.frame)]] ;
    
    //文件大小
    UILabel *fileSizeLabel = (UILabel*)[cell.contentView viewWithTag:file_size_tag];
    NSInteger fileSize = [[NSString stringWithFormat:@"%@",_convRecord.file_size] intValue];
    NSString *fileSizeStr = [StringUtil getDisplayFileSize:fileSize];
    
    // [[RobotDAO getDatabase]isRobotUser:_convRecord.conv_id.intValue]
    if (_convRecord.isRobotFileMsg){
        fileSizeLabel.text = _convRecord.robotModel.msgFileSize;
    }else{
        fileSizeLabel.text = fileSizeStr;
    }
    fileSizeLabel.frame = CGRectMake(_convRecord.imageDisplay.size.width+8.0,fileNameLabel.frame.origin.y+fileNameLabel.frame.size.height+2.0, 60.0, 20);
    fileSizeLabel.hidden = NO;
    
    //文件状态
    CGRect _frame = fileSizeLabel.frame;
    _frame.origin.x += _frame.size.width;
    _frame.size.width = fileNameLabel.frame.size.width - _frame.size.width;
    UILabel *fileDownloadSateLabel = (UILabel*)[cell.contentView viewWithTag:file_download_state_tag];
    fileDownloadSateLabel.frame = _frame;
    fileDownloadSateLabel.hidden = NO;
    
    if (_convRecord.cloudFileModel) {
        if (_convRecord.msg_flag == send_msg) {
            fileDownloadSateLabel.text = [StringUtil getLocalizableString:@"云文件"];
        }else{
            fileDownloadSateLabel.text = [StringUtil getLocalizableString:@"云文件"];
        }
    }
    
    //下载进度
    UIProgressView *_progressView = (UIProgressView*)[cell.contentView viewWithTag:file_progressview_tag];
    _progressView.frame = CGRectMake(filePicView.frame.origin.x, filePicView.frame.origin.y + filePicView.frame.size.height+2.0, _convRecord.msgSize.width - file_cell_space, 20.0);
        
    
//    if(_convRecord.msg_flag == rcv_msg)
//    {
//        UIImageView *bubbleImageView = (UIImageView*)[cell.contentView viewWithTag:bubble_rcv_tag];
//        
//        float bubbleX = bubbleImageView.frame.origin.x;
//        float bubbleY = bubbleImageView.frame.origin.y;
//        float bubbleHeight = bubbleImageView.frame.size.height;
//        float bubbleWidth = bubbleImageView.frame.size.width;
//        
//        NewFileMsgCell *fileCell = (NewFileMsgCell *)cell;
//        UIButton *_cancelBtn = fileCell.downloadCancelBtn;
//        _cancelBtn.frame = CGRectMake(bubbleX+bubbleWidth, bubbleY+bubbleHeight-24.0, 22.0, 22.0);
//        [_cancelBtn setImage:[StringUtil getImageByResName:@"file_stop.png"] forState:UIControlStateNormal];
//    }
}

#pragma mark - 设置下载提示
+ (void)configureFileDownOrUpLoadSateLabelCell:(UITableViewCell *)cell convRecord:(ConvRecord*)_convRecord{
    [self configureFileResumeDownOrUpLoadSateLabelCell:cell convRecord:_convRecord];
}

#pragma mark - 断点续传配置
+ (void)configureFileResumeDownOrUpLoadSateLabelCell:(UITableViewCell *)cell convRecord:(ConvRecord*)_convRecord{
    //文件发送或下载取消按钮
    UIImageView *bubbleImageView = (UIImageView*)[cell.contentView viewWithTag:bubble_rcv_tag];
    if (_convRecord.msg_flag == send_msg){
        bubbleImageView = (UIImageView*)[cell.contentView viewWithTag:bubble_send_tag];
    }
    float bubbleX = bubbleImageView.frame.origin.x;
    float bubbleY = bubbleImageView.frame.origin.y;
    float bubbleHeight = bubbleImageView.frame.size.height;
    float bubbleWidth = bubbleImageView.frame.size.width;
    UIImageView *_cancelBtn = (UIImageView*)[cell.contentView viewWithTag:file_download_cancel_tag];
    
    
    UIView *fileView = (UIView*)[cell.contentView viewWithTag:file_tag];
    UILabel *fileDownloadSateLabel = (UILabel*)[cell.contentView viewWithTag:file_download_state_tag];
    CGFloat failBtnX = bubbleX - FAIL_BTN_SIZE - FAIL_BTN_SPACE;
    CGFloat failBtnY = bubbleY + bubbleHeight - FAIL_BTN_SIZE - FAIL_BTN_SPACE;
    if (_convRecord.msg_flag == send_msg) {
//        _cancelBtn.frame = CGRectMake(bubbleX-22.0, bubbleY+bubbleHeight-26.0, FAIL_BTN_SIZE, FAIL_BTN_SIZE);
//        _cancelBtn.frame = CGRectMake(failBtnX, failBtnY, FAIL_BTN_SIZE, FAIL_BTN_SIZE);
        
        //发送文件
        switch (_convRecord.send_flag) {
            case send_uploading:
            {
                //正在上传
                fileDownloadSateLabel.text = [StringUtil getLocalizableString:@"sending"];
                
                _cancelBtn.hidden = NO;
                [_cancelBtn setImage:[StringUtil getImageByResName:@"file_stop_btn.png"]];
            }
                break;
            case sending:
            {
                //正在发送
                fileDownloadSateLabel.text = [StringUtil getLocalizableString:@"sending"];
                _cancelBtn.hidden = YES;
            }
                break;
            case send_success:
            {
                //发送成功
                fileDownloadSateLabel.text = [StringUtil getLocalizableString:@"sent"];
                _cancelBtn.hidden = YES;
            }
                break;
            case send_upload_fail:
            {
                //发送失败
                fileDownloadSateLabel.text = [StringUtil getLocalizableString:@"send_failure"];
                
                _cancelBtn.hidden = NO;
                [_cancelBtn setImage:[StringUtil getImageByResName:@"send_fail.png"]];
            }
                break;
            case send_upload_stop:
            {
                //发送暂停
                fileDownloadSateLabel.text = [StringUtil getLocalizableString:@"sent_stop"];
                
                _cancelBtn.hidden = NO;
                [_cancelBtn setImage:[StringUtil getImageByResName:@"re_upload_btn.png"]];
            }
                break;
            case send_upload_nonexistent:
            {
                //文件已过期
                fileDownloadSateLabel.text = [StringUtil getLocalizableString:@"file_has_expired"];
                _cancelBtn.hidden = YES;
            }
                break;
            default:
            {
                //上传准备中
                fileDownloadSateLabel.text = [StringUtil getLocalizableString:@"file_upload_waiting"];
                _cancelBtn.hidden = YES;
            }
                break;
        }
    }
    else{
        failBtnX = bubbleX+bubbleWidth+FAIL_BTN_SPACE;
        failBtnY = bubbleY + bubbleHeight - FAIL_BTN_SIZE - FAIL_BTN_SPACE;
        
        //接收文件
//        _cancelBtn.frame = CGRectMake(bubbleX+bubbleWidth, bubbleY+bubbleHeight-26.0, 20.0, 20.0);
//        _cancelBtn.frame = CGRectMake(failBtnX, failBtnY, FAIL_BTN_SIZE, FAIL_BTN_SIZE);
        
        switch (_convRecord.download_flag) {
            case state_download_unknow:
            {
                //文件未点击下载
                fileDownloadSateLabel.text = [StringUtil getLocalizableString:@"click_to_download"];
            }
                break;
            case state_download_success:
            {
                //文件下载成功  [[RobotDAO getDatabase]isRobotUser:_convRecord.conv_id.intValue]
                if ([[RobotDAO getDatabase]getRobotId] == _convRecord.conv_id.intValue && [StringUtil isVideoFile:[_convRecord.file_name pathExtension]]){
                    fileDownloadSateLabel.text = [StringUtil getLocalizableString:@"video_play"];
                }else{
                    fileDownloadSateLabel.text = [StringUtil getLocalizableString:@"downloaded"];
                }
            }
                break;
            case state_downloading:
            {
                fileDownloadSateLabel.text = [StringUtil getLocalizableString:@"downloading"];
                _cancelBtn.hidden = NO;
                [_cancelBtn setImage:[StringUtil getImageByResName:@"file_stop_btn.png"]];
            }
                break;
            case state_download_failure:
            {
                //下载失败
                fileDownloadSateLabel.text = [StringUtil getLocalizableString:@"download_failure"];
                
                _cancelBtn.hidden = NO;
                [_cancelBtn setImage:[StringUtil getImageByResName:@"send_fail.png"]];
            }
                break;
            case state_download_stop:
            {
                //文件下载暂停
                fileDownloadSateLabel.text = [StringUtil getLocalizableString:@"sent_stop"];
                _cancelBtn.hidden = NO;
                [_cancelBtn setImage:[StringUtil getImageByResName:@"re_download_btn.png"]];
            }
                break;
            case state_download_nonexistent:
            {
                //文件已过期
                fileDownloadSateLabel.text = [StringUtil getLocalizableString:@"file_has_expired"];
                _cancelBtn.hidden = YES;
            }
                break;
            default:
                break;
        }
    }
}

#pragma mark - 非断点续传配置
+ (void)configureFileUnResumeDownOrUpLoadSateLabelCell:(UITableViewCell *)cell convRecord:(ConvRecord*)_convRecord{
    UIView *fileView = (UIView*)[cell.contentView viewWithTag:file_tag];
    UILabel *fileDownloadSateLabel = (UILabel*)[cell.contentView viewWithTag:file_download_state_tag];
    if (_convRecord.msg_flag == send_msg) {
        //发送文件
        switch (_convRecord.send_flag) {
            case send_uploading:
            {
                //正在上传
                fileDownloadSateLabel.text = [StringUtil getLocalizableString:@"sending"];
            }
                break;
            case sending:
            {
                //正在发送
                fileDownloadSateLabel.text = [StringUtil getLocalizableString:@"sending"];
            }
                break;
            case send_success:
            {
                //发送成功
                fileDownloadSateLabel.text = [StringUtil getLocalizableString:@"sent"];
            }
                break;
            case send_upload_fail:
            {
                //发送失败
                fileDownloadSateLabel.text = [StringUtil getLocalizableString:@"send_failure"];
            }
                break;
            default:
                break;
        }
    }
    else{
        //接收文件
        if (_convRecord.isFileExists) {
            fileDownloadSateLabel.text = [StringUtil getLocalizableString:@"downloaded"];
        }
        else if (_convRecord.isDownLoading){
            fileDownloadSateLabel.text = [StringUtil getLocalizableString:@"downloading"];
        }
        else{
            fileDownloadSateLabel.text = [StringUtil getLocalizableString:@"click_to_download"];
        }
    }
}
#pragma mark -- 显示视频消息 --
+ (void)configureVideoMsg:(UITableViewCell *)cell convRecord:(ConvRecord *)_convRecord
{
    /*// 展示在cell中自动播放的视频
     UIImageView *showVideoView=(UIImageView*)[cell.contentView viewWithTag:video_tag];
     
     showVideoView.backgroundColor=[UIColor whiteColor];
     showVideoView.image=_convRecord.imageDisplay;
     
     showVideoView.frame = CGRectMake(0, 0, _convRecord.msgSize.width, _convRecord.msgSize.height);
     showVideoView.hidden = NO;
     //    UIImageView *bubble_sendPicView=(UIImageView*)[cell.contentView viewWithTag:bubble_send_tag];
     //    bubble_sendPicView.image=nil;
     //    bubble_sendPicView.highlightedImage=nil;
     //    UIImageView *bubble_rcvPicView=(UIImageView*)[cell.contentView viewWithTag:bubble_rcv_tag];
     //    bubble_rcvPicView.image=nil;
     //    bubble_rcvPicView.highlightedImage=nil;
     
     NSLog(@"frame = %@",NSStringFromCGRect(showVideoView.frame));
     
     //    AVPlayerLayer *playerLayer=[AVPlayerLayer playerLayerWithPlayer:_convRecord.avplay];
     //    playerLayer.frame=showVideoView.frame;
     //    [showVideoView.layer addSublayer:playerLayer];
     //    [_convRecord.avplay play];
     */
    //	展示给用户看的收到的图片，没下载前显示为默认图片bubble_send_tag
    NSString *videopath = [[StringUtil newRcvFilePath] stringByAppendingPathComponent:_convRecord.file_name];
    
    IrregularView *showPicView=(IrregularView*)[cell.contentView viewWithTag:video_tag];
    showPicView.backgroundColor=[UIColor whiteColor];
    //添加四个边阴影
    showPicView.layer.shadowColor = [UIColor blackColor].CGColor;
    showPicView.layer.shadowOffset = CGSizeMake(0, 0);
    showPicView.layer.shadowOpacity = 1;
    
    UIImage *_image = nil;
    if (_convRecord.imageDisplay) {
        _image = _convRecord.imageDisplay;
    }else{
        _image = [talkSessionUtil getVideoPreViewImage:[NSURL fileURLWithPath:videopath]];
        if (!_image) {
            //        如果第一帧没有取到，那么显示默认的图片
            _image = [StringUtil getImageByResName:@"default_video.png"];//默认图片
        }else{
            _convRecord.imageDisplay = _image;
        }
    }
    
    showPicView.image=_image;
    
    showPicView.frame = CGRectMake(0, 0, _convRecord.msgSize.width, _convRecord.msgSize.height);
    showPicView.contentMode = UIViewContentModeScaleAspectFill;
    showPicView.hidden = NO;
    UIImageView *bubble_sendPicView=(UIImageView*)[cell.contentView viewWithTag:bubble_send_tag];
    bubble_sendPicView.image=nil;
    bubble_sendPicView.highlightedImage=nil;
    UIImageView *bubble_rcvPicView=(UIImageView*)[cell.contentView viewWithTag:bubble_rcv_tag];
    bubble_rcvPicView.image=nil;
    bubble_rcvPicView.highlightedImage=nil;
   	BOOL fromSelf=YES;
    if (_convRecord.msg_flag==1) {//别人发送的信息
        fromSelf=NO;
    }
    if (fromSelf) {
        showPicView.trackPoints = [NSArray arrayWithObjects:[NSValue valueWithCGPoint:CGPointMake(0, 0)],
                                   [NSValue valueWithCGPoint:CGPointMake(_convRecord.msgSize.width-7.0, 0)],
                                   [NSValue valueWithCGPoint:CGPointMake(_convRecord.msgSize.width-7.0, 15.0)],
                                   [NSValue valueWithCGPoint:CGPointMake(_convRecord.msgSize.width, 18.0)],
                                   [NSValue valueWithCGPoint:CGPointMake(_convRecord.msgSize.width-7.0, 21.0)],
                                   [NSValue valueWithCGPoint:CGPointMake(_convRecord.msgSize.width-7.0, _convRecord.msgSize.height)],
                                   [NSValue valueWithCGPoint:CGPointMake(0, _convRecord.msgSize.height)],
                                   nil];
    }else
    {
        showPicView.trackPoints = [NSArray arrayWithObjects:[NSValue valueWithCGPoint:CGPointMake(7.0, 0)],
                                   [NSValue valueWithCGPoint:CGPointMake(_convRecord.msgSize.width, 0)],
                                   [NSValue valueWithCGPoint:CGPointMake(_convRecord.msgSize.width, _convRecord.msgSize.height)],
                                   [NSValue valueWithCGPoint:CGPointMake(7.0, _convRecord.msgSize.height)],
                                   [NSValue valueWithCGPoint:CGPointMake(7.0, 21.0)],
                                   [NSValue valueWithCGPoint:CGPointMake(0, 18.0)],
                                   [NSValue valueWithCGPoint:CGPointMake(7.0, 15.0)],
                                   nil];
    }
    
    showPicView.cornerRadius = 3;
    
    [showPicView setMask];
    //进度
    UIView *view = (UIView *)[cell.contentView viewWithTag:body_tag];
    //    view.backgroundColor = [UIColor blueColor];
    
    UIProgressView *progressCell=(UIProgressView*)[view viewWithTag:video_progress_tag];
    //    if (progressCell == nil) {
    //        progressCell = [[[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleBar]autorelease];
    //        [view addSubview:progressCell];
    //        progressCell.alpha = 0;
    //        progressCell.tag = video_progress_tag;
    //        progressCell.backgroundColor = [UIColor whiteColor];
    //    }
    
    float progressWidth = _convRecord.msgSize.width - VIDEO_MSG_PIC_ANGLE_WIDTH;
    
    //    update by shisp 如果是 钉消息类型的视频消息 那么已读和未读显示 特别靠下，因此把进度条 向上调整
    progressCell.frame=CGRectMake(0, 0, progressWidth, 5);
    
    //    progressCell.frame=CGRectMake(0, CGRectGetMaxY(showPicView.frame)+5, _convRecord.msgSize.width, 5);
    //    }
    
    // 在视频第一帧图片上面加一个播放图标，这个UIImageView放在VideoMsgCell中，不会显示
    UIImageView *video_play=(UIImageView*)[showPicView viewWithTag:video_play_tag];
    //    if (video_play == nil) {
    //        video_play = [[[UIImageView alloc]init]autorelease];
    //        video_play.contentMode = UIViewContentModeScaleAspectFit;
    //        video_play.tag = video_play_tag;
    //
    //        video_play.image = [StringUtil getImageByResName:@"message_video_play@2x.png"];// [StringUtil getImageByResName:@"message_video_play"];
    //        [showPicView addSubview:video_play];
    //    }
    video_play.hidden = NO;
    video_play.frame = CGRectMake(0, 0, showPicView.bounds.size.width/2, (showPicView.bounds.size.height)/2);
    CGPoint _center = CGPointMake(showPicView.bounds.size.width * 0.5, showPicView.bounds.size.height * 0.5) ;
    if (fromSelf) {
        _center.x = _center.x - VIDEO_MSG_PIC_ANGLE_WIDTH * 0.5;
    }else{
        _center.x = _center.x + VIDEO_MSG_PIC_ANGLE_WIDTH * 0.5;
    }
    video_play.center = _center;
    
    //    [video_play release];
    
    //视频秒数 用bringSubviewToFront:还是出现不了
    //    UILabel *secLab = (UILabel *)[cell.contentView viewWithTag:video_sec_tag];
    
    UILabel *secLab = (UILabel *)[showPicView viewWithTag:video_sec_tag];
    //    if (secLab == nil) {
    //        secLab = [[[UILabel alloc]init]autorelease];
    //        secLab.tag = video_sec_tag;
    //        secLab.textColor = [UIColor whiteColor];
    //        secLab.textAlignment = NSTextAlignmentCenter;
    //        secLab.font = [UIFont systemFontOfSize:14.0];
    //        [showPicView addSubview:secLab];
    //    }
    secLab.hidden = NO;
    secLab.frame = CGRectMake(_convRecord.msgSize.width-video_sec_width, _convRecord.msgSize.height-video_sec_height - 5, video_sec_width, video_sec_height);
    
#ifdef _XINHUA_FLAG_
    if (_convRecord.systemMsgModel)
    {
        videopath = [[StringUtil newRcvFilePath] stringByAppendingPathComponent:[talkSessionUtil getNewsVideoName:_convRecord]];
    }
#endif
    AVURLAsset *asset = [[[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:videopath] options:nil]autorelease];
    NSInteger *sec = asset.duration.value / asset.duration.timescale;
    secLab.text = [talkSessionUtil lessSecondToDay:sec];
    _convRecord.videoSeconds = (int)sec;
}

#pragma mark --显示图片消息--
+(void)configurePicMsg:(UITableViewCell *)cell convRecord:(ConvRecord*)_convRecord
{
	//	展示给用户看的收到的图片，没下载前显示为默认图片bubble_send_tag
	IrregularView *showPicView=(IrregularView*)[cell.contentView viewWithTag:pic_tag];
    showPicView.backgroundColor=[UIColor whiteColor];
//    showPicView.layer.shadowOffset = CGSizeMake(-5, -3);
//    showPicView.layer.shadowOpacity = 0.6;
//    showPicView.layer.shadowColor = [UIColor blackColor].CGColor;
    //添加四个边阴影
    showPicView.layer.shadowColor = [UIColor blackColor].CGColor;
    showPicView.layer.shadowOffset = CGSizeMake(0, 0);
    showPicView.layer.shadowOpacity = 1;
   // showPicView.layer.shadowRadius = 10.0;
    
	showPicView.image=_convRecord.imageDisplay;
	showPicView.frame = CGRectMake(0, 0, _convRecord.msgSize.width, _convRecord.msgSize.height);
	showPicView.hidden = NO;
	UIImageView *bubble_sendPicView=(UIImageView*)[cell.contentView viewWithTag:bubble_send_tag];
    bubble_sendPicView.image=nil;
    bubble_sendPicView.highlightedImage=nil;
    UIImageView *bubble_rcvPicView=(UIImageView*)[cell.contentView viewWithTag:bubble_rcv_tag];
    bubble_rcvPicView.image=nil;
    bubble_rcvPicView.highlightedImage=nil;
   	BOOL fromSelf=YES;
    if (_convRecord.msg_flag==1) {//别人发送的信息
        fromSelf=NO;
    }
    if (fromSelf) {
        showPicView.trackPoints = [NSArray arrayWithObjects:[NSValue valueWithCGPoint:CGPointMake(0, 0)],
                                   [NSValue valueWithCGPoint:CGPointMake(_convRecord.msgSize.width-7.0, 0)],
                                   [NSValue valueWithCGPoint:CGPointMake(_convRecord.msgSize.width-7.0, 15.0)],
                                   [NSValue valueWithCGPoint:CGPointMake(_convRecord.msgSize.width, 18.0)],
                                   [NSValue valueWithCGPoint:CGPointMake(_convRecord.msgSize.width-7.0, 21.0)],
                                   [NSValue valueWithCGPoint:CGPointMake(_convRecord.msgSize.width-7.0, _convRecord.msgSize.height)],
                                   [NSValue valueWithCGPoint:CGPointMake(0, _convRecord.msgSize.height)],
                                   nil];
    }else
    {
        showPicView.trackPoints = [NSArray arrayWithObjects:[NSValue valueWithCGPoint:CGPointMake(7.0, 0)],
                                   [NSValue valueWithCGPoint:CGPointMake(_convRecord.msgSize.width, 0)],
                                   [NSValue valueWithCGPoint:CGPointMake(_convRecord.msgSize.width, _convRecord.msgSize.height)],
                                   [NSValue valueWithCGPoint:CGPointMake(7.0, _convRecord.msgSize.height)],
                                    [NSValue valueWithCGPoint:CGPointMake(7.0, 21.0)],
                                   [NSValue valueWithCGPoint:CGPointMake(0, 18.0)],
                                   [NSValue valueWithCGPoint:CGPointMake(7.0, 15.0)],
                                   nil];
    }
   
//    //设置layer
//    CALayer *layer=[showPicView layer];
//    //是否设置边框以及是否可见
//   // [layer setMasksToBounds:YES];
//    //设置边框圆角的弧度
//    [layer setCornerRadius:3.0];
//    //设置边框线的宽
//    //
//    [layer setBorderWidth:1];
//    //设置边框线的颜色
//    [layer setBorderColor:[[UIColor grayColor] CGColor]];
    
    showPicView.cornerRadius = 3;
//    showPicView.borderWidth  = 1;
//    showPicView.borderColor  = [UIColor grayColor];
    
    //进度
    UILabel *progressCell=(UILabel *)[cell.contentView viewWithTag:pic_progress_Label_tag];
    progressCell.hidden = YES;
    progressCell.frame = showPicView.frame;
    progressCell.center = showPicView.center;
    
    
    [showPicView setMask];

//	//	进度条View
//	UIProgressView *progressCell=(UIProgressView*)[cell.contentView viewWithTag:pic_progress_tag];
//	progressCell.frame=CGRectMake(5, _convRecord.msgSize.height-10, _convRecord.msgSize.width - 10, 5);
    
    
}

#pragma mark -----显示位置类型消息-----
+(void)configureLocationMsg:(UITableViewCell *)cell convRecord:(ConvRecord*)_convRecord
{
    //	展示给用户看的收到的图片，没下载前显示为默认图片bubble_send_tag
    IrregularView *showPicView=(IrregularView*)[cell.contentView viewWithTag:location_pic_view_tag];
    showPicView.backgroundColor=[UIColor whiteColor];
    //    showPicView.layer.shadowOffset = CGSizeMake(-5, -3);
    //    showPicView.layer.shadowOpacity = 0.6;
    //    showPicView.layer.shadowColor = [UIColor blackColor].CGColor;
    //添加四个边阴影
    showPicView.layer.shadowColor = [UIColor blackColor].CGColor;
    showPicView.layer.shadowOffset = CGSizeMake(0, 0);
    showPicView.layer.shadowOpacity = 1;
    // showPicView.layer.shadowRadius = 10.0;
    
    showPicView.image=_convRecord.imageDisplay;
    showPicView.frame = CGRectMake(0, 0, _convRecord.msgSize.width, _convRecord.msgSize.height);
    showPicView.hidden = NO;
    UIImageView *bubble_sendPicView=(UIImageView*)[cell.contentView viewWithTag:bubble_send_tag];
    bubble_sendPicView.image=nil;
    bubble_sendPicView.highlightedImage=nil;
    UIImageView *bubble_rcvPicView=(UIImageView*)[cell.contentView viewWithTag:bubble_rcv_tag];
    bubble_rcvPicView.image=nil;
    bubble_rcvPicView.highlightedImage=nil;
   	BOOL fromSelf=YES;
    if (_convRecord.msg_flag == rcv_msg) {//别人发送的信息
        fromSelf=NO;
    }
    if (fromSelf) {
        showPicView.trackPoints = [NSArray arrayWithObjects:[NSValue valueWithCGPoint:CGPointMake(0, 0)],
                                   [NSValue valueWithCGPoint:CGPointMake(_convRecord.msgSize.width-7.0, 0)],
                                   [NSValue valueWithCGPoint:CGPointMake(_convRecord.msgSize.width-7.0, 15.0)],
                                   [NSValue valueWithCGPoint:CGPointMake(_convRecord.msgSize.width, 18.0)],
                                   [NSValue valueWithCGPoint:CGPointMake(_convRecord.msgSize.width-7.0, 21.0)],
                                   [NSValue valueWithCGPoint:CGPointMake(_convRecord.msgSize.width-7.0, _convRecord.msgSize.height)],
                                   [NSValue valueWithCGPoint:CGPointMake(0, _convRecord.msgSize.height)],
                                   nil];
    }else
    {
        showPicView.trackPoints = [NSArray arrayWithObjects:[NSValue valueWithCGPoint:CGPointMake(7.0, 0)],
                                   [NSValue valueWithCGPoint:CGPointMake(_convRecord.msgSize.width, 0)],
                                   [NSValue valueWithCGPoint:CGPointMake(_convRecord.msgSize.width, _convRecord.msgSize.height)],
                                   [NSValue valueWithCGPoint:CGPointMake(7.0, _convRecord.msgSize.height)],
                                   [NSValue valueWithCGPoint:CGPointMake(7.0, 21.0)],
                                   [NSValue valueWithCGPoint:CGPointMake(0, 18.0)],
                                   [NSValue valueWithCGPoint:CGPointMake(7.0, 15.0)],
                                   nil];
    }
    
    //    //设置layer
    //    CALayer *layer=[showPicView layer];
    //    //是否设置边框以及是否可见
    //   // [layer setMasksToBounds:YES];
    //    //设置边框圆角的弧度
    //    [layer setCornerRadius:3.0];
    //    //设置边框线的宽
    //    //
    //    [layer setBorderWidth:1];
    //    //设置边框线的颜色
    //    [layer setBorderColor:[[UIColor grayColor] CGColor]];
    
    showPicView.cornerRadius = 3;
    //    showPicView.borderWidth  = 1;
    //    showPicView.borderColor  = [UIColor grayColor];
    
    //    地址
    UILabel *addressLabel = (UILabel *)[showPicView viewWithTag:location_address_tag];
    addressLabel.frame = CGRectMake(0, _convRecord.msgSize.height - location_address_height, _convRecord.msgSize.width, location_address_height);
    if (_convRecord.msg_flag == rcv_msg) {
        addressLabel.text = [NSString stringWithFormat:@"    %@", _convRecord.locationModel.address];
    }else{
        addressLabel.text = [NSString stringWithFormat:@"  %@", _convRecord.locationModel.address];
    }
    addressLabel.hidden = NO;
    
    
    UIActivityIndicatorView *indicatorView = (UIActivityIndicatorView *)[showPicView viewWithTag:location_load_indicator_view_tag];
    CGRect _frame =  indicatorView.frame;
    _frame.origin = CGPointMake((_convRecord.msgSize.width - _frame.size.width) * 0.5, ((_convRecord.msgSize.height - location_address_height) - _frame.size.height) * 0.5);
    indicatorView.frame = _frame;
    
    [showPicView setMask];
    
}

#pragma mark --显示录音消息--
+(void)configureAudioMsg:(UITableViewCell *)cell convRecord:(ConvRecord*)_convRecord
{
//	录音秒数
	NSString *audioSec = [NSString stringWithFormat:@"%@\"",_convRecord.file_size];
	CGSize audioSecSize = [audioSec sizeWithFont:[UIFont systemFontOfSize:16]];

	float cwidth = _convRecord.msgSize.width;
	UIButton *clickbutton= (UIButton*)[cell.contentView viewWithTag:audio_tag];
	clickbutton.frame = CGRectMake(0, 0, cwidth, single_line_height + 20);
	clickbutton.hidden = NO;

	int buttonMargin = 6;
	float buttonWidth = 12.5;
#ifdef _LANGUANG_FLAG_
    
    buttonWidth = 22.5;
    
#endif
	float buttonHeight = 18.5;
	int buttonImageX = buttonMargin;
	int buttonImageY = (single_line_height - buttonHeight)/2;
	if(_convRecord.recordType == mass_conv_record_type)
	{
		buttonImageY = (clickbutton.frame.size.height - buttonHeight)/2;		
	}

	int timeMargin = 3;
	float timelabelWidth = audioSecSize.width;
	float timeLabelHeight = audioSecSize.height;
	float timeLabelX = cwidth -timeMargin - timelabelWidth;
	float timeLabelY = (single_line_height - timeLabelHeight)/2;
	if(_convRecord.recordType == mass_conv_record_type)
	{
		timeLabelY = (clickbutton.frame.size.height - timeLabelHeight)/2;
	}
	if(_convRecord.msg_flag == send_msg)
	{
		if(_convRecord.recordType == mass_conv_record_type)
		{
			
		}
		else
		{
			buttonImageX = cwidth - buttonMargin-buttonWidth;
			timeLabelX = timeMargin;
		}
	}
	UIImageView *buttonimage=(UIImageView*)[cell.contentView viewWithTag:audio_playImageView_tag];
	buttonimage.frame = CGRectMake(buttonImageX, buttonImageY, buttonWidth, buttonHeight);
	buttonimage.hidden = NO;
	
	
	UILabel *timeSecond = (UILabel*)[cell.contentView viewWithTag:audio_second_tag];
    
    // add by yanlei 机器人应答要单独处理,小万界面发送出去的语音有秒数，接收到的音频没有秒数[[RobotDAO getDatabase]isRobotUser:[_convRecord.conv_id intValue]]
    if (!([[RobotDAO getDatabase]getRobotId] == [_convRecord.conv_id intValue]) || [_convRecord.file_size intValue] > 0){
        timeSecond.frame = CGRectMake(timeLabelX, timeLabelY, timelabelWidth, timeLabelHeight);
        timeSecond.hidden = NO;
        if (_convRecord.file_size == 0) {
            timeSecond.hidden = YES;
        }
        timeSecond.text= [NSString stringWithFormat:@"%@\"",_convRecord.file_size];
        
        [self setTextMsgColor:timeSecond andConvRecord:_convRecord];
        
    }else{
        timeSecond.hidden = YES;
    }
	
	if(_convRecord.msg_flag == send_msg)
	{
		if(_convRecord.recordType == mass_conv_record_type)
		{
			timeSecond.textAlignment=UITextAlignmentRight;
			buttonimage.image=[StringUtil getImageByResName:@"voice_rcv_default.png"];
		}
		else
		{
			buttonimage.image=[StringUtil getImageByResName:@"voice_send_default.png"];			
		}
	}
	else
	{
		timeSecond.textAlignment=UITextAlignmentRight;
		buttonimage.image=[StringUtil getImageByResName:@"voice_rcv_default.png"];
	}
    
    // 如果是新华网的推送的语音消息
#if _XINHUA_FLAG_
    if (_convRecord.systemMsgModel)
    {
        timeSecond.text = _convRecord.systemMsgModel.title ?: @"";
        if(_convRecord.msg_flag == send_msg)
        {
            buttonimage.frame = CGRectMake(50, 12, buttonWidth, buttonHeight);
            timeSecond.frame = CGRectMake(12, 12, 40, 20);
            timeSecond.hidden = NO;
            timeSecond.textAlignment=NSTextAlignmentLeft;
        }
        else
        {
            buttonimage.frame = CGRectMake(21, 12, buttonWidth, buttonHeight);
            timeSecond.frame = CGRectMake(32, 12, 40, 20);
        }
    }
#endif
}

#pragma mark --显示长消息消息--
+(void)configureLongMsg:(UITableViewCell *)cell convRecord:(ConvRecord*)_convRecord
{
	//		检查长消息是否下载，如果没有下载，那么就先去下载，然后展示
	//		如果已经下载，那么就直接展示
	NSString *fileName=[NSString stringWithFormat:@"%@.txt",_convRecord.msg_body];
	NSString *filePath = [[StringUtil newRcvFilePath] stringByAppendingPathComponent:fileName];
    NSData *longMsgData = [EncryptFileManege getDataWithPath:filePath];
    NSString *longMsg = [[NSString alloc] initWithData:longMsgData encoding:NSUTF8StringEncoding];
//	NSString *longMsg = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
	if(longMsg == nil || longMsg.length == 0)
	{
		longMsg = _convRecord.file_name;
	}
    
	UILabel *textView = (UILabel*)[cell.contentView viewWithTag:normal_text_tag];
    textView.font = [UIFont systemFontOfSize:[FontSizeUtil getFontSize]];
	textView.frame = CGRectMake(0,0,_convRecord.msgSize.width,_convRecord.msgSize.height);
	textView.text = [NSString stringWithFormat:@"%@", longMsg];
	textView.hidden = NO;
    [self setTextMsgColor:textView andConvRecord:_convRecord];
}

#pragma mark --配置一呼百应消息提示-- 新
+(void)configureNewReceiptTips:(UITableViewCell *)cell convRecord:(ConvRecord*)_convRecord
{
    NSString *receiptTips = _convRecord.receiptTips;
    
    UIFont *_font = [UIFont systemFontOfSize:MSG_RECEIPT_FONTSIZE];
    
    CGSize size = [receiptTips sizeWithFont:_font];
    
    UIView *contentView = (UIView *)[cell.contentView viewWithTag:body_tag];
    CGRect cellFrame = contentView.frame;
    CGFloat receiptX = cellFrame.origin.x - MSG_RECEIPT_SPACE - size.width;
    CGFloat receiptY = cellFrame.origin.y + (cellFrame.size.height - size.height - MSG_RECEIPT_SPACE);
    
    if (_convRecord.msg_flag == rcv_msg){
        receiptX = cellFrame.origin.x + cellFrame.size.width + MSG_RECEIPT_SPACE;
    }
    
    // 如果上边距的距离小于下边距的距离，则居中显示
//    CGFloat topSpace = receiptY - cellFrame.origin.y;
//    CGFloat bottomSpace = cellFrame.origin.y + cellFrame.size.height - receiptY - size.height;
//    if (topSpace < bottomSpace) {
//        receiptY = cellFrame.origin.y + (cellFrame.size.height - size.height)/2;
//    }
    // 单行的情况下居中显示
    CGFloat viewH = cellFrame.size.height;
    if (viewH <= MSG_MIN_SINGLE_ROW_HEIGHT) {
        receiptY = cellFrame.origin.y + (cellFrame.size.height - size.height)/2;
    }
    
    UIImageView *receiptBGView = (UIImageView *)[cell.contentView viewWithTag:receipt_tag];
    receiptBGView.frame = CGRectMake(receiptX , receiptY,size.width, size.height);
    receiptBGView.hidden = NO;
    
    //		增加显示提示信息
    UILabel *receiptLabel= (UILabel*)[cell.contentView viewWithTag:receipt_text_tag];
    receiptLabel.text = receiptTips;
    receiptLabel.frame = CGRectMake(0, 0, size.width, size.height);
    receiptLabel.hidden = NO;
    
    receiptLabel.textColor = [self getReceiptTipsColorOfActive];
    
    //    增加判断 如果是发送的消息 显示激活的颜色 如果是收到的消息，那么还未发送回执，显示激活；已经发送了回执，则使用非激活颜色
    if (_convRecord.msg_flag == rcv_msg && _convRecord.readNoticeFlag == 1) {
        receiptLabel.textColor = [self getReceiptTipsColorOfInActive];
    }
}
// 设置回执控制位置  新
+ (void)configureNewHuizhiMsg:(UITableViewCell *)cell convRecord:(ConvRecord*)_convRecord
{
    /** 已经打开的密聊消息就不再显示发送回执或者回执已发送的提示了 */
    if (_convRecord.isMiLiaoMsg && _convRecord.isMiLiaoMsgOpen) {
        
    }else{
        [self configureNewReceiptTips:cell convRecord:_convRecord];
    }
}

#pragma mark --显示消息内容--
+(void)configureMsgBody:(UITableViewCell *)cell convRecord:(ConvRecord*)_convRecord
{
    BOOL isNeedNewConfigure = NO;
    if(_convRecord.isTextMsg)
    {
        if (_convRecord.locationModel) {
            LocationMsgCell *_cell = (LocationMsgCell *)cell;
            [LocationMsgCell configureCell:_cell andRecord:_convRecord];
            isNeedNewConfigure = YES;
        }else if (_convRecord.cloudFileModel){
        }else if (_convRecord.isRobotImgTxtMsg){
        }else if (_convRecord.isRobotFileMsg){
        }else if (_convRecord.replyOneMsgModel){
            WXReplyToOneMsgCellTableViewCellArc *_cell = (WXReplyToOneMsgCellTableViewCellArc *)cell;
            [WXReplyToOneMsgCellTableViewCellArc configureCell:_cell andRecord:_convRecord];
            isNeedNewConfigure = YES;
        }else if (_convRecord.redPacketModel){  // 红包消息
            
            if ([cell isKindOfClass:[RedpacketMessageCell class]]) {
                [RedpacketMessageCell showRedpacketMsgView:(RedpacketMessageCell *)cell andConvRecord:_convRecord];
            }else if ([cell isKindOfClass:[RedpacketTakenMessageTipCell class]]){
                [RedpacketTakenMessageTipCell showRedpacketMsgView:(RedpacketTakenMessageTipCell *)cell andConvRecord:_convRecord];
            }
            
            return;
        }else if (_convRecord.newsModel){
            
            LGNewsCellARC *_cell = (LGNewsCellARC *)cell;
            CGSize size;
            size.height = news_view_height;
            size.width = news_view_width;
            _convRecord.msgSize = size;
            [LGNewsCellARC configCellWithDataModel:_convRecord.newsModel andCell:_cell andRecord:_convRecord];
            
            isNeedNewConfigure = YES;
        }
//        else if(_convRecord.isHuizhiMsg){ // 回执
//            
//        }
        else{
            if(_convRecord.isLinkText)
            {
                LinkTextMsgCell *_cell = (LinkTextMsgCell *)cell;
                [LinkTextMsgCell configureCell:_cell andRecord:_convRecord];
                isNeedNewConfigure = YES;
            }
            else
            {
                if(_convRecord.isTextPic)
                {
                    FaceTextMsgCell *_cell = (FaceTextMsgCell *)cell;
                    [FaceTextMsgCell configureCell:_cell andRecord:_convRecord];
                    isNeedNewConfigure = YES;
                }
                else
                {
                    NormalTextMsgCell *_cell = (NormalTextMsgCell *)cell;
                    [NormalTextMsgCell configureCell:_cell andRecord:_convRecord];
                    isNeedNewConfigure = YES;
                }
            }
        }
    }else if(_convRecord.isLongMsg){
        NormalTextMsgCell *_cell = (NormalTextMsgCell *)cell;
        [NormalTextMsgCell configureLongMsg:_cell andRecord:_convRecord];
        isNeedNewConfigure = YES;
    }else if(_convRecord.isRecordMsg){
        AudioMsgCell *_cell = (AudioMsgCell *)cell;
        [AudioMsgCell configureCell:_cell andRecord:_convRecord];
        isNeedNewConfigure = YES;
    }else if(_convRecord.isPicMsg){
        PicMsgCell *_cell = (PicMsgCell *)cell;
        [PicMsgCell configureCell:_cell andRecord:_convRecord];
        isNeedNewConfigure = YES;
    }else if(_convRecord.isVideoMsg){
        VideoMsgCell *_cell = (VideoMsgCell *)cell;
        [VideoMsgCell configureCell:_cell andRecord:_convRecord];
        isNeedNewConfigure = YES;
    }else if(_convRecord.isFileMsg){
        NewFileMsgCell *_cell = (NewFileMsgCell *)cell;
        [NewFileMsgCell configureCell:_cell andRecord:_convRecord];
        isNeedNewConfigure = YES;
    }
    if (isNeedNewConfigure) {
        
        if (_convRecord.isHuizhiMsg) {
//            [self configureNewHuizhiMsg:cell convRecord:_convRecord];
        }
        
        return;
    }
    
	
    int msgType = _convRecord.msg_type;
    
	if(msgType == type_group_info)
	{
		[GroupInfoMsgCell configureGroupInfo:cell convRecord:_convRecord];
		return;
	}
	
	bool fromSelf = true;
	if(_convRecord.msg_flag == rcv_msg)
	{
		fromSelf = false;
	}
	
	UIImageView *bubbleImageView = (UIImageView *)[cell.contentView viewWithTag:bubble_send_tag];
	if(!fromSelf)
		 bubbleImageView = (UIImageView *)[cell.contentView viewWithTag:bubble_rcv_tag];
	
	bubbleImageView.hidden = NO;
	//		消息内容，消息size
	//	NSString *messageStr = _convRecord.msg_body;
	CGSize messageViewSize;
	
	if(_convRecord.isTextMsg)
	{
        if (_convRecord.locationModel) {
            [self configureLocationMsg:cell convRecord:_convRecord];
            UIImageView *showPicView=(UIImageView*)[cell.contentView viewWithTag:location_pic_view_tag];
            messageViewSize = showPicView.frame.size;
        }else if (_convRecord.cloudFileModel){
            [self configureFileMsg:cell convRecord:_convRecord];
            UIView *fileView = (UIView*)[cell.contentView viewWithTag:file_tag];
            messageViewSize = fileView.frame.size;
        }
        
#ifdef _LANGUANG_FLAG_
        else if (_convRecord.redPacketModel){
            
            UIView *fileView = (UIView*)[cell.contentView viewWithTag:red_pecket_view_tag];
            if (fileView) {
                messageViewSize = fileView.frame.size;
                if (_convRecord.msg_flag == rcv_msg) {
                    CGRect _frame = fileView.frame;
                    _frame.origin = CGPointMake(0, _frame.origin.y+5);
                    fileView.frame = _frame;
                }
                [[RedpacketConfig sharedConfig]showView:fileView];
            }else{
                [[RedpacketConfig sharedConfig]showView:cell.contentView];
            }
            
            bubbleImageView.hidden = YES;
        
        }
        else if (_convRecord.newsModel){
            
//            LGNewsCellARC *newCell = (LGNewsCellARC *)cell;
//            UIView *contentView = (UIView *)[cell.contentView viewWithTag:body_tag];
//            [newCell showView:contentView convRecord:_convRecord];
//            CGSize size;
//            size.width = 247;
//            size.height = 50;
//            messageViewSize = size;
           
        }
#endif
        else if (_convRecord.replyOneMsgModel){
            WXReplyToOneMsgCellTableViewCellArc *curCell = (WXReplyToOneMsgCellTableViewCellArc *)cell;
            [WXReplyToOneMsgCellTableViewCellArc configureReplyToOneMsgCell:curCell andConvRecord:_convRecord];
            messageViewSize = _convRecord.msgSize;
        }
        else if (_convRecord.isRobotImgTxtMsg){
            NewImgTxtMsgCell *curCell = (NewImgTxtMsgCell *)cell;
            [curCell configureCell:_convRecord];
            messageViewSize = _convRecord.msgSize;
        }else if (_convRecord.isRobotFileMsg){
            [self configureFileMsg:cell convRecord:_convRecord];
            UIView *fileView = (UIView*)[cell.contentView viewWithTag:file_tag];
            messageViewSize = fileView.frame.size;
        }else if (_convRecord.isRobotPicMsg){
            [self configurePicMsg:cell convRecord:_convRecord];
            [((PicMsgCell *)cell) configureRobotPicCell:_convRecord];
            UIImageView *showPicView=(UIImageView*)[cell.contentView viewWithTag:pic_tag];
            messageViewSize = showPicView.frame.size;
        }
        else{
            [self configureTextMsg:cell convRecord:_convRecord];
            
            if(_convRecord.isLinkText)
            {
                TextLinkView* linkView = (TextLinkView*)[cell.contentView viewWithTag:link_text_tag];
                messageViewSize = linkView.frame.size;
                
            }
            else
            {
                if(_convRecord.isTextPic)
                {
                    TextMessageView* textMessageView = (TextMessageView*)[cell.contentView viewWithTag:nolink_text_pic_tag];
                    messageViewSize = textMessageView.frame.size;
                }
                else
                {
                    UILabel *normalText = (UILabel*)[cell.contentView viewWithTag:normal_text_tag];
                    messageViewSize = normalText.frame.size;
                }
            }
        }
	}
    
	else if(_convRecord.isFileMsg)
	{
		[self configureFileMsg:cell convRecord:_convRecord];
		UIView *fileView = (UIView*)[cell.contentView viewWithTag:file_tag];
		messageViewSize = fileView.frame.size;
	}
	else if(_convRecord.isPicMsg)
	{
		[self configurePicMsg:cell convRecord:_convRecord];
		UIImageView *showPicView=(UIImageView*)[cell.contentView viewWithTag:pic_tag];
		messageViewSize = showPicView.frame.size;
	}
    else if (_convRecord.isVideoMsg)
    {
        [self configureVideoMsg:cell convRecord:_convRecord];
        UIImageView *showVideoView=(UIImageView*)[cell.contentView viewWithTag:video_tag];
        messageViewSize = showVideoView.frame.size;
    }
	else if(_convRecord.isRecordMsg)
	{
		[self configureAudioMsg:cell convRecord:_convRecord];
		UIButton *clickbutton= (UIButton*)[cell.contentView viewWithTag:audio_tag];
		messageViewSize = clickbutton.frame.size;
	}
	else if(_convRecord.isLongMsg)
	{
		[self configureLongMsg:cell convRecord:_convRecord];
		UILabel *textView = (UILabel*)[cell.contentView viewWithTag:normal_text_tag];
		messageViewSize = textView.frame.size;
	}
    else if(_convRecord.isImgtxtMsg)
    {
        [self configureImgtxtMsg:cell convRecord:_convRecord];
        
        DisplayImgtxtTableView *tableView = (DisplayImgtxtTableView*)[cell.contentView viewWithTag:imgtxt_table_tag];
        if(fromSelf){
            tableView.backgroundColor = [UIColor whiteColor];
        }
        if (_convRecord.robotModel) {
            messageViewSize = CGSizeMake(SCREEN_WIDTH-40-70, 90*_convRecord.robotModel.imgtxtArray.count);
        }
    }
    else if(_convRecord.isWikiMsg)
    {
        [self configureWikiMsg:cell convRecord:_convRecord];
        
        DisplayImgtxtTableView *tableView = (DisplayImgtxtTableView*)[cell.contentView viewWithTag:imgtxt_table_tag];
        if (_convRecord.robotModel) {
            messageViewSize = CGSizeMake(SCREEN_WIDTH-40-70, 90*_convRecord.robotModel.imgtxtArray.count);
        }
    }
	
	float bodyWidth = messageViewSize.width;
	float bodyHeight = messageViewSize.height;
	
	//	信息体在气泡中的起始位置
	float bodyX = 10;// 15;
	if(!fromSelf)
		bodyX = 15;//25;
	float bodyY = 10;
	
	//	如果是图片类型，那么bodyY是8
	if(_convRecord.isPicMsg || _convRecord.isFileMsg || _convRecord.locationModel || _convRecord.cloudFileModel || _convRecord.isRobotFileMsg)
	{
		bodyY = 8;
	}

	float bubbleWidth = bodyWidth + 25;
	float bubbleHeight = bodyHeight + 20;
	
	//	如果气泡的高度比头像的高度小
//    设置气泡最小高度
	if(bubbleHeight < min_height)
	{
//				NSLog(@"气泡高度比头像尺寸小，需要调整y值");
		bodyY = (min_height - bodyHeight)/2;
		bubbleHeight = min_height;
	}
    
    if(msgType == type_record)
	{
		bubbleHeight = bodyHeight;
	}
    
    //	设定一个最小的宽度
	if(bubbleWidth < MIN_WIDTH)
	{
		//		NSLog(@"气泡宽度小于最小宽度，需要调整x值");
		bodyX = bodyX + (MIN_WIDTH - bubbleWidth)/2;
		bubbleWidth = MIN_WIDTH;
	}
    
    UIImageView *headImageView = (UIImageView *)[cell.contentView viewWithTag:head_tag];
    float headX = headImageView.frame.origin.x;
	//	气泡的起始位置
	float bubbleX;
    if (fromSelf)
    {
        bubbleX = headX - bubbleWidth + 4.0 - logo_horizontal_space;
    }
    else
    {
        bubbleX = headX + headImageView.frame.size.width + logo_horizontal_space;
    }
//   
//    300 - bubbleWidth - chatview_logo_size + 5;
//	if(!fromSelf)
//		bubbleX = chat_user_logo_size - 5;
	
    
//    
//	if(_convRecord.recordType == ps_conv_record_type)
//	{
//		bubbleX = 300 - bubbleWidth - chatview_logo_size;
//		if(!fromSelf)
//		{
//			bubbleX = chat_user_logo_size;
//		}
//	}
	
	float headY = headImageView.frame.origin.y;
    
    if (_convRecord.msg_flag == rcv_msg) {
        headY+=15.5;
    }
    
	bubbleImageView.frame = CGRectMake(bubbleX, headY, bubbleWidth, bubbleHeight );
	
	UIView *bodyView = (UIView*)[cell.contentView viewWithTag:body_tag];
	bodyView.frame = CGRectMake(bubbleX, headY, bubbleWidth, bubbleHeight );
//    NSLog(@"----bodyView.frame = %@ , messageFrame = %@ , msgType = %d",NSStringFromCGRect(bodyView.frame),NSStringFromCGSize(messageViewSize),_convRecord.msg_type);
	bodyView.hidden = NO;
	
    
    CGRect messageFrame = CGRectMake(bodyX,bodyY,messageViewSize.width,messageViewSize.height);
    if(_convRecord.isTextMsg)
    {
        if (_convRecord.locationModel) {
            UIImageView *showPicView=(UIImageView*)[cell.contentView viewWithTag:location_pic_view_tag];
            
            if(_convRecord.msg_flag == send_msg)
            {
                showPicView.frame = CGRectMake(bodyX+14.0,bodyY - 8,messageViewSize.width,messageViewSize.height);
            }else
            {
                showPicView.frame = CGRectMake(bodyX-13.0,bodyY - 8,messageViewSize.width,messageViewSize.height);
            }
            
        }else if (_convRecord.cloudFileModel){
            [self adjustNewFileMsgCell:cell andMessageFrame:messageFrame andConvRecord:_convRecord];
        }else if (_convRecord.isRobotImgTxtMsg){
            UIView *parentView = [cell.contentView viewWithTag:new_imgtxt_parent_view_tag];
            parentView.frame = CGRectMake(bodyX + 2,bodyY,messageViewSize.width,messageViewSize.height);;
        }else if (_convRecord.isRobotFileMsg){
            [self adjustNewFileMsgCell:cell andMessageFrame:messageFrame andConvRecord:_convRecord];
        }
        else{
            if(_convRecord.isLinkText)
            {
                TextLinkView *linkView = (TextLinkView*)[cell.contentView viewWithTag:link_text_tag];
                messageFrame.origin.y -= 3.0;
                linkView.frame = messageFrame;
            }
            else
            {
                if(_convRecord.isTextPic)
                {
                    TextMessageView* textMessageView = (TextMessageView*)[cell.contentView viewWithTag:nolink_text_pic_tag];
                    messageFrame.origin.y -= 3.0;
                    textMessageView.frame = messageFrame;
                    
                    //                NSLog(@"bubble frame is %@ message frame is %@",NSStringFromCGRect(bubbleImageView.frame),NSStringFromCGRect(messageFrame));
                }
                else
                {
                    UILabel *normalText = (UILabel*)[cell.contentView viewWithTag:normal_text_tag];
                    messageFrame.origin.y -= 3.0;
#ifdef _LANGUANG_FLAG_
                    
                    messageFrame.origin.y += 3.0;
#endif
                    normalText.frame = messageFrame;
                }
            }
        }
	}
	else if(_convRecord.isFileMsg)
	{
        [self adjustNewFileMsgCell:cell andMessageFrame:messageFrame andConvRecord:_convRecord];
	}
	else if(_convRecord.isPicMsg || _convRecord.isRobotPicMsg)
	{
		UIImageView *showPicView=(UIImageView*)[cell.contentView viewWithTag:pic_tag];
		
        if(fromSelf)
        {
        showPicView.frame = CGRectMake(bodyX+14.0,bodyY - 8,messageViewSize.width,messageViewSize.height);
        }else
        {
        showPicView.frame = CGRectMake(bodyX-13.0,bodyY - 8,messageViewSize.width,messageViewSize.height);
        }
	}
    else if(_convRecord.isVideoMsg)
    {
        UIImageView *showPicView=(UIImageView*)[cell.contentView viewWithTag:video_tag];
        UIProgressView *progressView = (UIProgressView *)[cell.contentView viewWithTag:video_progress_tag];
        //        [bodyView setBackgroundColor:[UIColor redColor]];
        //        showPicView.frame = messageFrame;
        
        if(fromSelf)
        {
            showPicView.frame = CGRectMake(bodyX+10.0,bodyY - 8,messageViewSize.width,messageViewSize.height);
            
            progressView.frame = CGRectMake(0,messageViewSize.height - progressView.frame.size.height,progressView.frame.size.width,progressView.frame.size.height);
        }else
        {
            showPicView.frame = CGRectMake(bodyX-13.0,bodyY - 8,messageViewSize.width,messageViewSize.height);
            //            update by shisp 进度条的宽度变小了 因此x值 要增加
            progressView.frame = CGRectMake(VIDEO_MSG_PIC_ANGLE_WIDTH,messageViewSize.height - progressView.frame.size.height,progressView.frame.size.width,progressView.frame.size.height);
        }
    }
	else if(_convRecord.isRecordMsg)
	{
		UIButton *clickbutton= (UIButton*)[cell.contentView viewWithTag:audio_tag];
		clickbutton.frame = messageFrame;
	}
	else if(_convRecord.isLongMsg)
	{
		UILabel *longMsgView = (UILabel*)[cell.contentView viewWithTag:normal_text_tag];
       messageFrame.origin.y -= 3.0;
		longMsgView.frame = messageFrame;
	}
    else if(_convRecord.isImgtxtMsg || _convRecord.isWikiMsg)
    {
        if(_convRecord.isLinkText)
        {
            if (fromSelf) {
                bubbleImageView.frame = CGRectMake(bubbleImageView.frame.origin.x+7, bubbleImageView.frame.origin.y+2, bubbleImageView.frame.size.width-8, bubbleImageView.frame.size.height-9);
            }else{
                bubbleImageView.frame = CGRectMake(bubbleImageView.frame.origin.x, bubbleImageView.frame.origin.y, bubbleImageView.frame.size.width-5, bubbleImageView.frame.size.height-5);
            }
            
            DisplayImgtxtTableView *imgtxtTableView = (DisplayImgtxtTableView *)[cell.contentView viewWithTag:imgtxt_table_tag];
            messageFrame.origin.y -= 3.0;
            messageFrame.origin.x += 50.0;
            imgtxtTableView.frame = messageFrame;
            
        }
        else
        {
            if(_convRecord.isTextPic)
            {
                TextMessageView* textMessageView = (TextMessageView*)[cell.contentView viewWithTag:nolink_text_pic_tag];
                messageFrame.origin.y -= 3.0;
                textMessageView.frame = messageFrame;
                
                //                NSLog(@"bubble frame is %@ message frame is %@",NSStringFromCGRect(bubbleImageView.frame),NSStringFromCGRect(messageFrame));
            }
            else
            {
                UILabel *normalText = (UILabel*)[cell.contentView viewWithTag:normal_text_tag];
                messageFrame.origin.y -= 3.0;
                normalText.frame = messageFrame;
            }
        }
    }
	
//	如果是一户百应消息，那么要显示一呼百应消息的提示
	if(_convRecord.isReceiptMsg || _convRecord.isHuizhiMsg)
	{
        /** 已经打开的密聊消息就不再显示发送回执或者回执已发送的提示了 */
        if (_convRecord.isMiLiaoMsg && _convRecord.isMiLiaoMsgOpen) {
            
        }else{
            [self configureReceiptTips:cell convRecord:_convRecord];
            UIImageView *receiptBg = (UIImageView*)[cell.contentView viewWithTag:receipt_tag];
            CGSize receiptSize = receiptBg.frame.size;
            float receiptWidth = receiptSize.width;
            float receiptHeight = receiptSize.height;
            
            //        add by shisp 为了显示 回执消息，这里增加如下代码 回执消息的位置和bubbleX bubbleWidth bubbleHeight相关的 图片消息 因为不使用气泡，所以要重新赋值
            if (_convRecord.isPicMsg || _convRecord.isRobotPicMsg)
            {
                UIImageView *showPicView=(UIImageView*)[cell.contentView viewWithTag:pic_tag];
                
                bubbleHeight = showPicView.frame.size.height + 4;
                bubbleWidth = showPicView.frame.size.width;
                
                if (fromSelf) {
                    bubbleX = bubbleX + (bubbleImageView.frame.size.width - showPicView.frame.size.width);
                }
            }
            
            float receiptY = headY + bubbleHeight;
            if (_convRecord.isVideoMsg) {
                //            钉消息的已读和未读 距离 展示图片 太远了，因此减少了y值
                receiptY = headY + bubbleHeight - 10;
            }
            
            float receiptX;
            
            if(_convRecord.msg_flag == rcv_msg)
            {
                receiptX = headX + HEAD_TO_BUBBLE + headImageView.frame.size.width + 5;
                //			如果receiptWidth 没有 bubbleWidth
                //			if(receiptWidth > bubbleWidth)
                //			{
                //				receiptX = bubbleX;
                //			}
                //			else
                //			{
                //				receiptX = bubbleX + (bubbleWidth - receiptWidth);
                //			}
            }
            else
            {
                receiptX = (headX - HEAD_TO_BUBBLE - receiptWidth);
                //			if(receiptWidth > bubbleWidth)
                //			{
                //				receiptX = bubbleX - (receiptWidth - bubbleWidth);
                //			}
                //			else
                //			{
                //				receiptX = bubbleX;
                //			}
            }
            receiptBg.frame = CGRectMake(receiptX, receiptY, receiptWidth, receiptHeight);
        }
	}
}

#pragma mark --显示消息状态--
+(void)configureStatus:(UITableViewCell *)cell convRecord:(ConvRecord*)_convRecord
{
	UIImageView *bubbleImageView = (UIImageView*)[cell.contentView viewWithTag:bubble_send_tag];
    
	if(_convRecord.msg_flag == rcv_msg)
	{
		bubbleImageView = (UIImageView*)[cell.contentView viewWithTag:bubble_rcv_tag];
	}
	float bubbleX = bubbleImageView.frame.origin.x;
	float bubbleY = bubbleImageView.frame.origin.y;
	float bubbleHeight = bubbleImageView.frame.size.height;
	float bubbleWidth = bubbleImageView.frame.size.width;
	
    if (_convRecord.isPicMsg || _convRecord.locationModel || _convRecord.isRobotPicMsg)
    {
//        UIImageView *showPicView=(UIImageView*)[cell.contentView viewWithTag:pic_tag];
        
//        bubbleHeight = showPicView.frame.size.height + 4;
//        bubbleWidth = showPicView.frame.size.width;

        bubbleHeight = _convRecord.msgSize.height + 4;
        bubbleWidth = _convRecord.msgSize.width;

        if (_convRecord.msg_flag == send_msg) {
            bubbleX = bubbleX + (bubbleImageView.frame.size.width - _convRecord.msgSize.width);
        }
    }else if (_convRecord.isVideoMsg) {
        //    如果是视频消息 发送提示 距离 视频图片 距离较远 现在调整
        UIImageView *showPicView=(UIImageView*)[cell.contentView viewWithTag:video_tag];
        
        bubbleHeight = showPicView.frame.size.height + 4;
        bubbleWidth = showPicView.frame.size.width;
        
        if (_convRecord.msg_flag == send_msg) {
            bubbleX = bubbleX + (bubbleImageView.frame.size.width - showPicView.frame.size.width);
        }
    }
    

    
	//	状态宽度和高度
	float statusWidth = 30;//40;
	float statusHeight = bubbleHeight;//30;
	
	bool fromSelf = true;
	if(_convRecord.msg_flag == rcv_msg)
	{
		fromSelf = false;
	}
	
	float statusX = 0;
	
    if(fromSelf)
    {
        statusX = bubbleX - statusWidth;
//        if (_convRecord.isVideoMsg) {
//            //            如果是发送视频消息，那么x值减少5
//            statusX = bubbleX - statusWidth - 5;
//        }
        
        if (_convRecord.isHuizhiMsg) {
            // 获取回执消息宽度
            UIImageView *receiptBGView = (UIImageView *)[cell.contentView viewWithTag:receipt_tag];

            statusX = statusX - receiptBGView.bounds.size.width - MSG_RECEIPT_SPACE;
        }
    }
    else
    {
        statusX = bubbleX + bubbleWidth;
//        if (_convRecord.isVideoMsg) {
//            //            如果是接收视频消息，那么x值增加5
//            statusX = bubbleX + bubbleWidth + 5;
//        }
        if (_convRecord.isHuizhiMsg) {
            // 获取回执消息宽度
            UIImageView *receiptBGView = (UIImageView *)[cell.contentView viewWithTag:receipt_tag];
            
            statusX += MSG_RECEIPT_SPACE;
        }
    }
	
	float statusY = bubbleY;
	
	//	发送文本，图片或录音时需要提示，提示按钮的位置需要垂直居中，接收图片时提示按钮在图片正中间，录音在边上
	UIView *statusView = (UIView*)[cell.contentView viewWithTag:status_tag];
	statusView.frame = CGRectMake(statusX, statusY, statusWidth, statusHeight);
	statusView.hidden = NO;
    
    //        判断是否是钉消息
    UIImageView *dingxiaoxiImage = (UIImageView *)[cell.contentView viewWithTag:status_dingxiaoxi_flag_tag];
    dingxiaoxiImage.hidden = YES;
    
    //    钉消息图标height
    float dingxiaoxiImageHeight = 0.0;
    
    if (_convRecord.isHuizhiMsg) {
        
        dingxiaoxiImage.hidden = NO;
        NSString *imageName = @"rcv_dingxiaoxi_flag.png";
        if (fromSelf) {
            imageName = @"send_dingxiaoxi_flag.png";
        }
        dingxiaoxiImage.image = [StringUtil getImageByResName:imageName];
        dingxiaoxiImage.frame = CGRectMake((statusWidth - DINGXIAOXI_IMAGE_SIZE) * 0.5, DINGXIAOXI_IMAGE_Y, DINGXIAOXI_IMAGE_SIZE, DINGXIAOXI_IMAGE_SIZE);
        
        dingxiaoxiImageHeight = DINGXIAOXI_IMAGE_Y + DINGXIAOXI_IMAGE_SIZE;
    }

    int spinnerX = statusWidth - FAIL_BTN_SIZE - FAIL_BTN_SPACE;
    int spinnerY = bubbleHeight - FAIL_BTN_SIZE - FAIL_BTN_SPACE;
    
	if(fromSelf)
	{
		//	失败按钮的位置和提示的位置，都要根据内容的高度不同，y值不同
		//		如果是发送长消息，那么发送提示和重发提示按钮都放在最下面，就是y值不同
		int failBtnY = (bubbleHeight - FAIL_BTN_SIZE)/2;
        int failBtnX = statusWidth - FAIL_BTN_SIZE - FAIL_BTN_SPACE;
        if (bubbleHeight > MSG_MIN_SINGLE_ROW_HEIGHT) {
            failBtnY = bubbleHeight - FAIL_BTN_SIZE - FAIL_BTN_SPACE;
        }
		
        if (!dingxiaoxiImage.hidden) {
            if (dingxiaoxiImageHeight > failBtnY) {
                failBtnY = dingxiaoxiImageHeight;
            }
        }

		// 消息发送失败的按钮
		UIImageView *failView=(UIImageView*)[cell.contentView viewWithTag:status_failBtn_tag];
		failView.frame = CGRectMake(failBtnX,failBtnY, FAIL_BTN_SIZE, FAIL_BTN_SIZE);
		
		// 发送录音时需要一个view，提示用户正在上传录音
		//		现在是发送图片，录音和文字都需要上传提示
		
		UIActivityIndicatorView *spinner = (UIActivityIndicatorView*)[cell.contentView viewWithTag:status_spinner_tag];
//		int spinnerY = (bubbleHeight - spinner.frame.size.height)/2;
        
//		if(_convRecord.msg_type == type_long_msg)
//		{
//			spinnerY = (bubbleHeight - single_line_height * 2);
//		}
        if (bubbleHeight <= MSG_MIN_SINGLE_ROW_HEIGHT) {
            spinnerY = (bubbleHeight - spinner.frame.size.height) / 2;
        }else if (_convRecord.msg_type == type_file) {
            spinnerY -= spinner.frame.size.height;
        }
        
        if (!dingxiaoxiImage.hidden) {
            if (dingxiaoxiImageHeight > spinnerY) {
                spinnerY = dingxiaoxiImageHeight;
            }
        }
        
		spinner.frame = CGRectMake(spinnerX ,spinnerY,FAIL_BTN_SIZE,FAIL_BTN_SIZE);
		spinner.hidden = NO;
 	}
	else
	{
        int failBtnY = (bubbleHeight - FAIL_BTN_SIZE)/2;
        if (bubbleHeight > MSG_MIN_SINGLE_ROW_HEIGHT) {
            failBtnY = bubbleHeight - FAIL_BTN_SIZE - FAIL_BTN_SPACE;
        }
		// 文件下载失败按钮
		UIImageView *failView=(UIImageView*)[cell.contentView viewWithTag:status_failBtn_tag];
		failView.frame =CGRectMake(FAIL_BTN_SPACE, failBtnY, FAIL_BTN_SIZE, FAIL_BTN_SIZE);
		
		// 下载录音时需要一个view，提示用户正在下载录音
		UIActivityIndicatorView *spinner = (UIActivityIndicatorView*)[cell.contentView viewWithTag:status_spinner_tag];
        if (bubbleHeight <= MSG_MIN_SINGLE_ROW_HEIGHT) {
            spinnerY = (bubbleHeight - spinner.frame.size.height) / 2;
        }else if (_convRecord.msg_type == type_file) {
            spinnerY -= spinner.frame.size.height;
        }
        
		spinner.frame = CGRectMake(FAIL_BTN_SPACE ,spinnerY,FAIL_BTN_SIZE,FAIL_BTN_SIZE);
		spinner.hidden = NO;
		
		//		在这里需要判断，如果是收到的录音消息，那么需要判断，是否显示未读标志
        UIImageView *redimage=(UIImageView*)[cell.contentView viewWithTag:status_audio_tag];
		redimage.frame =CGRectMake(FAIL_BTN_SPACE, 16, 8, 8);
		redimage.hidden = YES;
        
        if (!dingxiaoxiImage.hidden) {
            failView.frame =CGRectMake((statusWidth - FAIL_BTN_SIZE) * 0.5,dingxiaoxiImageHeight, FAIL_BTN_SIZE, FAIL_BTN_SIZE);
            
            spinner.frame = CGRectMake((statusWidth - spinner.frame.size.width) * 0.5,dingxiaoxiImageHeight,spinner.frame.size.width,spinner.frame.size.height);
            
            redimage.frame =CGRectMake((statusWidth - 8) * 0.5, dingxiaoxiImageHeight, 8, 8);
        }

        
 	}
    
    if (_convRecord.isMiLiaoMsg) {
        
        if (_convRecord.miLiaoMsgLeftTime) {
            UILabel *miLiaoMsgLeftTimeLabel = (UILabel *)[cell.contentView viewWithTag:status_miliaomsg_lefttime];
            CGRect _frame = miLiaoMsgLeftTimeLabel.frame;
            _frame.origin.y = statusHeight - _frame.size.height - 5;
            miLiaoMsgLeftTimeLabel.frame = _frame;

            miLiaoMsgLeftTimeLabel.text = [NSString stringWithFormat:@"%dS",_convRecord.miLiaoMsgLeftTime];
            miLiaoMsgLeftTimeLabel.hidden = NO;
            
            miLiaoMsgLeftTimeLabel.textAlignment = NSTextAlignmentCenter;
        }
    }
}

#pragma mark --配置一呼百应消息提示--
+(void)configureReceiptTips:(UITableViewCell *)cell convRecord:(ConvRecord*)_convRecord
{
	NSString *receiptTips = _convRecord.receiptTips;
    
    UIFont *_font = [UIFont systemFontOfSize:MSG_RECEIPT_FONTSIZE];
    
    CGSize size = [receiptTips sizeWithFont:_font];
	
	//	提示信息的宽度和高度
	float labelWidth = size.width+14;
	float labelHeight = size.height;
	
	//	提示信息相对背景的起始位置
	float labelX = 0;
	float labelY = 3;
	
	//	背景的宽度和高度
	float bgWidth = labelWidth + 2*labelX;
	float bgHeight = labelHeight + 2*labelY;
	
	UIImageView *receiptBg = (UIImageView*)[cell.contentView viewWithTag:receipt_tag];
	receiptBg.frame = CGRectMake(0, 0, bgWidth, bgHeight );
	receiptBg.hidden = NO;
	
	
	//		增加显示提示信息
	UILabel *receiptLabel= (UILabel*)[cell.contentView viewWithTag:receipt_text_tag];
	receiptLabel.text = receiptTips;
	receiptLabel.frame = CGRectMake(labelX, labelY,labelWidth, labelHeight);
	receiptLabel.hidden = NO;
    
    receiptLabel.textColor = [self getReceiptTipsColorOfActive];

    if (_convRecord.isReceiptMsg) {
        if (_convRecord.msg_flag == rcv_msg) {
            receiptLabel.textColor = [self getReceiptTipsColorOfInActive];
        }
    }
    else if (_convRecord.isHuizhiMsg)
    {
        //    增加判断 如果是发送的消息 显示激活的颜色 如果是收到的消息，那么还未发送回执，显示激活；已经发送了回执，则使用非激活颜色
        if (_convRecord.msg_flag == rcv_msg && _convRecord.readNoticeFlag == 1) {
            receiptLabel.textColor = [self getReceiptTipsColorOfInActive];
        }
    }
}

#pragma mark ===========================================================================================================

#pragma mark 设置聊天记录的部门属性
+(void)setPropertyOfConvRecord:(ConvRecord*)_convRecord
{
    if (_convRecord.isMiLiaoMsg) {
        [[MiLiaoUtilArc getUtil]setMiLiaoPropertyOfRecord:_convRecord];
        
    }
	_convRecord.tryCount = 0;
	_convRecord.msgTimeDisplay = [StringUtil getDisplayTime_day:_convRecord.msg_time];
	if(_convRecord.isTextMsg)
	{
        [self preProcessTextMsg:_convRecord];
        if (_convRecord.locationModel || _convRecord.cloudFileModel || _convRecord.replyOneMsgModel) {
            return;
        }
#ifdef _LANGUANG_FLAG_
        [talkSessionUtil preProcessredPacketMsg:_convRecord];
        if (_convRecord.redPacketModel) {
            return;
        }
        [talkSessionUtil preProcessMettingAppMsg:_convRecord];
        if (_convRecord.newsModel) {
            return;
        }
#endif
    }
    
    if (_convRecord.isTextMsg) {
        [self preProcessRobotMsg:_convRecord];
    
		NSString *messageStr = _convRecord.msg_body;
        _convRecord.isTextPic = false;
        _convRecord.isLinkText = false;
		NSError *error = NULL;
        
        if (_convRecord.robotModel) {
            if (_convRecord.robotModel.msgType == type_text) {
                _convRecord.msg_body = _convRecord.robotModel.content;
                _convRecord.isLinkText = true;
            }else if (_convRecord.isRobotFileMsg){
                
                NSString *robotFileName = _convRecord.robotModel.msgFileName;
                NSString *robotFileSize = _convRecord.robotModel.msgFileSize;
                
                _convRecord.file_name = robotFileName;
                
                NSString *displayStr = [NSString stringWithFormat:@"%@(%@)",_convRecord.file_name,robotFileSize];
                _convRecord.fileNameAndSize = displayStr;

                
                //                设置文件是否存在
//                NSString *fileUrl = _convRecord.robotModel.msgFileDownloadUrl;
                
                NSString *robotFilePath = [RobotUtil getDownloadFilePathWithConvRecord:_convRecord];
                if ([[NSFileManager defaultManager]fileExistsAtPath:robotFilePath]) {
                    _convRecord.isFileExists = YES;
                    _convRecord.download_flag = state_download_success;
                }else{
                    [[RobotFileUtil getUtil]setDownloadPropertyOfRecord:_convRecord];
                    
                    if (_convRecord.isDownLoading) {
                        //                        正在下载
                    }else{
//                        还没有开始下载，需要点击的时候下载
                    }
                }
            }
        }else{
            NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink|NSTextCheckingTypePhoneNumber error:&error];
            NSUInteger numberOfMatches = [detector numberOfMatchesInString:messageStr options:0 range:NSMakeRange(0, [messageStr length])];
            
            if(numberOfMatches == 0)
            {
                MessageView *messageView = [MessageView getMessageView];
                //	把文字和表情分开
                NSMutableArray *data = [NSMutableArray array];
                [messageView getImageRange:messageStr:data];
                
                if (data.count > 1) {
                    //                    一定是包含了表情
                    _convRecord.isTextPic = true;
                    _convRecord.textMsgArray = data;
                }else if (data.count == 1){
                    //                    判断是否包含表情
                    NSString *temp = data[0];
                    
                    NSRange range=[temp rangeOfString: BEGIN_FLAG];
                    NSRange range1=[temp rangeOfString: END_FLAG];
                    //判断当前字符串是否还有表情的标志。
                    if (range.length>0 && range1.length>0 && range.location < range1.location)
                    {
                        _convRecord.isTextPic = true;
                        _convRecord.textMsgArray = data;
                    }
                }
                //
                //                NSRange range=[messageStr rangeOfString: BEGIN_FLAG];
                //                NSRange range1=[messageStr rangeOfString: END_FLAG];
                //                //判断当前字符串是否还有表情的标志。
                //                if (range.length>0 && range1.length>0 && range.location < range1.location)
                //                {
                //                    _convRecord.isTextPic = true;
                //                    //					NSLog(@"text pic message is %@ ",messageStr);
                //                }
                //                else
                //                {
                //                    _convRecord.isTextPic = false;
                //                }
                
            }
            else
            {
                _convRecord.isLinkText = true;
            }
        }
	}
    else if (_convRecord.isVideoMsg)
    {
        NSString *filePath = [self getVideoPath:_convRecord];
        _convRecord.isVideoExist = false;
        if([[NSFileManager defaultManager] fileExistsAtPath:filePath]==YES)
        {
            _convRecord.isVideoExist = true;
        }
        //                如果是视频 那么不自动下载 如果是移动网络 需要提示用户 所以给fileNameAndSize属性赋值
        NSString *fileSize = [StringUtil getDisplayFileSize:_convRecord.file_size.intValue];
        
        NSString *displayStr = [NSString stringWithFormat:@"%@(%@)",_convRecord.file_name,fileSize];
        _convRecord.fileNameAndSize = displayStr;
    }else if(_convRecord.isRecordMsg)
	{
		NSString *filePath = [self getAudioPath:_convRecord];
		if([[NSFileManager defaultManager] fileExistsAtPath:filePath]==YES)
		{
			_convRecord.isAudioExist = true;
		}
		else
		{
			filePath = 	[kRecorderDirectory stringByAppendingPathComponent:_convRecord.file_name];
			
			if([[NSFileManager defaultManager]fileExistsAtPath:filePath])
			{
				_convRecord.isAudioExist = true;
			}
			else
			{
				_convRecord.isAudioExist = false;
			}
		}
	}
	else if(_convRecord.isFileMsg)
	{
        NSString *msgId = [NSString stringWithFormat:@"%i",_convRecord.msgId];
		NSString *filePath = [[StringUtil newRcvFilePath]stringByAppendingPathComponent:[self getFileName:_convRecord]];
        NSString *fileTempPath = [[StringUtil newRcvFileTemPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@.zip",msgId,[self getFileName:_convRecord]]];
        
        // 对小万记录的文档做特殊处理 [[RobotDAO getDatabase]isRobotUser:_convRecord.conv_id.intValue]
//        if ([[RobotDAO getDatabase]getRobotId] == _convRecord.conv_id.intValue)
//        {
//            RobotResponseXmlParser *robotParser = [[[RobotResponseXmlParser alloc]init]autorelease];
//            bool result = [robotParser parse:[_convRecord msg_body] andIsParseAgent:YES];
//            
//            if (result || _convRecord.robotModel != nil) {
//                if (result) {
//                    if([@"videomsg" isEqualToString:robotParser.robotModel.nameString]){
////                        NSMutableString *fileSizeTmp = robotParser.robotModel.argsArray[5];
////                        fileSizeTmp = [fileSizeTmp substringToIndex: fileSizeTmp.length-3];
////                        NSLog(@"fileSizeTmp = %@,filesize = %ld,filesize=%ld",fileSizeTmp,[fileSizeTmp floatValue],14.7*1024*1024);
//                        
//                        _convRecord.file_name = [NSString stringWithFormat:@"robot_%@",robotParser.robotModel.argsArray[3]];
//                        _convRecord.file_size = _convRecord.robotModel.argsArray[5];
//                    }
//                }
//                filePath = [[StringUtil newRcvFilePath]stringByAppendingPathComponent:_convRecord.file_name];
//                fileTempPath = [[StringUtil newRcvFileTemPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@.zip",msgId,[_convRecord.file_name stringByDeletingPathExtension]]];
//            }
//        }
		if([[NSFileManager defaultManager] fileExistsAtPath:filePath]){
			_convRecord.isFileExists = YES;
            
            _convRecord.download_flag = state_download_success;
            [[FileAssistantDOA getDatabase] updateDownloadStateWithDownloadid:msgId withState:state_download_success];
            
            //对同一个文件的多次下载，需要解除同一个文件的多个下载
            [[talkSessionUtil2 getTalkSessionUtil] removeRecordFromDownloadList:_convRecord.msgId];
		}
        else if([[NSFileManager defaultManager] fileExistsAtPath:fileTempPath]){
            //缓存目录有文件，说明文件正在下载或暂停
            _convRecord.isFileExists = NO;
            
            DownloadFileModel *fileMode = [[FileAssistantDOA getDatabase] getDownloadFileWithUploadid:msgId];
            if (fileMode.download_id) {
                int uploadstate =  fileMode.download_state;
                _convRecord.download_flag = uploadstate;
            }
        }
		else{
			_convRecord.isFileExists = NO;
            if (_convRecord.send_flag == send_upload_nonexistent) {
                //文件不存在
                _convRecord.download_flag = state_download_nonexistent;
            }
            else{
                _convRecord.download_flag = state_download_unknow;
                [[FileAssistantDOA getDatabase] updateDownloadStateWithDownloadid:msgId withState:state_download_unknow];
            }
		}
        
		NSString *fileSize = [StringUtil getDisplayFileSize:_convRecord.file_size.intValue];
		
		NSString *displayStr = [NSString stringWithFormat:@"%@(%@)",_convRecord.file_name,fileSize];
		_convRecord.fileNameAndSize = displayStr;
	}
	else if(_convRecord.isPicMsg)
	{
        if (_convRecord.recordType == normal_conv_record_type || _convRecord.recordType == mass_conv_record_type || (_convRecord.recordType == ps_conv_record_type && _convRecord.msg_flag == send_msg))
        {
            NSString *picpath = [self getBigPicPath:_convRecord];
            if([[NSFileManager defaultManager] fileExistsAtPath:picpath])
            {
                _convRecord.isBigPicExist = true;
            }
            else
            {
                _convRecord.isBigPicExist = false;
            }
            
            picpath = [self getSmallPicPath:_convRecord];
            if([[NSFileManager defaultManager] fileExistsAtPath:picpath])
            {
                _convRecord.isSmallPicExist = true;
            }
            else
            {
                _convRecord.isSmallPicExist = false;
            }
        }
        else if (_convRecord.recordType == ps_conv_record_type && _convRecord.msg_flag == rcv_msg)
        {
//            update by shisp 只有收到的图片消息 才 特殊处理
            NSString *imagePath = [PSMsgUtil getPSPicMsgImagePath:_convRecord];
            if([[NSFileManager defaultManager] fileExistsAtPath:imagePath])
            {
                _convRecord.isBigPicExist = true;
            }
            else
            {
                _convRecord.isBigPicExist = false;
            }
        }
	}
	else if(_convRecord.isLongMsg)
	{
		NSString *filePath = [self getLongMsgPath:_convRecord];
		bool isFileExists = [[NSFileManager defaultManager]fileExistsAtPath:filePath];
		if(isFileExists)
		{
			_convRecord.isLongMsgExist = true;
		}
		else
		{
			_convRecord.isLongMsgExist = false;
		}
	}
    else if(_convRecord.isImgtxtMsg || _convRecord.isWikiMsg)
    {
        NSString *messageStr = _convRecord.msg_body;
        NSError *error = NULL;
        NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink|NSTextCheckingTypePhoneNumber error:&error];
        NSUInteger numberOfMatches = [detector numberOfMatchesInString:messageStr options:0 range:NSMakeRange(0, [messageStr length])];
        
        if(numberOfMatches == 0)
        {
            _convRecord.isLinkText = false;
            
            NSRange range=[messageStr rangeOfString: BEGIN_FLAG];
            NSRange range1=[messageStr rangeOfString: END_FLAG];
            //判断当前字符串是否还有表情的标志。
            if (range.length>0 && range1.length>0 && range.location < range1.location)
            {
                _convRecord.isTextPic = true;
                //					NSLog(@"text pic message is %@ ",messageStr);
            }
            else
            {
                _convRecord.isTextPic = false;
            }
            
        }
        else
        {
            _convRecord.isLinkText = true;
            //			_convRecord.isTextPic = true;
        }
    }
}

+(NSString*)getBigPicPath:(ConvRecord*)_convRecord
{
	NSString *picname=[NSString stringWithFormat:@"%@.png",_convRecord.msg_body];
    // [[RobotDAO getDatabase]isRobotUser:_convRecord.conv_id.intValue]
    if ([[RobotDAO getDatabase]getRobotId] == _convRecord.conv_id.intValue || [_convRecord.msg_body rangeOfString:@"imgmsg"].length > 0) {
        picname = _convRecord.file_name;
    }
    
	NSString *fileName = [[StringUtil newRcvFilePath] stringByAppendingPathComponent:picname];
	return fileName;
}

+(NSString*)getSmallPicPath:(ConvRecord*)_convRecord
{
	NSString *picname=[NSString stringWithFormat:@"small%@.png",_convRecord.msg_body];
    // [[RobotDAO getDatabase]isRobotUser:_convRecord.conv_id.intValue]
    if ([[RobotDAO getDatabase]getRobotId] == _convRecord.conv_id.intValue || [_convRecord.msg_body rangeOfString:@"imgmsg"].length > 0) {
        picname = [NSString stringWithFormat:@"small%@",_convRecord.file_name];
    }
	NSString *fileName = [[StringUtil newRcvFilePath] stringByAppendingPathComponent:picname];
	return fileName;
}

+(NSString*)getAudioPath:(ConvRecord*)_convRecord
{
	NSString *fileName = _convRecord.file_name;
	NSString *filePath = [[StringUtil newRcvFilePath] stringByAppendingPathComponent:fileName];
	return filePath;
}
+ (NSString *)getVideoPath:(ConvRecord*)_convRecord
{
    return [self getAudioPath:_convRecord];
}

+(NSString*)getLongMsgPath:(ConvRecord*)_convRecord
{
	NSString *fileName=[NSString stringWithFormat:@"%@.txt",_convRecord.msg_body];
	NSString *filePath = [[StringUtil newRcvFilePath] stringByAppendingPathComponent:fileName];
	return filePath;
}
+(UIImage*)getEmpLogo:(ConvRecord*)recordObject andHeadView:(UIImageView*)headView
{
	Emp *emp = [[Emp alloc]init];
	emp.emp_id = recordObject.emp_id;
	emp.empCode = recordObject.emp_code;
	emp.emp_logo = recordObject.emp_logo;
	emp.emp_sex = recordObject.emp_sex;
	emp.emp_status = recordObject.empStatus;
	emp.loginType = recordObject.empLoginType;
	emp.emp_name = recordObject.emp_name;
	
	UIImage *image = nil;
	NSString *empLogo = emp.emp_logo;
	if(empLogo && [empLogo length] > 0)
	{
        if ([[MiLiaoUtilArc getUtil]isMiLiaoConv:recordObject.conv_id])
        {
//            不再使用生成的马赛克头像
//            NSString *empId = [[MiLiaoUtilArc getUtil] getEmpIdWithMiLiaoConvId:recordObject.conv_id];
//            NSString *imagePath = [StringUtil getProcessLogoFilePathBy:empId andLogo:@"0"];
//            image = [UIImage imageWithContentsOfFile:imagePath];
        }
        else
        {
            image = [ImageUtil getLogo:emp];
        }
	}
    
	if(image == nil)
    {
        if ([[MiLiaoUtilArc getUtil]isMiLiaoConv:recordObject.conv_id]){
            image = [ImageUtil getDefaultMiLiaoLogo:emp];
        }else{
            image = [ImageUtil getDefaultLogo:emp];
        }
    }
//	{
//		NSDictionary *dic = [[eCloudDAO getDatabase]searchEmp:[StringUtil getStringValue:recordObject.emp_id]];
//		empLogo = [dic valueForKey:@"emp_logo"];
//		emp.emp_logo = empLogo;
//		recordObject.emp_logo = empLogo;
//		if(empLogo && [empLogo length] > 0)
//		{
//			image = [ImageUtil getLogo:emp];
//		}
//		if(image == nil)
//		{
//			image = [ImageUtil getDefaultLogo:emp];
//		}
//	}
	
    if ([recordObject.conv_id isEqualToString:File_ID]) {
        
        /** 2是文件助手id，和文件助手会话，需要把自己的头像改成固定头像 */
        if (emp.emp_id != 2) {
            
            image = [StringUtil getImageByResName:@"ic_contact_mobile.png"];
        }
        
    }
	[UserDisplayUtil displayLittleView:headView andEmp:emp];
	
	[emp release];
	return image;
}

#pragma mark 图片裁剪，上传
+(CGSize)getImageSizeAfterCropForUpload:(UIImage*)image
{
	float width = image.size.width;
	float height = image.size.height;
	
	float aspect = width/height;
	int maxWidth = SCREEN_WIDTH;
	int maxHeight = SCREEN_HEIGHT;
//	if(IS_IPHONE_5)
//        maxHeight = SCREEN_HEIGHT;
//    else if (IS_IPHONE_6){
//        maxWidth = SCREEN_WIDTH * 2;
//        maxHeight = SCREEN_HEIGHT * 2;
//    }else if (IS_IPHONE_6P){
//        maxWidth = SCREEN_WIDTH * 3;
//        maxHeight = SCREEN_HEIGHT * 3;
//    }
    
    [LogUtil debug:[NSString stringWithFormat:@"%s maxWidth is %d maxHeight is %d",__FUNCTION__,maxWidth,maxHeight]];
	
	bool needCrop = false;
	
	if(aspect > 1)
	{//横向图片
		if(width > maxWidth)
		{
			width = maxWidth;
			height = maxWidth / aspect;
			needCrop = true;
		}
	}
	else
	{//纵向图片
		if(height > maxHeight)
		{
			height = maxHeight;
			width = maxHeight * aspect;
			needCrop = true;
		}
	}
	
	if(needCrop)
	{
		CGSize size = CGSizeMake(width, height);
		return size;
	}
	return CGSizeZero;
}


#pragma mark 图片裁剪，上传 1080
+(CGSize)getImageSizeAfterCropForKapod:(UIImage*)image
{
    return [talkSessionUtil getImageSizeAfterCropForUpload:image];
//    
//	float width = image.size.width;
//	float height = image.size.height;
//	NSLog(@"---width,height ---  %f  , %f",width,height);
//	float aspect = height/width;
//	int maxWidth = 1080;
//    
//    if (width>maxWidth)
//    {
//        CGSize size = CGSizeMake(maxWidth,maxWidth*aspect);
//		return size;
//    }
//    else
//    {
//        CGSize size = image.size;
//		return size;
//    }
//	return CGSizeZero;
}


#pragma mark 检查图片是否需要裁减，如果需要则返回裁减后的尺寸
+(CGSize)getImageSizeAfterCrop:(UIImage*)image
{
    return [talkSessionUtil getImageSizeAfterCropForUpload:image];
//
//	float width = image.size.width;
//	float height = image.size.height;
//	
//	float aspect = width/height;
//	int maxWidth = SCREEN_WIDTH;
//	int maxHeight = SCREEN_HEIGHT;
////	if(iPhone5)
////		maxHeight = 1136;
//	
//	bool needCrop = false;
//	
//	if(aspect > 1)
//	{//横向图片
//		if(width > maxWidth)
//		{
//			width = maxWidth;
//			height = maxWidth / aspect;
//			needCrop = true;
//		}
//	}
//	else
//	{//纵向图片
//		if(height > maxHeight)
//		{
//			height = maxHeight;
//			width = maxHeight * aspect;
//			needCrop = true;
//		}
//	}
//	
//	if(needCrop)
//	{
//		CGSize size = CGSizeMake(width, height);
//		return size;
//	}
//	return CGSizeZero;
}

+(void)hideProgressView:(UIProgressView*)progressView
{
	//		设置进度条为透明
    progressView.alpha = 0;
}

+(void)displayProgressView:(UIProgressView*)progressView
{
	//		显示进度条
	progressView.alpha = 1;
}

#pragma mark 获取文件的扩展名
+(NSString*)getFileExt:(ConvRecord*)_convRecord
{
	NSString *file_Ext = nil;
	NSString *originFileName = _convRecord.file_name;
	NSRange _range = [originFileName rangeOfString:@"." options:NSBackwardsSearch];
	if(_range.length > 0)
	{
		file_Ext = [originFileName substringFromIndex:_range.location+1];
	}
	return file_Ext;
}

#pragma mark 获取推送消息的视频文件名称
+(NSString*)getNewsVideoName:(ConvRecord*)_convRecord
{
#ifdef _XINHUA_FLAG_
    NSString *str = @"";
    if ([_convRecord.systemMsgModel.msgType isEqualToString:TYPE_VOICE])
    {
        str = _convRecord.systemMsgModel.msgBody;
    }
    else if ([_convRecord.systemMsgModel.msgType isEqualToString:TYPE_VIDEO])
    {
        str = _convRecord.systemMsgModel.urlStr;
    }
    
    NSArray *arr = [str componentsSeparatedByString:@"/"];
    
    if (arr.count) {
        return [arr lastObject];
    }
#endif
    return @"";
}

#pragma mark 获取文件消息的文件名称，在原名字的基础上增加了文件url，以防名字重复
#pragma mark 如果是本地发送的文件，会在URL后面附加一个_,获取文件名称时不用和URL合并
+(NSString*)getFileName:(ConvRecord*)_convRecord
{
	NSString *fileName;
	
    NSString *msgBodyStr = _convRecord.msg_body;
    NSString *msgBody = @"";
	
	NSString *originFileName = _convRecord.file_name;
    
//    如果是本地发送的文件，那么会在URL后面附加一个_,直接返回文件名称即可
    NSRange range = [msgBodyStr rangeOfString:@"_"];
    if(range.length > 0 ){
        //        NSLog(@"是本地发送的文件，直接返回文件名称即可");
        //        return originFileName;
        msgBody = [msgBodyStr substringToIndex:range.location];
    }
    else{
        msgBody = msgBodyStr;
    }
	NSRange _range = [originFileName rangeOfString:@"." options:NSBackwardsSearch];
	if(_range.length > 0)
	{
		NSString *file_Ext = [originFileName substringFromIndex:_range.location+1];
		NSString *file_name = [originFileName substringToIndex:_range.location];
        
        NSRange _bodyRange = [msgBody rangeOfString:@"." options:NSBackwardsSearch];
        if(_bodyRange.length > 0){
            fileName = [NSString stringWithFormat:@"%@_%@",file_name,msgBody];
        }
        else{
            fileName = [NSString stringWithFormat:@"%@_%@.%@",file_name,msgBody,file_Ext];
        }
	}
	else
	{
		fileName = [NSString stringWithFormat:@"%@_%@",originFileName,msgBody];
	}
//	[LogUtil debug:[NSString stringWithFormat:@"%s,%@",__FUNCTION__,fileName]];
	
	return fileName;
}

#pragma mark 下载完文件后，如果是txt文件那么需要进行转码
+(void)transferFile:(ConvRecord*)_convRecord
{
	if(!_convRecord.isFileMsg)
		return;
	NSString *ext = [self getFileExt:_convRecord];
	if([ext isEqualToString:@"txt"])
	{
		NSString *originPath = [[StringUtil newRcvFilePath]stringByAppendingPathComponent:[self getFileName:_convRecord]];
		//				首先读下载下来的文件内容
		NSFileHandle *inputFileHandle = [NSFileHandle fileHandleForReadingAtPath:originPath];
		NSData *data = [inputFileHandle readDataToEndOfFile];
		//				对内容进行转码
		NSStringEncoding encoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
		NSString *convertData = [[NSString alloc] initWithData:data encoding:encoding];
//		if(convertData == nil)
//		{
//			NSStringEncoding encoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingMacChineseSimp);
//			 convertData = [[NSString alloc] initWithData:data encoding:encoding];
//		}
		//把转码后的内容写到新文件
		NSString *newPath = [[StringUtil newRcvFilePath]stringByAppendingPathComponent:[NSString stringWithFormat:@"new_%@",[self getFileName:_convRecord]]];
		bool success = [convertData writeToFile:newPath atomically:YES encoding:NSUTF16StringEncoding error:nil];
		//				关闭原始文件
		[inputFileHandle closeFile];
		inputFileHandle = nil;
		
		//				把文件更新为转码后的文件
		if(success)
		{
			if([[NSFileManager defaultManager]removeItemAtPath:originPath error:nil])
			{
				if([[NSFileManager defaultManager]moveItemAtPath:newPath toPath:originPath error:nil])
				{
					[LogUtil debug:@"文件转码成功"];
				}
				else
				{
					[LogUtil debug:@"把转码后的文件重命名失败"];
				}
			}
			else
			{
				[LogUtil debug:@"删除原始文件失败"];
			}
		}
		else
		{
			[LogUtil debug:@"保存转码文件失败"];
		}
		[convertData release];
	}
}

+(void)sendReadNotice:(ConvRecord*)convRecord
{
    conn *_conn = [conn getConn];

//    不再自动发送已读，修改为手动发送
    /** 如果是已经打开的密聊消息也自动发送已读 */
    if(convRecord.msg_flag == rcv_msg && convRecord.readNoticeFlag == 0 && (convRecord.isReceiptMsg || (convRecord.isHuizhiMsg && [eCloudConfig getConfig].autoSendMsgReadOfHuizhiMsg) || (convRecord.isMiLiaoMsg && convRecord.isMiLiaoMsgOpen)))
    {
        if (convRecord.isMiLiaoMsg) {
            switch (convRecord.msg_type) {
                case type_pic:
                {
                    if (convRecord.isSmallPicExist) {
                        [_conn sendMsgReadNotice:convRecord];
                    }
                }
                    break;
                case type_record:{
                    if(convRecord.isAudioExist){
                        [_conn sendMsgReadNotice:convRecord];
                    }
                }
                    break;
                case type_video:{
                    if(convRecord.isVideoExist){
                        [_conn sendMsgReadNotice:convRecord];
                    }
                }
                    break;
                    
                default:
                    break;
            }
        }else{
            [_conn sendMsgReadNotice:convRecord];
        }
    }
}

+ (CGFloat)measureHeightOfUITextView:(UITextView *)textView
{
    if ([textView respondsToSelector:@selector(snapshotViewAfterScreenUpdates:)])
    {
        // This is the code for iOS 7. contentSize no longer returns the correct value, so
        // we have to calculate it.
        //
        // This is partly borrowed from HPGrowingTextView, but I've replaced the
        // magic fudge factors with the calculated values (having worked out where
        // they came from)
        
        CGRect frame = textView.bounds;
        
        // Take account of the padding added around the text.
        
        UIEdgeInsets textContainerInsets = textView.textContainerInset;
        UIEdgeInsets contentInsets = textView.contentInset;
        
        CGFloat leftRightPadding = textContainerInsets.left + textContainerInsets.right + textView.textContainer.lineFragmentPadding * 2 + contentInsets.left + contentInsets.right;
        CGFloat topBottomPadding = textContainerInsets.top + textContainerInsets.bottom + contentInsets.top + contentInsets.bottom;
        
        frame.size.width -= leftRightPadding;
        frame.size.height -= topBottomPadding;
        
        NSString *textToMeasure = textView.text;
        if ([textToMeasure hasSuffix:@"\n"])
        {
            textToMeasure = [NSString stringWithFormat:@"%@-", textView.text];
        }
        
        // NSString class method: boundingRectWithSize:options:attributes:context is
        // available only on ios7.0 sdk.
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
        
        NSDictionary *attributes = @{ NSFontAttributeName: textView.font, NSParagraphStyleAttributeName : paragraphStyle };
        
        CGRect size = [textToMeasure boundingRectWithSize:CGSizeMake(CGRectGetWidth(frame), MAXFLOAT)
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                               attributes:attributes
                                                  context:nil];
        [paragraphStyle release];
        CGFloat measuredHeight = ceilf(CGRectGetHeight(size) + topBottomPadding);
        return measuredHeight;
    }
    else
    {
        return textView.contentSize.height;
    }
}

//如果文本消息里有很多空格，使用现有的方式计算文本消息的size不正确，要使用新的方式 不过新的方式也没有用处
+ (CGSize)getSizeOfTextMsg:(NSString *)textMsg withFont:(UIFont*)textFont withMaxWidth:(float)textMaxWidth
{
    CGSize _size;
    if ([NSString instancesRespondToSelector:@selector(boundingRectWithSize:options:attributes:context:)])
    {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
        
        NSDictionary *attributes = @{ NSFontAttributeName: textFont, NSParagraphStyleAttributeName : paragraphStyle};
        
        _size = [textMsg boundingRectWithSize:CGSizeMake(textMaxWidth, MAXFLOAT)
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                               attributes:attributes
                                                  context:nil].size;
        [paragraphStyle release];
    }
    else
    {
        _size = [textMsg sizeWithFont:textFont constrainedToSize:CGSizeMake(textMaxWidth,MAXFLOAT) lineBreakMode:UILineBreakModeWordWrap];
    }
//    如果计算出来的宽度 大于实际的宽度，则强行设置为最大宽度
    if (_size.width > textMaxWidth) {
        _size.width = textMaxWidth;
    }
    return _size;
}

+(void)sendReadNoticeByHand:(ConvRecord*)convRecord
{
    if(convRecord.msg_flag == rcv_msg && (convRecord.isReceiptMsg || convRecord.isHuizhiMsg) && convRecord.readNoticeFlag == 0)
    {
        /** 如果是未打开的密聊消息，则需要执行打开操作 */
        if (convRecord.isMiLiaoMsg && !convRecord.isMiLiaoMsgOpen) {
            [[eCloudDAO getDatabase]deleteMiLiaoMsg:convRecord.msgId];
            
            //        发一个通知出来，重新加载这条消息？
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[StringUtil getStringValue:convRecord.msgId],@"MSG_ID", nil];
            
            eCloudNotification *_notificationObject = [[[eCloudNotification alloc]init]autorelease];
            _notificationObject.cmdId = open_encrypt_msg;
            _notificationObject.info = dic;
            
            [[NotificationUtil getUtil]sendNotificationWithName:CONVERSATION_NOTIFICATION andObject:_notificationObject andUserInfo:nil];
            return;
        }

        conn *_conn = [conn getConn];
        if([_conn sendMsgReadNotice:convRecord])
        {
            //			[[ReceiptDAO getDataBase]updateMsgReadNoticeFlag:convRecord];
            //			convRecord.readNoticeFlag = 1;
        }
    }
}

//修改群组名称的按钮背景颜色
+ (UIColor *)getBgColorOfModifyGroupNameButton
{
    //    邹林杨提供的颜色值 #f3f5f2
    UIColor *bgColor = [UIColor colorWithRed:0xf3/255.0 green:0xf5/255.0 blue:0xf2/255.0 alpha:1];//0.7
    return bgColor;
}

//回执模式的背景颜色
+ (UIColor *)getBgColorOfReceiptModelColor
{
#if defined(_HUAXIA_FLAG_)
                
    UIColor *bgColor = HX_LIGHT_RED_COLOR;
    
#elif defined(_ZHENGRONG_FLAG_)
    //            #018f44，透明度%60
    UIColor *bgColor = [UIColor colorWithRed:0x01 / 255.0 green:0x8f / 255.0 blue:0x44 / 255.0 alpha:0.6];
    
#elif defined(_LANGUANG_FLAG_)
    
    UIColor *bgColor = [UIColor colorWithRed:36/255.0 green:129/255.0 blue:252/255.0 alpha:0.85];
    
#else
    //    正常#669900   高亮#66cc00    白色字
    UIColor *bgColor = [UIColor colorWithRed:0x66/255.0 green:0x99/255.0 blue:0x00/255.0 alpha:0.8];    
#endif

    return bgColor;}

//回执模式的高亮背景颜色
+ (UIColor *)getHLBgColorOfReceiptModelColor
{
    
#if defined(_HUAXIA_FLAG_)
    UIColor *bgColor = HX_HIGHLIGHT_RECEIPT_COLOR;
#elif defined(_ZHENGRONG_FLAG_)
    //    万达要求另外的颜色 #03c55e  透明度60%
    UIColor *bgColor = [[UIColor alloc]initWithRed:0x03/255.0 green:0xc5/255.0 blue:0x5e/255.0 alpha:0.6];
#else
    UIColor *bgColor = [UIColor colorWithRed:36/255.0 green:129/255.0 blue:252/255.0 alpha:0.6];
#endif

    return bgColor;
}

//回执模式的字体颜色
//蓝色激活字体
+ (UIColor *)getReceiptTipsColorOfActive
{
//    #1087f7
    UIColor *_color = [UIColor colorWithRed:0x10/255.0 green:0x87/255.0 blue:0xf7/255.0 alpha:1];
    return _color;
}

//灰色非激活字体
+ (UIColor *)getReceiptTipsColorOfInActive
{
    return [StringUtil colorWithHexString:@"#A3A3A3"];
}

#pragma mark - 获取视频缩略图
+ (UIImage *)getVideoPreViewImage:(NSURL *)videoPath
{
    AVURLAsset *asset = [[[AVURLAsset alloc] initWithURL:videoPath options:nil]autorelease];
    AVAssetImageGenerator *gen = [[[AVAssetImageGenerator alloc] initWithAsset:asset]autorelease];
    gen.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(0.0, 10);
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    
    UIImage *img = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);
    
    return [img autorelease];
}
#pragma mark - 获取视频时长
+ (CGFloat) getVideoDuration:(NSURL*) URL
{
    NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                     forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:URL options:opts];
    float second = 0;
    second = urlAsset.duration.value/urlAsset.duration.timescale;
    return second;
}

#pragma mark - 删除视频
+ (void)delFileFromPath:(NSString *)filePath{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSLog(@"picpath: %@",filePath);
    BOOL success1 = [fileManager fileExistsAtPath:filePath];
    if (success1) {
        if ([fileManager removeItemAtPath:filePath error:&error] != YES){
            NSLog(@"Unable to delete file: %@", [error localizedDescription]);
        }
    }
}

#pragma mark - 时间显示格式
+ (NSString *)lessSecondToDay:(NSInteger)seconds
{
    NSInteger day  = (NSInteger)seconds/(24*3600);
    NSInteger hour = (NSInteger)(seconds%(24*3600))/3600;
    NSInteger min  = (NSInteger)(seconds%(3600))/60;
    NSInteger second = (NSInteger)(seconds%60);
    
    NSString *time = [NSString stringWithFormat:@"%02d:%02d:%02d",hour,min,second];
    if(hour == 0 && min != 0) {
        time = [NSString stringWithFormat:@"%02d:%02d",min,second];
    }else if(min == 0 && second != 0) {
        time = [NSString stringWithFormat:@"%02d:%02d",min,second];
    }
    return time;
}

//预处理 位置类型消息
+ (void)preProcessTextMsg:(ConvRecord *)_convRecord
{
    NSDictionary *dic = [_convRecord.msg_body objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode];
    if (dic == nil || ![dic isKindOfClass:[NSDictionary class]]) {
        return;
    }
    if ([dic[KEY_MSG_TYPE] isEqual:LOCATION_TYPE])  // 如果是地址信息
    {
        if (!_convRecord.locationModel) {
            LocationModel *model = [[[LocationModel alloc]init]autorelease];
            NSDictionary *locationDic = dic[LOCATION_TYPE];
            model.lantitude = [locationDic[KEY_LOCATION_LANTITUDE] doubleValue];
            model.longtitude = [locationDic[KEY_LOCATION_LONGITUDE] doubleValue];
            model.address = locationDic[KEY_LOCATION_ADDRESS];
            _convRecord.locationModel = model;
        }
    }
#ifdef _XINHUA_FLAG_
    else if(dic[KEY_SYSTEM_TYPE])
    {
        if (!_convRecord.systemMsgModel) {
            SystemMsgModelArc *systemMsgModel = [[SystemMsgModelArc alloc] init];
            NSString *type = dic[KEY_SYSTEM_TYPE];
            systemMsgModel.msgType = type;
            if ([type isEqualToString:TYPE_NEWS]) // 图文消息
            {
                NSDictionary *dictionary = dic[KEY_SYSTEM_CONTENT];
                systemMsgModel.msgBody = dictionary[KEY_SYSTEM_PIC];
                systemMsgModel.title = dictionary[KEY_SYSTEM_TITLE];
                systemMsgModel.descriptionStr = dictionary[KEY_SYSTEM_DESCRIPTION];
                systemMsgModel.urlStr = dictionary[KEY_SYSTEM_URL];
            }
            else if ([type isEqualToString:TYPE_VIDEO])
            {
                NSDictionary *dictionary = dic[KEY_SYSTEM_CONTENT];
                systemMsgModel.msgBody = dictionary[KEY_SYSTEM_PIC];
                systemMsgModel.title = dictionary[KEY_SYSTEM_TITLE];
                systemMsgModel.descriptionStr = dictionary[KEY_SYSTEM_DESCRIPTION];
                systemMsgModel.urlStr = dictionary[KEY_SYSTEM_URL];
            }
            else // 文本 、图片、视频、声音
            {
                systemMsgModel.msgBody = dic[KEY_SYSTEM_CONTENT];
            }
            
            _convRecord.systemMsgModel = systemMsgModel;
        }
    }
#endif
    else if([dic[KEY_MSG_TYPE] isEqual:KEY_REPLY_MSG_TYPE])  // 如果是定向回复信息
    {
        if (!_convRecord.replyOneMsgModel) {
            ReplyOneMsgModelArc *_model = [[ReplyOneMsgModelArc alloc]init];
            NSString *userId = [NSString stringWithFormat:@"%@",dic[KEY_REPLY_MSG_SENDER_ID]];
            Emp *emp = [[eCloudDAO getDatabase] getEmployeeById:userId];
            if (emp) {
                _model.senderName = emp.emp_name;
            }else{
                _model.senderName = @"未知用户";
            }
            
            NSNumber *msgId = dic[KEY_REPLY_MSG_MSG_ID];
            
            
            NSArray *_array = [[eCloudDAO getDatabase] searchConvRecordByMsgId:[NSString stringWithFormat:@"%@",msgId] userId:userId.intValue];
            _model.senderRecords = _array;
            
            if (_array.count == 0) {
                _model.sendTimeDsp = @"未知时间";
                _model.sendMsgBody = @"未知消息";
            }else{
                ConvRecord *_convRecord = _array[0];
                _model.sendTimeDsp = [StringUtil getDisplayTime_day:_convRecord.msg_time];
                
                NSMutableString *mStr = [NSMutableString string];
                for (ConvRecord *_convRecord in _array) {
                    
                    NSString *msgBody = [[WXReplyOneMsgUtil getUtil] getMsgBodyWithConvRecord:_convRecord];
                    [mStr appendString:msgBody];
                    
                    //                if (_convRecord.msg) {
                    //                    <#statements#>
                    //                }
                }
                _model.sendMsgBody = mStr;
                
            }
            //        _model.msg_id = recor.msgId;
            
            _convRecord.msg_body = dic[KEY_REPLY_MSG_REPLY_MSG];
            _convRecord.replyOneMsgModel = _model;
        }
        
        
    }
    else  // 如果是云文件信息
    {
        if ([dic[KEY_MSG_TYPE] isEqual:CLOUD_FILE_TYPE]) {
            
            if(!_convRecord.cloudFileModel) {
                CloudFileModel *model = [[[CloudFileModel alloc]init]autorelease];
                model.fileName = dic[KEY_FILE_NAME];
                model.fileUrl = dic[KEY_FILE_URL];
                model.fileSize = [dic[KEY_FILE_SIZE] intValue];
                _convRecord.cloudFileModel = model;
                _convRecord.file_name = model.fileName;
                _convRecord.file_size = [StringUtil getStringValue:model.fileSize];
            }
        }
    }
   
}

//预处理 第三方推送消息
+ (void)preProcessTextAppMsg:(ConvRecord *)_convRecord
{
    NSData *bodyData = [_convRecord.msg_body dataUsingEncoding:NSUTF8StringEncoding];
    if (bodyData) {
        NSDictionary *appMsgDic = [NSJSONSerialization JSONObjectWithData:bodyData options:kNilOptions error:nil];
        if (appMsgDic && [appMsgDic isKindOfClass:[NSDictionary class]])
        {
#ifdef _TAIHE_FLAG_
            if (!_convRecord.appMsgModel) {
                TAIHEAppMsgModel *model = [[TAIHEAppMsgModel appMsgModelWithDic:appMsgDic]autorelease];
                
                _convRecord.appMsgModel = model;
            }
#endif
        }
    }
}

/** 预处理会议和新闻消息消息 */
+ (void)preProcessMettingAppMsg:(ConvRecord *)_convRecord
{
    NSData *bodyData = [_convRecord.msg_body dataUsingEncoding:NSUTF8StringEncoding];
    if (bodyData) {
        NSDictionary *appMsgDic = [NSJSONSerialization JSONObjectWithData:bodyData options:kNilOptions error:nil];
        if (appMsgDic != nil && [appMsgDic isKindOfClass:[NSDictionary class]])
        {
#ifdef _LANGUANG_FLAG_
            if ([appMsgDic[KEY_MSG_TYPE] isEqual:KEY_LANGUANG_MEETING_TYPE]) {
                
                if (!_convRecord.meetingMsgModel) {
                    LANGUANGAppMsgModelARC *model = [LANGUANGAppMsgModelARC appMsgModelWithDic:appMsgDic];
                    //_msg_time
                    
                    model.msgtime = _convRecord.msg_time;
                    _convRecord.meetingMsgModel = model;
                }
            }else if ([appMsgDic[KEY_MSG_TYPE] isEqual:KEY_LANGUANG_NEWS_TYPE]){
     
                    
                    LGNewsMdelARC *model = [LGNewsMdelARC newsModelWithDic:appMsgDic];

                    _convRecord.newsModel = model;
                    
              
            }
            
#endif
        }
    }
}

+ (void)preProcessredPacketMsg:(ConvRecord *)_convRecord{
    
    NSData *bodyData = [_convRecord.msg_body dataUsingEncoding:NSUTF8StringEncoding];
    if (bodyData) {
        
        NSDictionary *appMsgDic = [NSJSONSerialization JSONObjectWithData:bodyData options:kNilOptions error:nil];
        
        if (appMsgDic && [appMsgDic isKindOfClass:[NSDictionary class]])
        {
#ifdef _LANGUANG_FLAG_
            if (!_convRecord.redPacketModel) {
                
                if ([appMsgDic[@"type"] isEqualToString:@"redPacketAction"] || [appMsgDic[@"type"] isEqualToString:@"redPacket"]) {
                    
                    RedPacketModelArc *model = [RedPacketModelArc appMsgModelWithDic:appMsgDic];
                    
                    _convRecord.redPacketModel = model;
                }
                
            }
#endif
        }
    }
}
//看看是否小万消息 ，如果是先解析一下
+ (void)preProcessRobotMsg:(ConvRecord *)_convRecord
{
    if ([StringUtil isXiaoWanMsg:_convRecord.msg_body] || _convRecord.emp_id == [[RobotDAO getDatabase]getRobotId])
    {
        if (_convRecord.robotModel) {
            return;
        }
        RobotResponseXmlParser *robotParser = [[[RobotResponseXmlParser alloc]init]autorelease];
        bool result = [robotParser parse:[_convRecord msg_body] andIsParseAgent:YES];
        
        if (result) {
            
            if (robotParser.robotModel.msgType == type_record || robotParser.robotModel.msgType == type_video) {
//                _convRecord.msg_type = type_file;
//                //                需要给convRecord赋值
//                _convRecord.file_name = robotParser.robotModel.msgFileName;
//                _convRecord.file_size = robotParser.robotModel.msgFileSize;
            }else if (robotParser.robotModel.msgType == type_pic)
            {
//                _convRecord.msg_type = type_pic;
//                _convRecord.file_name = robotParser.robotModel.msgFileName;
            }else{
                //                图文 或 百科
//                _convRecord.msg_type = robotParser.robotModel.msgType;
            }
            
            _convRecord.robotModel = robotParser.robotModel;
        }
    }
}

//调整文件cell的布局 普通文件需要调用 小万回复的文件消息也需要使用
+ (void)adjustNewFileMsgCell:(UITableViewCell *)cell andMessageFrame:(CGRect)messageFrame andConvRecord:(ConvRecord *)_convRecord{
    UIView *fileView = (UIView*)[cell.contentView viewWithTag:file_tag];
    //    fileView.backgroundColor = [UIColor blueColor];
    
    //    if (_convRecord.msg_flag == rcv_msg) {
    //        messageFrame.origin.x += 5.5;
    //    }else{
    //        messageFrame.origin.x -= 5.5;
    //    }
    messageFrame.origin.x -= 5.5;
    messageFrame.origin.y -= 6.0;
    messageFrame.size.width += 9.5;
    messageFrame.size.height +=11.0;
    
    fileView.frame = messageFrame;
    
    UIView *fileSubView = (UIView*)[cell.contentView viewWithTag:file_sub_view_tag];
    //    fileSubView.backgroundColor = [UIColor orangeColor];
    
    CGRect fileSubViewFrame = CGRectMake(file_cell_space, file_cell_space, messageFrame.size.width - file_cell_space, messageFrame.size.height - 2 * file_cell_space);
    
    fileSubView.frame =  fileSubViewFrame;
}

+ (void)getRobotPicSize:(ConvRecord *)_convRecord{
    NSString *picpath = [RobotUtil getDownloadFilePathWithConvRecord:_convRecord];
    UIImage *img = [UIImage imageWithContentsOfFile:picpath];
    if (!img) {
        img = [StringUtil getImageByResName:@"default_pic.png"];//默认图片
    }
    _convRecord.imageDisplay = img;
    _convRecord.msgSize = [MessageView getImageDisplaySize:img];
}

//设置文本消息字体的颜色
+ (void)setTextMsgColor:(UILabel *)textLabel andConvRecord:(ConvRecord *)_convRecord
{
    if (_convRecord.msg_flag == send_msg) {
 
        textLabel.textColor = send_msg_text_color;
    }else{
        textLabel.textColor = rcv_msg_text_color;
    }
}

@end
