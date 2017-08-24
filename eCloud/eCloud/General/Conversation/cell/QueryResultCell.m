
#import "QueryResultCell.h"
#import "RobotResponseModel.h"
#import "CustomMyCell.h"
#import "eCloudDefine.h"
#import "NewMsgNumberUtil.h"
#import "UserDisplayUtil.h"
#import "StringUtil.h"
#import "LastRecordView.h"
#import "Conversation.h"
#import "MessageView.h"
#import "DAOverlayView.h"
#import "contactViewController.h"
#import "RobotDAO.h"
#import "UIAdapterUtil.h"
#import "ImageUtil.h"
#import "UserDefaults.h"
#import "FontUtil.h"
#import "CloudFileModel.h"
#import "RobotUtil.h"
#import "conn.h"
#import "UIImageOfCrop.h"

#ifdef _XINHUA_FLAG_
#import "SystemMsgModelArc.h"
#endif

#import "eCloudDAO.h"

#ifdef _LANGUANG_FLAG_
#import "RedPacketModelArc.h"
#import "LANGUANGAppMsgModelARC.h"
#import "MiLiaoUtilArc.h"
#import "LGNewsMdelARC.h"
#import "MiLiaoUtilArc.h"
#endif

#ifdef _TAIHE_FLAG_
#import "TAIHEAppMsgModel.h"
#endif
//定义cell 每个元素的 tag
#define logo_tag 101
//#define conv_name_tag 102
//#define time_tag 103
#define detail_tag 104
#define rcv_msg_image_tag 105

//发送状态的view
#define send_flag_view_tag 106

//只有群聊时显示，单聊时不显示
#define group_logo_parentview_tag (107)

//一个 subview,新消息条数就是放在这个子view当中的
#define new_msg_number_parent_view_tag (108)

@interface QueryResultCell()<UIGestureRecognizerDelegate>

@property (retain, nonatomic) UIView *contextMenuView;
@property (assign, nonatomic) BOOL shouldDisplayContextMenuView;
@property (assign, nonatomic) CGFloat initialTouchPositionX;

@end

@implementation QueryResultCell
{
    float defaultDetailX;
    
    float defaultDetailY;
    float defaultDetailHeight;
}

@synthesize cellWidth;

- (void)dealloc
{
    NSLog(@"%s",__FUNCTION__);
//    NSLog(@"%d",[self.cellView retainCount]);
    self.deleteButtonTitle = nil;
    self.moreOptionsButtonTitle = nil;
//    self.deleteButton = nil;
//    self.moreOptionsButton = nil;

    self.cellView = nil;
    self.contextMenuView = nil;
    [super dealloc];
}

- (void)initSubView
{
    self.cellView = [[[UIView alloc] init]autorelease];
    self.cellView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:self.cellView];
    //        NSLog(@"%d",[self.cellView retainCount]);
    
    
    //-----logo----
    
    
    UIImageView *iconview = [UserDisplayUtil getUserLogoView];
    iconview.tag = logo_tag;
    iconview.userInteractionEnabled=NO;

    float logoX = 10;//4.0;
    float logoY = (conv_row_height - iconview.frame.size.height)/2.0;

    //		设置frame
    CGRect _frame = iconview.frame;
#ifdef _LANGUANG_FLAG_
    
    logoX = 12;
    logoY = 8.5;
    
#endif
    _frame.origin.x = logoX;
    _frame.origin.y = logoY;
    iconview.frame = _frame;
    

    [QueryResultCell initGroupLogoView:iconview];
    
    //增加到cell中
    //        [self.contentView addSubview:iconview];
    [self.cellView addSubview:iconview];
    
    //        update by shisp begin 把显示新消息个数的代码放在 cellView上，而不是放在iconView上
    //	 新消息数量	在iconView的右上角显示，字体使用白色，背景可以拉伸，
    if ([[self class] isUnreadNumDisplayOnLogo]) {
        [NewMsgNumberUtil addNewMsgNumberView:iconview];
    }
    
    //        update by shisp end
    
    //----conv_name----
    float nameX = logoX + iconview.frame.size.width + 10;
#ifdef _LANGUANG_FLAG_
    
    nameX = 12 + iconview.frame.size.width +12;
    
#endif
//    float nameX = logoX + chatview_logo_size + 6;
    		float nameY = logoY ;
//    float nameY = logoY+1 ;
    float nameWidth = 200;//默认是200
    float nameHeight = chatview_logo_size/2;
    
    UILabel *namelable=[[UILabel alloc]initWithFrame:CGRectMake(nameX, nameY, nameWidth, nameHeight)];
    namelable.tag=conv_name_tag;
    
    namelable.font= [FontUtil getTitleFontOfConvList];
    namelable.backgroundColor=[UIColor clearColor];
    //        [self.contentView addSubview:namelable];

    [self.cellView addSubview:namelable];
    [namelable release];

    //----timeLable---
    float timeX = self.cellWidth - 10 - time_width;
    float timeY = nameY ;
    //        float timeY = nameY-1 ;
    float timeWidth = time_width;
    float timeHeight = nameHeight;
    
    UILabel *timelabel=[[UILabel alloc]initWithFrame:CGRectMake(timeX, timeY, timeWidth, timeHeight)];
    timelabel.tag = time_tag;
    timelabel.adjustsFontSizeToFitWidth = YES;
    timelabel.font= [FontUtil getLastMsgTimeFontOfConvList];
    timelabel.backgroundColor=[UIColor clearColor];
    timelabel.textColor=[UIColor colorWithRed:178/255.0 green:178/255.0 blue:178/255.0 alpha:1];
    timelabel.textAlignment = NSTextAlignmentRight;
    //        [self.contentView addSubview:timelabel];
    [self.cellView addSubview:timelabel];
    [timelabel release];
    
    //        这里可以增加显示正在上传或下载的view
    float sendFlagViewX = nameX;
    float sendFlagViewY = nameY + nameHeight;
    
    UIImageView *sendFlagView = [[UIImageView alloc]initWithFrame:CGRectMake(sendFlagViewX, sendFlagViewY, KFacialSizeWidth, KFacialSizeHeight)];
    sendFlagView.tag = send_flag_view_tag;
    //        [self.contentView addSubview:sendFlagView];
    [self.cellView addSubview:sendFlagView];
    [sendFlagView release];
    
    //---detail label--
    float detailX = nameX;
    //        float detailY = nameY + nameHeight;
    float detailY = nameY + nameHeight+2;
    float detailWidth = 200;//默认是200
    float detailHeight = KFacialSizeWidth;
    
    LastRecordView *detailView = [[LastRecordView alloc]initWithFrame:CGRectMake(detailX, detailY + 3, detailWidth, detailHeight)];
    detailView.tag = detail_tag;
    //		[self.contentView addSubview:detailView];
    [self.cellView addSubview:detailView];
    [detailView release];
    
    detailView.backgroundColor = [UIColor clearColor];
    
    defaultDetailX = detailX;
    defaultDetailY = detailY;
    defaultDetailHeight = detailHeight;
    
    //----rcv msg flag image---
    //        add by shisp 新消息不提醒提示图片
    
    UIImage *rcvFlagImage = [ImageUtil getNoAlarmImage:0];
    
    UIImageView *rcvFlagView = [[UIImageView alloc]initWithImage:rcvFlagImage];
    rcvFlagView.frame = CGRectMake(0, detailY + (detailHeight - rcvFlagImage.size.height)/2 - 2, rcvFlagImage.size.width, rcvFlagImage.size.height);
    rcvFlagView.tag = rcv_msg_image_tag;
    //        [self.contentView addSubview:rcvFlagView];
    [self.cellView addSubview:rcvFlagView];
    [rcvFlagView release];
    
    //        未读消息数量
    // 新消息 的 高度 和 详细信息的高度一致
    if (![[self class]isUnreadNumDisplayOnLogo]) {
        UIView *newMsgNumberParentView = [[UIView alloc]initWithFrame:CGRectMake(0, detailY, 0, detailHeight)];
        newMsgNumberParentView.tag = new_msg_number_parent_view_tag;
        [self.cellView addSubview:newMsgNumberParentView];
        [newMsgNumberParentView release];
        
        [NewMsgNumberUtil addNewMsgNumberView:newMsgNumberParentView];
    }
    [UIAdapterUtil customSelectBackgroundOfCell:self];
    
    self.contextMenuView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0,self.cellWidth,conv_row_height)]autorelease];
    self.contextMenuView.backgroundColor = self.cellView.backgroundColor;
    [self.contentView insertSubview:self.contextMenuView belowSubview:self.cellView];
    
    self.contextMenuHidden = self.contextMenuView.hidden = YES;
    self.shouldDisplayContextMenuView = NO;
    self.editable = YES;
    //    self.moreOptionsButtonTitle = @"置顶";
    //    self.deleteButtonTitle = @"删除";
    self.menuOptionButtonTitlePadding = 0.;
    self.menuOptionsAnimationDuration = 0.2;
    self.bounceValue = 20.0;
#ifdef _LANGUANG_FLAG_

    timelabel.font = [UIFont systemFontOfSize:12];
    timelabel.textColor=[UIColor colorWithRed:163/255.0 green:163/255.0 blue:163/255.0 alpha:1];

#endif
}

//增加自定义手势
- (void)addCustomGesture
{
    //    只在初始化时增加手势，否则列表滑动时会引起卡顿
    [self configContextMenuView];
}

//
//- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
//{
//    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
//    if (self)
//    
//    
//    return self;
//}
#pragma mark 显示会话列表界面
- (void)configCell:(Conversation *)conv
{
    [self configLogo:conv];

    [self configConvName:conv];
    
    [self configTime:conv];
    
    [self configDetail:conv];
    
    [self configRcvFlagView:conv];
    
//    [self configContextMenuView];
}

#pragma mark 配置查询结果界面
- (void)configSearchResultCell:(Conversation *)conv
{
//    update by shisp 如果是查询 对于群组的头像使用生成的缩略图
    [self configLogo:conv];

    [self configConvName:conv];
    
    [self configTime:conv];
    
    [self configSearchResultDetail:conv];
    
    [self configRcvFlagView:conv];
}

#pragma mark 配置查询结果的最后一条记录
- (void)configSearchResultDetail:(Conversation *)conv
{
    [RobotUtil getIMMsgTypeOfRobotRecord:conv.last_record];
    
    UIImageView *sendFlagView = (UIImageView *)[self.contentView viewWithTag:send_flag_view_tag];
    sendFlagView.hidden = YES;

    LastRecordView *detailView = (LastRecordView *)[self.contentView viewWithTag:detail_tag];
//    79.0   157.0   83.0
    UIColor *greenColor = [UIColor colorWithRed:63.0/255.0 green:180.8/255.0 blue:8.0/255.0 alpha:1];
    detailView.specialColor = greenColor;// [UIColor greenColor];
    detailView.specialStr = conv.specialStr;
    
//    查找body里是否有回车换行符，如果有，替换成空格
    NSString *str = [NSString stringWithFormat:@"%@",conv.last_record.msg_body];
    if ([str rangeOfString:@"\n"].length > 0) {
        str = [str stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    }
    if ([str rangeOfString:@"\r"].length > 0) {
        str = [str stringByReplacingOccurrencesOfString:@"\r" withString:@" "];
    }
    
    detailView.msgBody = str;
    detailView.maxWidth = [self getContentWidth];
    
    
    UILabel *nameLabel = (UILabel*)[self.contentView viewWithTag:conv_name_tag];
//    如果有最后一条记录，那么就显示会话标题和最后一条记录
//    否则只显示会话标题，但是要垂直居中显示，并且能够显示特殊字符
    if (conv.last_record && conv.last_record.msg_body.length > 0) {
        nameLabel.hidden = NO;
        detailView.textFont = [FontUtil getLastMsgFontOfConvList];
        detailView.textColor = [UIColor darkGrayColor];
        
        CGRect _frame = detailView.frame;
        _frame.origin.y = defaultDetailY;
        detailView.frame = _frame;
    }
    else
    {
//        detailView.textFont = [nameLabel font];
        detailView.textFont = [FontUtil getTitleFontOfConvList];
        detailView.textColor = [UIColor blackColor];
       nameLabel.hidden = YES;
        detailView.msgBody = conv.conv_title;
        
        if (conv.conv_type == mutiableType && conv.totalEmpCount) {
            detailView.msgBody = [NSString stringWithFormat:@"%@(%d)",conv.conv_title,conv.totalEmpCount];
        }
        
        CGRect _frame = detailView.frame;
        _frame.origin.y = (conv_row_height - defaultDetailHeight) / 2;
        detailView.frame = _frame;
    }
    
    [detailView display];
}

//对于群聊
//只要是有未读的@消息，那么就红色字体，显示[有人@我]并且显示最后消息的发送人: 最后一条消息
//否则看是否有草稿，如果有草稿，那么就红色字体显示[草稿]草稿内容
//否则显示发送人:发送内容
//如果屏蔽了群租消息，那么如果未读信息条数大于1，那么显示[具体条数]发送人:发送内容
//
//对于单聊
//如果有草稿，那么就红色字体显示[草稿]草稿内容
//否则就显示最后一条消息的内容

- (void)configDetail:(Conversation *)conv
{
    UIImageView *sendFlagView = (UIImageView *)[self.contentView viewWithTag:send_flag_view_tag];
    int lastSendFlag = conv.last_record.send_flag;
//    lastSendFlag = send_failure;
    if (lastSendFlag != send_success) {
        sendFlagView.hidden = NO;
        if (lastSendFlag == sending || lastSendFlag == send_uploading || lastSendFlag == send_upload_waiting || lastSendFlag == send_upload_stop || lastSendFlag == save_location) {
            sendFlagView.frame=CGRectMake(sendFlagView.frame.origin.x,  ((conv_row_height - chatview_logo_size)/2-3)+ (chatview_logo_size/2)+6, KFacialSizeWidth-5, KFacialSizeHeight-5);
            [sendFlagView setImage:[UIImage imageWithContentsOfFile:[StringUtil getResPath:@"sending_status" andType:@"png"]]];
        }
        else
//            if(lastSendFlag == send_upload_fail || lastSendFlag == send_failure)
        {  sendFlagView.frame=CGRectMake(sendFlagView.frame.origin.x, ((conv_row_height - chatview_logo_size)/2-3)+ (chatview_logo_size/2)+6, KFacialSizeWidth-5, KFacialSizeHeight-5);
            [sendFlagView setImage:[UIImage imageWithContentsOfFile:[StringUtil getResPath:@"send_fail" andType:@"png"]]];
        }
    }
    else
    {
        sendFlagView.hidden = YES;
    }

    LastRecordView *detailView = (LastRecordView *)[self.contentView viewWithTag:detail_tag];
    detailView.textFont = [FontUtil getLastMsgFontOfConvList];
    
    detailView.textColor = [UIColor colorWithRed:163/255.0 green:163/255.0 blue:163/255.0 alpha:1];
    
    //	参照微信，如果设置了群租新消息不提示，那么未读信息条数要特别处理
    NSString *unreadStr = @"";
    if(conv.recv_flag == 1 && conv.unread > 1)
    {
//        按照万达的需求 未读消息数，无论是否开启了新消息通知，都要同样显示，所以这里就不用显示了
//        unreadStr = [NSString stringWithFormat:@"[%d条]",conv.unread];
    }
    
	//			add by shisp 如果是群聊，那么最后一条记录需要显示发送人
	//默认发送人为空
	NSString *_lastMsgEmpName = @"";
	if(conv.conv_type == mutiableType && conv.last_record.msg_body && conv.last_record.msg_body.length > 0 && conv.last_record.msg_type != type_group_info)
	{
        if (conv.last_record.emp_name && conv.last_record.emp_name.length > 0) {
            _lastMsgEmpName = [NSString stringWithFormat:@"%@:", conv.last_record.emp_name];            
        }
	}
     if(conv.last_record.msg_body && conv.last_record.msg_body.length > 0)
    {
        NSString *msgBody = @"";
        
       int msgType = conv.last_record.msg_type;
        
        msgType =  [RobotUtil getIMMsgTypeOfRobotRecord:conv.last_record];
        
        switch (msgType) {
            case type_text:
            {
                msgBody =  conv.last_record.msg_body;

                if (conv.last_record.locationModel) {
                    msgBody = [StringUtil getLocalizableString:@"msg_type_location"];
                    break;
                }else if (conv.last_record.cloudFileModel){
                    msgBody = [NSString stringWithFormat:@"%@%@",[StringUtil getLocalizableString:@"msg_type_file"],conv.last_record.cloudFileModel.fileName];
                    break;
                }
#ifdef _XINHUA_FLAG_
                else if (conv.last_record.systemMsgModel){
                    SystemMsgModelArc *model = conv.last_record.systemMsgModel;
                    if ([model.msgType isEqualToString:TYPE_TEXT]) {
                        
                        msgBody = model.msgBody;
                    }
                    else if ([model.msgType isEqualToString:TYPE_PIC]) {
                        
                        msgBody = [StringUtil getLocalizableString:@"msg_type_pic"];
                    }
                    else if ([model.msgType isEqualToString:TYPE_VIDEO]) {
                        
                        msgBody = [StringUtil getLocalizableString:@"msg_type_video"];
                    }
                    else if ([model.msgType isEqualToString:TYPE_NEWS]) {
                        
                        msgBody = [StringUtil getLocalizableString:@"msg_type_imgtxt"];
                    }
                    else if ([model.msgType isEqualToString:TYPE_VOICE]) {
                        
                        msgBody = [StringUtil getLocalizableString:@"msg_type_record"];
                    }
                    
                    break;
                }
#endif
#ifdef _TAIHE_FLAG_
                else if(conv.last_record.appMsgModel){
                    
                    msgBody = conv.last_record.appMsgModel.title;

                    break;
                }
#endif

#ifdef _LANGUANG_FLAG_
                
                else if (conv.last_record.redPacketModel){
                    
                    if ([conv.last_record.redPacketModel.type isEqualToString:@"redPacketAction"]) {
                        
                        /** 红包动作消息不显示发送人名字 */
                        _lastMsgEmpName = @"";
                        
                        conn *_conn = [conn getConn];
                        NSString *hostId = conv.last_record.redPacketModel.hostId;
                        NSString *guestId = conv.last_record.redPacketModel.guestId;
                        eCloudDAO* db=[eCloudDAO getDatabase];
                        Emp *emp = [db getEmployeeById:hostId];
                        
                        if ([hostId isEqualToString:_conn.userId]) {
                            
                            msgBody = [NSString stringWithFormat:@"%@领取了你的红包",conv.last_record.redPacketModel.guestName];
                            
                        }else{
                            
                            msgBody = [NSString stringWithFormat:@"你领取了%@的红包",emp.emp_name];
                        }
                  
                        if ([conv.last_record.redPacketModel.hostId isEqualToString:conv.last_record.redPacketModel.guestId]) {
                            
                            msgBody = @"你领取了自己发的红包";
                        }
                    }else{
                        
                        msgBody = [NSString stringWithFormat:@"[蓝信红包]%@",conv.last_record.redPacketModel.greeting];
                    }
                    
                    
                    break;
                }
                else if (conv.last_record.meetingMsgModel){
                    
                    msgBody = conv.last_record.meetingMsgModel.title;
                    
                    break;
                }
                else if (conv.last_record.newsModel){
                    
                    msgBody = conv.last_record.newsModel.title;
                    
                    break;
                }
                
#endif
            }
            case type_long_msg:
            case type_group_info:
                msgBody = conv.last_record.msg_body;
                break;
//                update by shisp
            case type_file:
                msgBody = [NSString stringWithFormat:@"%@%@",[StringUtil getLocalizableString:@"msg_type_file"],conv.last_record.msg_body];
                break;
            case type_pic:
                msgBody = [StringUtil getLocalizableString:@"msg_type_pic"];
                break;
            case type_record:
                msgBody = [StringUtil getLocalizableString:@"msg_type_record"];
                break;
            case type_video:
                msgBody = [StringUtil getLocalizableString:@"msg_type_video"];
                break;
            case type_imgtxt:
                msgBody = [StringUtil getLocalizableString:@"msg_type_imgtxt"];
                break;
            case type_wiki:
                msgBody = [StringUtil getLocalizableString:@"msg_type_wiki"];
                break;
            default:
                break;
        }
        
        if (conv.conv_type == mutiableType && conv.is_tip_me)
        {
            detailView.specialColor = [UIColor redColor];
            detailView.specialStr = [StringUtil getLocalizableString:@"someone_at_me"];
            detailView.msgBody = [NSString stringWithFormat:@"%@%@%@",detailView.specialStr,_lastMsgEmpName,msgBody];
        }
        else if (conv.lastInput_msg.length>0)
        {
            detailView.specialStr = [StringUtil getLocalizableString:@"draft"];
            detailView.specialColor = [UIColor redColor];
            detailView.msgBody = [NSString stringWithFormat:@"%@%@",detailView.specialStr,conv.lastInput_msg];
        }
        else
        {
            detailView.specialStr = nil;
            detailView.specialColor = nil;
            detailView.msgBody = [NSString stringWithFormat:@"%@%@%@",unreadStr,_lastMsgEmpName,msgBody];
            
#ifdef _LANGUANG_FLAG_
            if ([[MiLiaoUtilArc getUtil]isMiLiaoConv:conv.conv_id]) {
                if ([[eCloudDAO getDatabase]hasUnreadEncryptMsg:conv.conv_id]) {
                    detailView.specialStr = [StringUtil getLocalizableString:@"key_unread_message"];
                    //                0088c8
                    detailView.specialColor = lg_main_color;
                }
                
                if (detailView.specialStr.length) {
                    detailView.msgBody = [NSString stringWithFormat:@"%@%@",detailView.specialStr,[StringUtil getLocalizableString:@"key_message"]];
                }else{
                    if (msgType == type_group_info) {
                        detailView.msgBody = @"";
                    }else{
                        detailView.msgBody = [StringUtil getLocalizableString:@"key_message"];
                    }
                }
            }
#endif

        }
    }
    else if (conv.lastInput_msg && conv.lastInput_msg.length>0)
    {
        detailView.specialStr = [StringUtil getLocalizableString:@"draft"];
        detailView.specialColor = [UIColor redColor];
        detailView.msgBody = [NSString stringWithFormat:@"%@%@",detailView.specialStr,conv.lastInput_msg];
    }
    else
    {
        detailView.msgBody = @"";
    }
    float contentWidth = [self getContentWidth];
    
//    float maxWidth = contentWidth;
//    if((conv.displayRcvMsgFlag && conv.recv_flag == 1) || (![[self class]isUnreadNumDisplayOnLogo] && conv.unread > 0))
//    {
//       maxWidth = contentWidth - time_width;
//    }
    // 蓝光要求显不显示未读数，文字最长都要空出未读数的位置
    // 首先获取时间的实际宽度
    UILabel *timeLabel = (UILabel *)[self.contentView viewWithTag:time_tag];
    CGSize timeSize = [timeLabel.text sizeWithAttributes:@{NSFontAttributeName:timeLabel.font}];
    float maxWidth = contentWidth - timeSize.width;
    
    CGRect _frame = detailView.frame;

    if (sendFlagView.hidden == YES) {
         _frame.origin.x = defaultDetailX;
    }
    else
    {
        _frame.origin.x = defaultDetailX + KFacialSizeWidth;
        maxWidth = maxWidth - KFacialSizeWidth;
    }
    detailView.frame = _frame;
    detailView.maxWidth = maxWidth;
    
    [detailView display];
}
- (void)configLogo:(Conversation *)conv
{
    //    logo
    UIImageView *iconview = (UIImageView *)[self.contentView viewWithTag:logo_tag];
    
    [UserDisplayUtil setUserLogoView:iconview andConversation:conv];
    iconview.contentMode = UIViewContentModeScaleToFill;
//    如果显示合成头像，就不用下面的操作
    if (!conv.displayMergeLogo) {
        [QueryResultCell configGroupLogoView:conv andIconView:iconview];
    }
    
//    未读数要显示在头像右上角
    if ([[self class] isUnreadNumDisplayOnLogo]) {
        [NewMsgNumberUtil displayNewMsgNumber:iconview andNewMsgNumber:conv.unread];
        [NewMsgNumberUtil setUnreadViewFrame:iconview];
    }
}

- (void)configConvName:(Conversation *)conv
{
//    NSLog(@"%s,conv_title is %@",__FUNCTION__,conv.conv_title);

    UILabel *namelabel = (UILabel *)[self.contentView viewWithTag:conv_name_tag];
    NSString *convName = conv.conv_title;
    NSString *convId = conv.conv_id;
    if ([convId hasPrefix:@"g"])
    {
        //        如果是机组群，那么会话标题字体定为16，便于完整展示机组群的标题，不如在收到机组群的时候，就把机组群标题中的空格去掉
        namelabel.font = [FontUtil getLastMsgFontOfConvList];
    }
    else
    {
        namelabel.font = [FontUtil getTitleFontOfConvList];
        namelabel.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];

        if ([[MiLiaoUtilArc getUtil]isMiLiaoConv:convId]) {
            
            namelabel.font = [UIFont systemFontOfSize:16];
            namelabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1/1.0];
        }
    }
    namelabel.text = convName;
    if (conv.conv_type == mutiableType && conv.totalEmpCount) {
        namelabel.text = [NSString stringWithFormat:@"%@(%d)",convName,conv.totalEmpCount];
    }
    float contentWidth = [self getContentWidth];
    
    float width =  contentWidth;
    
    if (conv.displayTime)
    {
        width = contentWidth - time_width;
    }
    CGRect _frame = namelabel.frame;
    _frame.size.width = width;
    namelabel.frame = _frame;
}

- (float)getContentWidth
{
    UIImageView *iconView = (UIImageView*)[self.contentView viewWithTag:logo_tag];
    
#ifdef _LANGUANG_FLAG_
    return self.cellWidth - iconView.frame.size.width - 36;
#else
    return self.cellWidth - iconView.frame.size.width - 30;
#endif
}
- (void)configTime:(Conversation *)conv
{
    //    time
    UILabel *timeLabel = (UILabel *)[self.contentView viewWithTag:time_tag];
    //	如果是空会话，那么显示群组创建时间
    if(conv.last_record.msg_time)
    {
        timeLabel.text=[StringUtil getLastMessageDisplayTime:conv.last_record.msg_time];
    }
    else
    {
        timeLabel.text=[StringUtil getLastMessageDisplayTime:conv.create_time];
    }
    
    if (conv.displayTime)
    {
        timeLabel.hidden = NO;
    }else
    {
        timeLabel.hidden = YES;
    }
    
//    设置timeLabel的frame
    CGRect _frame = timeLabel.frame;
    _frame.origin.x = self.cellWidth - 10 - time_width;
    timeLabel.frame = _frame;
}

- (void)configRcvFlagView:(Conversation *)conv
{
//    新消息数量
    UIView *newMsgNumberParentView = [self.contentView viewWithTag:new_msg_number_parent_view_tag];
    
    [NewMsgNumberUtil displayNewMsgNumber:newMsgNumberParentView andNewMsgNumber:conv.unread];
    
    if (conv.unread) {
        //        宽度已经ok了 现在 设置下 显示的位置
        UIImageView *newMsgBg = (UIImageView *) [newMsgNumberParentView viewWithTag:new_msg_number_bg_tag];
        
//        NSLog(@"%s,new msg bg frame is %@",__FUNCTION__,NSStringFromCGRect(newMsgBg.frame));
        
        float newMsgX = self.cellWidth - 10 - newMsgBg.frame.size.width;
        
        CGRect _frame = newMsgNumberParentView.frame;
        _frame.origin.x = newMsgX;
        _frame.size.width = newMsgBg.frame.size.width;
        newMsgNumberParentView.frame = _frame;
        
//        NSLog(@"%s new msg number frame is %@",__FUNCTION__,NSStringFromCGRect(_frame));
    }
    
    UIImageView *rcvFlagView = (UIImageView*)[self.contentView viewWithTag:rcv_msg_image_tag];
    rcvFlagView.hidden = YES;
    if(conv.displayRcvMsgFlag && conv.recv_flag == 1)
    {
        rcvFlagView.hidden = NO;
        
//        万达需求 即使群组设置了新消息不提醒，也要显示未读消息条数，不提醒标志要放在 未读消息数的左侧
        CGRect _frame = rcvFlagView.frame;
        if (conv.unread > 0)
        {
//            找到未读消息数的view，
            //    logo
            UIView *newMsgParentView = [self.contentView viewWithTag:new_msg_number_parent_view_tag];

            _frame.origin.x = ( self.cellWidth - 10 - _frame.size.width - 5 - newMsgParentView.frame.size.width);
        }
        else
        {
            _frame.origin.x = (self.cellWidth - 10 - _frame.size.width);
        }
        rcvFlagView.frame = _frame;
        
//        NSLog(@"%s,rcvFlagView frame is %@",__FUNCTION__,NSStringFromCGRect(_frame));
    }
}


#pragma mark  cell 左滑菜单
-(void)configContextMenuView
{
    /*
    self.contextMenuView = [[UIView alloc] initWithFrame:CGRectMake(160, 0, 160, 64)];
    self.contextMenuView.backgroundColor = [UIColor redColor];
//    self.contextMenuView.backgroundColor = self.contentView.backgroundColor;
    self.contextMenuView.tag = 10009812;
    [self.contentView insertSubview:self.contextMenuView belowSubview:self.cellView];
//    [self.contentView insertSubview:self.contextMenuView atIndex:0];
    self.contextMenuHidden = self.contextMenuView.hidden = YES;
    self.shouldDisplayContextMenuView = NO;
    self.editable = YES;
    self.moreOptionsButtonTitle = @"More";
    self.deleteButtonTitle = @"Delete";
    self.menuOptionButtonTitlePadding = 25.;
    self.menuOptionsAnimationDuration = 0.3;
    self.bounceValue = 30.;
     */
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    panRecognizer.delegate = self;
    [self addGestureRecognizer:panRecognizer];
    [panRecognizer release];
//    [self setNeedsLayout];
}

#pragma mark - Public

- (CGFloat)contextMenuWidth
{
    return CGRectGetWidth(self.deleteButton.frame) + CGRectGetWidth(self.moreOptionsButton.frame);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
//    self.frame
//    self.contextMenuView.frame = self.cellView.bounds;
//    self.contextMenuView.backgroundColor = [UIColor redColor];
//    [self.contentView sendSubviewToBack:self.contextMenuView];
//    [self.contentView bringSubviewToFront:self.cellView];
//    [self.contentView insertSubview:self.contextMenuView atIndex:0];
    CGFloat height = CGRectGetHeight(self.bounds);
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat menuOptionButtonWidth = 64.0;
    if ([UIAdapterUtil isGOMEApp]) {
        menuOptionButtonWidth = height;
    }
    self.deleteButton.frame = CGRectMake(width - menuOptionButtonWidth, 0., menuOptionButtonWidth, height);
    self.moreOptionsButton.frame = CGRectMake(width - menuOptionButtonWidth - CGRectGetWidth(self.deleteButton.frame), 0., menuOptionButtonWidth, height);
}

- (CGFloat)menuOptionButtonWidth
{
//    NSString *string = ([self.deleteButtonTitle length] > [self.moreOptionsButtonTitle length]) ? self.deleteButtonTitle : self.moreOptionsButtonTitle;
//    CGFloat width = roundf([string sizeWithFont:self.moreOptionsButton.titleLabel.font].width + 2. * self.menuOptionButtonTitlePadding);
//    width = MIN(width, CGRectGetWidth(self.bounds) / 2. - 10.);
//    if ((NSInteger)width % 2) {
//        width += 1.;
//    }
//    return width;
    return 64;
}

- (void)setDeleteButtonTitle:(NSString *)deleteButtonTitle
{
    if (deleteButtonTitle) {
        _deleteButtonTitle = deleteButtonTitle;
        [self.deleteButton setTitle:deleteButtonTitle forState:UIControlStateNormal];
    }
//    [self setNeedsLayout];
}

- (void)setEditable:(BOOL)editable
{
    if (_editable != editable) {
        _editable = editable;
//        [self setNeedsLayout];
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    if (self.contextMenuHidden) {
        self.contextMenuView.hidden = YES;
        [super setHighlighted:highlighted animated:animated];
    }
}

- (void)setMenuOptionButtonTitlePadding:(CGFloat)menuOptionButtonTitlePadding
{
    if (_menuOptionButtonTitlePadding != menuOptionButtonTitlePadding) {
        _menuOptionButtonTitlePadding = menuOptionButtonTitlePadding;
//        [self setNeedsLayout];
    }
}

- (void)setMenuOptionsViewHidden:(BOOL)hidden animated:(BOOL)animated completionHandler:(void (^)(void))completionHandler
{
    if (self.selected) {
        [self setSelected:NO animated:NO];
    }
    CGRect frame = CGRectMake((hidden) ? 0 : -[self contextMenuWidth], 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
//    [UIView animateWithDuration:(animated) ? self.menuOptionsAnimationDuration : 0.
//                          delay:0.
//                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut
//                     animations:^
//     {
//         self.cellView.frame = frame;
//     } completion:^(BOOL finished) {
//         self.contextMenuHidden = hidden;
//         self.shouldDisplayContextMenuView = !hidden;
//         if (!hidden) {
//             [self.delegate contextMenuDidShowInCell:self];
//         } else {
//             [self.delegate contextMenuDidHideInCell:self];
//         }
//         if (completionHandler) {
//             completionHandler();
//         }
//     }];
    
    /** 大的BOOl值会造成编译错误，换个动画 */
//    [DAOverlayView animateWithDuration:(animated) ? self.menuOptionsAnimationDuration : 0. delay:0. options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^{
//        self.cellView.frame = frame;
//    } completion:^(BOOL finished) {
//        self.contextMenuHidden = hidden;
//        self.shouldDisplayContextMenuView = !hidden;
//        if (!hidden) {
//            [self.delegate contextMenuDidShowInCell:self];
//        } else {
//            [self.delegate contextMenuDidHideInCell:self];
//        }
//        if (completionHandler) {
//            completionHandler();
//        }
//    }];
    
    [UIView beginAnimations:nil
                    context:nil];
    self.cellView.frame = frame;
    self.contextMenuHidden = hidden;
    self.shouldDisplayContextMenuView = !hidden;
    if (!hidden) {
        [self.delegate contextMenuDidShowInCell:self];
    } else {
        [self.delegate contextMenuDidHideInCell:self];
    }
    if (completionHandler) {
        completionHandler();
    }
    [UIView commitAnimations];
    
}
- (void)setMoreOptionsButtonTitle:(NSString *)moreOptionsButtonTitle
{
    if (moreOptionsButtonTitle) {
        _moreOptionsButtonTitle = moreOptionsButtonTitle;
        [self.moreOptionsButton setTitle:self.moreOptionsButtonTitle forState:UIControlStateNormal];
    }
//    [self setNeedsLayout];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    if (self.contextMenuHidden) {
        self.contextMenuView.hidden = YES;
        [super setSelected:selected animated:animated];
    }
}

#pragma mark - Private

- (void)handlePan:(UIPanGestureRecognizer *)recognizer;
{
    if ([recognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        UIPanGestureRecognizer *panRecognizer = (UIPanGestureRecognizer *)recognizer;
        
        CGPoint currentTouchPoint = [panRecognizer locationInView:self.contentView];
        CGFloat currentTouchPositionX = currentTouchPoint.x;
        CGPoint velocity = [recognizer velocityInView:self.contentView];
        if (recognizer.state == UIGestureRecognizerStateBegan) {
            self.initialTouchPositionX = currentTouchPositionX;
            if (velocity.x > 0) {
                [self.delegate contextMenuWillHideInCell:self];
            } else {
                [self.delegate contextMenuDidShowInCell:self];
            }
        } else if (recognizer.state == UIGestureRecognizerStateChanged) {
            CGPoint velocity = [recognizer velocityInView:self.contentView];
            if (!self.contextMenuHidden || (velocity.x > 0. || [self.delegate shouldShowMenuOptionsViewInCell:self])) {
                if (self.selected) {
                    [self setSelected:NO animated:NO];
                }
                self.contextMenuView.hidden = NO;
                CGFloat panAmount = currentTouchPositionX - self.initialTouchPositionX;
                self.initialTouchPositionX = currentTouchPositionX;
                CGFloat minOriginX = -[self contextMenuWidth] - self.bounceValue;
                CGFloat maxOriginX = 0.;
                CGFloat originX = CGRectGetMinX(self.cellView.frame) + panAmount;
                originX = MIN(maxOriginX, originX);
                originX = MAX(minOriginX, originX);
                
                
                if ((originX < -0.5 * [self contextMenuWidth] && velocity.x < 0.) || velocity.x < -100) {
                    self.shouldDisplayContextMenuView = YES;
                } else if ((originX > -0.3 * [self contextMenuWidth] && velocity.x > 0.) || velocity.x > 100) {
                    self.shouldDisplayContextMenuView = NO;
                }
                self.cellView.frame = CGRectMake(originX, 0., CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
            }
        } else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
            [self setMenuOptionsViewHidden:!self.shouldDisplayContextMenuView animated:YES completionHandler:nil];
        }
    }
}

- (void)deleteButtonTapped
{
    if ([self.delegate respondsToSelector:@selector(contextMenuCellDidSelectDeleteOption:)]) {
        [self.delegate contextMenuCellDidSelectDeleteOption:self];
    }
}

- (void)moreButtonTapped
{
    [self.delegate contextMenuCellDidSelectMoreOption:self];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self setMenuOptionsViewHidden:YES animated:NO completionHandler:nil];
}

#pragma mark * Lazy getters

- (UIButton *)moreOptionsButton
{
    if (!_moreOptionsButton) {
        CGRect frame = CGRectMake(0., 0., 100., CGRectGetHeight(self.cellView.frame));
        _moreOptionsButton = [[UIButton alloc] initWithFrame:frame];
        _moreOptionsButton.backgroundColor = CONTACTVIEW_SET_TOP_BTN_BGCOLOR;
        [self.contextMenuView addSubview:_moreOptionsButton];
        [_moreOptionsButton addTarget:self action:@selector(moreButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [_moreOptionsButton release];
    }
    return _moreOptionsButton;
}

- (UIButton *)deleteButton
{
    if (self.editable) {
        if (!_deleteButton) {
            CGRect frame = CGRectMake(0., 0., 100., CGRectGetHeight(self.cellView.frame));
            _deleteButton = [[UIButton alloc] initWithFrame:frame];
            _deleteButton.backgroundColor = CONTACTVIEW_DELETE_CONV_BTN_BGCOLOR;
            if ([UIAdapterUtil isGOMEApp]) {
                [_deleteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [_deleteButton setTitle:[StringUtil getLocalizableString:@"delete"] forState:UIControlStateNormal];
            }else{
                [_deleteButton setBackgroundImage:[StringUtil getImageByResName:@"cellMenueDelete.png"] forState:UIControlStateNormal];
            }

            [self.contextMenuView addSubview:_deleteButton];
            [_deleteButton addTarget:self action:@selector(deleteButtonTapped) forControlEvents:UIControlEventTouchUpInside];
            [_deleteButton release];
        }
        return _deleteButton;
    }
    return nil;
}

#pragma mark * UIPanGestureRecognizer delegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if([UIAdapterUtil isHongHuApp]){
        
        NSString *edit = [UserDefaults getSessionIsEdit];
        if ([edit isEqualToString:@"是"]) {
            
            return NO;
        }else{
            
            if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
                CGPoint translation = [(UIPanGestureRecognizer *)gestureRecognizer translationInView:self];
                return fabs(translation.x) > fabs(translation.y);
            }
            
            return YES;
        }
        
    }else{
        if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
            CGPoint translation = [(UIPanGestureRecognizer *)gestureRecognizer translationInView:self];
            return fabs(translation.x) > fabs(translation.y);
        }
        
        return YES;
    }
    
    
}

#pragma mark =======万达需求 参照微信 生成群头像========

//增加相关的view
+ (void)initGroupLogoView:(UIImageView *)iconview
{
    
    //        万达需求，群聊logo要求参展微信显示，需要增加一些view
    UIImage *groupLogoBgImage = [UIImage imageWithContentsOfFile:[[StringUtil getBundle] pathForResource:@"group_logo_bg" ofType:@"png"]];
//    
    
    float groupLogoParentViewX = 0;//(chatview_logo_size - groupLogoBgImage.size.width) / 2.0;
    float groupLogoParentViewY = 0;//(chatview_logo_size - groupLogoBgImage.size.height) / 2.0;
    
    UIImageView *groupLogoParentView = [[UIImageView alloc]initWithImage:groupLogoBgImage];
    CGRect _frame =  CGRectMake(groupLogoParentViewX, groupLogoParentViewY, groupLogoBgImage.size.width, groupLogoBgImage.size.height);
    groupLogoParentView.frame = _frame;
    groupLogoParentView.tag = group_logo_parentview_tag;
    groupLogoParentView.hidden = YES;
//    设置圆角
    [UIAdapterUtil setCornerPropertyOfView:groupLogoParentView];
    
    //        增加4个小的view
#ifdef _LANGUANG_FLAG_
    float subview_width = (groupLogoBgImage.size.width -  group_logo_subview_spacing)/ 2.0;
    float suvview_height = (groupLogoBgImage.size.height -  group_logo_subview_spacing) / 2.0;

#else
    float subview_width = (groupLogoBgImage.size.width - 3 * group_logo_subview_spacing) / 2.0;
    float suvview_height = (groupLogoBgImage.size.height - 3 *  group_logo_subview_spacing) / 2.0;
    //

    
#endif
        for (int row = 1; row <= 2; row ++ )
    {
        for (int col = 1; col <= 2; col++)
        {
            UIImageView *_subView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, subview_width, suvview_height)];
            
            [UserDisplayUtil addLogoTextLabelToLogoView:_subView];
            
            if ([eCloudConfig getConfig].useOriginUserLogo) {
                _subView.contentMode = UIViewContentModeScaleAspectFit;
            }

#ifdef _ZHENGRONG_FLAG_
            _subView.contentMode = UIViewContentModeScaleAspectFit;
#endif
            _subView.tag = row * 10 + col;
            [groupLogoParentView addSubview:_subView];
            [_subView release];
        }
    }
    
    
    if ([UIAdapterUtil isBGYApp])
    {
        groupLogoParentView.layer.cornerRadius = groupLogoParentView.frame.size.width/2;
        groupLogoParentView.clipsToBounds = YES;
    }
    
    [iconview addSubview:groupLogoParentView];
    
    [groupLogoParentView release];
}

//配置View
+ (void)configGroupLogoView:(Conversation *)conv andIconView:(UIImageView *)iconview
{
    //    logo
//    UIImageView *iconview = (UIImageView *)[self.contentView viewWithTag:logo_tag];

    UIImageView *groupLogoParentView = (UIImageView *)[iconview viewWithTag:group_logo_parentview_tag];
    groupLogoParentView.hidden = YES;
    
    //    万达需求，要求群图标参照微信显示多个小图
    if (conv.conv_type == mutiableType)
    {
        [iconview setImage:nil];
        
        UIImageView *temp = (UIImageView *)[iconview viewWithTag:999];
        [temp setImage:nil];
        
//        [groupLogoParentView setImage:nil];
        
        groupLogoParentView.hidden = NO;
        
//        原来获取头像image是在此进行的，因为滑动很卡，所以放到从数据库获取群组成员后进行
//        NSArray *convEmps = conv.groupLogoEmpArray; // [self getGroupLogoEmpsBy:conv];
        
        NSArray *empsRow = [QueryResultCell getLogoRowsAndColsOfConv:conv];
        //
        
        for (UIImageView *_subView in [groupLogoParentView subviews])
        {
            _subView.hidden = YES;
        }
        
        CGRect _parentFrame = groupLogoParentView.frame;
        
        NSInteger rowCount = empsRow.count;
        
        for (int i = 0; i < rowCount; i++)
        {
            NSArray *empsCol = [empsRow objectAtIndex:i];
            
            NSInteger colCount = empsCol.count;
            
            for (int j = 0; j < colCount; j++)
            {
                
                Emp *_emp = [empsCol objectAtIndex:j];
                
                int tag = (i + 1) * 10 + (j + 1);
                UIImageView *_subView = (UIImageView *)[iconview viewWithTag:tag];
                _subView.hidden = NO;
                
                CGRect _subviewFrame = _subView.frame;
                float x = 0.0;
                float y = 0.0;
                
                float adjust = 0.0;
                
                switch (colCount) {
                    case 1:
                    {
#ifdef _LANGUANG_FLAG_
                        x = 0;

#else
                        x = (_parentFrame.size.width - _subviewFrame.size.width) / 2.0;
 
#endif


                    }
                        break;
                    case 2:
                    {
#ifdef _LANGUANG_FLAG_
                        if (j == 0)
                        {
                            NSArray *temp = [empsRow objectAtIndex:0];
                            if (temp.count == 1) {
                                x = _parentFrame.size.width - _subviewFrame.size.width;
                            }else{
                                x =  adjust;
                            }
                        }
                        else if (j == 1)
                        {
                            x = _parentFrame.size.width  - _subviewFrame.size.width;
                        }
                        
#else
                        if (j == 0)
                        {
                            x = group_logo_subview_spacing + adjust;
                        }
                        else if (j == 1)
                        {
                            x = _parentFrame.size.width - group_logo_subview_spacing - _subviewFrame.size.width;
                        }
                        
#endif

                                            }
                        break;
                        
                    default:
                        break;
                }
                
                switch (rowCount) {
                    case 1:
                    {
#ifdef _LANGUANG_FLAG_
                        y = (_parentFrame.size.height - _subviewFrame.size.height) / 2.0;
                        
#else
                        y = (_parentFrame.size.height - _subviewFrame.size.height) / 2.0;
                        
#endif

                    }
                        break;
                    case 2:
                    {
#ifdef _LANGUANG_FLAG_
                        if (i == 0)
                        {
                            y = adjust;
                            if (colCount == 1) {
                                
                                _subviewFrame.size.height =  _subviewFrame.size.height*2+group_logo_subview_spacing;
                                
                            }
                            
                        }
                        else if (i == 1)
                        {
                            NSArray *temp = [empsRow objectAtIndex:0];
                            if (j == 0 && temp.count == 1) {
                                y =  adjust;
                                //                                _subView.contentMode = UIViewContentModeScaleToFill;
                                
                            }else{
                                
                                y = _parentFrame.size.height - _subviewFrame.size.height;
                            }
                        }
                        
#else
                        if (i == 0)
                        {
                            y = group_logo_subview_spacing + adjust;
                        }
                        else if (i == 1)
                        {
                            y = _parentFrame.size.height - group_logo_subview_spacing - _subviewFrame.size.height;
                        }
                        
#endif

                       
                    }
                        break;
                        
                    default:
                        break;
                }
                
                _subviewFrame.origin = CGPointMake(x, y);
                
                _subView.frame = _subviewFrame;
                
                if ([_emp.logoImage isEqual:default_logo_image]) {
                    NSDictionary *mDic = [UserDisplayUtil getUserDefinedGroupLogoDicOfEmp:_emp];
                    [UserDisplayUtil setUserDefinedLogo:_subView andLogoDic:mDic];
                    NSLog(@"%s 显示人员名字",__FUNCTION__);
                }else{
                    if (i == 0 && colCount == 1) {

                        UIImage *images =  [_emp.logoImage imageByScalingAndCroppingForSize:CGSizeMake(_subView.frame.size.width*1.2, _subView.frame.size.height*1.2)];

                        _subView.image = images;

                        NSLog(@"%s 为了不拉伸头像 对头像进行裁剪",__FUNCTION__);
                    }else
                    {
                        _subView.image = _emp.logoImage;
                        NSLog(@"%s 显示头像",__FUNCTION__);
                    }
                    
                    [UserDisplayUtil hideLogoText:_subView];
                    
                }
            }
        }
    }
}

//获取下小头像有几行几列
+ (NSArray *)getLogoRowsAndColsOfConv:(Conversation *)conv
{
    //原来获取头像image是在此进行的，因为滑动很卡，所以放到从数据库获取群组成员后进行
    NSArray *convEmps = conv.groupLogoEmpArray; // [self getGroupLogoEmpsBy:conv];
    
    NSMutableArray *empsRow = [NSMutableArray array];
    
    int empCount = convEmps.count;
    switch (empCount) {
        case 1:
        {
            //                    一行一列
            [empsRow addObject:[NSArray arrayWithArray:convEmps]];
        }
            break;
        case 2:
        {
            //                    一行两列
            [empsRow addObject:[NSArray arrayWithArray:convEmps]];
        }
            break;
        case 3:
        {
            //                    两行，第一行1列，第二行2列
            [empsRow addObject:[NSArray arrayWithObjects:[convEmps objectAtIndex:0], nil]];
            [empsRow addObject:[NSArray arrayWithObjects:[convEmps objectAtIndex:1],[convEmps objectAtIndex:2], nil]];
            
        }
            break;
        case 4:
        {
            //                    两行，第一行2列，第二行2列
            [empsRow addObject:[NSArray arrayWithObjects:[convEmps objectAtIndex:0],[convEmps objectAtIndex:1], nil]];
            [empsRow addObject:[NSArray arrayWithObjects:[convEmps objectAtIndex:2],[convEmps objectAtIndex:3], nil]];
        }
            break;
            
        default:
            break;
    }
    return empsRow;
}

- (void)configAppLogo:(Conversation *)conv
{
    UIImageView *iconview = (UIImageView *)[self.contentView viewWithTag:logo_tag];
    
    iconview = [iconview viewWithTag:999];
    
    UIImage *appImage = [CustomMyCell getAppLogo:conv.appModel];
    iconview.image = appImage;
    
       
}

//未读数是否显示在头像右上角
+ (BOOL)isUnreadNumDisplayOnLogo
{
    if ([UIAdapterUtil isGOMEApp]) {
        return YES;
    }
    return NO;
}

@end
