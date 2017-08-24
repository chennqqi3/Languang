
#import "PicMsgCell.h"
#import "IrregularView.h"
#import "RobotUtil.h"
#import "RobotFileUtil.h"
#import "talkSessionUtil.h"
#import "EncryptFileManege.h"

@implementation PicMsgCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [super addCommonView:self];
        UIView *contentView = (UIView *)[self.contentView viewWithTag:body_tag];

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
        
        //进度条百分比
        UILabel *progressLab = [[UILabel alloc] initWithFrame:CGRectZero];
        progressLab.tag=pic_progress_Label_tag;
        progressLab.backgroundColor = [UIColor blackColor];
        progressLab.alpha = 0.6;
        progressLab.hidden = YES;
        progressLab.textColor = [UIColor whiteColor];
        progressLab.textAlignment = NSTextAlignmentCenter;
        progressLab.font = [UIFont systemFontOfSize:14.0];
        [showPicView addSubview:progressLab];
        [progressLab release];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

#pragma mark --显示图片消息--
+ (void)configureCell:(UITableViewCell *)cell andRecord:(ConvRecord*)_convRecord
{
    //	展示给用户看的收到的图片，没下载前显示为默认图片bubble_send_tag
    IrregularView *showPicView=(IrregularView*)[cell.contentView viewWithTag:pic_tag];
    showPicView.backgroundColor=[UIColor whiteColor];
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
                                   [NSValue valueWithCGPoint:CGPointMake(_convRecord.msgSize.width, 0)],
                                   [NSValue valueWithCGPoint:CGPointMake(_convRecord.msgSize.width, _convRecord.msgSize.height)],
                                   [NSValue valueWithCGPoint:CGPointMake(0, _convRecord.msgSize.height)],
                                   nil];
    }else{
        showPicView.trackPoints = [NSArray arrayWithObjects:[NSValue valueWithCGPoint:CGPointMake(0, 0)],
                                   [NSValue valueWithCGPoint:CGPointMake(_convRecord.msgSize.width, 0)],
                                   [NSValue valueWithCGPoint:CGPointMake(_convRecord.msgSize.width, _convRecord.msgSize.height)],
                                   [NSValue valueWithCGPoint:CGPointMake(0, _convRecord.msgSize.height)],
                                   nil];
    }
    
    //进度
    UILabel *progressCell=(UILabel *)[cell.contentView viewWithTag:pic_progress_Label_tag];
    progressCell.hidden = YES;
    progressCell.frame = showPicView.frame;
    progressCell.center = showPicView.center;
    
    [showPicView setMask];
    
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
    // 为会话实体设置显示的图片
    [self setImageForConvRecord:_convRecord];
    // 为会话实体设置msgSize
    CGSize _size = [self getPicImageDisplaySize:_convRecord.imageDisplay];
    float defaultframeWidth = _size.width;
    float defaultframeHeight = _size.height;
    
    _convRecord.msgSize = CGSizeMake(defaultframeWidth,defaultframeHeight);
    
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

+ (void)setImageForConvRecord:(ConvRecord *)_convRecord
{
    // 获取图片的缩放比例，取出宽与高
    if (_convRecord.recordType == normal_conv_record_type || _convRecord.recordType == mass_conv_record_type || (_convRecord.recordType == ps_conv_record_type && _convRecord.msg_flag == send_msg)) {
        //		消息内容，消息size
        NSString *messageStr = _convRecord.msg_body;
        
        NSString *picname = [NSString stringWithFormat:@"%@.png",messageStr];
        
        if ([_convRecord.msg_body rangeOfString:@"imgmsg"].length > 0) {
            picname = _convRecord.file_name;
        }
        NSString *picpath = [[StringUtil newRcvFilePath] stringByAppendingPathComponent:picname];
        
        UIImage *originImg = [UIImage imageWithData:[EncryptFileManege getDataWithPath:picpath]];
        
        NSString *smallpicname = [NSString stringWithFormat:@"small%@.png",messageStr];
        
        if ([_convRecord.msg_body rangeOfString:@"imgmsg"].length > 0) {
            smallpicname = [NSString stringWithFormat:@"small%@",_convRecord.file_name];
        }
        NSString *smallpicpath = [[StringUtil newRcvFilePath] stringByAppendingPathComponent:smallpicname];
        
        UIImage *smallimg = [UIImage imageWithData:[EncryptFileManege getDataWithPath:smallpicpath]];
        
        UIImage *img = nil;
        
        if(originImg == nil)
        {
            if (smallimg == nil) {
                img = [StringUtil getImageByResName:@"default_pic.png"];//默认图片
            }
            else
            {
                img = smallimg;
            }
        }
        else
        {
            img = originImg;
        }
        _convRecord.imageDisplay = img;
    }
}

#pragma mark 取得图片在聊天界面中显示的尺寸
+(CGSize)getPicImageDisplaySize:(UIImage *)img
{
    //	最高或最宽为
    int max_size = MAX_PIC_WIDTH;
    if (IS_IPAD) {
        max_size = 300;
    }
    
    //	宽和高的比例
    float rate=img.size.width/img.size.height;
    
    float frameWidth = img.size.width;
    float frameHeight = img.size.height;
    
    if(rate >= 1)
    {
        //		横向图片
        if(frameWidth >= max_size)
        {
            frameWidth = max_size;
            frameHeight = max_size / rate;
        }
    }
    else
    {
        //	纵向图片
        if(frameHeight >= max_size)
        {
            frameHeight = max_size;
            frameWidth = max_size * rate;
        }
    }
    
    if(frameHeight < MIN_PIC_HEIGHT)
    {
        frameHeight = MIN_PIC_HEIGHT;
    }
    if(frameWidth < MIN_PIC_WIDTH)
    {
        frameWidth = MIN_PIC_WIDTH;
    }
    return CGSizeMake(frameWidth, frameHeight);
}

- (void)configureRobotPicCell:(ConvRecord *)_convRecord{
    NSString *picPath = [RobotUtil getDownloadFilePathWithConvRecord:_convRecord];
    if (![[NSFileManager defaultManager]fileExistsAtPath:picPath]) {
        [[RobotFileUtil getUtil]setDownloadPropertyOfRecord:_convRecord];
        if (!_convRecord.isDownLoading) {
            [[RobotFileUtil getUtil]downloadRobotFile1:_convRecord];
        }
    }
}

@end
